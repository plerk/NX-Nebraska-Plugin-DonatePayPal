package NX::Nebraska;

use Moose;
use POSIX ();
use Cwd ();
use JSON::XS ();
use NX::Ziyal ();
use NX::Nebraska::NewsItem;
use feature qw( :5.10 );
use namespace::autoclean;
use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application
#
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
    StackTrace
    Unicode::Encoding
/;

extends 'Catalyst';

do {

  my $mod_location = $INC{'NX/Nebraska.pm'};
  $mod_location =~ s/NX\/Nebraska.pm$//;
  $mod_location = Cwd::abs_path($mod_location);
  
  my $found = 0;
  
  for my $try ("$mod_location/nebraska.yml", "$mod_location/../nebraska.yml", '/etc/nebraska.yml')
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

our $VERSION = '0.04';
$VERSION = eval $VERSION;

# Get an instance of an object with a 
# Cache::Memcached compatible interface 
# to a memcached server.  At the moment 
# I'm using ::Fast
sub memd
{
  my $class = shift;
  state $memd;
  return $memd if defined $memd;
  require Cache::Memcached::Fast;
  return $memd = new Cache::Memcached::Fast({
    servers => [ { address => '127.0.0.1:11211' } ],
  });
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
  
  my $doc = NX::Ziyal::ziyal2html($zl, default => $class->uri_for('/'));
  
  my @result = (
    html => $doc->html,
    title => $doc->title,
    template => 'ziyal.tt2',
  );
  
  $class->memd->set($cache_key => \@result, 60*60);
  
  return @result;
}

# Generate a timestamp in the format expected by RSS
sub rss_timestamp
{
  my $class = shift;
  my $time = shift;
  return POSIX::strftime("%a, %d %b %Y %H:%M:%S GMT", gmtime $time)
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

# return a json document to the web browser.  This is 
# usually for a AJAX call.
sub json
{
  my $self = shift;
  my $object = shift;
  state $encoder;
  
  unless(defined $encoder)
  {
    # confusingly, what we want to do is set the UTF8 flag
    # on the encoder to zero / false.  This tells the encoder 
    # not to encode the UTF8 strings (flaged by Perl mind 
    # you as UTF8) that are coming from MySQL into UTF8 as
    # though they were something other than UTF8 even though
    # they are CLEARLY taged by Perl as UTF8.  Yay.
    $encoder = JSON::XS->new->utf8(0);
  }
  
  my $json = $encoder->encode($object);
  # use bytes forces length to return the length
  # of the json string in bytes instead of 
  # characters, which in Unicode are not the
  # same thing!
  use bytes;
  $self->response->content_length(length $json);
  $self->response->body($json);
  
  # FOR NOW
  # we are using text/html for the JSON content type,
  # although IT IS WRONG because the Catalyst Unicode
  # plugin only works with certain content-types,
  # including text/html.
  
  #$self->response->content_type('application/json');
  $self->response->content_type('text/html');
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
