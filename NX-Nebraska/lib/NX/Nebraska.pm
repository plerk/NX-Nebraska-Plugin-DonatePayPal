package NX::Nebraska;

use Moose;
use Cwd ();
use NX::Ziyal ();
use NX::Nebraska::NewsItem;
use NX::Nebraska::Cache;
use feature qw( :5.10 );
use namespace::autoclean;
use Catalyst::Runtime 5.80;

our $VERSION = '0.09';
$VERSION = eval $VERSION;

# Set flags and add plugins for the application
#
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw(
    ConfigLoader
    Static::Simple
    StackTrace
    Unicode::Encoding
    Authentication
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    Session::PerUser
);

extends 'Catalyst';

do {

  my $mod_location = $INC{'NX/Nebraska.pm'};
  $mod_location =~ s/NX\/Nebraska.pm$//;
  $mod_location = Cwd::abs_path($mod_location);
  
  my $found = 0;
  
  for my $try ("$mod_location/nebraska.yml", "$mod_location/../nebraska.yml", "$mod_location/../../nebraska.yml", '/etc/nebraska.yml')
  {
    if(-r $try)
    {
      warn "using config $try\n" if 0;
      __PACKAGE__->config( 'Plugin::ConfigLoader' => { file => $try } );
      $found = 1;
      last;
    }
  }
  
  __PACKAGE__->config( 'Plugin::ConfigLoader' => { file => 'nebraska.yml' })
    unless $found;

  for my $try ("$mod_location",  "$mod_location/..", '/var/lib/nebraska')
  {
    if(-d "$try/root" && -d "$try/ziyal" && -d "$try/tmpl" && -d "$try/sql")
    {
      warn "using home $try\n" if 0;
      __PACKAGE__->config(home => $try);
      __PACKAGE__->config(root => "$try/root");
      last;
    }
  }

};

sub guess_user_country_code
{
  my $self = shift;
  my $ip = shift;
  my $value = shift;
  
  if(defined $value)
  {
    return $self->session->{guess_user_country_code} = $value;
  }
  
  if(exists $self->session->{guess_user_country_code})
  {
    return $self->session->{guess_user_country_code};
  }

  state $okay;
  return undef if defined $okay && $okay == 0;

  state $gi;
  unless(defined $gi)
  {
    eval "use Geo::IP";
    $gi = eval { Geo::IP->open($self->config->{GeoIP}) };
    unless(defined $gi)
    {
      $okay = 0;
      return 0;
    }
  }
  
  my $code = $gi->country_code_by_addr($ip);
  unless(defined $code)
  {
    return $self->session->{guess_user_country_code} = undef;
  }
  
  return $self->session->{guess_user_country_code} = lc $code;
}

sub flickr
{
  my $self = shift;
  state $no_flickr = 0;
  return undef if $no_flickr;
  state $flickr;
  return $flickr if $flickr;
  
  eval "use NX::Flickr";
  warn $@ if $@;
  $flickr = NX::Flickr->new({
    key => $self->config->{Flickr}->{key},
    secret => $self->config->{Flickr}->{secret},
  });
  $flickr->api->env_proxy;
  
  if(defined $flickr)
  {
    return $flickr;
  }
  else
  {
    $no_flickr = 1;
    return undef;
  }
}

sub flickr_user
{
  my $self = shift;
  if($self->user_exists)
  {
    return $self->user->get_object->user->flickr_user;
  }
  else
  {
    return undef;
  }
}

