package NX::Nebraska::User::Result::UserAnon;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::UserAnon

=cut

__PACKAGE__->table("user_anon");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 free

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 modified_at

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0

=head2 secret

  data_type: 'char'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "free",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "modified_at",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
  "secret",
  { data_type => "char", is_nullable => 0, size => 64 },
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-10-01 19:36:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4H8wPfSWgmzNrtQ7Hb9cAg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
