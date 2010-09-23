package NX::Nebraska::User::Result::UserTwitter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::UserTwitter

=cut

__PACKAGE__->table("user_twitter");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 twitter_user

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 twitter_user_id

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 twitter_access_token

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 twitter_access_token_secret

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "twitter_user",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "twitter_user_id",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "twitter_access_token",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "twitter_access_token_secret",
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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-22 09:26:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8Ya7vRmEj3yhbXz1B3RGlw

sub auth_realm { 'twitter' }
sub url
{
  my $self = shift;
  return $self->user->realm->url . "/" . $self->twitter_user;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
