package WardrobeManager::Schema::Result::Outfit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WardrobeManager::Schema::Result::Outfit

=cut

__PACKAGE__->table("outfit");

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


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-04-23 23:33:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RfZ5CCtX3UAX4HJn7HQHUQ


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->has_many( clothing_outfits => 'WardrobeManager::Schema::Result::ClothingOutfit',
					  'outfit');
__PACKAGE__->many_to_many( clothings => 'clothing_outfits', 'clothing');

1;
