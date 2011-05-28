use Module::Build;

#TODO: use better checks for the Java stuff being installed.
my $nlppath = $ENV{NLPSTANFORD}
  or die "Please set the NLPSTANFORD environment variable to point "
  . "the Stanford NLP distribution";
my $build = Module::Build->new(
    module_name => 'NLP::StanfordParser',
    license     => 'restrictive',
    dist_author => 'Vikas Naresh Kumar <vikas@selectiveintellect.com>',
    requires    => {
        'perl'                 => '5.10.0',
        'common::sense'        => 0,
        'Carp'                 => 0,
        'namespace::autoclean' => 0,
        'Moose'                => 0,
        'Dancer'               => 0,
        'Dancer::Plugin::REST' => 0,
        'Inline::Java'         => 0,
        'Test::More'           => 0,
        'Test::Moose'          => 0,
    },
    java_files => {
        "$nlppath/stanford-parser.jar" =>
          'lib/NLP/StanfordParser/stanford-parser.jar',
        "$nlppath/englishPCFG.ser.gz" =>
          'lib/NLP/StanfordParser/englishPCFG.ser.gz',
        "$nlppath/englishFactored.ser.gz" =>
          'lib/NLP/StanfordParser/englishFactored.ser.gz',
    },
);
$build->add_build_element('java');
$build->create_build_script;
$build->dispatch('build');
__END__
###
###
COPYRIGHT: 2011. Selective Intellect LLC. All Rights Reserved.
AUTHOR: Vikas Naresh Kumar
DATE: 24th May 2011
###

