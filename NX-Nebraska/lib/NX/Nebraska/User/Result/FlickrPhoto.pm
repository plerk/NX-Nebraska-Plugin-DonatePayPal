package NX::Nebraska::User::Result::FlickrPhoto;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::FlickrPhoto

=cut

__PACKAGE__->table("flickr_photo");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 flickr_webservice_id

  data_type: 'bigint'
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "flickr_webservice_id",
  { data_type => "bigint", is_nullable => 0 },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 128 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("flickr_webservice_id", ["flickr_webservice_id"]);

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

=head2 flickr_photo_urls

Type: has_many

Related object: L<NX::Nebraska::User::Result::FlickrPhotoUrl>

=cut

__PACKAGE__->has_many(
  "flickr_photo_urls",
  "NX::Nebraska::User::Result::FlickrPhotoUrl",
  { "foreign.flickr_photo_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 trip_visits

Type: has_many

Related object: L<NX::Nebraska::User::Result::TripVisit>

=cut

__PACKAGE__->has_many(
  "trip_visits",
  "NX::Nebraska::User::Result::TripVisit",
  { "foreign.flickr_photo_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-28 18:13:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:D9uAXC1IHBD0JZUwFvj01Q

sub to_json_hash
{
  my $self = shift;
  return {
    url => $self->url,
    id => $self->flickr_webservice_id,
    title => $self->title,
    photo_urls => [ map { $_->to_json_hash } $self->flickr_photo_urls ],
  };
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
