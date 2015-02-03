package WardrobeManager::Schema::Result::ClothingOutfit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WardrobeManager::Schema::Result::ClothingOutfit

=cut

__PACKAGE__->table("clothing_outfit");

=head1 ACCESSORS

=head2 clothing

  data_type: 'integer'
  is_nullable: 0

=head2 outfit

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "clothing",
  { data_type => "integer", is_nullable => 0 },
  "outfit",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("clothing", "outfit");


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-04-23 23:33:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I98rYaPtqqa3QukpqiheCA


# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
  "clothing",
  "WardrobeManager::Schema::Result::Clothing",
  { id => "clothing" },
  { is_deferrable => 1, on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "outfit",
  "WardrobeManager::Schema::Result::Outfit",
  { id => "outfit" },
  { is_deferrable => 1, on_update => "CASCADE" },
);

1;
