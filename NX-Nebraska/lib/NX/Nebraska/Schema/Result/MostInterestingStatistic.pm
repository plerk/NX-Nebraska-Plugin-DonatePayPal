package NX::Nebraska::Schema::Result::MostInterestingStatistic;

use strict;
use warnings;
use base qw( DBIx::Class::Core );

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('most_interesting_statistic');

__PACKAGE__->add_columns(
  "year",
  { data_type => "integer", is_nullable => 0 },
  "value",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "units",
  { data_type => "varchar", is_nullable => 0, size => 10 },
);

__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q(
  SELECT 
    v.year AS year, 
    v.value AS value, 
    s.name AS name, 
    s.units AS units 
  FROM 
    place AS p JOIN 
    integer_value AS v ON v.place_id = p.id JOIN 
    integer_statistic AS s ON s.id = v.integer_statistic_id 
  WHERE 
    p.id = ? AND 
    s.units LIKE ? 
  ORDER BY 
    v.year DESC, 
    s.is_primary DESC
));

1;
