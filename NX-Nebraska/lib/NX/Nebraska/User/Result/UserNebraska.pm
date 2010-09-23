package NX::Nebraska::User::Result::UserNebraska;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::UserNebraska

=cut

__PACKAGE__->table("user_nebraska");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 password

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "password",
  { data_type => "varchar", is_nullable => 0, size => 64 },
);
__PACKAGE__->set_primary_key("user_id");
__PACKAGE__->add_unique_constraint("username", ["username"]);

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-22 09:46:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ArvfGSNaodwaWHkWWuJ/MA

sub url { return undef }

# You can replace this text with custom content, and it will be preserved on regeneration
1;
