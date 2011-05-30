use Test::More;

BEGIN {
    use_ok('NLP::Service');
}

# we need to laod the models before the Dancer::Test otherwise the path does not
# work for some reason.
can_ok( 'NLP::Service', 'load_models' );
my $count = NLP::Service::load_models;
is( $count, 4, 'Load models worked' );

# the below module should always be after the package being tested.
use Dancer::Test;

subtest 'GET/POST routes that should pass' => sub {
    my @ser    = qw(yml json xml);
    my %routes = (
        '/'              => undef,
        '/nlp/info'      => \@ser,
        '/nlp/models'    => \@ser,
        '/nlp/languages' => \@ser,
    );
    my %modelroutes = (
        '/nlp/parse'                => \@ser,
        '/nlp/parse/en_pcfg'        => \@ser,
        '/nlp/parse/en_factored'    => \@ser,
        '/nlp/parse/en_pcfgwsj'     => \@ser,
        '/nlp/parse/en_factoredwsj' => \@ser,
    );
    my $check_request = sub {
        my ( $meth, $rte, $flag ) = @_;
        Carp::croak 'Invalid method' unless defined $meth;
        Carp::croak 'Invalid route'  unless defined $rte;
        $flag = 0 unless defined $flag;
        route_exists       [ $meth => $rte ], "$meth $rte exists";
        response_exists    [ $meth => $rte ], "$meth $rte response exists";
        response_status_is [ $meth => $rte ], 200,
          "$meth $rte responds with 200"
          if $flag;
    };
    foreach my $meth (qw/GET POST/) {
        foreach my $rte ( sort keys %routes ) {
            defined $routes{$rte}
              ? map { &$check_request( $meth, "$rte." . $_, 1 ) }
              @{ $routes{$rte} }
              : &$check_request( $meth, $rte );
        }
        foreach my $rte ( sort keys %modelroutes ) {
            defined $modelroutes{$rte}
              ? map { &$check_request( $meth, "$rte." . $_ ) }
              @{ $modelroutes{$rte} }
              : &$check_request( $meth, $rte );
        }
    }
    done_testing();
};

subtest 'GET/POST routes that should fail' => sub {
    my @routes = qw(
      /nlp/info
      /nlp/
      /robots.txt
    );
    map { route_doesnt_exist( [ GET => $_ ], "GET $_ does not exist." ) }
      @routes;
    map { route_doesnt_exist( [ POST => $_ ], "POST $_ does not exist." ) }
      @routes;
    my @modelroutes = qw(
      /nlp/parse/en_pcfg.yml
      /nlp/parse/en_pcfg1.yml
    );
    map { response_status_is( [ GET => $_ ], 500, "GET $_ responds with 500" ) }
      @modelroutes;
    map {
        response_status_is( [ POST => $_ ], 500, "POST $_ responds with 500" )
    } @modelroutes;
    done_testing();
};

subtest 'parse text using GET/POST' => sub {
    my @modelroutes = qw(
      /nlp/parse/en_pcfg.yml
      /nlp/parse/en_pcfgwsj.yml
      /nlp/parse/en_factored.yml
      /nlp/parse/en_factoredwsj.yml
    );
    my $params = { data => 'The quick brown fox jumped over a lazy dog.', };
    my $output = qq/[det(fox-4, The-1), amod(fox-4, quick-2), amod(fox-4,
    brown-3), nsubj(jumped-5, fox-4), det(dog-9, a-7), amod(dog-9, lazy-8),
    prep_over(jumped-5, dog-9)]/;
    $output =~ tr/\040\012//ds;
    my $check_request = sub {
        my ( $meth, $rte, $code ) = @_;
        Carp::croak 'Invalid method' unless defined $meth;
        Carp::croak 'Invalid route'  unless defined $rte;
        $code = 200 unless defined $code;

        my $res = dancer_response( $meth => $rte, { params => $params } );
        isa_ok( $res, 'Dancer::Response' );
        is( $res->{status}, $code, "$meth $rte responds with $code" );
        my $content = $res->{content} or fail("No content received");
        if ( $code eq 200 ) {
            $content =~ tr/\040\012//ds;
            is( $content, $output,
                "Response content looks good for $meth $rte" );
        } elsif ( $code eq 500 ) {
            like( $content, qr/error/, "Error: $content" );
        } elsif ( $code eq 404 ) {
            pass('Expected a 404 response');
        }
    };
    &$check_request( 'GET',  '/nlp/parse.yml', 200 );
    &$check_request( 'POST', '/nlp/parse.yml', 200 );
    map {
        &$check_request( 'POST', $_, 200 );
        &$check_request( 'GET',  $_, 200 );
    } @modelroutes;
    my @nonroutes = map { $_ if $_ =~ s/\./dummy\./g } @modelroutes;
    map {
        &$check_request( 'GET',  $_, 500 );
        &$check_request( 'POST', $_, 500 );
    } @nonroutes;
    &$check_request( 'GET',  '/nlp/parsedummy.yml', 404 );
    &$check_request( 'POST', '/nlp/parsedummy.yml', 404 );
    done_testing();
};
done_testing();
__END__
COPYRIGHT: 2011. Vikas Naresh Kumar.
AUTHOR: Vikas Naresh Kumar
DATE: 28th May 2011.
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
