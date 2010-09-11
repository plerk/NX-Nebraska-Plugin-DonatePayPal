use strict;
use warnings;
use feature qw( :5.10 );
use Test::More;

eval 'use Test::NX::JavaScript;';
if($@) { plan skip_all => 'test requires Test::NX::JavaScript' }

use_ok('NX::Nebraska');

my $js_directory = NX::Nebraska->path_to(qw( root js ));
my @js_list = findjs($js_directory);

foreach my $js ("$js_directory/NX/Nebraska/Util.js", sort @js_list)
{
  my $name = $js;
  $name =~ s/^$js_directory//;
  js_eval_file_ok($js, $name);
}

done_testing(2 + int @js_list);

sub findjs
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
      push @result, findjs("$dir/$fn");
    }
    elsif($fn =~ /\.js$/)
    {
      push @result, "$dir/$fn";
    }
  }
  
  return @result;
}
