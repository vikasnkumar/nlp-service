use Module::Build;

my $build = Module::Build->new(
    module_name => 'NLP::StanfordParser',
    license     => 'restrictive',
    dist_author => 'Vikas Naresh Kumar <vikas@selectiveintellect.com>',
    requires    => {
        'perl'                     => '5.10.0',
        'common::sense'            => 0,
        'Carp'                     => 0,
        'namespace::autoclean'     => 0,
        'Moose'                    => 0,
        'AnyEvent'                 => 0,
        'EV'                       => 0,
        'Inline::Java'             => 0,
        'Test::More' => 0,
        'Test::Moose' => 0,
    },
    java_files => {

    },
);
#$build->add_build_element('java');
$build->create_build_script;
__END__
###
###
COPYRIGHT: 2011. Selective Intellect LLC. All Rights Reserved.
AUTHOR: Vikas Naresh Kumar
DATE: 24th May 2011
###

