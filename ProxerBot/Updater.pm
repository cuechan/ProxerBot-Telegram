#!/usr/bin/env perl


package ProxerBot::Updater;


use strict;
use warnings;
use lib '.';
use Data::Dumper;
use YAML::XS 'LoadFile', 'DumpFile';
use WWW::Telegram::BotAPI;
use ProxerBot::Bool;
use ProxerBot::Chat;
use ProxerBot::Event;
use ProxerBot::DB;
use feature 'say';



sub update_cycle {
	my $telegram = shift;
	my $sleep = shift;

	while (1) {
		my $offset = get_latest_updateID();
		$offset++;

		my $api_res = $telegram->api_request('getUpdates',{
			offset => $offset,
			limit => 100
		});

		if ($api_res->{ok}) {
			my $updates = $api_res->{result};

			my $db_updates = _get_collection("Updates");
			foreach (@$updates) {
				$db_updates->replace_one(
					{update_id => $_->{update_id}},
					$_,
					{upsert => 1}
				);
			}
		}

		sleep $sleep;
	}
}


sub _get_collection {
    my $collection = shift;

    my $mongoclient = MongoDB::MongoClient->new(
        host => 'mongodb://127.0.0.1',
        port => 27017,
        bson_codec => MongoDB::BSON->new(
            prefer_numeric => 1,
            dt_type        => 'Time::Moment'
        ),
    );

    my $mongodb = $mongoclient->get_database("ProxerBot");
    return $mongodb->get_collection($collection);
}

1;
