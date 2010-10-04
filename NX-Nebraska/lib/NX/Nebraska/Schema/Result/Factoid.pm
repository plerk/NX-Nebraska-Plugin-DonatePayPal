package NX::Nebraska::Schema::Result::Factoid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::Schema::Result::Factoid

=cut

__PACKAGE__->table("factoid");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 trip_place_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 factoid

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "trip_place_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "factoid",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 256 },
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-25 18:47:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hmZIEFe/fZJ+0soqZBG0zA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
