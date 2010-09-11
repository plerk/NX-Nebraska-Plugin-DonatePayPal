package NX::Nebraska::Controller::Compare;

use Moose;
use feature qw( :5.10 );
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

# This is the server side code for the compare functionality.
# Most of the work is done in the JavaScript and the AJAX
# entry points in NX::Nebraska::Controller::Map
sub index :Path :Args(0) {
  my $self = shift;
  my $c = shift;
  
  my($news_item) = $c->get_news(limit => 1);
  my %extra = $c->ziyal('doc', 'about');
  delete $extra{template};

  $c->stash(
    news_item => $news_item,
    maps => [ 
      { 
        default => ( $c->req->param('input_map_code') // 'us1'), 
        id => 'input', name => 'Input', 
      }, 
      { 
        default => ( $c->req->param('output_map_code') // 'au1'), 
        id => 'output', name => 'Output' 
      } 
    ],
    js => [ map { "/js/NX/Nebraska/$_.js" } qw( 
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
    ) ],
    available_maps => [ $c->model('DB::MapWithValues')->all ],
    template => 'compare/index.tt2',
    extra => \%extra,
  );
}

__PACKAGE__->meta->make_immutable;

1;
