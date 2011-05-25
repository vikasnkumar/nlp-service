### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas N Kumar
### DATE: 8th March 2011

use Test::More;
use Test::Moose;

BEGIN {
    plan skip_all =>
'Environment variable NLPSTANFORD should be defined to the directory where the Java libraries reside.'
      unless defined $ENV{NLPSTANFORD};
    use_ok('NLP::StanfordParser');
}
my $nlp = new_ok('NLP::StanfordParser');
meta_ok($nlp);
can_ok( $nlp, 'parse' );

my $sentence = 'The quick brown fox jumped over the lazy dog!';
isnt( $nlp->parse($sentence), undef );

done_testing();
