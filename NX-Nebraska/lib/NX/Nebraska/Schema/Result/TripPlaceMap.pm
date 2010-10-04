package NX::Nebraska::Schema::Result::TripPlaceMap;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::Schema::Result::TripPlaceMap

=cut

__PACKAGE__->table("trip_place_map");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 trip_place_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 map_id

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 1
  size: 3

=head2 map_code

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 small

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "trip_place_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "map_id",
  { data_type => "char", is_foreign_key => 1, is_nullable => 1, size => 3 },
  "map_code",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "small",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 trip_place

Type: belongs_to

Related object: L<NX::Nebraska::Schema::Result::TripPlace>

=cut

__PACKAGE__->belongs_to(
  "trip_place",
  "NX::Nebraska::Schema::Result::TripPlace",
  { id => "trip_place_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 map

Type: belongs_to

Related object: L<NX::Nebraska::Schema::Result::Map>

=cut

__PACKAGE__->belongs_to(
  "map",
  "NX::Nebraska::Schema::Result::Map",
  { id => "map_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-27 09:41:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aEgDexcqhznhGwXFPg1/Yg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
