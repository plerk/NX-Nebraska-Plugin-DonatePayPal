package NX::Nebraska::User::Result::FlickrPhotoUrl;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

NX::Nebraska::User::Result::FlickrPhotoUrl

=cut

__PACKAGE__->table("flickr_photo_url");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 flickr_photo_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 type

  data_type: 'enum'
  extra: {list => ["m","s","t","sq"]}
  is_nullable: 0

=head2 width

  data_type: 'integer'
  is_nullable: 0

=head2 height

  data_type: 'integer'
  is_nullable: 0

=head2 url

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "flickr_photo_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "type",
  {
    data_type => "enum",
    extra => { list => ["m", "s", "t", "sq"] },
    is_nullable => 0,
  },
  "width",
  { data_type => "integer", is_nullable => 0 },
  "height",
  { data_type => "integer", is_nullable => 0 },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 128 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("flickr_photo_id", ["flickr_photo_id", "type"]);

=head1 RELATIONS

=head2 flickr_photo

Type: belongs_to

Related object: L<NX::Nebraska::User::Result::FlickrPhoto>

=cut

__PACKAGE__->belongs_to(
  "flickr_photo",
  "NX::Nebraska::User::Result::FlickrPhoto",
  { id => "flickr_photo_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-09-28 19:14:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:C9ucVzYZUSMcyMwggmQgUw

sub to_json_hash
{
  my $self = shift;
  return {
    type => $self->type,
    url => $self->url,
    width => $self->width,
    height => $self->height,
  };
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
