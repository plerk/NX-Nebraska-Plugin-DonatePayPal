package NX::Nebraska::User::Result::UserFacebook;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::UserFacebook

=cut

__PACKAGE__->table("user_facebook");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 session_key

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 session_expires

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 session_uid

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "session_key",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "session_expires",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "session_uid",
  { data_type => "varchar", is_nullable => 1, size => 128 },
);
__PACKAGE__->set_primary_key("user_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<NX::Nebraska::User::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "NX::Nebraska::User::Result::User",
  { id => "user_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-22 22:15:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fvdq7ZoA5p8FVKLMlZ/ycA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
