package NX::Nebraska::Import::Source::GKS;

use utf8;
use strict;
use feature qw( :5.10 );
use base qw( NX::Nebraska::Import::Source );
use Spreadsheet::ParseExcel;
use NX::Nebraska::Import::Stat::AreaMetric;
use NX::Nebraska::Import::Stat::Population::Census;
use NX::Nebraska::Import::Stat::Population::FemaleCensus;
use NX::Nebraska::Import::Stat::Population::MaleCensus;

our $VERSION = '0.01';

# Russian pop data.  Source English:
# http://www.perepis2002.ru/index.html?id=87
# and Russian:
# http://www.perepis2002.ru/index.html?id=12
#
# actual XLC:
# http://www.perepis2002.ru/ct/doc/English/1-2.xls
# and
# http://www.perepis2002.ru/ct/doc/TOM_14_02.xls

sub fetch_data
{
  my $self = shift;
  
  my %files = (
    pop_english => 'http://www.perepis2002.ru/ct/doc/English/1-2.xls',
    pop_russian => 'http://www.perepis2002.ru/ct/doc/TOM_14_02.xls',
  );
  
  while(my($name, $url) = each %files)
  {
    next if -e $self->work_area . "/$name.xls";
    my $response = $self->ua->get($url);
    if($response->is_success)
    {
      open(OUT, ">" . $self->work_area . "/$name.xls");
      print OUT $response->decoded_content;
      close OUT;
    }
    else
    {
      die $response->status_line; 
    }
  }
}

sub import_data
{
  my $self = shift;
  my $parser = new Spreadsheet::ParseExcel;
  my $en = $parser->parse($self->work_area . "/pop_english.xls")->worksheet(0);
  my $ru = $parser->parse($self->work_area . "/pop_russian.xls")->worksheet(0);
  
  my $area = new NX::Nebraska::Import::Stat::AreaMetric(year => 2010);
  
  my $by_year = {
    1989 => {
      all => new NX::Nebraska::Import::Stat::Population::Census(year => 1989),
      female => new NX::Nebraska::Import::Stat::Population::FemaleCensus(year => 1989),
      male => new NX::Nebraska::Import::Stat::Population::MaleCensus(year => 1989),
    },
    2002 => {
      all => new NX::Nebraska::Import::Stat::Population::Census(year => 2002),
      female => new NX::Nebraska::Import::Stat::Population::FemaleCensus(year => 2002),
      male => new NX::Nebraska::Import::Stat::Population::MaleCensus(year => 2002),
    },
  };
  
  my $parent = new NX::Nebraska::Import::Place(
    map_id => 'top',
    map_code => 'ru',
    name => 'Russia', 
    parent_id => undef,
    flag => undef,
  );
  
  my $y = 4;
  
  my $x = {};
  foreach my $v (values %{ $self->codes->{name} })
  {
    $x->{$v} = 0;
  }
  
  my $name = $en->get_cell($y,0);
  my $ru_name = $ru->get_cell($y+1, 0);
  my @no;
  my $count = 0;
  while(defined $name)
  {
    $name = $name->value;
    $ru_name = $ru_name->value;
    last if $name eq '';
    binmode STDOUT, ":utf8";
    #say $name . " (" . $ru_name . ")";
    
    my $code = $self->codes->{name}->{$ru_name} // $self->codes->{name}->{$name};
    
    unless(defined $code)
    {
      my $tmp_ru_name = $ru_name;
      $tmp_ru_name =~ s/^Республика //;
      $code = $self->codes->{name}->{$tmp_ru_name};
      
      unless(defined $code)
      {
        $tmp_ru_name =~ s/ - .*$//;
        $code = $self->codes->{name}->{$tmp_ru_name};
      }
    }
    
    unless(defined $code)
    {
      push @no, "$name ($ru_name)";
      if($name eq 'The City of Saint-Petersburg')
      { $y += 4 }
      else
      { $y += 10 }
      $name = $en->get_cell($y,0);
      $ru_name = $ru->get_cell($y+1, 0);
      next;
    }

    $x->{$code} ++;
    $count++;
    
    my $db_name = $name; #"$name ($ru_name)";
    my $place = new NX::Nebraska::Import::Place(
      map_id => 'ru1',
      map_code => $code,
      name => $db_name, 
      parent_id => $parent->id,
      flag => undef,
    );
    
    my $pop_1989 = $en->get_cell($y+2,1)->value;
    my $pop_2002 = $en->get_cell($y+3,1)->value;
    
    unless($pop_1989 =~ /^[0-9]+$/ && $pop_2002 =~ /^[0-9]+$/)
    {
      die "bad population for $name [$pop_1989, $pop_2002]";
    }
    
    $by_year->{1989}->{all}->add_value(place => $place, value => $pop_1989);
    $by_year->{2002}->{all}->add_value(place => $place, value => $pop_1989);
    
    my $pop_1989 = $en->get_cell($y+2,2)->value;
    my $pop_2002 = $en->get_cell($y+3,2)->value;
    
    unless($pop_1989 =~ /^[0-9]+$/ && $pop_2002 =~ /^[0-9]+$/)
    {
      die "bad population for $name [$pop_1989, $pop_2002]";
    }
    
    $by_year->{1989}->{male}->add_value(place => $place, value => $pop_1989);
    $by_year->{2002}->{male}->add_value(place => $place, value => $pop_1989);
    
    my $pop_1989 = $en->get_cell($y+2,3)->value;
    my $pop_2002 = $en->get_cell($y+3,3)->value;
    
    unless($pop_1989 =~ /^[0-9]+$/ && $pop_2002 =~ /^[0-9]+$/)
    {
      die "bad population for $name [$pop_1989, $pop_2002]";
    }
    
    $by_year->{1989}->{female}->add_value(place => $place, value => $pop_1989);
    $by_year->{2002}->{female}->add_value(place => $place, value => $pop_1989);
    
    my $area_data = $self->codes->{area}->{$code};
    if(defined $area)
    {
      $area->add_value(place => $place, value => $area_data);
    }
    else
    {
      warn "no area data for $code";
    }
    
    if($name eq 'The City of Saint-Petersburg')
    { $y += 4 }
    else
    { $y += 10 }
    $name = $en->get_cell($y,0);
    $ru_name = $ru->get_cell($y+1, 0);
  }
  
  foreach my $k (keys %$x)
  {
    delete $x->{$k} if $x->{$k} == 1;
  }
  
  my $place = new NX::Nebraska::Import::Place(
    map_id => 'ru1',
    map_code => 'ZAB',
    name => 'Zabaykalsky Krai',
    parent_id => $parent->id,
    flag => undef,
  );
  
  $by_year->{2002}->{all}->add_value(place => $place, value => 1155346);
  $area->add_value(place => $place, value => 431500);
  
  #use YAML ();
  #print YAML::Dump(\@no, $x);
  #say "bad: ", int @no, " good: ", $count;
}

