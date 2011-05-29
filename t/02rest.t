use Test::More;

BEGIN {
    use_ok('NLP::Service');

    # the below module should always be after the package being tested.
    use Dancer::Test;
}

subtest 'route exists' => sub {
    my @ser    = qw(yml json);
    my @routes = qw(
      /nlp/info
      /nlp/models
      /nlp/languages
    );
    foreach my $route (@routes) {
        foreach my $ser (@ser) {
            $route .= ".$ser";
            route_exists    [ GET => $route ], "GET $route exists";
            response_exists [ GET => $route ], "GET $route response exists";
        }
    }
    done_testing();
};

subtest 'route does not exist' => sub {
    my @routes = qw(
      /
      /nlp/
    );
    foreach my $route (@routes) {
        route_doesnt_exist [ GET => $route ], "GET $route does not exist.";
    }
    done_testing();
};

done_testing();
__END__
COPYRIGHT: 2011. Vikas Naresh Kumar.
AUTHOR: Vikas Naresh Kumar
DATE: 28th May 2011.
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
