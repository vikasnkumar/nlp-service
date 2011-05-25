### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas N Kumar
### DATE: 8th March 2011
package NLP::StanfordParser;

use 5.010000;
use feature ':5.10';
use common::sense;
use Carp;

BEGIN {
    use Exporter();
    our @ISA = qw(Exporter);
    our $VERSION = '0.01';
    # extract the path from the Package
    my $package = __PACKAGE__ . '.pm';
    $package =~ s/::/\//g;
    our $JarPath = $INC{$package};
    $JarPath =~ s/\.pm$//g;
}
use constant {
    MODEL_FACTORED => "$NLP::StanfordParser::JarPath/englishFactored.ser.gz",
    MODEL_PCFG => "$NLP::StanfordParser::JarPath/englishPCFG.ser.gz",
    PARSER_JAR => "$NLP::StanfordParser::JarPath/stanford-parser.jar",
};
our @EXPORT = qw(MODEL_FACTORED MODEL_PCFG);
use Inline (
    Java => << 'END_OF_JAVA_CODE',
	import java.util.*;
	import edu.stanford.nlp.trees.*;
	import edu.stanford.nlp.parser.lexparser.LexicalizedParser;

	class Java {
		LexicalizedParser parser;
		TreebankLanguagePack tlp;
		GrammaticalStructureFactory gsf;
		public Java (String model) {
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
    CLASSPATH       => PARSER_JAR,
    EXTRA_JAVA_ARGS => '-Xmx800m'
);
use Moose;
use namespace::autoclean;

has model => (
    is      => 'ro',
    isa     => 'Str',
    default => MODEL_PCFG,
);

has parser => ( is => 'ro', lazy_build => 1, handles => [qw/parse/],
    isa => 'NLP::StanfordParser::Java',
);

sub _build_parser {
    my $self = shift;
    return new NLP::StanfordParser::Java( $self->model );
}

before '_build_parser' => sub {
    croak 'Unable to find ' . PARSER_JAR unless -e PARSER_JAR;
    croak 'Unable to find ' . MODEL_PCFG unless -e MODEL_PCFG;
    croak 'Unable to find ' . MODEL_FACTORED unless -e MODEL_FACTORED;
};

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
