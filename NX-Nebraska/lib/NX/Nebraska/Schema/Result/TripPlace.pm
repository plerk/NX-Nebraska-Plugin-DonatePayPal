package NX::Nebraska::Schema::Result::TripPlace;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::Schema::Result::TripPlace

=cut

__PACKAGE__->table("trip_place");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 country_code

  data_type: 'char'
  is_nullable: 0
  size: 2

=head2 region_code

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 flag

  data_type: 'tinyint'
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "country_code",
  { data_type => "char", is_nullable => 0, size => 2 },
  "region_code",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "flag",
  { data_type => "tinyint", is_nullable => 1 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 factoids

Type: has_many

Related object: L<NX::Nebraska::Schema::Result::Factoid>

=cut

__PACKAGE__->has_many(
  "factoids",
  "NX::Nebraska::Schema::Result::Factoid",
  { "foreign.trip_place_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 trip_place_maps

Type: has_many

Related object: L<NX::Nebraska::Schema::Result::TripPlaceMap>

=cut

__PACKAGE__->has_many(
  "trip_place_maps",
  "NX::Nebraska::Schema::Result::TripPlaceMap",
  { "foreign.trip_place_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-24 13:21:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:H/UsCPzx7k+LipGJzZIFng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
