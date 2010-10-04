package Catalyst::Authentication::Credential::Flickr::Nebraska;

use strict;
use warnings;
use base qw( Class::Accessor::Fast );

BEGIN {
  __PACKAGE__->mk_accessors(qw/_flickr key secret perms/);
}

use Catalyst::Exception ();
use NX::Flickr;

sub new {
  my $ob = shift;
  my $config = shift;
  my $c = shift;
  my $realm = shift;
  
  my $self = bless {}, ref($ob) || $ob;
  
  # Hack to make lookup of the configuration parameters less painful
  my $params = { %{ $config }, %{ $realm->{config} } };
  
  # Check for required params (yes, nasty)
  for my $param (qw/key secret perms/) 
  {
    $self->$param($params->{$param}) || Catalyst::Exception->throw("$param not defined") 
  }
  
  my $flickr = new NX::Flickr({
    key => $self->key,
    secret => $self->secret,
  });
  $flickr->api->env_proxy;
  
  $self->_flickr($flickr);
  
  return $self;
}

sub authenticate {
  my ( $self, $c, $realm, $authinfo ) = @_;
  
  my $frob = $c->req->params->{frob};
  return undef unless defined $frob && $frob;
  
  my $response = eval { $self->_flickr->execute_method( 'flickr.auth.getToken', { frob => $frob, } ) };
  
  if(my $error = $@)
  {
    warn $error;
    return undef;
  }
  
  my $user = {
    flickr_username => $response->hash->{auth}->{user}->{username},
  };
  
  use YAML ();
  warn YAML::Dump({ hsah => $response->hash, user => $user });
  
  my $user_obj = $realm->find_user( $user, $c );
  
  if(defined $user_obj)
  {
    my $user_flickr = $user_obj->get_object;
    $user_flickr->flickr_nsid($response->hash->{auth}->{user}->{nsid});
    $user_flickr->flickr_token($response->hash->{auth}->{token});
    $user_flickr->update;
    return $user_obj;
  }
  else
  {
    return undef;
  }
}
    
sub authenticate_flickr_url
{
  my $self = shift;
  my $c = shift;
  
  my $uri = $self->_flickr->request_auth_url($self->perms);
  return $uri;
}

1;