# Trip Journal allows use by logged in users as well as anon users.
# we jump through some manual hoops here, because we want the user
# to revery to the anon user version of himself if he logs in and
# then back out again.
#
# The security on this is very poor, and needs to be fixed.
sub trip_user_id
{
  my $self = shift;
  my $args = shift // { try_real_user => 1, recycle => 0, };
  state $chars = ['a'..'z', 'A'..'Z', '0'..'9'];
  
  if($args->{recycle})
  {
    delete $self->request->cookies->{anon_trip_user};
    delete $self->request->cookies->{anon_trip_user_secret};
  }
  
  return $self->user->id if $args->{try_real_user} && $self->user_exists;

  if(exists $self->request->cookies->{anon_trip_user} && exists $self->request->cookies->{anon_trip_user_secret})
  {
    my $user_id = $self->request->cookies->{anon_trip_user}->value;
    my $secret = $self->request->cookies->{anon_trip_user_secret}->value;
    my $cache_key = join(':', 'trip_user_id', $user_id, $secret);
    my $cache_data = $self->memd->get($cache_key);
    return $cache_data if defined $cache_data;
    
    if($secret =~ /^[a-zA-Z0-9]{64}$/)
    {
      my $user = $self->model('User::UserAnon')->search({ 
        user_id => $user_id, 
        secret => $secret,
        free => 0,
      })->first;
      if(defined $user)
      {
        # towards the end of the life of the anon user (assuming
        # no memcached restarts which could happen) we only 
        # cache for 15 minutes.
        $self->memd->set($cache_key => $user_id, 15*60);
        return $user_id;
      }
    }
  }
  
  # try to use a recycled anon user first
  $self->model('User')->schema->storage->dbh_do(
    sub { $_[1]->do(qq{ LOCK TABLES user_anon AS user_anon WRITE, user_anon AS me WRITE }) },
  );
  my $auser = $self->model('User::UserAnon')->search({ free => 1 })->first;
  if(defined $auser)
  {
    $auser->free(0);
    $auser->secret(join('', map { $chars->[rand int @$chars] } 1..64));
    $auser->update;
    $self->model('User')->schema->storage->dbh_do(
      sub { $_[1]->do(qq{ UNLOCK TABLES }) },
    );
  }
  else
  {
    $self->model('User')->schema->storage->dbh_do(
      sub { $_[1]->do(qq{ UNLOCK TABLES }) },
    );
    my $realm = $self->model('User::Realm')->search({ name => 'anonymous' })->first;
    my $user = $self->model('User::User')->create({
      realm_id => $realm->id,
      name => 'rand_' . int rand 1024,
    });
    $user->name('id_' . $user->id);
    $user->update;
    $auser = $self->model('User::UserAnon')->create({
      user_id => $user->id,
      secret => join('', map { $chars->[rand int @$chars] } 1..64),
      free => 0,
    });
  }
  
  $self->response->cookies->{anon_trip_user} = {
    value => $auser->user_id,
    expires => '+6h',
  };
  
  $self->response->cookies->{anon_trip_user_secret} = {
    value => $auser->secret,
    expires => '+6h',
  };
  
  # On the initial set we set it to 5 hrs because the cookie is going to
  # be alive for at least six hours.
  my $cache_key = join(':', 'trip_user_id', $auser->user_id, $auser->secret);
  $self->memd->set($cache_key => $auser->user_id, 5*60*60);
  
  return $auser->user_id;
}

# Provider objects for ads and donate buttons.
# We're going to use AdSense and PayPal for
# the main site, but the idea is that you could
# plugin in your own providers if they don't 
# suit.
# IF they are not defined then the website should
# simply be blank in those locations.
sub ad 
{
  state $provider;

  return $provider->[0] if defined $provider;
  
  if(defined __PACKAGE__->config->{Ad})
  {
    my %ad = %{ __PACKAGE__->config->{Ad} };
    my $classname = delete $ad{classname};
    eval "use $classname";
    die $@ if $@;
    warn "using ad provider: $classname\n" if 1;
    my $ap = $classname->new(%ad);
    $provider = [ $ap ];
    return $ap;
  }
  else
  {
    $provider = [ undef ];
    return undef;
  }
}

sub donate 
{
  state $provider;
  
  return $provider->[0] if defined $provider;
  
  if(defined __PACKAGE__->config->{Donate})
  {
    my %donate = %{ __PACKAGE__->config->{Donate} };
    my $classname = delete $donate{classname};
    eval "use $classname";
    die $@ if $@;
    warn "using donate provider: $classname\n" if 1;
    my $dp = $classname->new(%donate);
    $provider = [ $dp ];
    return $dp;
  }
  else
  {
    $provider = [ undef ];
    return undef;
  }
}

