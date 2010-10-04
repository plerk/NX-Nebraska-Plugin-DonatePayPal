package NX::Nebraska::Cache;

use strict;
use warnings;
use feature qw( :5.10 );
use constant VALUE => 0;
use constant EXPIRE => 1;

sub get_cache_object
{
  my $class = shift;
  my $memd;
  
  foreach my $try (qw( Cache::Memcached::Fast Cache::Memcached Cache::Memcached::Mock NX::Nebraska::Cache))
  {
    $memd = eval qq{
      use $try;
      new $try(\@_);
    };
    last if defined $memd;
  }
  
  return $memd;
}

sub new
{
  my $ob = shift;
  my $class = ref($ob) || $ob;
  return bless {}, $class;
}

sub get
{
  my $self = shift;
  my $key = shift;
  return undef unless defined $self->{$key};
  return undef if defined $self->{$key}->[EXPIRE] && $self->{$key}->[EXPIRE] > time;
  return $self->{$key}->[VALUE];
}

sub set
{
  my $self = shift;
  my $key = shift;
  my $value = shift;
  my $expire = shift;
  $expire += time if defined $expire;
  $self->{$key}->[VALUE] = $value;
  $self->{$key}->[EXPIRE] = $expire;
  return 1;
}

sub delete
{
  # This hasn't tested and might not work since
  # we're trying to call delete from delete. 
  # Hrm.
  my $self = shift;
  my $key = shift;
  delete $self->{$key};
}

1;