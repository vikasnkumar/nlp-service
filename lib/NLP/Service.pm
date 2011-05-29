package NLP::Service;

use 5.010000;
use feature ':5.10';
use common::sense;
use Carp ();

BEGIN {
    use Exporter();
    our @ISA     = qw(Exporter);
    our $VERSION = '0.01';
}

use Dancer qw(:tests); # we do not want the tests exporting the wrong functions.
use Dancer::Plugin::REST;
use NLP::StanfordParser;

my %_nlp = ();

prepare_serializer_for_format;

get '/' => sub {
    #TODO: show a UI form based thing for easy use for the end user.
    return 'This is ' . config->{appname} . "\n";
};

get '/nlp/models.:format' => sub {
    return [ keys %_nlp ];
};

get '/nlp/languages.:format' => sub {
    return [qw/en/];
};

get '/nlp/info.:format' => sub {
    return {
        version        => $NLP::Service::VERSION,
        nlplib_name    => 'Stanford Parser',
        nlplib_source  => PARSER_SOURCE_URI,
        nlplib_release => PARSER_RELEASE_DATE,
    };
};

any [qw/get post/] => '/nlp/parse/:model.:format' => sub {
    my $model = params->{model};
    return send_error({ error => "Unknown parsing model $model"} , 500) unless defined $_nlp{model};
    my $txt = params->{text};
    return send_error({ error => "Empty 'text' parameter" }, 500)  unless defined $txt;
    return $_nlp{$model}->parse($txt) . "\n";
};

sub run {
    my %args = @_;
    my $force = $args{force} if scalar( keys(%args) );
   
    #TODO: should be able to take a YAML file that can convert to a
    #Dancer::Config object and use that. should also add logging statements.
    set log => 'debug';
    set logger => 'console';
    set show_errors => 1;
   
    say 'Forcing loading of all NLP models.' if $force;
    $_nlp{en_pcfg} = new NLP::StanfordParser( model => MODEL_EN_PCFG )
      or Carp::croak 'Unable to create MODEL_EN_PCFG for NLP::StanfordParser';

    # PCFG load times are reasonable ~ 5 sec. We force load on startup.
    $_nlp{en_pcfg}->parser if $force;
    $_nlp{en_factored} = new NLP::StanfordParser( model => MODEL_EN_FACTORED )
      or Carp::croak 'Unable to create MODEL_EN_FACTORED for NLP::StanfordParser';

    # Factored load times can be quite slow ~ 30 sec. We force load on startup.
    $_nlp{en_factored}->parser if $force;

    # PCFG WSJ takes ~ 2-3 seconds to load
    $_nlp{en_pcfgwsj} = new NLP::StanfordParser( model => MODEL_EN_PCFG_WSJ )
      or Carp::croak 'Unable to create MODEL_EN_PCFG_WSJ for NLP::StanfordParser';
    $_nlp{en_pcfgwsj}->parser if $force;
    $_nlp{en_factoredwsj} =
         new NLP::StanfordParser( model => MODEL_EN_FACTORED_WSJ )
      or Carp::croak 'Unable to create MODEL_EN_FACTORED_WSJ for NLP::StanfordParser';

    # FACTORED WSJ takes ~ 20 seconds to load
    $_nlp{en_factoredwsj}->parser if $force;

    # dancer's invocation
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

The C<run()> function starts up the NLP::Service, and listens to requests. It currently takes no parameters.
It makes sure that the NLP Engines that are being used are loaded up before the web service is ready.

It takes only 1 argument, that denotes whether the models are lazily loaded or
instantly loaded. For example,

C<NLP::Service::run(load =E<gt> 1)>

=back

=head1 RESTful API

Multiple formats are supported in the API. Most notably they are XML, YAML and JSON.
The URIs need to end with C<.xml>, C<.yml> and C<.json> for XML, YAML and JSON, respectively.

=over

=item B<GET> I</nlp/models.json /nlp/models.yml> 

Returns an array of loaded models. These are the model names that will be used
in the other RESTful API URI strings.

=item B<GET> I</nlp/languages.json /nlp/languages.yml>

Returns an array of supported languages. Default is "en" for English.

=item B<GET> I</nlp/info.json /nlp/info.yml>

Returns a hashref of details about the NLP tool being used.

=back

=head1 COPYRIGHT

Copyright (C) 2011. B<Vikas Naresh Kumar> <vikas@cpan.org>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

Started on 25th March 2011.

