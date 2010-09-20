package NX::Nebraska::Import::Source::USACensus;

use strict;
use warnings;
use Text::CSV_XS;
use NX::Nebraska::Import::Place;
use NX::Nebraska::Import::Stat::Population::Estimate;
use NX::Nebraska::Import::Stat::Population::Census;
use feature qw( :5.10 );
use base qw( NX::Nebraska::Import::Source );
use constant url => 'http://www.census.gov/popest/states/tables/NST-EST2009-01.csv';

my %states;

sub local_file
{
  my $class = shift;
  state $local_file;
  return $local_file if defined $local_file;
  return $local_file = $class->work_area . "/NST-EST2009-01.csv";
}

sub fetch_data
{
  my $self = shift;
  return if -e $self->local_file;
  my $response = $self->ua->get($self->url);
  if ($response->is_success) 
  {
    open(OUT, ">" . $self->local_file );
    print OUT $response->decoded_content;
    close OUT;
  }
  else
  {
    die $response->status_line; 
  }
}

sub import_data
{
  my $self = shift;
  
  my $csv = new Text::CSV_XS;
  
  open(IN, $self->local_file) || die "unable to read ", $self->local_file, " $!";
  
  $csv->getline(*IN);
  $csv->getline(*IN);
  $csv->getline(*IN);
  my $dates = $csv->getline(*IN);
  shift @$dates;
  my @stats;
  foreach my $date (@$dates)
  {
    if($date =~ /(\d+)$/)
    {
      push @stats, new NX::Nebraska::Import::Stat::Population::Estimate(year => $1);
    }
    elsif($date eq 'Census')
    {
      push @stats, new NX::Nebraska::Import::Stat::Population::Census(year => 2000);
    }
  }
  
  my $parent = new NX::Nebraska::Import::Place(
    map_id => 'top',
    map_code => 'us',
    name => 'United States of America', 
    parent_id => undef,
    flag => undef,
  );
  
  while(my $row = $csv->getline(*IN))
  {
    my $name = shift @$row;
    if($name eq 'United States')
    {
      for(my $i=0; $i<=$#stats; $i++)
      {
        my $num = $row->[$i];
        $num =~ s/,//g;
        $stats[$i]->add_value(place => $parent, value => $num);
      }
    }
    elsif($name =~ /^\.(.*)$/)
    {
      my $name = $1;
      
      my $place = new NX::Nebraska::Import::Place(
        map_id => 'us1',
        map_code => $states{uc($name)},
        name => $name,
        parent_id => $parent->id,
        flag => "us-" . lc($states{uc($name)}) . ".png",
      );
      
      for(my $i=0; $i<=$#stats;$i++)
      {
        my $num = $row->[$i];
        $num =~ s/,//g;
        $stats[$i]->add_value(place => $place, value => $num);
      }
    }
  }
  
  close IN;
}

while(<DATA>)
{
  chomp;
  s/\s+([A-Z][A-Z])$//;
  $states{$_} = $1;
}

1;

__DATA__
ALABAMA                         AL
ALASKA                          AK
AMERICAN SAMOA                  AS
ARIZONA                         AZ
ARKANSAS                        AR
CALIFORNIA                      CA
COLORADO                        CO
CONNECTICUT                     CT
DELAWARE                        DE
DISTRICT OF COLUMBIA            DC
FEDERATED STATES OF MICRONESIA  FM
FLORIDA                         FL
GEORGIA                         GA
GUAM                            GU
HAWAII                          HI
IDAHO                           ID
ILLINOIS                        IL
INDIANA                         IN
IOWA                            IA
KANSAS                          KS
KENTUCKY                        KY
LOUISIANA                       LA
MAINE                           ME
MARSHALL ISLANDS                MH
MARYLAND                        MD
MASSACHUSETTS                   MA
MICHIGAN                        MI
MINNESOTA                       MN
MISSISSIPPI                     MS
MISSOURI                        MO
MONTANA                         MT
NEBRASKA                        NE
NEVADA                          NV
NEW HAMPSHIRE                   NH
NEW JERSEY                      NJ
NEW MEXICO                      NM
NEW YORK                        NY
NORTH CAROLINA                  NC
NORTH DAKOTA                    ND
NORTHERN MARIANA ISLANDS        MP
OHIO                            OH
OKLAHOMA                        OK
OREGON                          OR
PALAU                           PW
PENNSYLVANIA                    PA
PUERTO RICO                     PR
RHODE ISLAND                    RI
SOUTH CAROLINA                  SC
SOUTH DAKOTA                    SD
TENNESSEE                       TN
TEXAS                           TX
UTAH                            UT
VERMONT                         VT
VIRGIN ISLANDS                  VI
VIRGINIA                        VA
WASHINGTON                      WA
WEST VIRGINIA                   WV
WISCONSIN                       WI
WYOMING                         WY
