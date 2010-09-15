package NX::Nebraska::Controller::Map;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

# This is an interface to the maps stored in the database.
# some of this functionality is depricated and may not work.
# the things which ARE used are the three AJAX calls at the
# top here:

# /map/id/[id]/statistics get the list of statistics available
# for the given map.
sub statistics :Chained('object') :PathPart('statistics') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my @list;
  foreach my $stat ($c->stash->{map}->statistics)
  {
    # this statistics table is really a virtual view.
    # $stat->id is not by istelf unique, so we 
    # use stat_id:year instead.
    push @list, { 
      id => join(':', $stat->id, $stat->year), 
      name => $stat->name, 
      year => $stat->year, 
      units => $stat->units,
      is_primary => $stat->is_primary,
    };
  }
  
  $c->stash->{current_view} = 'JSON';
  $c->stash->{json_data} = \@list;
}

# /map/id/[id]/places get the list of places (states, territories,
# proviences, etc, what ever is appropriate for the map).
sub places :Chained('object') :PathPart('places') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my @list;
  
  foreach my $place ($c->stash->{map}->places)
  {
    push @list, {
      id => $place->id, 
      name => $place->name, 
      code => $place->map_code, 
      flag => $place->flag,
    };
  }
  
  $c->stash->{current_view} = 'JSON';
  $c->stash->{json_data} = \@list;
}

# /map/id/[id]/values/[stat_id] get the values for each place for the given
# stat_id.  Note, the stat_id is NOT the database integer_statistic.id.  It
# is "id:year".
sub values :Chained('object') :PathPart('values') :Args(1)
{
  my $self = shift;
  my $c = shift;
  my $id = shift;  # id here is 'stat_id:year'
  
  my @list;
  
  foreach my $value ($c->stash->{map}->values(split /:/, $id))
  {
    push @list, { place_id => $value->place_id, value => $value->value };
  }
  
  $c->stash->{current_view} = 'JSON';
  $c->stash->{json_data} = \@list;
}

sub index :Path: Args(0)
{
  my $self = shift;
  my $c = shift;
  $c->response->redirect($c->uri_for($self->action_for('list')));
}

sub list :Chained('base') :Args(0) 
{
  my $self = shift;
  my $c = shift;
 
  $c->stash(
    maps => [$c->stash->{resultset}
                ->search(undef, { order_by => { -asc => qw( name ) }} )
                ->all],
    js => [ qw( /js/NX/Nebraska/Map.js ) ],
    template => 'map/list.tt2',
  );
}

sub view :Chained('object') :PathPart('view') :Args(0)
{
  my $self = shift;
  my $c = shift;
  $c->stash(
    js => [ map { "/js/NX/Nebraska/$_.js" } qw( PopUp Map ) ],,
    places => [$c->model('DB::Place')->search({ map_id => $c->stash->{map}->id })->all],
    template => 'map/view.tt2',
  );
}

# subs edit and add were used as scafolding early on
# but we don't want people to be able to edit the database
# remotely for now.  So we'll just pod cut comment them out
# for now.

=pod

sub edit :Chained('object') :PathPart('edit') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my $name = $c->request->params->{name};
  my $country_code = $c->request->params->{country_code};
  
  if(defined $name || defined $country_code)
  {
    my $map = $c->stash->{map};
    $map->name($name) if defined $name;
    $map->country_code($country_code) if defined $country_code;
    $map->update;
    $c->response->redirect('/map/id/' . $map->id . "/view");
    return;
  }
  
  $c->stash(
    template => 'map/edit.tt2',
  );
}

sub add :Chained('object') :PathPart('add') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my $name = $c->request->params->{name};
  my $parent_id = $c->request->params->{parent_id};
  my $map_code = $c->request->params->{map_code};
  
  if(defined $name && defined $parent_id && defined $map_code)
  {
    my $map = $c->stash->{map};
    $parent_id = undef if $parent_id == 0;
    $c->model('DB::Place')->create({
      name => $name,
      parent_id => $parent_id,
      map_code => $map_code,
      map_id => $map->id,
    });
    $c->response->redirect('/map/id/' . $map->id . "/view");
    return;
  }
  
  $c->stash(
    places => [$c->model('DB::Place')->all],
    template => 'map/add.tt2',
  );
}

=cut

sub object :Chained('base') :PathPart('id') :CaptureArgs(1)
{
  my $self = shift;
  my $c = shift;
  my $id = shift;
  $c->stash(map => $c->stash->{resultset}->search({ id => $id })->first);
}

sub base :Chained('/') :PathPart('map') :CaptureArgs(0)
{
  my $self = shift;
  my $c = shift;
  $c->stash(resultset => $c->model('DB::Map'));
}

__PACKAGE__->meta->make_immutable;

1;