sub codes
{
  state $data;
  return $data if defined $data;
  
  $data = {};
  
  <DATA>; # ignore the top;
  while(<DATA>)
  {
    chomp;
    last if $_ eq '===';
    if($_ eq '---')
    {
      <DATA>; #ignore first line;
      next;
    }
    my($code, $name) = split /\t/, $_;
    $code =~ s/^RU-([A-Z]+)\s+$/$1/;
    $name =~ s/^\s+//;
    $name =~ s/\s+$//;
    $data->{name}->{$name} = $code;
  }
  
  $data->{name}->{'г. Москва'} = 'MOW';
  $data->{name}->{'г. Санкт-Петербург'} = 'SPE';
  $data->{name}->{'Кабардино-Балкарская Республика'} = 'KB';
  $data->{name}->{'Карачаево-Черкесская Республика'} = 'KC';
  $data->{name}->{'Тыва'} = 'TY';
  $data->{name}->{'Республика Башкортостан'} = 'BA';
  $data->{name}->{'Камчатская область'} = 'KAM';
  $data->{name}->{'Пермская область'} = 'PER';
  $data->{name}->{'Чеченская Республика'} = 'CE';
  $data->{name}->{'Чувашская Республика'} = 'CU';
  $data->{name}->{'Республика Саха (Якутия)'} = 'SA';
  $data->{name}->{'Удмуртская Республика'} = 'UD';
  
  <DATA>; # ignore the top line;
  while(<DATA>)
  {
    chomp;
    last if $_ eq '===';
    my @values = split /\t/, $_;
    for(@values) { s/^\s+//; s/\s+$// } 
    my($num_code, $iso_code) = @values;
    $data->{num}->{$num_code} = $iso_code;
    $data->{iso}->{$iso_code} = $num_code;
  }
  
  <DATA>; # ignore the top line;
  while(<DATA>)
  {
    chomp;
    my @values = split /\t/, $_;
    for(@values) { s/^\s+//; s/\s+$//; }
    my($code, $name, $capital, $flag, $arms, $district, $eco, $area, $population) = @values;
    $area =~ s/,//g;
    my $iso_code = $data->{num}->{$code};
    if(defined $iso_code)
    {
      $data->{area}->{$iso_code} = $area;
    }
    else
    {
      #warn "no ISO numeric mapping for $code\n";
    }
  }
  
  #   KAM       Kamchatka (Камчатская)  area NaN                431,500
  #   PER       Perm (Пермская)  area NaN                       160,600
  #   ZAB       Zabaykalsky Krai is too new                     472,300

  $data->{area}->{KAM} = 431500;
  $data->{area}->{PER} = 160600;
  $data->{area}->{ZAB} = 472300;
  
  return $data;
}

1;

# Data is copied from English and Russian Wikipedia:
#
# http://en.wikipedia.org/wiki/ISO_3166-2:RU
# http://ru.wikipedia.org/wiki/ISO_3166-2:RU
# http://www.indopedia.org/Federal_subjects_of_Russia.html
# http://en.wikipedia.org/wiki/Federal_subjects_of_Russia

__DATA__
Code↓ 	Subdivision name 1↓ 	Subdivision name 2↓ 	Subdivision category↓
RU-AD 	 Adygeya, Respublika 	Adygeja, Respublika 	republic
RU-AL 	 Altay, Respublika 	Altaj, Respublika 	republic
RU-BA 	 Bashkortostan, Respublika 	Baškortostan, Respublika 	republic
RU-BU 	 Buryatiya, Respublika 	Burjatija, Respublika 	republic
RU-CE 	 Chechenskaya Respublika 	Cecenskaja Respublika !Čečenskaja Respublika 	republic
RU-CU 	 Chuvashskaya Respublika 	Cuvašskaja Respublika !Čuvašskaja Respublika 	republic
RU-DA 	 Dagestan, Respublika 	Dagestan, Respublika 	republic
RU-IN 	 Ingushetiya, Respublika 	Ingušetija, Respublika 	republic
RU-KB 	 Kabardino-Balkarskaya Respublika 	Kabardino-Balkarskaja Respublika 	republic
RU-KL 	 Kalmykiya, Respublika 	Kalmykija, Respublika 	republic
RU-KC 	 Karachayevo-Cherkesskaya Respublika 	Karačajevo-Čerkesskaja Respublika 	republic
RU-KR 	 Kareliya, Respublika 	Karelija, Respublika 	republic
RU-KK 	 Khakasiya, Respublika 	Hakasija, Respublika 	republic
RU-KO 	 Komi, Respublika 	Komi, Respublika 	republic
RU-ME 	 Mariy El, Respublika 	Marij Èl, Respublika 	republic
RU-MO 	 Mordoviya, Respublika 	Mordovija, Respublika 	republic
RU-SA 	 Sakha, Respublika [Yakutiya] 	Saha, Respublika [Jakutija] 	republic
RU-SE 	 Severnaya Osetiya-Alaniya, Respublika 	Severnaja Osetija-Alanija, Respublika 	republic
RU-TA 	 Tatarstan, Respublika 	Tatarstan, Respublika 	republic
RU-TY 	 Tyva, Respublika [Tuva] 	Tyva, Respublika [Tuva] 	republic
RU-UD 	 Udmurtskaya Respublika 	Udmurtskaja Respublika 	republic
RU-ALT 	 Altayskiy kray 	Altajskij kraj 	administrative territory
RU-KAM 	 Kamchatskiy kray 	Kamčatskij kraj 	administrative territory
RU-KHA 	 Khabarovskiy kray 	Habarovskij kraj 	administrative territory
RU-KDA 	 Krasnodarskiy kray 	Krasnodarskij kraj 	administrative territory
RU-KYA 	 Krasnoyarskiy kray 	Krasnojarskij kraj 	administrative territory
RU-PER 	 Permskiy kray 	Permskij kraj 	administrative territory
RU-PRI 	 Primorskiy kray 	Primorskij kraj 	administrative territory
RU-STA 	 Stavropol'skiy kray 	Stavropol'skij kraj 	administrative territory
RU-ZAB 	 Zabaykal'skiy kray 	Zabajkal'skij kraj 	administrative territory
RU-AMU 	 Amurskaya oblast' 	Amurskaja oblast' 	administrative region
RU-ARK 	 Arkhangel'skaya oblast' 	Arhangel'skaja oblast' 	administrative region
RU-AST 	 Astrakhanskaya oblast' 	Astrahanskaja oblast' 	administrative region
RU-BEL 	 Belgorodskaya oblast' 	Belgorodskaja oblast' 	administrative region
RU-BRY 	 Bryanskaya oblast' 	Brjanskaja oblast' 	administrative region
RU-CHE 	 Chelyabinskaya oblast' 	Celjabinskaja oblast' !Čeljabinskaja oblast' 	administrative region
RU-IRK 	 Irkutskaya oblast' 	Irkutskaja oblast' 	administrative region
RU-IVA 	 Ivanovskaya oblast' 	Ivanovskaja oblast' 	administrative region
RU-KGD 	 Kaliningradskaya oblast' 	Kaliningradskaja oblast' 	administrative region
RU-KLU 	 Kaluzhskaya oblast' 	Kalužskaja oblast' 	administrative region
RU-KEM 	 Kemerovskaya oblast' 	Kemerovskaja oblast' 	administrative region
RU-KIR 	 Kirovskaya oblast' 	Kirovskaja oblast' 	administrative region
RU-KOS 	 Kostromskaya oblast' 	Kostromskaja oblast' 	administrative region
RU-KGN 	 Kurganskaya oblast' 	Kurganskaja oblast' 	administrative region
RU-KRS 	 Kurskaya oblast' 	Kurskaja oblast' 	administrative region
RU-LEN 	 Leningradskaya oblast' 	Leningradskaja oblast' 	administrative region
RU-LIP 	 Lipetskaya oblast' 	Lipetskaja oblast' 	administrative region
RU-MAG 	 Magadanskaya oblast' 	Magadanskaja oblast' 	administrative region
RU-MOS 	 Moskovskaya oblast' 	Moskovskaja oblast' 	administrative region
RU-MUR 	 Murmanskaya oblast' 	Murmanskaja oblast' 	administrative region
RU-NIZ 	 Nizhegorodskaya oblast' 	Nižegorodskaja oblast' 	administrative region
RU-NGR 	 Novgorodskaya oblast' 	Novgorodskaja oblast' 	administrative region
RU-NVS 	 Novosibirskaya oblast' 	Novosibirskaja oblast' 	administrative region
RU-OMS 	 Omskaya oblast' 	Omskaja oblast' 	administrative region
RU-ORE 	 Orenburgskaya oblast' 	Orenburgskaja oblast' 	administrative region
RU-ORL 	 Orlovskaya oblast' 	Orlovskaja oblast' 	administrative region
RU-PNZ 	 Penzenskaya oblast' 	Penzenskaja oblast' 	administrative region
RU-PSK 	 Pskovskaya oblast' 	Pskovskaja oblast' 	administrative region
RU-ROS 	 Rostovskaya oblast' 	Rostovskaja oblast' 	administrative region
RU-RYA 	 Ryazanskaya oblast' 	Rjazanskaja oblast' 	administrative region
RU-SAK 	 Sakhalinskaya oblast' 	Sahalinskaja oblast' 	administrative region
RU-SAM 	 Samarskaya oblast' 	Samarskaja oblast' 	administrative region
RU-SAR 	 Saratovskaya oblast' 	Saratovskaja oblast' 	administrative region
RU-SMO 	 Smolenskaya oblast' 	Smolenskaja oblast' 	administrative region
RU-SVE 	 Sverdlovskaya oblast' 	Sverdlovskaja oblast' 	administrative region
RU-TAM 	 Tambovskaya oblast' 	Tambovskaja oblast' 	administrative region
RU-TOM 	 Tomskaya oblast' 	Tomskaja oblast' 	administrative region
RU-TUL 	 Tul'skaya oblast' 	Tul'skaja oblast' 	administrative region
RU-TVE 	 Tverskaya oblast' 	Tverskaja oblast' 	administrative region
RU-TYU 	 Tyumenskaya oblast' 	Tjumenskaja oblast' 	administrative region
RU-ULY 	 Ul'yanovskaya oblast' 	Ul'janovskaja oblast' 	administrative region
RU-VLA 	 Vladimirskaya oblast' 	Vladimirskaja oblast' 	administrative region
RU-VGG 	 Volgogradskaya oblast' 	Volgogradskaja oblast' 	administrative region
RU-VLG 	 Vologodskaya oblast' 	Vologodskaja oblast' 	administrative region
RU-VOR 	 Voronezhskaya oblast' 	Voronežskaja oblast' 	administrative region
RU-YAR 	 Yaroslavskaya oblast' 	Jaroslavskaja oblast' 	administrative region
RU-MOW 	 Moskva 	Moskva 	autonomous city
RU-SPE 	 Sankt-Peterburg 	Sankt-Peterburg 	autonomous city
RU-YEV 	 Yevreyskaya avtonomnaya oblast' 	Evrejskaja avtonomnaja oblast' 	autonomous region
RU-CHU 	 Chukotskiy avtonomnyy okrug 	Cukotskij avtonomnyj okrug !Čukotskij avtonomnyj okrug 	autonomous district
RU-KHM 	 Khanty-Mansiyskiy avtonomnyy okrug-Yugra 	Hanty-Mansijskij avtonomnyj okrug-Jugra 	autonomous district
RU-NEN 	 Nenetskiy avtonomnyy okrug 	Nenetskij avtonomnyj okrug 	autonomous district
RU-YAN 	 Yamalo-Nenetskiy avtonomnyy okrug 	Jamalo-Nenetskij avtonomnyj okrug 	autonomous district
---
Код↓ 	Регион↓
RU-AD 	Адыгея
RU-AL 	Республика Алтай
RU-ALT 	Алтайский край
RU-AMU 	Амурская область
RU-ARK 	Архангельская область
RU-AST 	Астраханская область
RU-BA 	Башкирия
RU-BEL 	Белгородская область
RU-BRY 	Брянская область
RU-BU 	Бурятия
RU-CE 	Чечня
RU-CHE 	Челябинская область
RU-CHU 	Чукотский автономный округ
RU-CU 	Чувашия
RU-DA 	Дагестан
RU-IN 	Ингушетия
RU-IRK 	Иркутская область
RU-IVA 	Ивановская область
RU-KAM 	Камчатский край
RU-KB 	Кабардино-Балкария
RU-KC 	Карачаево-Черкессия
RU-KDA 	Краснодарский край
RU-KEM 	Кемеровская область
RU-KGD 	Калининградская область
RU-KGN 	Курганская область
RU-KHA 	Хабаровский край
RU-KHM 	Ханты-Мансийский автономный округ
RU-KIR 	Кировская область
RU-KK 	Хакасия
RU-KL 	Калмыкия
RU-KLU 	Калужская область
RU-KO 	Коми
RU-KOS 	Костромская область
RU-KR 	Карелия
RU-KRS 	Курская область
RU-KYA 	Красноярский край
RU-LEN 	Ленинградская область
RU-LIP 	Липецкая область
RU-MAG 	Магаданская область
RU-ME 	Марий Эл
RU-MO 	Мордовия
RU-MOS 	Московская область
RU-MOW 	Москва
RU-MUR 	Мурманская область
RU-NEN 	Ненецкий автономный округ
RU-NGR 	Новгородская область
RU-NIZ 	Нижегородская область
RU-NVS 	Новосибирская область
RU-OMS 	Омская область
RU-ORE 	Оренбургская область
RU-ORL 	Орловская область
RU-PER 	Пермский край
RU-PNZ 	Пензенская область
RU-PRI 	Приморский край
RU-PSK 	Псковская область
RU-ROS 	Ростовская область
RU-RYA 	Рязанская область
RU-SA 	Якутия
RU-SAK 	Сахалинская область
RU-SAM 	Самарская область
RU-SAR 	Саратовская область
RU-SE 	Северная Осетия
RU-SMO 	Смоленская область
RU-SPE 	Санкт-Петербург
RU-STA 	Ставропольский край
RU-SVE 	Свердловская область
RU-TA 	Татарстан
RU-TAM 	Тамбовская область
RU-TOM 	Томская область
RU-TUL 	Тульская область
RU-TVE 	Тверская область
RU-TY 	Тува
RU-TYU 	Тюменская область
RU-UD 	Удмуртия
RU-ULY 	Ульяновская область
RU-VGG 	Волгоградская область
RU-VLA 	Владимирская область
RU-VLG 	Вологодская область
RU-VOR 	Воронежская область
RU-YAN 	Ямало-Ненецкий автономный округ
RU-YAR 	Ярославская область
RU-YEV 	Еврейская автономная область
RU-ZAB 	Забайкальский край
===
No.	Abbr.	Subject of the federation	Capital city	Federal district	Economic region Republics - республики - respubliki
01 	AD 	Adygeya (Адыгея) 	Maykop (Майкоп) 	Southern 	North Caucasus
02 	BA 	Bashkortostan (Башкортостан) 	Ufa (Уфа) 	Privolzhsky (Volga) 	Urals
03 	BU 	Buryatia (Бурятия) 	Ulan-Ude (Улан-Удэ) 	Siberian 	East Siberia
04 	AL 	Altai Republic (Алтай) 	Gorno-Altaysk (Горно-Алтайск) 	Siberian 	West Siberia
05 	DA 	Dagestan (Дагестан) 	Makhachkala (Махачкала) 	Southern 	North Caucasus
06 	IN 	Ingushetia (Ингушская) 	Magas (Магас) 	Southern 	North Caucasus
07 	KB 	Kabardino-Balkaria (Кабардино-Балкарская) 	Nalchik (Нальчик) 	Southern 	North Caucasus
08 	KL 	Kalmykia (Калмыкия) 	Elista (Элиста) 	Southern 	Povolzhye
09 	KC 	Karachay-Cherkessia (Карачаево-Черкесская) 	Cherkessk (Черкесск) 	Southern 	North Caucasus
10 	KR 	Karelia (Карелия) 	Petrozavodsk (Петрозаводск) 	Northwestern 	North
11 	KO 	Komi (Коми) 	Syktyvkar (Сыктывкар) 	Northwestern 	North
12 	ME 	Mari El (Марий-Эл) 	Yoshkar-Ola (Йошкар-Ола) 	Privolzhsky (Volga) 	Volga-Vyatka
13 	MO 	Mordovia (Мордовия) 	Saransk (Саранск) 	Privolzhsky (Volga) 	Volga-Vyatka
14 	SA 	Sakha (Yakutia) (Саха (Якутия)) 	Yakutsk (Якутск) 	Far Eastern 	Far East
15 	SE 	North Ossetia (Alania) (Северная Осетия) 	Vladikavkaz (Владикавказ) 	Southern 	North Caucasus
16 	TA 	Tatarstan (Татарстан) 	Kazan (Казань; Tatar: Qazan) 	Privolzhsky (Volga) 	Povolzhye
17 	TY 	Tuva (Тува) 	Kyzyl (Кызыл) 	Siberian 	West Siberia
18 	UD 	Udmurtia (Удмуртская) 	Izhevsk (Ижевск) 	Privolzhsky (Volga) 	Urals
19 	KK 	Khakassia (Хакасия) 	Abakan (Абакан) 	Siberian 	West Siberia
20 	CE 	Chechnya (Чеченская) 	Grozny (Грозный) 	Southern 	North Caucasus
21 	CU 	Chuvashia (Чувашская (Чаваш)) 	Cheboksary (Чебоксары) 	Privolzhsky (Volga) 	Volga-Vyatka Territories - края - kraya
22 	ALT 	Altai Krai (Алтайский) 	Barnaul (Барнаул) 	Siberian 	West Siberia
23 	KDA 	Krasnodar (Краснодарский) 	Krasnodar (Краснодар) 	Southern 	North Caucasus
24 	KYA 	Krasnoyarsk (Красноярский) 	Krasnoyarsk (Красноярск) 	Siberian 	East Siberia
25 	PRI 	Primorsky (Приморский) 	Vladivostok (Владивосток) 	Far Eastern 	Far East
26 	STA 	Stavropol (Ставропольский) 	Stavropol (Ставрополь) 	Southern 	North Caucasus
27 	KHA 	Khabarovsk (Хабаровский) 	Khabarovsk (Хабаровск) 	Far Eastern 	Far East Provinces - области - oblasti
28 	AMU 	Amur (Амурская) 	Blagoveshchensk (Благовещенск) 	Far Eastern 	Far East
29 	ARK 	Arkhangelsk (Архангельская) 	Arkhangelsk (Архангельск) 	Northwestern 	North
30 	AST 	Astrakhan (Астраханская) 	Astrakhan (Астрахань) 	Southern 	Povolzhye
31 	BEL 	Belgorod (Белгородская) 	Belgorod (Белгород) 	Central 	Central-Chernozem
32 	BRY 	Bryansk (Брянская) 	Bryansk (Брянск) 	Central 	Central
33 	VLA 	Vladimir (Владимирская) 	Vladimir (Владимир) 	Central 	Central
34 	VGG 	Volgograd (Волгоградская) 	Volgograd (Волгоград) 	Southern 	Povolzhye
35 	VLG 	Vologda (Вологодская) 	Vologda (Вологда) 	Northwestern 	North
36 	VOR 	Voronezh (Воронежская) 	Voronezh (Воронеж) 	Central 	Central-Chernozem
37 	IVA 	Ivanovo (Ивановская) 	Ivanovo (Иваново) 	Central 	Central
38 	IRK 	Irkutsk (Иркутская) 	Irkutsk (Иркутск) 	Siberian 	East Siberia
39 	KGD 	Kaliningrad (Калининградская) 	Kaliningrad (Калининград) 	Northwestern 	Northwest
40 	KLU 	Kaluga (Калужская) 	Kaluga (Калуга) 	Central 	Central
41 	KAM 	Kamchatka (Камчатская) 	Petropavlovsk-Kamchatsky (Петропавловск-Камчатский) 	Far Eastern 	Far East
42 	KEM 	Kemerovo (Кемеровская) 	Kemerovo (Кемерово) 	Siberian 	West Siberia
43 	KIR 	Kirov (Кировская) 	Kirov (Киров) 	Privolzhsky (Volga) 	Volga-Vyatka
44 	KOS 	Kostroma (Костромская) 	Kostroma (Кострома) 	Central 	Central
45 	KGN 	Kurgan (Курганская) 	Kurgan (Курган) 	Urals 	Urals
46 	KRS 	Kursk (Курская) 	Kursk (Курск) 	Central 	Central-Chernozem
47 	LEN 	Leningrad (Ленинградская) 	St. Petersburg (Санкт-Петербург) 	Northwestern 	Northwest
48 	LIP 	Lipetsk (Липецкая) 	Lipetsk (Липецк) 	Central 	Central-Chernozem
49 	MAG 	Magadan (Магаданская) 	Magadan (Магадан) 	Far Eastern 	Far East
50 	MOS 	Moscow (Московская) 	Moscow (Москва) 	Central 	Central
51 	MUR 	Murmansk (Мурманская) 	Murmansk (Мурманск) 	Northwestern 	North
52 	NIZ 	Nizhny Novgorod (Нижегородская) 	Nizhny Novgorod (Нижний Новгород) 	Privolzhsky (Volga) 	Volga-Vyatka
53 	NGR 	Novgorod (Новгородская) 	Novgorod (Новгород) 	Northwestern 	Northwest
54 	NVS 	Novosibirsk (Новосибирская) 	Novosibirsk (Новосибирск) 	Siberian 	West Siberia
55 	OMS 	Omsk (Омская) 	Omsk (Омск) 	Siberian 	West Siberia
56 	ORE 	Orenburg (Оренбургская) 	Orenburg (Оренбург) 	Privolzhsky (Volga) 	Urals
57 	ORL 	Oryol (Орловская) 	Oryol (Орёл) 	Central 	Central
58 	PNZ 	Penza (Пензенская) 	Penza (Пенза) 	Privolzhsky (Volga) 	Povolzhye
59 	PER 	Perm (Пермская) 	Perm (Пермь) 	Privolzhsky (Volga) 	Urals
60 	PSK 	Pskov (Псковская) 	Pskov (Псков) 	Northwestern 	Northwest
61 	ROS 	Rostov (Ростовская) 	Rostov-na-Donu (Ростов) 	Southern 	North Caucasus
62 	RYA 	Ryazan (Рязанская) 	Ryazan (Рязань) 	Central 	Central
63 	SAM 	Samara (Самарская) 	Samara, Russia (Самара) 	Privolzhsky (Volga) 	Povolzhye
64 	SAR 	Saratov (Саратовская) 	Saratov (Саратов) 	Privolzhsky (Volga) 	Povolzhye
65 	SAK 	Sakhalin (Сахалинская) 	Yuzhno-Sakhalinsk (Южно-Сахалинск) 	Far Eastern 	Far East
66 	SVE 	Sverdlovsk (Свердловская) 	Yekaterinburg (Екатеринбург) 	Urals 	Urals
67 	SMO 	Smolensk (Смоленская) 	Smolensk (Смоленск) 	Central 	Central
68 	TAM 	Tambov (Тамбовская) 	Tambov (Тамбов) 	Central 	Central-Chernozem
69 	TVE 	Tver (Тверская) 	Tver (Тверь) 	Central 	Central
70 	TOM 	Tomsk (Томская) 	Tomsk (Томск) 	Siberian 	West Siberia
71 	TUL 	Tula (Тульская) 	Tula (Тула) 	Central 	Central
72 	TYU 	Tyumen (Тюменская) 	Tyumen (Тюмень) 	Urals 	West Siberia
73 	ULY 	Ulyanovsk (Ульяновская) 	Ulyanovsk (Ульяновск) 	Privolzhsky (Volga) 	Povolzhye
74 	CHE 	Chelyabinsk (Челябинская) 	Chelyabinsk (Челябинск) 	Urals 	Urals
75 	CHI 	Chita (Читинская) 	Chita (Чита) 	Siberian 	East Siberia
76 	YAR 	Yaroslavl (Ярославская) 	Yaroslavl (Ярославль) 	Central 	Central Federal cities - федеральные города - federalnyye goroda
77 	MOW 	Moscow (Москва) 	Central 	Central
78 	SPE 	St. Petersburg (Санкт-Петербург) 	Northwestern 	Northwest Autonomous oblast - автономная область - avtonomnaya oblast
79 	YEV 	Jewish (Еврейская) 	Birobidzhan (Биробиджан) 	Far Eastern 	Far East Autonomous districts - автономные округа - avtonomnyye okruga
80 	AGB 	Aga Buryatia (Агинский-Бурятский) 	Aginskoye (Агинское) 	Siberian 	East Siberia
81 	KOP 	Permyakia (Коми-Пермяцкий) 	Kudymkar (Кудымкар) 	Privolzhsky (Volga) 	Urals
82 	KOR 	Koryakia (Корякский) 	Palana (Палана) 	Far Eastern 	Far East
83 	NEN 	Nenetsia (Ненецкий) 	Naryan-Mar (Нарьян-Мар) 	Northwestern 	North
84 	TAY 	Taymyria (Таймырский (Долгано-Ненецкий)) 	Dudinka (Дудинка) 	Siberian 	East Siberia
85 	UOB 	Ust-Orda Buryatia (Усть-Ордынский Бурятский) 	Ust-Ordynsky (Усть-Ордынский) 	Siberian 	East Siberia
86 	KHM 	Khantia-Mansia (Ханты-Мансийский) 	Khanty-Mansiysk (Ханты-Мансийск) 	Urals 	West Siberia
87 	CHU 	Chukotka (Чукотский) 	Anadyr (Анадырь) 	Far Eastern 	Far East
88 	EVE 	Evenkia (Эвенкийский) 	Tura (Тура) 	Siberian 	East Siberia
89 	YAN 	Yamalia (Ямало-Ненецкий) 	Salekhard (Салехард) 	Urals 	West Siberia 
===
Code↓ 	Name↓ 	Capital/administrative centre (Largest city given if not capital)↓ 	Flag 	Coat of arms 	Federal district↓ 	Economic region↓ 	Area (km²)[2]↓ 	Population[3]↓
01 	Republic of Adygea 	Maykop 	Flag of Adygea.svg 	Adygeya - Coat of Arms.png 	Southern 	North Caucasus 	7,600 	447,109
02 	Republic of Bashkortostan 	Ufa 	Flag of Bashkortostan.svg 	Coat of Amrs of Bashkortostan.svg 	Volga 	Urals 	143,600 	4,104,336
03 	Republic of Buryatia 	Ulan-Ude 	Flag of Buryatia.svg 	Coat of Arms of Buryatiya.svg 	Siberian 	East Siberian 	351,300 	981,238
04 	Altai Republic 	Gorno-Altaysk 	Flag of Altai Republic.svg 	Coat of Arms of Altai Republic.png 	Siberian 	West Siberian 	92,600 	202,947
05 	Republic of Dagestan 	Makhachkala 	Flag of Dagestan.svg 	Coat of Arms of Dagestan.svg 	North Caucasian 	North Caucasus 	50,300 	2,576,531
06 	Republic of Ingushetia 	Magas (Largest city: Nazran) 	Flag of Ingushetia.svg 	Coat of Arms of Ingushetia.svg 	North Caucasian 	North Caucasus 	4,000 	467,294
07 	Kabardino-Balkar Republic 	Nalchik 	Flag of Kabardino-Balkaria.svg 	Coat of Arms of Kabardino-Balkaria.svg 	North Caucasian 	North Caucasus 	12,500 	901,494
08 	Republic of Kalmykia 	Elista 	Flag of Kalmykia.svg 	Coat of Arms of Kalmykia.svg 	Southern 	Volga 	76,100 	292,410
09 	Karachay-Cherkess Republic 	Cherkessk 	Flag of Karachay-Cherkessia.svg 	Coat of Arms of Karachay-Cherkessia.svg 	North Caucasian 	North Caucasus 	14,100 	439,470
10 	Republic of Karelia 	Petrozavodsk 	Flag of Karelia.svg 	Coat of Arms of Republic of Karelia.svg 	Northwestern 	Northern 	172,400 	716,281
11 	Komi Republic 	Syktyvkar 	Flag of Komi.svg 	Coat of Arms of the Komi Republic.svg 	Northwestern 	Northern 	415,900 	1,018,674
12 	Mari El Republic 	Yoshkar-Ola 	Flag of Mari El.svg 	Coat of Arms of Mari El.svg 	Volga 	Volga-Vyatka 	23,200 	727,979
13 	Republic of Mordovia 	Saransk 	Flag of Mordovia.svg 	Coat of Arms of Mordovia.svg 	Volga 	Volga-Vyatka 	26,200 	888,766
14 	Sakha (Yakutia) Republic 	Yakutsk 	Flag of Sakha.svg 	Coat of Arms of Sakha (Yakutia).png 	Far Eastern 	Far Eastern 	3,103,200 	949,280
15 	Republic of North Ossetia-Alania 	Vladikavkaz 	Flag of North Ossetia.svg 	Coat of Arms of North Ossetia-Alania.png 	North Caucasian 	North Caucasus 	8,000 	710,275
16 	Republic of Tatarstan 	Kazan 	Flag of Tatarstan.svg 	Coat of Arms of Tatarstan.svg 	Volga 	Volga 	68,000 	3,779,265
17 	Tuva Republic 	Kyzyl 	Flag of Tuva.svg 	Coat of arms of Tuva.svg 	Siberian 	East Siberian 	170,500 	305,510
18 	Udmurt Republic 	Izhevsk 	Flag of Udmurtia.svg 	Coat of arms of Udmurtia.svg 	Volga 	Urals 	42,100 	1,570,316
19 	Republic of Khakassia 	Abakan 	Flag of Khakassia.svg 	Coat of arms of Khakassia .svg 	Siberian 	East Siberian 	61,900 	546,072
20 	Chechen Republic 	Grozny 	Flag of Chechen Republic since 2004.svg 	Coat of arms of Chechnya.svg 	North Caucasian 	North Caucasus 	15,300 	1,103,686
21 	Chuvash Republic 	Cheboksary 	Flag of Chuvashia.svg 	Coat of Arms of Chuvashia.svg 	Volga 	Volga-Vyatka 	18,300 	1,313,754
22 	Altai Krai 	Barnaul 	Flag of Altai Krai.png 	Coat of Arms of Altai Krai.svg 	Siberian 	West Siberian 	169,100 	2,607,426
92 	Zabaykalsky Krai 	Chita 	Flag of Zabaykalsky Krai.svg 	Chita Oblast coat of arms.jpg 	Siberian 	East Siberian 	431,500 	1,155,346
91 	Kamchatka Krai 	Petropavlovsk-Kamchatsky 	Flag of Kamchatka Krai.svg 	Coat of Arms of Kamchatka Krai.svg 	Far Eastern 	Far Eastern 	472,300 	358,801
23 	Krasnodar Krai 	Krasnodar 	Flag of Krasnodar Krai.png 	Coat of Arms of Krasnodar kray.png 	Southern 	North Caucasus 	76,000 	5,125,221
24 	Krasnoyarsk Krai 	Krasnoyarsk 	KrasnoyarskKray-Flag.svg 	Coat of arms of Krasnoyarsk Krai.svg 	Siberian 	East Siberian 	2,339,700 	2,966,042
90 	Perm Krai 	Perm 	Perm Oblast Flag.gif 	Coat of Arms of Perm.svg 	Volga 	Urals 	160,600 	2,819,421
25 	Primorsky Krai 	Vladivostok 	Flag of Primorsky Krai.svg 	Coat of arms of Primorsky Krai.svg 	Far Eastern 	Far Eastern 	165,900 	2,071,210
26 	Stavropol Krai 	Stavropol 	Flag of Stavropol Krai.png 	Coat of Arms of Stavropol kray.png 	North Caucasian 	North Caucasus 	66,500 	2,735,139
27 	Khabarovsk Krai 	Khabarovsk 	Flag of Khabarovsk Krai.svg 	Coat of Arms of Khabarovsky kray (N2).png 	Far Eastern 	Far Eastern 	788,600 	1,436,570
28 	Amur Oblast 	Blagoveshchensk 	Flag of Amur Oblast.svg 	Coat of Arms of Amur oblast.png 	Far Eastern 	Far Eastern 	363,700 	902,844
29 	Arkhangelsk Oblast 	Arkhangelsk 	Flag of Arkhangelsk Oblast.png 	Coat of Arms of Arkhangelsk oblast (2003).png 	Northwestern 	Northern 	587,400 	1,336,539
30 	Astrakhan Oblast 	Astrakhan 	Flag of Astrakhan Oblast.svg 	Coat of Arms of Astrakhan Oblast.png 	Southern 	Volga 	44,100 	1,005,276
31 	Belgorod Oblast 	Belgorod 	Flag of Belgorod Oblast.png 	Герб Белгородской области.gif 	Central 	Central Black Earth 	27,100 	1,511,620
32 	Bryansk Oblast 	Bryansk 	Flag of Bryansk Oblast.png 	Coat of arms of Bryansk Oblast.jpg 	Central 	Central 	34,900 	1,378,941
33 	Vladimir Oblast 	Vladimir 	Flag of Vladimiri Oblast.gif 	Coat of arms of Vladimiri Oblast.png 	Central 	Central 	29,000 	1,523,990
34 	Volgograd Oblast 	Volgograd 	Flag of Volgograd Oblast.svg 	Coat of Arms of Volgograd oblast.png 	Southern 	Volga 	113,900 	2,699,223
35 	Vologda Oblast 	Vologda (Largest city: Cherepovets) 	Flag of Vologda Oblast.png 	Coat of Arms of Vologda oblast.png 	Northwestern 	Northern 	145,700 	1,269,568
36 	Voronezh Oblast 	Voronezh 	Flag of Voronezh Oblast.svg 	Coat of Arms of Voronezh oblast (2005).png 	Central 	Central Black Earth 	52,400 	2,378,803
37 	Ivanovo Oblast 	Ivanovo 	Flag of Ivanovo Oblast.png 	Coat of Arms of Ivanovo oblast.png 	Central 	Central 	21,800 	1,148,329
38 	Irkutsk Oblast 	Irkutsk 	Flag of Irkutsk Oblast.png 	Coat of arms of Irkutsk Oblast.png 	Siberian 	East Siberian 	767,900 	2,581,705
39 	Kaliningrad Oblast 	Kaliningrad 	Flag of Kaliningrad Oblast.png 	Kaliningrad Oblast Coat of Arms 2006.svg 	Northwestern 	Kaliningrad 	15,100 	955,281
40 	Kaluga Oblast 	Kaluga 	Flag of Kaluga Oblast.png 	Gerb kalug obl.png 	Central 	Central 	29,900 	1,041,641
42 	Kemerovo Oblast 	Kemerovo (Largest city: Novokuznetsk) 	Flag of Kemerovo oblast.gif 	Coat of arms of Kemerovo Oblast.png 	Siberian 	West Siberian 	95,500 	2,899,142
43 	Kirov Oblast 	Kirov 	Kirov Oblast Flag.gif 	Kirov COA.gif 	Volga 	Volga-Vyatka 	120,800 	1,503,529
44 	Kostroma Oblast 	Kostroma 	Flag of kostroma oblast.gif 	Coat of arms of Kostroma oblast.gif 	Central 	Central 	60,100 	736,641
45 	Kurgan Oblast 	Kurgan 	Flag of Kurgan Oblast.svg 	Coat of Arms of Kurgan oblast.png 	Urals 	Urals 	71,000 	1,019,532
46 	Kursk Oblast 	Kursk 	Flag of Kursk Oblast.png 	Coat of Arms of Kursk oblast.png 	Central 	Central Black Earth 	29,800 	1,235,091
47 	Leningrad Oblast 	Largest city: Gatchina[a] 	Flag of Leningrad Oblast.svg 	Coat of arms of Leningrad Oblast.svg 	Northwestern 	Northwestern 	84,500 	1,669,205
48 	Lipetsk Oblast 	Lipetsk 	Flag of Lipetsk Oblast.gif 	Coat of Arms of Lipetsk oblast.png 	Central 	Central Black Earth 	24,100 	1,213,499
49 	Magadan Oblast 	Magadan 	Flag of Magadan Oblast.png 	Coat of Arms of Magadan oblast.png 	Far Eastern 	Far Eastern 	461,400 	182,726
50 	Moscow Oblast 	Largest city: Balashikha[b] 	Flag of Moscow Oblast.png 	Coat of Arms of Moscow oblast.png 	Central 	Central 	45,900 	6,618,538
51 	Murmansk Oblast 	Murmansk 	Flag of Murmansk Oblast.svg 	Coat of Arms of Murmansk oblast (2004).png 	Northwestern 	Northern 	144,900 	892,534
52 	Nizhny Novgorod Oblast 	Nizhny Novgorod 	Flag of Nizhny Novgorod Region.svg 	Coat of Arms of Nizhniy Novgorod Oblast.png 	Volga 	Volga-Vyatka 	76,900 	3,524,028
53 	Novgorod Oblast 	Veliky Novgorod 	Flag of Novgorod oblast.png 	Novgorodi oblasti vapp.gif 	Northwestern 	Northwestern 	55,300 	694,355
54 	Novosibirsk Oblast 	Novosibirsk 	Flag of Novosibirsk Oblast.gif 	Coat of arms of Novosibirsk Oblast.gif 	Siberian 	West Siberian 	178,200 	2,692,251
55 	Omsk Oblast 	Omsk 	Flag of Omsk Oblast.svg 	Coat of arms of Omsk Oblast.png 	Siberian 	West Siberian 	139,700 	2,079,220
56 	Orenburg Oblast 	Orenburg 	Flag of Orenburg Oblast.png 	Coat of Arms of Orenburg oblast.png 	Volga 	Urals 	124,000 	2,179,551
57 	Oryol Oblast 	Oryol 	Flag of Oryol Oblast.png 	Coat of arms of Oryol Oblast.gif 	Central 	Central 	24,700 	860,262
58 	Penza Oblast 	Penza 	Flag of Penza Oblast.png 	Coat of Arms of Penza oblast.png 	Volga 	Volga 	43,200 	1,452,941
60 	Pskov Oblast 	Pskov 	Flag of None.svg 	Coat of Arms of Pskov oblast.png 	Northwestern 	Northwestern 	55,300 	760,810
61 	Rostov Oblast 	Rostov-on-Don 	Flag of Rostov Oblast.svg 	Rostov oblast coa.png 	Southern 	North Caucasus 	100,800 	4,404,013
62 	Ryazan Oblast 	Ryazan 	Flag of Ryazan Oblast.png 	Coat of Arms of Ryazan oblast.png 	Central 	Central 	39,600 	1,227,910
63 	Samara Oblast 	Samara 	Flag of Samara Oblast.svg 	Coat of Arms of Samara oblast.png 	Volga 	Volga 	53,600 	3,239,737
64 	Saratov Oblast 	Saratov 	Flag of Saratov Oblast.png 	Coat of Arms of Saratov oblast.png 	Volga 	Volga 	100,200 	2,668,310
65 	Sakhalin Oblast 	Yuzhno-Sakhalinsk 	Flag of Sakhalin Oblast.svg 	Sakhalin Oblast Coat of Arms.png 	Far Eastern 	Far Eastern 	87,100 	546,695
66 	Sverdlovsk Oblast 	Yekaterinburg 	Flag of Sverdlovsk Oblast.svg 	Coat of Arms of Sverdlovsk oblast (2005).png 	Urals 	Urals 	194,800 	4,486,214
67 	Smolensk Oblast 	Smolensk 	Flag of Smolensk Oblast.png 	Coat of arms of Smolenskaya Oblast.png 	Central 	Central 	49,800 	1,049,574
68 	Tambov Oblast 	Tambov 	Flag of Tambov Oblast.svg 	Coat of arms of Tambovskaya Oblast.png 	Central 	Central Black Earth 	34,300 	1,178,443
69 	Tver Oblast 	Tver 	Flag of Tver Oblast.png 	Coat of Arms of Tver oblast.png 	Central 	Central 	84,100 	1,471,459
70 	Tomsk Oblast 	Tomsk 	TomskOblastFlag.png 	Coat of arms of Tomsk Oblast.png 	Siberian 	West Siberian 	316,900 	1,046,039
71 	Tula Oblast 	Tula 	Flag of Tula Oblast.svg 	Coat of Arms of Tula oblast.png 	Central 	Central 	25,700 	1,675,758
72 	Tyumen Oblast 	Tyumen 	Flag of Tyumen Oblast.svg 	Coat of arms of Tyumen Oblast.svg 	Urals 	West Siberian 	1,435,200 	3,264,841
73 	Ulyanovsk Oblast 	Ulyanovsk 	Flag of Ulyanovsk Oblast.png 	Coat of Arms of Ulyanovsk Oblast.png 	Volga 	Volga 	37,300 	1,382,811
74 	Chelyabinsk Oblast 	Chelyabinsk 	Flag of Chelyabinsk Oblast.svg 	Coat of arms of Chelyabinsk Oblast.svg 	Urals 	Urals 	87,900 	3,603,339
76 	Yaroslavl Oblast 	Yaroslavl 	Flag of Yaroslavl Oblast.png 	Coat of arms of Yaroslavl Oblast.png 	Central 	Central 	36,400 	1,367,398
77 	Moscow 	— 	Flag of Moscow (Russia).png 	Coat of Arms of Moscow.png 	Central 	Central 	1,100 	10,382,754
78 	Saint Petersburg 	— 	Flag of St Petersburg (Russia).png 	Coat of Arms of Saint Petersburg (2003).png 	Northwestern 	Northwestern 	1,439 	4,662,547
79 	Jewish Autonomous Oblast 	Birobidzhan 	Flag of the Jewish Autonomous Oblast.svg 	Coat of Arms of Jewish AO.png 	Far Eastern 	Far Eastern 	36,000 	190,915
83 	Nenets Autonomous Okrug 	Naryan-Mar 	Flag of Nenets Autonomous District.svg 	Coat of Arms of Nenetsia.png 	Northwestern 	Northern 	176,700 	41,546
86 	Khanty-Mansi Autonomous Okrug-Yugra 	Khanty-Mansiysk (Largest city: Surgut) 	Flag of Yugra.svg 	Coat of Arms of Khanty-Mansia.png 	Urals 	West Siberian 	523,100 	1,432,817
87 	Chukotka Autonomous Okrug 	Anadyr 	Flag of Chukotka.svg 	Coat of Arms of Chukotka.png 	Far Eastern 	Far Eastern 	737,700 	53,824
89 	Yamalo-Nenets Autonomous Okrug 	Salekhard (Largest city: Novy Urengoy) 	Flag of Yamal-Nenets Autonomous District.svg 	Coat of Arms of Yamal Nenetsia.png 	Urals 	West Siberian 	750,300 	507,006
