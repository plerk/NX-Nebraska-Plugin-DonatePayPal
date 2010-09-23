package Catalyst::Authentication::Store::DBIx::Class::Twitter;

use strict;
use warnings;
use base qw( Catalyst::Authentication::Store::DBIx::Class );

sub auto_create_user
{
  my $self = shift;
  my $authinfo = shift;
  my $c = shift;
  
  do {
    my $twitter_user_id = $authinfo->{twitter_user_id};
    my $realm = $c->model('User::Realm')->search({ name => 'twitter' })->first;
    my $user = $c->model('User::User')->create({
      name => "id:" . $twitter_user_id,
      realm_id => $realm->id,
    });
    my $twitter_user = $c->model('User::UserTwitter')->create({
      twitter_user_id => $twitter_user_id,
      user_id => $user->id,
    });
  };
  
  my $user = $self->config->{'store_user_class'}->new($self->{'config'}, $c);
  return $user->load($authinfo, $c);
}

1;