sub apps
{
  my $class = shift;
  state $apps = [
    [ '/app/compare'  => 'Compare Maps' ],
    [ '/app/trip'     => 'Trip Journal' ],
  ];
  
  push @$apps, $_ for @_;
  
  return unless defined wantarray;
  
  return $apps;
}

sub app_extras
{
  my $self = shift;
  my $args = shift;
  
  my $short_app_name = $args->{short_app_name};
  my $js_list = $args->{js_list};
  my $map_list_class = $args->{map_list_class};
  
  my $cache_key = "app:$short_app_name";
  if(my $cache = $self->memd->get($cache_key))
  {
    return ($cache->{list}, $cache->{maps})
  }
  # we cache a few things here that take a while.
  
  # rendering .zl into .html is usually time consuming
  my %about_summary = $self->ziyal('doc', "about_$short_app_name");
  my %about_detail = $self->ziyal({ brief => 1, url => '/doc/about' }, 'doc', 'about');
  
  my $js = [];
  if(defined $js_list)
  {
    # this requires us to do a (very quick) disk read, but
    # but is worth caching
    $js = [ "/js/$short_app_name-$NX::Nebraska::VERSION.js" ];
    unless(-r NX::Nebraska->config->{root} . $js->[0] )
    {
      $js = $js_list;
    }
  }
  
  my $maps = [];
  if(defined $map_list_class)
  {
    # SELECT with many JOINs worth caching
    #
    # we store a hash ref with the id and name because we only
    # need the id and name, and this gets cached in memcached, 
    # and there really isn't any need to cache all the database
    # baggage that comes with it if you store the whole object.
    $maps = [ map { { id => $_->id, name => $_->name } } grep { $_->id ne 'top' } $self->model($map_list_class)->all ];
  }
  
  # store as a list for easy rolling out later
  my $cache_data = [
    about_summary => \%about_summary,
    about_detail => \%about_detail,
    available_maps => $maps,
    js => $js,
  ];
  
  if(defined $args->{sub})
  {
    push @$cache_data, $args->{sub}->();
  }
  
  $self->memd->set($cache_key => { list => $cache_data, maps => $maps }, 60*60);
  
  return ($cache_data, $maps);
}

sub nav
{
  my $class = shift;
  
  state $news_menu = [];
  state $menu = [
    [ '/app'          => 'Applications', $class->apps                   ],
    [ '/doc/about'    => 'About',
      [ [ '/doc/about'                       => 'General'               ],
        [ '/doc/about#compare_details'       => 'About Compare Maps'    ],
        [ '/doc/about#trip_details'          => 'About Trip Journal'    ],
        [ '/doc/about#browser_compatibility' => 'Browser Compatibility' ], 
        [ '/doc/about#privacy'               => 'Privacy Policy'        ],
        [ '/doc/about#contact'               => 'Contact'               ], 
        [ '/doc/about#tos'                   => 'Terms of Service'      ], ], ],
    [ '/news'         => 'News', $news_menu                             ],
    [ '/doc/download' => 'Download',
      [ [ 'https://github.com/plicease/NX-Nebraska' => 'GitHub'         ], ], ],
  ];
  
  push @$menu, $_ for @_;
  
  return unless defined wantarray;
  
  if(my $cache = $class->memd->get('menu:news'))
  {
    @$news_menu = @$cache;
  }
  else
  {
    @$news_menu = map { [ '/news/item/' . $_->id . '/view' => $_->title ] } $class->get_news;
    $class->memd->set('menu:news' => $news_menu, 15*60);
  }
  
  if($class->user_exists)
  {
    return [ @$menu, [ '/logout' => 'Logout' ] ];
  }
  else
  {
    return [ @$menu, [ '/login' => 'Login' ] ];
  }
}

# Get an instance of an object with a 
# Cache::Memcached compatible interface 
# to a memcached server.  NX::Nebraska::Cache
# will find the best available option,
# or fall back on a simple in-core
# memory cache (using a Perl hash) that
# only provides get() and set() 
# (so don't use any other functions without
# implementing them in NX::Nebraska::Cache)
sub memd
{
  my $class = shift;
  state $memd;
  return $memd if defined $memd;
  
  return $memd = NX::Nebraska::Cache->get_cache_object({
    servers => [ { address => '127.0.0.1:11211' } ],
  });
}

