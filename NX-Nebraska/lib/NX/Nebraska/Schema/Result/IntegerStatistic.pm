package NX::Nebraska::Schema::Result::IntegerStatistic;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::Schema::Result::IntegerStatistic

=cut

__PACKAGE__->table("integer_statistic");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 units

  data_type: 'varchar'
  is_nullable: 0
  size: 10

=head2 is_primary

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "units",
  { data_type => "varchar", is_nullable => 0, size => 10 },
  "is_primary",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 integer_values

Type: has_many

Related object: L<NX::Nebraska::Schema::Result::IntegerValue>

=cut

__PACKAGE__->has_many(
  "integer_values",
  "NX::Nebraska::Schema::Result::IntegerValue",
  { "foreign.integer_statistic_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-24 11:01:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F+mAiBZEkq+bZsLEQDjatQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
