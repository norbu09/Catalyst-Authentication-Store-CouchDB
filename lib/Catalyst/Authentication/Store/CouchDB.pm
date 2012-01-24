#!/usr/bin/perl

package Catalyst::Authentication::Store::CouchDB;

use base qw/Class::Accessor::Fast/;

use strict;
use warnings;
use Store::CouchDB;
use Data::Dumper;
use Catalyst::Authentication::Store::CouchDB::User;
use Scalar::Util qw/blessed/;

our $VERSION = '1.0';

BEGIN { __PACKAGE__->mk_accessors(qw/_db user_class _auth_couch_config/) }

sub new {
    my ($class, $config, $app, $realm) = @_;

    $config->{_auth_couch_config} = $config;
    $config->{user_class} ||= __PACKAGE__ . '::User';
    $config->{_db} = Store::CouchDB->new();

    bless {%$config}, $class;
}

sub find_user {
    my ($self, $authinfo, $c) = @_;

    return unless $authinfo->{_id};

    $c->log->debug(Dumper($authinfo));

    $self->_verify_couchdb_connection($c);
    my $doc = $self->_db->get_doc({ id => $authinfo->{_id} });
    if ($doc) {
        $self->user_class->new($self, $doc);
    }
}

sub user_supports {
    my $self = shift;

    # this can work as a class method, but in that case you can't have
    # a custom user class
    ref($self)
        ? $self->user_class->supports(@_)
        : Catalyst::Authentication::Store::CouchDB::User->supports(@_);
}

sub from_session {
    my ($self, $c, $id) = @_;
    $self->find_user($id, $c);
}

sub _verify_couchdb_connection {
    my ($self, $c) = @_;

    my $db = 'auth';
    if ($self->_auth_couch_config->{use_host_based_db}) {
        $db =
            $c->request->headers->header(
            $self->_auth_couch_config->{host_header});
        $db =~ s/\./_/g;
    }
    elsif ($self->_auth_couch_config->{db}) {
        $db = $self->_auth_couch_config->{db};
    }

    $self->_db->host($self->_auth_couch_config->{host} || '127.0.0.1');
    $self->_db->port($self->_auth_couch_config->{port} || '5984');
    $self->_db->user($self->_auth_couch_config->{user} || '');
    $self->_db->pass($self->_auth_couch_config->{pass} || '');
    $self->_db->db($db);
}

1;

