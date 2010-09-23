package NX::Nebraska::Controller::Compare;

use Moose;
use feature qw( :5.10 );
use namespace::autoclean;
use NX::Nebraska;

BEGIN {extends 'Catalyst::Controller'; }

use constant JS => [ map { "/js/NX/Nebraska/$_.js" } qw( 
  Debug 
  Map 
  PopUp 
  Ajax 
  PageLocation 
  Util 
  Place 
  Stat 
  CompareMap 
  AlgoList 
  AlgoResult 
  Compare 
  Algo/SmallestFirst 
  Algo/LargestFirst 
  Algo/Optimal 
) ];

# This is the server side code for the compare functionality.
# Most of the work is done in the JavaScript and the AJAX
# entry points in NX::Nebraska::Controller::Map
sub compare :Chained('/') :PathPart('app/compare') :Args(0) 
{
  my $self = shift;
  my $c = shift;
  
  my($news_item) = $c->get_news(limit => 1);
  
  my $cache_data;
  my $maps;
  if(my $cache = $c->memd->get('app:compare'))
  {
    $cache_data = $cache->{list};
    $maps = $cache->{maps};
  }
  else
  {
    # we cache a few things here that take a while.
    
    # rendering .zl into .html is usually time consuming
    my %about_summary = $c->ziyal('doc', 'about_compare');
    my %about_detail = $c->ziyal({ brief => 1, url => '/doc/about' }, 'doc', 'about');
    
    # this requires us to do a (very quick) disk read, but
    # but is worth caching
    my $js = [ "/js/compare-$NX::Nebraska::VERSION.js" ];
    unless(-r NX::Nebraska->config->{root} . $js->[0] )
    {
      $js = JS;
    }
    
    # SELECT with many JOINs worth caching
    $maps = [ grep { $_->id ne 'top' } $c->model('DB::MapWithValues')->all ];
    
    # store as a list for easy rolling out later
    $cache_data = [
      about_summary => \%about_summary,
      about_detail => \%about_detail,
      available_maps => $maps,
      js => $js,
    ];
    $c->memd->set('app:compare' => { list => $cache_data, maps => $maps }, 60*60);
  }

  my $input_map_code = $c->req->param('input_map_code');
  my $output_map_code = $c->req->param('output_map_code');
  
  my @rand_maps = map { $_->id } @$maps;
  
  unless(defined $input_map_code)
  {
    my $size = int @rand_maps;
    my $i = int rand $size;
    $input_map_code = splice @rand_maps, $i, 1;
  }
  unless(defined $output_map_code)
  {
    my $size = int @rand_maps;
    my $i = int rand $size;
    $output_map_code = splice @rand_maps, $i, 1;
  }
  
  die "bad input map" unless $input_map_code =~ /^[a-z][a-z]1$/;
  die "bad output map" unless $output_map_code =~ /^[a-z][a-z]1$/;
  
  $c->stash(
    news_item => $news_item,
    maps => [ 
      { 
        default => $input_map_code, 
        id => 'input', name => 'Input', 
      }, 
      { 
        default => $output_map_code, 
        id => 'output', name => 'Output' 
      } 
    ],
    template => 'compare/index.tt2',
    @$cache_data,
    icon_name => 'compare',
  );
}

sub old_compare :Chained('/') :PathPart('compare') :Args(0) 
{
  my $self = shift;
  my $c = shift;
  $c->response->redirect('/app/compare');
}

__PACKAGE__->meta->make_immutable;

1;
