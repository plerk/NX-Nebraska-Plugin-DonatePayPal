package NX::Nebraska::Schema::Result::IntegerValueForMap;

use strict;
use warnings;
use base qw( DBIx::Class::Core );

# Interface to get the values for a map given a particular
# statistic id and year.  See NX::Nebraska::Controller::Map
# for more details.

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('integer_value_for_map');

__PACKAGE__->add_columns(
  "place_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "value",
  { data_type => "integer", is_nullable => 1 },
);

__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q(
  SELECT
    v.place_id AS place_id,
    v.value AS value
  FROM
    integer_value AS v JOIN
    place AS p ON p.id = v.place_id
  WHERE
    p.map_id = ? AND
    integer_statistic_id = ? AND
    v.year = ?
));

1;
