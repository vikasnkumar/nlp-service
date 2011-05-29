use Test::More;

BEGIN {
    use_ok('NLP::Service');

    # the below module should always be after the package being tested.
    use Dancer::Test;
}

subtest 'GET routes that should pass' => sub {
    my @ser    = qw(yml json xml);
    my %routes = (
        '/'              => undef,
        '/nlp/info'      => \@ser,
        '/nlp/models'    => \@ser,
        '/nlp/languages' => \@ser,
    );
    my %modelroutes = (
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
      /nlp/parse/en_pcfg.yml
      /nlp/parse/en_pcfg1.yml
    );
    my $check_get_req = sub {
        my ( $rte ) = @_;
        Carp::croak 'Invalid argument' unless defined $rte;
        route_exists       [ GET => $rte ], "GET $rte exists";
        response_exists    [ GET => $rte ], "GET $rte response exists";
        response_status_is [ GET => $rte ], 500, "GET $rte responds with 500";
    };
    my $check_post_req = sub {
        my $rte = shift;
        Carp::croak 'Invalid argument' unless defined $rte;
        my $res = dancer_response( POST => $rte );
        isa_ok( $res, 'Dancer::Response' );
        is( $res->{status}, 500, "POST $rte responds with 500" );
    };
    map { &$check_post_req($_) } @modelroutes;
    map { &$check_get_req($_) } @modelroutes;
    done_testing();
};

done_testing();
__END__
COPYRIGHT: 2011. Vikas Naresh Kumar.
AUTHOR: Vikas Naresh Kumar
DATE: 28th May 2011.
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
