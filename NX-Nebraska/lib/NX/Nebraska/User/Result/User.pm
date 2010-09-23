package NX::Nebraska::User::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::User

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 realm_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "realm_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name", ["name", "realm_id"]);

=head1 RELATIONS

=head2 realm

Type: belongs_to

Related object: L<NX::Nebraska::User::Result::Realm>

=cut

__PACKAGE__->belongs_to(
  "realm",
  "NX::Nebraska::User::Result::Realm",
  { id => "realm_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 user_facebook

Type: might_have

Related object: L<NX::Nebraska::User::Result::UserFacebook>

=cut

__PACKAGE__->might_have(
  "user_facebook",
  "NX::Nebraska::User::Result::UserFacebook",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_nebraska

Type: might_have

Related object: L<NX::Nebraska::User::Result::UserNebraska>

=cut

__PACKAGE__->might_have(
  "user_nebraska",
  "NX::Nebraska::User::Result::UserNebraska",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_twitter

Type: might_have

Related object: L<NX::Nebraska::User::Result::UserTwitter>

=cut

__PACKAGE__->might_have(
  "user_twitter",
  "NX::Nebraska::User::Result::UserTwitter",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-22 22:12:53
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:McsMOwBX0xGKYtOJKS3upQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
