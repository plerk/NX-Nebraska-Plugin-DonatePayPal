package NX::Nebraska::Controller::Place;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched NX::Nebraska::Controller::Place in Place.');
}

sub view :Chained('object') :PathPart('view') :Args(0)
{
  my $self = shift;
  my $c = shift;
  $c->stash(
    js => [ qw( /js/NX/Nebraska/Map.js ) ],
    map => $c->model('DB::Map')->search({ id => $c->stash->{place}->map_id })->first,
    template => 'place/view.tt2',
  );
}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1)
{
  my $self = shift;
  my $c = shift;
  my $id = shift;
  $c->stash(place => $c->stash->{resultset}->search({ id => $id })->first);
}

sub base :Chained('/') :PathPart('place') :CaptureArgs(0)
{
  my $self = shift;
  my $c = shift;
  $c->stash(resultset => $c->model('DB::Place'));
}

__PACKAGE__->meta->make_immutable;

1;
