package NX::Nebraska;

use Moose;
use Cwd ();
use NX::Ziyal ();
use NX::Nebraska::NewsItem;
use NX::Nebraska::Cache;
use feature qw( :5.10 );
use namespace::autoclean;
use Catalyst::Runtime 5.80;

our $VERSION = '0.07';
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

sub nav
{
  my $class = shift;
  state $menu = [
    [ '/app/compare'  => 'Compare'  ],
    [ '/doc/about'    => 'About'    ],
    [ '/news'         => 'News'     ],
    [ '/doc/contact'  => 'Contact'  ],
    [ '/doc/download' => 'Download' ],
  ];

  push @$menu, $_ for @_;
  
  return $menu;
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
  
  my $cache_key = 'zl:' . join('/', @_);
  
  my $cached = $class->memd->get($cache_key);
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
  
  my $doc = NX::Ziyal::ziyal2html($zl, default => $class->uri_for('/'), var => $class->ziyal_var);
  
  my @result = (
    html => $doc->html,
    title => $doc->title,
    template => 'ziyal.tt2',
  );
  
  $class->memd->set($cache_key => \@result, 60*60);
  
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
