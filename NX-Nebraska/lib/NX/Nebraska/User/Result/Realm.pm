package NX::Nebraska::User::Result::Realm;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::Realm

=cut

__PACKAGE__->table("realm");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 url

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "url",
  { data_type => "varchar", is_nullable => 1, size => 128 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name", ["name"]);

=head1 RELATIONS

=head2 users

Type: has_many

Related object: L<NX::Nebraska::User::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "NX::Nebraska::User::Result::User",
  { "foreign.realm_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-22 14:01:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XUHnR8xWM3wiJUs9cquCDA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
