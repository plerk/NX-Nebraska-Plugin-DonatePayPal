use strict;
use warnings;
use feature qw( :5.10 );
use Test::More;
use Test::NX::Ziyal;

use_ok('NX::Nebraska');

my $zl_directory = NX::Nebraska->path_to(qw( root ziyal ));
my @zl_list = findzl($zl_directory);

foreach my $zl (sort @zl_list)
{
  my $name = $zl;
  $name =~ s/^$zl_directory//;
  ziyal_file_ok($zl, $name);
}

done_testing(1 + int @zl_list);

sub findzl
{
  my $dir = shift;
  opendir(DIR, $dir);
  my @file_list = readdir DIR;
  closedir DIR;
  
  my @result;
  
  foreach my $fn (@file_list)
  {
    next if $fn =~ /^\..?$/;
    if(-d "$dir/$fn")
    {
      push @result, findzl("$dir/$fn");
    }
    elsif($fn =~ /\.zl$/)
    {
      push @result, "$dir/$fn";
    }
  }
  
  return @result;
}
