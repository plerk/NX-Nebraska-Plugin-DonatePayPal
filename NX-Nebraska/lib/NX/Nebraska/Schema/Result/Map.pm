package NX::Nebraska::Schema::Result::Map;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::Schema::Result::Map

=cut

__PACKAGE__->table("map");

=head1 ACCESSORS

=head2 id

  data_type: 'char'
  is_nullable: 0
  size: 3

=head2 country_code

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "char", is_nullable => 0, size => 3 },
  "country_code",
  { data_type => "char", is_nullable => 1, size => 2 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 places

Type: has_many

Related object: L<NX::Nebraska::Schema::Result::Place>

=cut

__PACKAGE__->has_many(
  "places",
  "NX::Nebraska::Schema::Result::Place",
  { "foreign.map_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 trip_place_maps

Type: has_many

Related object: L<NX::Nebraska::Schema::Result::TripPlaceMap>

=cut

__PACKAGE__->has_many(
  "trip_place_maps",
  "NX::Nebraska::Schema::Result::TripPlaceMap",
  { "foreign.map_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-24 11:01:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:A2IWrs5fBzuukGP5yUNFZw

sub statistics
{
  my $self = shift;
  $self->result_source->schema->resultset('IntegerStatisticForMap')->search({ }, { bind => [ $self->id ]});
}

sub values
{
  my $self = shift;
  my $stat_id = shift;
  my $year = shift;
  $self->result_source->schema->resultset('IntegerValueForMap')->search({ }, { bind => [ $self->id, $stat_id, $year ]});
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
