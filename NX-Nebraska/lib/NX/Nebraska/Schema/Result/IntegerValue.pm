package NX::Nebraska::Schema::Result::IntegerValue;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::Schema::Result::IntegerValue

=cut

__PACKAGE__->table("integer_value");

=head1 ACCESSORS

=head2 place_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 integer_statistic_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 year

  data_type: 'integer'
  is_nullable: 0

=head2 value

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "place_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "integer_statistic_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "year",
  { data_type => "integer", is_nullable => 0 },
  "value",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("place_id", "integer_statistic_id", "year");

=head1 RELATIONS

=head2 place

Type: belongs_to

Related object: L<NX::Nebraska::Schema::Result::Place>

=cut

__PACKAGE__->belongs_to(
  "place",
  "NX::Nebraska::Schema::Result::Place",
  { id => "place_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 integer_statistic

Type: belongs_to

Related object: L<NX::Nebraska::Schema::Result::IntegerStatistic>

=cut

__PACKAGE__->belongs_to(
  "integer_statistic",
  "NX::Nebraska::Schema::Result::IntegerStatistic",
  { id => "integer_statistic_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-08-17 14:06:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GICPaifHAW++P+/7ULQf2Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
