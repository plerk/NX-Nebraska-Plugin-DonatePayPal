package NX::Nebraska::Import::Source::StatisticsCanada;

use strict;
use warnings;
use feature qw( :5.10 );
use NX::Nebraska::Import::Stat::Population::Estimate;
use NX::Nebraska::Import::Stat::AreaMetric;
use base qw( NX::Nebraska::Import::Source );

# see http://www40.statcan.gc.ca/l01/cst01/demo02a-eng.htm
use constant url => 'http://www40.statcan.gc.ca/cbin/fl/cstsaveascsv.cgi?filename=demo02a-eng.htm&lan=eng';

sub local_file
{
  my $class = shift;
  state $local_file;
  return $local_file if defined $local_file;
  return $local_file = $class->work_area . "/demo02a-eng.csv";
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
  
  my @stats;
  my $years = $csv->getline(*IN);
  shift @$years;
  foreach my $year (@$years)
  {
    push @stats, new NX::Nebraska::Import::Stat::Population::Estimate(year => $year);
  }
  
  my $parent = new NX::Nebraska::Import::Place(
    map_id => 'top',
    map_code => 'ca',
    name => 'Canada', 
    parent_id => undef,
    flag => undef,
  );
  
  my $area = new NX::Nebraska::Import::Stat::AreaMetric(year => 2010);
  
  $csv->getline(*IN);
  
  while(my $row = $csv->getline(*IN))
  {
    my $name = shift @$row;
    if($name eq 'Canada')
    {
      for(my $i=0; $i<=$#stats; $i++)
      {
        use integer;
        my $num = $row->[$i];
        $num =~ s/,//g;
        $num *= 1000;
        $stats[$i]->add_value(place => $parent, value => $num);
      }
      $area->add_value(place => $parent, value => $self->data->{Canada}->{area_km2});
    }
    else
    {
      my $data = $self->data->{$name};
      next unless defined $data;
      
      my $place = new NX::Nebraska::Import::Place(
        map_id => 'ca1',
        map_code => $data->{map_code},
        name => $name,
        parent_id => $parent->id,
        flag => undef, #"us-" . lc($states{uc($name)}) . ".png",
      );
      
      for(my $i=0; $i<=$#stats; $i++)
      {
        use integer;
        my $num = $row->[$i];
        $num =~ s/,//g;
        $num *=  1000;
        $stats[$i]->add_value(place => $place, value => $num);
      }
      
      $area->add_value(place => $place, value => $data->{area_km2});
    }
  }
  
  close IN;
}

sub data
{
  state $data;
  return $data if defined $data;
  
  $data = {};
  while(<DATA>)
  {
    chomp;
    my($name, $ab, $km2, $sqmi) = split /:/;
    die "abreviation is not correct for $name" unless $ab =~ /^[A-Z][A-Z]$/ || $ab eq 'ca';
    $km2 =~ s/,//g;
    die "area km2 is not correct for $name" unless $km2 =~ /^[0-9]+$/;
    $sqmi =~ s/,//g;
    die "area sqmi is not correct for $name" unless $sqmi =~ /^[0-9]+$/;
    $data->{$name} = {
      map_code => $ab,
      area_km2 => $km2,
      area_sqmi => $sqmi,
    };
  }
  
  return $data;
}

1;

# name, abreviation, area km2, area sq mi
# the areas are from wikipedia and are not
# expected to change too much
__DATA__
Canada:ca:9093507:3510005
Newfoundland and Labrador:NL:373872:144353
Prince Edward Island:PE:5,684:2,194
Nova Scotia:NS:53,338:20,594
New Brunswick:NB:71450:27590
Quebec:QC:1,365,128:527,079
Ontario:ON:917,741:354,342
Manitoba:MB:548,360:211,720
Saskatchewan:SK:591,670:228,450
Alberta:AB:642,317:248,000
British Columbia:BC:925,186:357,216
Yukon:YT:474,391:183,163
Northwest Territories:NT:1,140,835:440,479
Nunavut:NU:1,932,255:746,048