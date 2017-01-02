#!/usr/bin/env perl

package ProxerBot::Bool;

our $VERSION = '0.00';
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = (
	'TRUE',
	'FALSE'
);

use constant {
	TRUE => 1,
	FALSE => 0
};

1
