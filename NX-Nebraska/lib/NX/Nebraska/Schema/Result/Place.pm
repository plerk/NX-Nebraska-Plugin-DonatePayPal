package NX::Nebraska::Schema::Result::Place;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::Schema::Result::Place

=cut

__PACKAGE__->table("place");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 parent_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 map_id

  data_type: 'char'
  is_foreign_key: 1
  is_nullable: 0
  size: 3

=head2 map_code

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 flag

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "parent_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "map_id",
  { data_type => "char", is_foreign_key => 1, is_nullable => 0, size => 3 },
  "map_code",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "flag",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("map_id_2", ["map_id", "map_code"]);
__PACKAGE__->add_unique_constraint("map_id", ["map_id", "name"]);

=head1 RELATIONS

=head2 integer_values

Type: has_many

Related object: L<NX::Nebraska::Schema::Result::IntegerValue>

=cut

__PACKAGE__->has_many(
  "integer_values",
  "NX::Nebraska::Schema::Result::IntegerValue",
  { "foreign.place_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 parent

Type: belongs_to

Related object: L<NX::Nebraska::Schema::Result::Place>

=cut

__PACKAGE__->belongs_to(
  "parent",
  "NX::Nebraska::Schema::Result::Place",
  { id => "parent_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 places

Type: has_many

Related object: L<NX::Nebraska::Schema::Result::Place>

=cut

__PACKAGE__->has_many(
  "places",
  "NX::Nebraska::Schema::Result::Place",
  { "foreign.parent_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 map

Type: belongs_to

Related object: L<NX::Nebraska::Schema::Result::Map>

=cut

__PACKAGE__->belongs_to(
  "map",
  "NX::Nebraska::Schema::Result::Map",
  { id => "map_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-08-30 16:27:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EjumE4kzH7EOkY6r8g6oxQ

sub most_interesting_statistic
{
  my $self = shift;
  my $units = shift;
  return $self->result_source->schema->resultset('MostInterestingStatistic')->search({ }, { bind => [ $self->id, $units]})->first;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
