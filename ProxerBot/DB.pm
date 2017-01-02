#!/usr/bin/env perl

package ProxerBot::DB;

our $VERSION = '0.00';
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw(
	get_next_event
	add_event
	get_latest_updateID
);

use feature 'say';
use Data::Dumper;
use MongoDB;
use Time::Moment;
use ProxerBot::Bool;
use ProxerBot::Chat;



sub get_next_event {
	my $db_events = _get_collection('Events');

	my $raw = $db_events->find_one(
		{processed => 0},
		{},
		{sort => {update_id => -1}}
	);

	return ProxerBot::Event->new($raw);
}



sub get_latest_updateID {
	my $db_events = _get_collection('Events');

	my $raw = $db_events->find_one(
		{},
		{},
		{sort => {update_id => -1}}
	);

	return $raw->{update_id};
}



sub add_event {
	my $event = shift;
	my $db_event = _get_collection("Events");

	$db_event->replace_one(
		{update_id => $event->{update_id}},
		$event,
		{upsert => 1}
	);
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
