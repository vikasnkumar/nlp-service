package NLP::Service;

use 5.010000;
use feature ':5.10';
use common::sense;
use Carp;

BEGIN {
    use Exporter();
    our @ISA     = qw(Exporter);
    our $VERSION = '0.01';
}

use Dancer;
use Dancer::Plugin::REST;
use NLP::StanfordParser;

my %_nlp = ();

set serializer => 'YAML';

get '/nlp/:name' => sub {
    return { name => params->{name} };
};

sub run {
    $_nlp{en_pcfg} = new NLP::StanfordParser( model => MODEL_EN_PCFG )
      or croak 'Unable to create MODEL_EN_PCFG for NLP::StanfordParser';

    # PCFG load times are reasonable ~ 5 sec. We force load on startup.
    $_nlp{en_pcfg}->parser;
    $_nlp{en_factored} = new NLP::StanfordParser( model => MODEL_EN_FACTORED )
      or croak 'Unable to create MODEL_EN_FACTORED for NLP::StanfordParser';

    # Factored load times can be quite slow ~ 30 sec. We force load on startup.
    $_nlp{en_factored}->parser;

    dance;
}

1;
__END__
COPYRIGHT: 2011. Vikas Naresh Kumar.
AUTHOR: Vikas Naresh Kumar
DATE: 25th March 2011
This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 NAME

NLP::Service

=head1 SYNOPSIS

NLP::Service is a RESTful web service based off Dancer to provide natural language parsing for English.

=head1 METHODS

=over

=item B<run()>

The run() function starts up the NLP::Service, and listens to requests. It currently takes no parameters.
It makes sure that the NLP Engines that are being used are loaded up before the web service is ready.

=back

=head1 RESTful API

=over

=item GET /nlp/models 

=back

=head1 COPYRIGHT

Copyright (C) 2011. B<Vikas Naresh Kumar> <vikas@cpan.org>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

Started on 25th March 2011.

