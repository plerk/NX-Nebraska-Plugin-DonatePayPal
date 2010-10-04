package NX::Nebraska::User::Result::TripVisit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::TripVisit

=cut

__PACKAGE__->table("trip_visit");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 trip_place_id

  data_type: 'integer'
  is_nullable: 0

=head2 user_comment

  data_type: 'text'
  is_nullable: 1

=head2 youtube_video_id

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 flickr_photo_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "trip_place_id",
  { data_type => "integer", is_nullable => 0 },
  "user_comment",
  { data_type => "text", is_nullable => 1 },
  "youtube_video_id",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "flickr_photo_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

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

=head2 flickr_photo

Type: belongs_to

Related object: L<NX::Nebraska::User::Result::FlickrPhoto>

=cut

__PACKAGE__->belongs_to(
  "flickr_photo",
  "NX::Nebraska::User::Result::FlickrPhoto",
  { id => "flickr_photo_id" },
  { join_type => "LEFT", on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-10-01 19:36:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WChWDsRCXfusKyljfiw8Kw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
