package NX::Nebraska::Import::Stat;

use strict;
use warnings;
use feature qw( :5.10 );
use NX::Nebraska;

# year
sub new
{
  my $ob = shift;
  my %args = @_;
  my $class = ref($ob) || $ob;
  my $self =  bless {}, $class;
  
  $self->{stat} = NX::Nebraska->model('DB::IntegerStatistic')->search({ name => $self->name })->first;
  unless(defined $self->{stat})
  {
    $self->{stat} = NX::Nebraska->model('DB::IntegerStatistic')->create({
      name => $self->name,
      units => $self->units,
      is_primary => $self->is_primary,
    });
  }
  
  $self->{year} = $args{year};
  
  return $self;
}

sub name { die "implement" }
sub units { die "implement" }
sub is_primary { die "implement" }
sub year { shift->{year} }

sub add_value
{
  my $self = shift;
  my %args = @_;
  
  NX::Nebraska->model('DB::IntegerValue')->update_or_create({
    place_id => $args{place}->id,
    integer_statistic_id => $self->{stat}->id,
    year => $self->{year},
    value => $args{value},
  });
}

1;
