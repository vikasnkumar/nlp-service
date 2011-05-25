### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas N Kumar
### DATE: 8th March 2011
package NLP::StanfordParser;

use 5.010000;
use feature ':5.10';
use strict;
use warnings;
use Carp;

BEGIN {
    $NLP::StanfordParser::VERSION = '0.02';
    croak "You need to set NLPSTANFORD environment variable to run this" unless defined $ENV{NLPSTANFORD};
}
use Inline (
    Java => << 'END_OF_JAVA_CODE',
	import java.util.*;
	import edu.stanford.nlp.trees.*;
	import edu.stanford.nlp.parser.lexparser.LexicalizedParser;

	class JavaStanfordParser {
		LexicalizedParser parser;
		TreebankLanguagePack tlp;
		GrammaticalStructureFactory gsf;
		public JavaStanfordParser (String model) {
			parser = new LexicalizedParser(model);
			parser.setOptionFlags("-retainTmpSubcategories");
			tlp = new PennTreebankLanguagePack();
			gsf = tlp.grammaticalStructureFactory();
		}
		public String parse(String sentence) {
			parser.parse(sentence);
//			Tree tree = (Tree)parser.apply(sentence);
//			TreePrint trpr = new TreePrint("penn,typedDependenciesCollapsed");
//			trpr.printTree(tree);
			GrammaticalStructure gs = gsf.newGrammaticalStructure(parser.getBestParse());
			return gs.typedDependenciesCollapsed().toString();
		}
		public String parseold(String sentence) {
			parser.parse(sentence);
			return parser.getBestParse().toString();
		}
	}
END_OF_JAVA_CODE
    CLASSPATH       => "$ENV{NLPSTANFORD}/stanford-parser.jar",
    EXTRA_JAVA_ARGS => '-Xmx800m'
);
use Moose;
use namespace::autoclean;

has model => (
    is      => 'ro',
    isa     => 'Str',
    default => "$ENV{NLPSTANFORD}/englishPCFG.ser.gz"
);
has parser => ( is => 'ro', lazy_build => 1, handles => [qw/parse/] );

sub _build_parser {
    my $self = shift;
    return new NLP::StanfordParser::JavaStanfordParser(
        $self->model );
}

__PACKAGE__->meta->make_immutable;
1;

__END__
#####################################################################
# This loads the stanford NLP Parser into Perl.
# should really be loaded only once per model.
#
### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas N Kumar
### DATE: 6th March 2011
