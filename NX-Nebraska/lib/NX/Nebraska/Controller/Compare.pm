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
  my %about_summary = $c->ziyal('doc', 'about_compare');
  my %about_detail = $c->ziyal('doc', 'about');
  
  my @maps = grep { $_->id ne 'top' } $c->model('DB::MapWithValues')->all;
  
  my $input_map_code = $c->req->param('input_map_code');
  my $output_map_code = $c->req->param('output_map_code');
  
  my @rand_maps = map { $_->id } @maps;
  
  unless(defined $input_map_code)
  {
    my $size = int @rand_maps;
    my $i = int rand $size;
    $input_map_code = splice @rand_maps, $i, 1;
    use YAML ();
    #warn YAML::Dump({size => $size, i => $i, input_map_code => $input_map_code});
  }
  unless(defined $output_map_code)
  {
    my $size = int @rand_maps;
    my $i = int rand $size;
    $output_map_code = splice @rand_maps, $i, 1;
    use YAML ();
    #warn YAML::Dump({size => $size, i => $i, output_map_code => $output_map_code});
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
    available_maps => \@maps,
    template => 'compare/index.tt2',
    about_detail => \%about_detail,
    about_summary => \%about_summary,
  );
}

__PACKAGE__->meta->make_immutable;

1;
