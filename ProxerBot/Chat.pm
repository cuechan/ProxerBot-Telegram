#!/usr/bin/env perl

package ProxerBot::Chat;

our $VERSION = '0.00';
use strict;
use warnings;
use feature 'say';
use Data::Dumper;
use MongoDB;
use Time::Moment;
use ProxerBot::Bool;


sub new {
	my $class = shift;
	my $telegram = shift;
	my $chat = shift;
	my $self = bless({}, $class);

	die "A bug" if !$telegram or !$chat;

	$self->{telegram} = $telegram;
	$self->{chat} = $chat;
	$self->{DB_CHATS} = _get_collection('Chats');
	$self->{DB_UPDATES} = _get_collection('Updates');
	$self->{DB_PROCESSED} = _get_collection('Processed');

	my $db_chats = $self->{DB_CHATS};



	if ($db_chats->find_one({chat_id => $self->chatID})) {
		$self->{is_new} = FALSE;
	}
	else {
	    $self->{is_new} = TRUE;
	}


	$db_chats->update_one(
		{chat_id => $self->chatID},
		{'$set' => {chat_conf => $chat}},
		{upsert => 1}
	);

	return $self;
}



sub is_new {
    my $self = shift;

	return $self->{is_new};
}


sub chatID {
    my $self = shift;

	return $self->{chat}->{id};
}


sub send_message {
    my $self = shift;
	my $message = join '', @_;
	my $telegram = $self->{telegram};

	$telegram->api_request('sendMessage', {
		chat_id => $self->chatID,
		text => $message,
		reply_markup => {
			remove_keyboard => \0
		}
	});

    return 1;
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
