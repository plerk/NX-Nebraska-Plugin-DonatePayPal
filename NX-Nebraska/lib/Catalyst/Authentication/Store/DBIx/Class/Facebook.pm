package Catalyst::Authentication::Store::DBIx::Class::Facebook;

use strict;
use warnings;
use base qw( Catalyst::Authentication::Store::DBIx::Class );

sub auto_create_user
{
  my $self = shift;
  my $authinfo = shift;
  my $c = shift;
  
  do {
    # session_expires session_key session_uid
    my $realm = $c->model('User::Realm')->search({ name => 'facebook' })->first;
    my $user = $c->model('User::User')->create({
      name => 'id_' . $authinfo->{session_uid},
      realm_id => $realm->id,
    });
    my $facebook_user = $c->model('User::UserFacebook')->create({
      session_expires => $authinfo->{session_expires},
      session_key => $authinfo->{session_key},
      session_uid => $authinfo->{session_uid},
      user_id => $user->id,
    });
  };
  
  my $user = $self->config->{'store_user_class'}->new($self->{'config'}, $c);
  return $user->load($authinfo, $c);
}

1;
