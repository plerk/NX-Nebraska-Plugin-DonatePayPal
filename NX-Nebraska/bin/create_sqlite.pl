#!/usr/bin/perl

BEGIN { $ENV{DBIC_TRACE} = 0 };

use strict;
use warnings;
use FindBin qw( $Bin );
use lib "$Bin/../lib";
use feature qw( :5.10 );
use NX::Nebraska::Schema;
use YAML ();
use File::Temp qw( tempdir );
use DBI;
use IPC::Run qw( run );

my $config = YAML::LoadFile("$Bin/../nebraska.yml");
print YAML::Dump($config->{'Model::DB'}->{connect_info});

say "connecting to source database ", $config->{'Model::DB'}->{connect_info}->{dsn};

my $dbh = DBI->connect(
#  $config->{'Model::DB'}->{connect_info}->{dsn},
#  $config->{'Model::DB'}->{connect_info}->{user},
#  $config->{'Model::DB'}->{connect_info}->{password},
  'dbi:mysql:database=nebraska;host=db01',
  'nebraska',
  'nebraska',
);

my $dir = tempdir( CLEANUP => 1 );

say "using temp $dir";

my $sqlite_dsn = "dbi:SQLite:dbname=$dir/data.sqlite";

say "temp database $sqlite_dsn";

my $sql_dbh;

my $schema = NX::Nebraska::Schema->connect({ 
  dbh_maker => sub 
  { 
    $sql_dbh = DBI->connect($sqlite_dsn, '', '');
    # hrm.  isn't working.
    $sql_dbh->do(qq{ PRAGMA foreign_keys = ON });
    return $sql_dbh;
  }, 
});

$schema->deploy;

foreach my $table (qw( map place integer_statistic integer_value ))
{
  my $sth_select = $dbh->prepare(qq{ SELECT * FROM $table });
  my @keys;
  my $sth_insert;
  $sth_select->execute;
  while(my $h = $sth_select->fetchrow_hashref)
  {
    unless(defined $sth_insert)
    {
      @keys = sort keys %$h;
      my $sql = "INSERT INTO $table (" . join(',', map { qq{"$_"} } @keys) . ") VALUES (" . ('?,' x ((int @keys)-1)) . "?)";
      $sth_insert = $sql_dbh->prepare($sql);
      say $sql;
    }
    my @values = map { $h->{$_} } @keys;
    #say join ',', @values;
    $sth_insert->execute(@values);
  }
}

my $cmd = [ 'sqlite3', "$dir/data.sqlite", ];
my $in = "PRAGMA foreign_keys = ON;\n.dump";
my $out;
my $err;
run $cmd, \$in, \$out, \$err;

if ($? == -1) 
{
  print "failed to execute: $!\n";
  exit 1;
}
elsif ($? & 127) 
{
  printf "child died with signal %d, %s coredump\n",
      ($? & 127),  ($? & 128) ? 'with' : 'without';
  exit 1;
}
elsif($? >> 8)
{
  printf "child exited with value %d\n", $? >> 8;
  exit 1;
}

warn "$err" if $err;

say "writing to $Bin/../sql/sqlite/data.sql";

utf8::decode($out);

open(OUT, ">$Bin/../sql/sqlite/data.sql");
binmode(OUT, ":encoding(ISO-8859-1)");
print OUT $out;
close OUT;