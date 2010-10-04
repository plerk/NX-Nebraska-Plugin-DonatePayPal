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
  JSON
  Compare/Place 
  Compare/Stat 
  Compare/Map 
  Compare/AlgoList 
  Compare/AlgoResult
  Compare/Main
  Compare/Algo/SmallestFirst 
  Compare/Algo/LargestFirst 
  Compare/Algo/Optimal 
) ];

# This is the server side code for the compare functionality.
# Most of the work is done in the JavaScript and the AJAX
# entry points in NX::Nebraska::Controller::Map
sub compare :Chained('/') :PathPart('app/compare') :Args(0) 
{
  my $self = shift;
  my $c = shift;
  
  my($news_item) = $c->get_news(limit => 1);
  
  my($cache_data, $maps) = $c->app_extras({
    short_app_name => 'compare',
    js_list => JS(),
    map_list_class => 'DB::MapWithValues',
  });

  my $input_map_code = $c->req->param('input_map_code');
  my $output_map_code = $c->req->param('output_map_code');
  
  my @rand_maps = map { $_->{id} } @$maps;
  
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
    icon_url => '/app/compare',
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
    template => 'app/compare.tt2',
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
