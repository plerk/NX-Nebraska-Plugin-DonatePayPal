package NX::Nebraska::Controller::Root;

use Moose;
use feature qw( :5.10 );
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
sub internal_error :Chained('/') :PathPart('test/internal_error') :Args(0)
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
  $c->response->redirect('/app/compare');
}

sub login :Chained('/') :PathPart('login') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  # This usually happens if you click on the Login
  # button from the Login screen, thus setting 
  # $return below to /login, which really doesn't
  # make sense.  Instead of going to /login when
  # we're already logged in we redirect the user
  # back to /, which isn't as good as redirecting
  # them to where they were.
  if($c->user_exists)
  {
    $c->response->redirect('/');
    return;
  }
  
  my $username = $c->request->param('username');
  my $password = $c->request->param('password');
  my $facebook = $c->request->param('facebook');
  my $twitter  = $c->request->param('twitter');
  my $return   = $c->request->param('return');
  $return = $c->request->referer unless defined $return && $return;
  
  if(defined $twitter && $twitter)
  {
    my $realm = $c->get_auth_realm('twitter');
    $c->response->redirect( $realm->credential->authenticate_twitter_url($c) );
    return;
  }
  
  elsif(defined $facebook && $facebook)
  {
    ## This doesn't work.  So don't try and use it.
    #if ($c->authenticate(undef,'facebook')) 
    #{
    #  warn "auth redirect => $return\n";
    #  $c->response->redirect($return);
    #  return;
    #}
    #else
    #{
    #  warn "auth fail Unable to authenticate against facebook\n";
    #  $c->stash(
    #    error_msg => 'Unable to authenticate against facebook',
    #  );
    #}
    $c->response->redirect('/api/facebook?internal=1');
  }
  
  elsif(defined $username && defined $password && $username ne '' && $password ne '')
  {
    if($c->authenticate({ username => $username, password => $password }, 'nebraska')) 
    {
      $c->response->redirect($return);
      return;
    }
    else
    {
      $c->stash(
        error_msg => 'Invalid username or incorrect password',
      );
    }
  }
  
  my %realms = map { $_ => 1 } keys %{ $c->config->{'Plugin::Authentication'}->{realms} };
  
  $c->stash(
    template => 'login.tt2',
    return => $return,
    realms => \%realms, 
  );
}

sub logout :Chained('/') :PathPart('logout') :Args(0)
{
  my $self = shift;
  my $c = shift;
  $c->logout;
  $c->response->redirect($c->request->referer);
}

sub api_twitter :Chained('/') :PathPart('api/twitter') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my $return = '/';
  
  if (my $twitter_user = $c->authenticate(undef,'twitter')) 
  {
    # The auto create creats a user with name id:integer
    # so we fill in the real twitter name here.
    my $user = $twitter_user->get_object->user;
    $user->name($twitter_user->twitter_user);
    $user->update;
    $c->response->redirect($return);
  }
  else
  {
    $c->response->redirect('/login?error_msg=Unable+to+authenticate+against+twitter');
  }
}

sub api_facebook :Chained('/') :PathPart('api/facebook') :Args(0)
{
  my $self = shift;
  my $c = shift;
  my $internal = $c->request->param('internal');
  my $return = '/';
  my $is_auth = $c->authenticate(undef, 'facebook');
  if($is_auth)
  {
    $c->response->redirect($return);
  }
  else
  {
    $c->response->redirect('/login?error_msg=Unable+to+authenticate+against+facebook')
      unless defined $internal && $internal;
  }
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
    icon_name => 'icon',
    error_msg => $c->request->param('error_msg') // '',
    warning_msg => $c->request->param('warning_msg') // '',
  );
}

# Attempt to render a view, if needed.
sub end : ActionClass('RenderView') 
{
  my $self = shift;
  my $c = shift;
  
  #$c->response->headers->header(
  #  'Last-Modified' => localtime(time),
  #);
  
  return if $c->debug;
  
  my $errors = scalar @{ $c->error };
  if($errors)
  {
    # maybe dump some debugging information
    # or email the data so that we can 
    # debug issues from the production
    # website.
    $c->res->status(500);
    $c->stash($c->ziyal(500));
    $c->clear_errors;
  }
}

__PACKAGE__->meta->make_immutable;

1;
