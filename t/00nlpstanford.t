use Test::More;
use Test::Moose;

BEGIN {
    plan skip_all => 'Environment variable NLPSTANFORD should be defined '
      . 'to the directory where the Java libraries reside.'
      unless defined $ENV{NLPSTANFORD};
    use_ok('NLP::StanfordParser');
}

subtest 'model is PCFG' => sub {
    my $nlp = new_ok('NLP::StanfordParser');
    meta_ok($nlp);
    can_ok( $nlp, 'parse' );
    has_attribute_ok( $nlp, 'parser' );
    has_attribute_ok( $nlp, 'model' );
    is( $nlp->model, MODEL_EN_PCFG, 'Model is PCFG' );
    isa_ok( $nlp->parser, 'NLP::StanfordParser::Java' );
    my $sentence = 'The quick brown fox jumped over the lazy dog!';
    isnt( $nlp->parse($sentence), undef );

    done_testing();
};

subtest 'model is FACTORED' => sub {
    my $nlp = new_ok( 'NLP::StanfordParser' => [ model => MODEL_EN_FACTORED ] );
    meta_ok($nlp);
    can_ok( $nlp, 'parse' );
    has_attribute_ok( $nlp, 'parser' );
    has_attribute_ok( $nlp, 'model' );
    is( $nlp->model, MODEL_EN_FACTORED, 'Model is Factored' );
    isa_ok( $nlp->parser, 'NLP::StanfordParser::Java' );

    my $sentence = 'The quick brown fox jumped over the lazy dog!';
    isnt( $nlp->parse($sentence), undef );

    done_testing();
};

done_testing();
__END__
COPYRIGHT: 2011. Vikas Naresh Kumar.
AUTHOR: Vikas Naresh Kumar
DATE: 24th May 2011
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
