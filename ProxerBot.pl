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


my @hi = (
	'Hey, human :)',
	'Hello, human :)',
	'Wazzup? :D',
	'Hii :)',
);

if (fork() == 0) {
	ProxerBot::Updater::update_cycle($telegram, 3);
	say "Updater crashed";
	exit;
}


while (1) {
	my $event = get_unprocessed();

	if (!$event) {
		sleep 1;
		redo;
	};

	$event->processed;

	my $chat = $event->chat($telegram);

	if ($chat->is_new) {
		$chat->send_message($hi[int rand @hi]);
	}
	else {
		$chat->send_message('Huhu :)');
	}



	print Dumper $event->updateID
}


















sub get_unprocessed {
	my $db_events = _get_collection('Updates');

	my $cursor = $db_events->aggregate([
	    {'$lookup' => {
	        from => "Processed",
	        localField => "update_id",
	        foreignField => "update_id",
	        as => "processed"
	    }},
	    {'$match' => {
	        processed => {'$size' => 0}
	    }},
		{'$sort' => {
			update_id => 1
		}}
	]);


	my $next = $cursor->next;
	if ($next) {
		return ProxerBot::Event->new($next->{update_id});
	}
	else {
	    return;
	}
}




wait;
