#!/usr/bin/env perl

use strict;
use warnings;
use FindBin::libs;

use Getopt::Long;
use Pod::Usage;
use YAML;

use Github::IRCBot;

GetOptions(
    \my %option,
    qw/help config=s/,
);
pod2usage(0) if $option{help};

my $config = $option{config} || "$FindBin::Bin/../config.yaml";
$config = YAML::LoadFile($config);

my $bot = Github::IRCBot->new( config => $config );
$bot->run;