sub ziyal_var
{
  state %hash;
  return \%hash;
}

# Ziyal is an alternative document syntax used for
# static documents (it's not really a templating
# language, for that we use Tempalte Toolkit).
# See NX::Ziyal for more details.
#
# Because it often takes a while to render a Ziyal
# document into HTML we store them in memcached.
# At the moment these memcached object expire in
# 1 hour, although for a future TODO, it would 
# probably be better to see if the files on disk 
# have been updated.
sub ziyal
{
  my $class = shift;
  
  my $args = {};
  my $use_cache = 1;
  if(ref $_[0] eq 'HASH')
  {
    $args = shift;
    $use_cache = 0;
  }
  
  my $cache_key = 'zl:' . join('/', @_);
  
  my $cached;
  $cached = $class->memd->get($cache_key)
    if $use_cache;
  if(defined $cached)
  {
    return @{ $cached };
  }
  
  my $document = pop;
  
  my $fn = NX::Nebraska->path_to('ziyal', @_, $document . ".zl");
  die "$document not found" unless -r $fn;
  open(IN, $fn);
  my $zl = do { local $/; <IN> };
  close IN;
  
  my $doc = NX::Ziyal::ziyal2html($zl, 
    default => $class->uri_for('/'), 
    var => $class->ziyal_var, 
    %$args,
  );
  
  my @result = (
    html => $doc->html,
    title => $doc->title,
    template => 'ziyal.tt2',
  );
  
  $class->memd->set($cache_key => \@result, 60*60)
    if $use_cache;
  
  return @result;
}

# Get a list of news items (blog entries).  At the moment these are
# simply stored in the news directly as [id].zl where [id] is also
# the UNIX timestamp of the entry.  In the future it would be good
# to store this in the database, but for now we are only going to
# have a few news items.
#
# TODO: offset is not implemented yet.
#
# ARGS:
#  limit => limit the number of new items
#  offset => start at the given offset in terms of # of news items
#  id => get a single news item of the given id
sub get_news
{
  my $class = shift;
  my %args = @_;
  my $limit = $args{limit} // 10;
  my $offset = $args{offset} // 0;
  my $id = $args{id};
  my $include_working_news = $args{include_working_news} // 0;
  
  my @news_list;
  
  my $dist_news_dir = NX::Nebraska->path_to('ziyal', 'news');
  my $user_news_dir = NX::Nebraska->config->{News}->{archive_dir};
  my $temp_news_dir = NX::Nebraska->config->{News}->{working_dir};
  
  if(defined $id)
  {
    push @news_list, NX::Nebraska::NewsItem->find_by_id(
      dir_spec => [ [ $dist_news_dir, 1 ], [ $user_news_dir, 1 ], [ $temp_news_dir, 0 ] ],
      id => $id,
      c => $class,
    );
  }
  else
  {
    push @news_list, NX::Nebraska::NewsItem->get_news_from_directory(
      dir => $dist_news_dir,
      is_cached => 1,
      c => $class,
    );
    push @news_list, NX::Nebraska::NewsItem->get_news_from_directory(
      dir => $user_news_dir,
      is_cached => 1,
      c => $class,
    );
    push @news_list, NX::Nebraska::NewsItem->get_news_from_directory(
      dir => $temp_news_dir,
      is_cached => 0,
      c => $class,
    ) if $include_working_news;
    
    @news_list = sort { $b->id <=> $a->id } @news_list;
  }
  
  if($limit >= int @news_list)
  {
    return @news_list
  }
  else
  {
    return @news_list[0..$limit];
  }
}

# Configure the application.
#
# Note that settings in nx_nebraska.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
  name => 'NX::Nebraska',
  # Disable deprecated behavior needed by old applications
  disable_component_resolution_regex_fallback => 1,
  encoding => 'UTF-8',
  default_view => 'TT::HTML',
  static => {
    mime_types => {
      # These are needed by Google's svgweb
      # that we use for IE8 which does not 
      # have native SVG support.
      swf => 'application/x-shockwave-flash',
      htc => 'text/x-component',
      svg => 'image/svg+xml',
    },
  },
);

# Start the application
__PACKAGE__->setup();

1;
