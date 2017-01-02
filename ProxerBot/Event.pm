#!/usr/bin/env perl

package ProxerBot::Event;

our $VERSION = '0.00';
use strict;
use warnings;
use feature 'say';
use Data::Dumper;
use MongoDB;
use Time::Moment;
use ProxerBot::Bool;
use ProxerBot::Chat;



sub new {
	my $class = shift;
	my $eventID = shift;
	my $self = bless({}, $class);

	return if !$eventID;


	$self->{eventID} = $eventID;
	$self->{DB_UPDATES} = _get_collection('Updates');
	$self->{DB_CHATS} = _get_collection('Chats');
	$self->{DB_PROCESSED} = _get_collection('Processed');

	$self->{event} = $self->getEvent;


	return $self;
}



sub chat {
    my $self = shift;
    my $telegram = shift;
	my $chat = $self->{event}->{message}->{chat};

    return ProxerBot::Chat->new($telegram, $chat);
}


sub processed {
    my $self = shift;
	my $db_processed = $self->{DB_PROCESSED};


	$db_processed->update_one(
		{update_id => $self->updateID},
		{'$set' => {processed => TRUE}},
		{upsert => 1}
	);

    return 1;
}


sub getEvent {
    my $self = shift;
	my $db_updates = $self->{DB_UPDATES};

	return $db_updates->find_one({update_id => $self->updateID});
}

sub updateID {
    my $self = shift;

	return $self->{eventID};
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
