package Catalyst::Authentication::Store::DBIx::Class::Flickr;

use strict;
use warnings;
use base qw( Catalyst::Authentication::Store::DBIx::Class );

sub auto_create_user
{
  my $self = shift;
  my $authinfo = shift;
  my $c = shift;
  
  do {
    my $realm = $c->model('User::Realm')->search({ name => 'flickr' })->first;
    my $user = $c->model('User::User')->create({
      name => $authinfo->{flickr_username},
      realm_id => $realm->id,
    });
    $user->flickr_user_id($user->id);
    $user->update;
    my $user_flickr = $c->model('User::UserFlickr')->create({
      user_id => $user->id,
      flickr_username => $authinfo->{flickr_username},
    });
  };
  
  my $user = $self->config->{'store_user_class'}->new($self->{'config'}, $c);
  return $user->load($authinfo, $c);
}

1;
