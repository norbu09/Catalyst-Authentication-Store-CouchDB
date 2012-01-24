#!/usr/bin/perl

package Catalyst::Authentication::Store::CouchDB::User;

use base qw/Catalyst::Authentication::User Class::Accessor::Fast/;

use strict;
use warnings;
use Data::Dumper;

BEGIN { __PACKAGE__->mk_accessors(qw/_user _store/) }

use overload '""' => sub { shift->id }, fallback => 1;

sub new {
    my ($class, $store, $user) = @_;

    return unless $user;

    bless { _store => $store, _user => $user }, $class;
}

sub id {
    my $self = shift;
    return $self->_user->{id};
}

sub supported_features {
    return {
        password => { self_check => 1 },
        session  => 1,
        roles    => 1,
    };
}

sub check_password {
    my ($self, $password) = @_;

    my $doc = $self->_user->_db->get_doc({ id => $self->_user->{_id} });

    if (my $pass = delete $doc->{password}) {
        return 1 if $pass eq Digest::SHA::sha1_hex($password);
    }
}

sub roles {
    my $self = shift;

    my $doc = $self->_user->_db->get_doc({ id => $self->_user->{_id} });
    return $doc->{roles} || ();
}

*for_session = \&id;

*get_object = \&_user;

sub AUTOLOAD {
    my $self = shift;

    (my $method) = (our $AUTOLOAD =~ /([^:]+)$/);

    return if $method eq "DESTROY";

    $self->_user->{$method};
}

1;

__END__

=pod

=head1 NAME

Catalyst::Authentication::Store::CouchDB::User - A user object
representing an entry in a CouchDB document.

=head1 METHODS

=head2 id

Returns the username.

=head2 check_password($password)

Returns whether the password is valid.

=head2 roles

Returns an array of roles.

=head2 for_session

Returns the username, which is then stored in the session.

=head2 supported_features

Returns data about which featurs this user module supports.

=head1 AUTHORS

Lenz Gschwendtner

=head1 COPYRIGHT & LICENSE

	Copyright (c) 2011 the aforementioned authors. All rights
	reserved. This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=cut


