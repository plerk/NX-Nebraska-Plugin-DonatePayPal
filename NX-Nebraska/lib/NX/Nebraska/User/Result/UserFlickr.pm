package NX::Nebraska::User::Result::UserFlickr;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::UserFlickr

=cut

__PACKAGE__->table("user_flickr");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 flickr_username

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 flickr_nsid

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 flickr_token

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "flickr_username",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "flickr_nsid",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "flickr_token",
  { data_type => "varchar", is_nullable => 1, size => 64 },
);
__PACKAGE__->set_primary_key("user_id");
__PACKAGE__->add_unique_constraint("flickr_username", ["flickr_username"]);

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


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-28 10:09:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:huvgL3/Ti1lEfgYS9pRmFA

sub url
{
  my $self = shift;
  return $self->user->realm->url . "/photos/" . $self->flickr_username;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
