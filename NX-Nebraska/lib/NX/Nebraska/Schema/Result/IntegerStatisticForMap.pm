package NX::Nebraska::Schema::Result::IntegerStatisticForMap;

use strict;
use warnings;
use base qw( DBIx::Class::Core );

# Interface to get the statistics available for a given map.
# see NX::Nebraska::Controller::Map for more details.

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('integer_statistic_for_map');

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "units",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "is_primary",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q(
  SELECT 
    s.id AS id, 
    s.name AS name, 
    v.year AS year,
    s.units AS units,
    s.is_primary AS is_primary
  FROM 
    place AS p JOIN 
    integer_value AS v ON v.place_id = p.id JOIN 
    integer_statistic AS s ON s.id = v.integer_statistic_id 
  WHERE 
    p.map_id = ?
  GROUP BY 
    s.id, v.year
  ORDER BY 
    s.name, v.year
));

1;
