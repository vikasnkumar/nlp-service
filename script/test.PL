#!/usr/bin/perl
use common::sense;
use LWP::UserAgent;
my $lwp  = new LWP::UserAgent;
my %form = ( text => 'This is not a box.', );
my $resp = $lwp->post( "http://localhost:3000/", \%form );
print $resp->as_string, "\n";
$resp = $lwp->post( "http://localhost:3000/nlp/parse/en_pcfg.yml", \%form );
print $resp->as_string, "\n";
$resp = $lwp->post( "http://localhost:3000/nlp/parse.json", \%form );
print $resp->as_string, "\n";
