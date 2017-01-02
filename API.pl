#!/usr/bin/env perl


package ProxerBot::Updater;


use strict;
use warnings;
use feature 'say';
use lib '.';
use Data::Dumper;
use YAML::XS 'LoadFile', 'DumpFile';
use WWW::Telegram::BotAPI;
use ProxerBot::Bool;
use ProxerBot::Chat;
use ProxerBot::Event;
use ProxerBot::DB;
use ProxerBot::Updater;


my $config = LoadFile('ProxerBot.conf');
my $api_token = $config->{API_token};

my $telegram = WWW::Telegram::BotAPI->new(token => $api_token);












sub send_message {
	my $telegram = shift;
	my $message = join '', @_;

	$telegram->api_request('sendMessage', {
		chat_id => '282403434',
		text => "Hello Human",
		reply_markup => {
			remove_keyboard => \0
		}
	});

    return 1;
}
