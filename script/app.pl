#!/usr/bin/perl
use common::sense;
use lib "$ENV{PWD}/blib/lib";
use NLP::Service;

NLP::Service->run();
