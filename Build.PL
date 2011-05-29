use strict;
use warnings;
use Module::Build;

my $nlppath = defined $ENV{NLPSTANFORD} ? $ENV{NLPSTANFORD} : 'data/stanford-parser-2010-11-30';
print "Using datafiles and jar files from $nlppath\n";
my @nlpfiles = qw(
  stanford-parser.jar
  englishPCFG.ser.gz
  englishFactored.ser.gz
  wsjPCFG.ser.gz
  wsjFactored.ser.gz
);
my %nlpjava = map { "$nlppath/" . $_ => "lib/NLP/StanfordParser/$_" } @nlpfiles;

my $build = Module::Build->new(
    module_name    => 'NLP::Service',
    dist_name      => 'nlp-service',
    dist_author    => 'Vikas Naresh Kumar <vikas@cpan.org>',
    dist_abstract  => 'A RESTful NLP Service',
    license        => 'perl',
    create_license => 1,
    create_readme  => 1,
    requires       => {
        'perl'                 => '5.10.0',
        'common::sense'        => 0,
        'Carp'                 => 0,
        'namespace::autoclean' => 0,
        'Moose'                => 0,
        'Inline::Java'         => 0,
        'Dancer'               => 0,
        'Dancer::Plugin::REST' => 0,
    },
    build_requires => {
        'Test::More'  => 0,
        'Test::Moose' => 0,
        'Dancer::Test' => 0,
    },
    script_files => qw( script/nlpservice ),
    install_path => { java => 'lib/NLP/StanfordParser/', },
    java_files   => \%nlpjava,
);
$build->add_build_element('java');
$build->add_to_cleanup(qw/_Inline *.bak/);
$build->create_build_script;
$build->dispatch('clean');
$build->dispatch('distmeta');
$build->dispatch('manifest');
$build->dispatch('build');
__END__
COPYRIGHT: 2011. Vikas Naresh Kumar.
AUTHOR: Vikas Naresh Kumar
DATE: 24th May 2011
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
