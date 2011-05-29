use Test::More;

BEGIN {
    use_ok('NLP::Service');

    # the below module should always be after the package being tested.
    use Dancer::Test;
}

ok( NLP::Service::load_models(), 'Load models worked' );
subtest 'GET routes that should pass' => sub {
    my @ser    = qw(yml json xml);
    my %routes = (
        '/'              => undef,
        '/nlp/info'      => \@ser,
        '/nlp/models'    => \@ser,
        '/nlp/languages' => \@ser,
    );
    my %modelroutes = (
        '/nlp/parse/default'        => \@ser,
        '/nlp/parse/en_pcfg'        => \@ser,
        '/nlp/parse/en_factored'    => \@ser,
        '/nlp/parse/en_pcfgwsj'     => \@ser,
        '/nlp/parse/en_factoredwsj' => \@ser,
    );
    my $check_get_req = sub {
        my ( $rte, $dores ) = @_;
        Carp::croak 'Invalid argument' unless defined $rte;
        $dores = 0 unless defined $dores;
        route_exists       [ GET => $rte ], "GET $rte exists";
        response_exists    [ GET => $rte ], "GET $rte response exists";
        response_status_is [ GET => $rte ], 200, "GET $rte responds with 200"
          if $dores;
    };
    foreach my $rte ( sort keys %routes ) {
        defined $routes{$rte}
          ? map { &$check_get_req( "$rte." . $_, 1 ) } @{ $routes{$rte} }
          : &$check_get_req($rte);
    }
    foreach my $rte ( sort keys %modelroutes ) {
        defined $modelroutes{$rte}
          ? map { &$check_get_req( "$rte." . $_ ) } @{ $modelroutes{$rte} }
          : &$check_get_req($rte);
    }
    done_testing();
};

subtest 'GET routes that should fail' => sub {
    my @routes = qw(
      /nlp/info
      /nlp/
      /robots.txt
    );
    map { route_doesnt_exist( [ GET => $_ ], "GET $_ does not exist." ) }
      @routes;
    my @modelroutes = qw(
      /nlp/parse/en_pcfg.yml
      /nlp/parse/en_pcfg1.yml
    );
    map { response_status_is( [ GET => $_ ], 500, "GET $_ responds with 500" ) }
      @modelroutes;
    done_testing();
};

subtest 'parse text using GET or POST' => sub {
    my @modelroutes = qw(
      /nlp/parse/default.yml
      /nlp/parse/en_pcfg.yml
      /nlp/parse/en_pcfgwsj.yml
      /nlp/parse/en_factored.yml
      /nlp/parse/en_factoredwsj.yml
    );
    my $params = { text => qq/The quick brown fox jumped over a lazy dog./ };
    my $output = qq/[det(fox-4, The-1), amod(fox-4, quick-2), amod(fox-4,
    brown-3), nsubj(jumped-5, fox-4), det(dog-9, a-7), amod(dog-9, sexy-8),
    prep_over(jumped-5, dog-9)]/;
    my $check_get_req = sub {
        my ( $rte, $code ) = @_;
        Carp::croak 'Invalid argument' unless defined $rte;
        $code = 200 unless defined $code;
        route_exists       [ GET => $rte ], "GET $rte exists";
        response_exists    [ GET => $rte ], "GET $rte response exists";
        response_status_is [ GET => $rte ], $code,
          "GET $rte responds with $code";

        my $res = dancer_response( GET => $rte, { params => $params } );
        isa_ok( $res, 'Dancer::Response' );
        is( $res->{status}, $code, "GET $rte responds with $code" );
        if ( $code ne 500 ) {
            is( $res->{content}, $output,
                "Response content looks good for GET $rte" );
        } else {
            ok( $res->{content} =~ /error/,
                'Error: ' . $res->{content} . "\n" );
        }
    };
    my $check_post_req = sub {
        my ( $rte, $code ) = @_;
        Carp::croak 'Invalid argument' unless defined $rte;
        $code = 200 unless defined $code;

        my $res = dancer_response( POST => $rte, { params => $params } );
        isa_ok( $res, 'Dancer::Response' );
        is( $res->{status}, $code, "POST $rte responds with $code" );
        if ( $code ne 500 ) {
            is( $res->{content}, $output,
                "Response content looks good for POST $rte" );
        } else {
            ok( $res->{content} =~ /error/,
                'Error: ' . $res->{content} . "\n" );
        }
    };
  TODO: {
        local $TODO = 'Dancer::Test does not handle POST with vars well.';
        map { &$check_post_req( $_, 200 ) } @modelroutes;
        map { &$check_get_req( $_, 200 ) } @modelroutes;
    }
    my @nonroutes = map { $_ if $_ =~ s/\./dummy\./g } @modelroutes;
    map { &$check_post_req( $_, 500 ) } @nonroutes;
    map { &$check_get_req( $_, 500 ) } @nonroutes;
    done_testing();
};
done_testing();
__END__
COPYRIGHT: 2011. Vikas Naresh Kumar.
AUTHOR: Vikas Naresh Kumar
DATE: 28th May 2011.
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
