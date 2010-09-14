package NX::Nebraska::Controller::Root;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(
  namespace => '',
);

# Handle the ziyal documents in the /doc URI location
sub ziyal :Chained('/') :PathPart('doc') :Args(1)
{
  my $self = shift;
  my $c = shift;
  my $document_name = shift;
  
  eval { $c->stash($c->ziyal('doc', $document_name)) };
  $c->forward('default') if $@;
}

# used for testing 500 errors
sub internal_error :Chained('/'): PathPart('test/internal_error') :Args(0)
{
  my $self = shift;
  my $c = shift;

  die "intenral error";
}

# The root page (/)
# For now, redirect to our only application which is the
# Map Compare application.  In the future when we have 
# more than one app, choose a random one and redirect 
# to that.
sub index :Path :Args(0) 
{
  my $self = shift;
  my $c = shift;
  $c->response->redirect('/compare');
}

#Standard 404 error page
sub default :Path 
{
  my $self = shift;
  my $c = shift;
  
  $c->stash($c->ziyal('404'));
  $c->response->status(404);
}

# This runs before any of the other handlers, and
# sets up the default JavaScript and navigation
# links.
sub begin :Private
{
  my $self = shift;
  my $c = shift;
  
  my $ad = $c->ad;
  my $donate = $c->donate;
  my $nav = $c->nav; 
 
  $c->stash(
    js => [],
    navs => $nav,
    ad => $ad,
    donate => $donate,
  );
}

# Attempt to render a view, if needed.
sub end : ActionClass('RenderView') 
{
  my $self = shift;
  my $c = shift;
  
  return if $c->debug;
  
  my $errors = scalar @{ $c->error };
  if($errors)
  {
    $c->res->status(500);
    $c->stash($c->ziyal(500));
    $c->clear_errors;
  }
}

__PACKAGE__->meta->make_immutable;

1;
