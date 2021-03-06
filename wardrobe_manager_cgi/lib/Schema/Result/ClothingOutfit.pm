package Schema::Result::ClothingOutfit;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Schema::Result::ClothingOutfit

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

__PACKAGE__->belongs_to(
  "clothing",
  "Schema::Result::Clothing",
  { id => "clothing" },
  { is_deferrable => 1, on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "outfit",
  "Schema::Result::Outfit",
  { id => "outfit" },
  { is_deferrable => 1, on_update => "CASCADE" },
);

1;
