#!/usr/bin/perl

package Schema::Result::OutfitTest;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Schema::Result::Outfit

=cut

__PACKAGE__->table("outfit_test");

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

=head2 Relationships

=cut

__PACKAGE__->has_many( clothing_outfits => 'Schema::Result::ClothingOutfitTest',
					  'outfit');
__PACKAGE__->many_to_many( clothings => 'clothing_outfits', 'clothing');

1;
