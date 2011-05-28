### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas N Kumar
### DATE: 25th March 2011
package NLP::Service;

use 5.010000;
use feature ':5.10';
use common::sense;
use Carp;

BEGIN {
    use Exporter();
    our @ISA = qw(Exporter);
    our $VERSION = '0.01';
}

use Dancer;
use Dancer::Plugin::REST;
use NLP::StanfordParser;

our $timer;

set serializer => 'YAML';

get '/nlp/:name' => sub {
    return { name => params->{name}};
};

sub run {
    $_nlp{pcfg} = new NLP::StanfordParser(model => MODEL_PCFG) or
                  croak 'Unable to create MODEL_PCFG for NLP::StanfordParser';
    # PCFG load times are reasonable ~ 5 sec. We force load on startup.
    $_nlp{pcfg}->parser;
    $_nlp{factored} = new NLP::StanfordParser(model => MODEL_FACTORED) or
                  croak 'Unable to create MODEL_FACTORED for NLP::StanfordParser';
    # Factored load times can be quite slow ~ 30 sec. We force load on startup.
     $_nlp{factored}->parser;

    dance;
}

1;
__END__
#####################################################################
# This creates a RESTful service around the StanfordParser.
#
### COPYRIGHT: Selective Intellect LLC
### AUTHOR: Vikas N Kumar
### DATE: 25th March 2011
#
#

=head1 NAME

NLP::Service

=head1 SYNOPSIS

NLP::Service is a RESTful web service based off Dancer to provide natural language parsing for English.

=head1 COPYRIGHT

Vikas Naresh Kumar, Selective Intellect LLC. All Rights Reserved.

=head1 METHODS

=over

=item run()

The run() function starts up the NLP::Service, and listens to requests. It currently takes no parameters.
It makes sure that the NLP Engines that are being used are loaded up before the web service is ready.

=back

=head1 RESTful API

=over

=item GET /nlp/models 

=back




