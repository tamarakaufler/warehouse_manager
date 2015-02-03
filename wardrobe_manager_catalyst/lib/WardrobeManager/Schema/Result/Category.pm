package WardrobeManager::Schema::Result::Category;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WardrobeManager::Schema::Result::Category

=cut

__PACKAGE__->table("category");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 clothings

Type: has_many

Related object: L<WardrobeManager::Schema::Result::Clothing>

=cut

__PACKAGE__->has_many(
  "clothings",
  "WardrobeManager::Schema::Result::Clothing",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-04-23 23:33:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fGoJ1PK+jSTxZTYVOtJy+A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
