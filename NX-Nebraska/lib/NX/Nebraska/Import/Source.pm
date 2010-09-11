package NX::Nebraska::Import::Source;

use strict;
use warnings;
use feature qw( :5.10 );
use LWP::UserAgent;
use File::HomeDir;

sub new
{
  my $ob = shift;
  my $class = ref($ob) || $ob;
  return bless {}, $class;
}

sub ua
{
  state $ua;
  return $ua if defined $ua;
  $ua = new LWP::UserAgent;
  $ua->env_proxy;
  return $ua;
}

sub work_area
{
  my $ob = shift;
  
  my $mod_name = ref $ob || $ob;
  $mod_name =~ s/^.*:://;
  
  state $work_area;
  if(defined $work_area)
  {
    mkdir File::HomeDir->my_home . "/.nebraska/work/$mod_name" unless -d File::HomeDir->my_home . ".nebraska/work/$mod_name";
    return $work_area . "/$mod_name";
  }
    
  mkdir File::HomeDir->my_home . "/.nebraska" unless -d File::HomeDir->my_home . ".nebraska";
  mkdir File::HomeDir->my_home . "/.nebraska/work" unless -d File::HomeDir->my_home . ".nebraska/work";
  mkdir File::HomeDir->my_home . "/.nebraska/work/$mod_name" unless -d File::HomeDir->my_home . ".nebraska/work/$mod_name";
  
  $work_area = File::HomeDir->my_home . "/.nebraska/work";
  
  return $work_area . "/$mod_name";
}

1;
