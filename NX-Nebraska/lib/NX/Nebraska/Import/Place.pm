package NX::Nebraska::Import::Place;

use strict;
use warnings;
use feature qw( :5.10 );
use NX::Nebraska;

# map_id, map_code, name, parent, flag
sub new
{
  my $ob = shift;
  my %args = @_;
  my $class = ref($ob) || $ob;
  my $self =  bless {}, $class;
  
  $self->{place} = NX::Nebraska->model('DB::Place')->search({ map_id => $args{map_id}, map_code => $args{map_code} })->first;
  unless(defined $self->{place})
  {
    $self->{place} = NX::Nebraska->model('DB::Place')->create({
      name => $args{name},
      map_id => $args{map_id},
      map_code => $args{map_code},
      parent_id => $args{parent_id},
      flag => $args{flag},
    });
  }
  
  return $self;
}

sub id { shift->{place}->id }

1;
