package NX::Nebraska::Import::Source::INEGI;

# The data came from
# http://en.wikipedia.org/wiki/List_of_Mexican_states_by_population
# which says the data came from 
# http://www.inegi.org.mx/
# which is the Mexican Website of the National Institute of Statistics, Geography, and Data Processing
# presumably it is accurate.  Ideally we'd snark the CSV or XLS and get the data out of that
# but navigating the website without knowing spanish is going to be tricky (volinteers anyone?)

use utf8;
use strict;
use warnings;
use feature qw( :5.10 );
use NX::Nebraska::Import::Stat::AreaMetric;
use NX::Nebraska::Import::Stat::Population::Census;
use base qw( NX::Nebraska::Import::Source );

sub fetch_data
{
}

sub import_data
{
  my $self = shift;

  my $area = new NX::Nebraska::Import::Stat::AreaMetric(year => 2010);
  my $pop_2000 = new NX::Nebraska::Import::Stat::Population::Census(year => 2000);
  my $pop_2005 = new NX::Nebraska::Import::Stat::Population::Census(year => 2005);
  my $parent = new NX::Nebraska::Import::Place(
    map_id => 'top',
    map_code => 'mx',
    name => 'Mexico', 
    parent_id => undef,
    flag => undef,
  );
  
  my $alldata = $self->data;
  while(my($name, $data) = each %$alldata)
  {
    my $save_name = $name;
    utf8::decode($name);
  
    my $place =  new NX::Nebraska::Import::Place(
      map_id => 'mx1',
      map_code => $data->{map_code},
      name => $name,
      parent_id => $parent->id,
      flag => undef,
    );
    
    $area->add_value(place => $place, value => $data->{area_km2});
    $pop_2000->add_value(place => $place, value => $data->{population_2000});
    $pop_2005->add_value(place => $place, value => $data->{population_2005});
  }
}

sub codes
{
  state $codes = {
    'Aguascalientes' => 'AGU',
    'Baja California' => 'BCN',
    'Baja California Sur' => 'BCS',
    'Campeche' => 'CAM',
    'Chiapas' => 'CHP',
    'Chihuahua' => 'CHH',
    'Coahuila' => 'COA',
    'Colima' => 'COL',
    'Districto Federal' => 'DIF',
    'Durango' => 'DUR',
    'Guanajuato' => 'GUA',
    'Guerrero' => 'GRO',
    'Hidalgo' => 'HID',
    'Jalisco' => 'JAL',
    'México' => 'MEX',
    'Michoacán' => 'MIC',
    'Morelos' => 'MOR',
    'Nayarit' => 'NAY',
    'Nuevo León' => 'NLE',
    'Oaxaca' => 'OAX',
    'Puebla' => 'PUE',
    'Querétaro' => 'QUE',
    'Quintana Roo' => 'ROO',
    'San Luis Potosí' => 'SLP',
    'Sinaloa' => 'SIN',
    'Sonora' => 'SON',
    'Tabasco' => 'TAB',
    'Tamaulipas' => 'TAM',
    'Tlaxcala' => 'TLA',
    'Veracruz' => 'VER',
    'Yucatán' => 'YUC',
    'Zacatecas' => 'ZAC',
  };
  return $codes;
}

sub english_to_spanish
{
  state $xlate = {
    'Mexico State' => 'México',
    'Federal District' => 'Districto Federal',
  };
  my $english = shift;
  my $spanish = $xlate->{$english};
  return $spanish if defined $spanish;
  return $english;
}

sub data
{
  my $self = shift;
  
  state $data;
  return $data if defined $data;
  
  $data = {};
  my $header = <DATA>; # ignore;
  while(<DATA>)
  {
    chomp;
    my(@values) = split /\t/, $_;
    for(@values) { s/^\s+//; s/\s+$//; }
    
    my($rank, $name, $population_2005, $population_2000, $area_km2) = @values;
    
    $name = english_to_spanish($name);
    
    unless(defined $self->codes->{$name})
    {
      warn "couldn't find abreviation for $name";
      next;
    }
    
    for($population_2005, $population_2000, $area_km2) { s/,//g }
    
    $data->{$name} = {
      map_code => $self->codes->{$name},
      population_2005 => $population_2005,
      population_2000 => $population_2000,
      area_km2 => $area_km2,
    };
  }
  
  return $data;
}

1;

__DATA__
Rank ? 	 State ? 	 Population (2005) ? 	 Population (2000) ? 	 km² ?
1  	 Mexico State  	 14,007,495  	 13,096,686  	 21,355
2  	 Federal District  	 8,720,916 	 8,605,239  	 1,479
3  	 Veracruz  	 7,110,214  	 6,908,975  	 71,699
4  	 Jalisco  	 6,752,113  	 6,322,002  	 80,386
5  	 Puebla  	 5,383,133  	 5,076,686  	 33,902
6  	 Guanajuato  	 4,893,812  	 4,663,032  	 30,491
7  	 Chiapas  	 4,293,459  	 3,920,892  	 74,211
8  	 Nuevo León  	 4,199,292  	 3,834,141  	 64,924
9  	 Michoacán  	 3,966,073  	 3,985,667  	 59,928
10  	 Oaxaca  	 3,506,821  	 3,438,765  	 93,952
11  	 Chihuahua  	 3,241,444  	 3,052,907  	 244,938
12  	 Guerrero  	 3,115,202  	 3,079,649  	 64,281
13  	 Tamaulipas  	 3,024,238  	 2,753,222  	 79,384
14  	 Baja California  	 2,844,469  	 2,487,367  	 69,921
15  	 Sinaloa  	 2,608,442  	 2,536,844  	 58,328
16  	 Coahuila  	 2,495,200  	 2,298,070  	 149,982
17  	 San Luis Potosí  	 2,410,414  	 2,299,360  	 63,068
18  	 Sonora  	 2,394,861  	 2,216,969  	 182,052
19  	 Hidalgo  	 2,345,514  	 2,235,591  	 20,813
20  	 Tabasco  	 1,989,969  	 1,891,829  	 25,267
21  	 Yucatán  	 1,818,948  	 1,658,210  	 38,402
22  	 Morelos  	 1,612,899  	 1,555,296  	 4,950
23  	 Querétaro  	 1,598,139  	 1,404,306  	 11,449
24  	 Durango  	 1,509,117  	 1,448,661  	 123,181
25  	 Zacatecas  	 1,367,692  	 1,353,610  	 73,252
26  	 Quintana Roo  	 1,135,309  	 874,963  	 50,212
27  	 Tlaxcala  	 1,068,207  	 962,646  	 4,016
28  	 Aguascalientes  	 1,065,416  	 944,285  	 5,471
29  	 Nayarit  	 949,684  	 920,185  	 26,979
30  	 Campeche  	 754,730  	 690,689  	 50,812
31  	 Colima  	 567,996  	 617,800  	 5,191
32  	 Baja California Sur  	 512,170  	 424,041  	 73,475
