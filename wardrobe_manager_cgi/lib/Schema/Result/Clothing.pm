package Schema::Result::Clothing;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Schema::Result::Clothing

=cut

__PACKAGE__->table("clothing");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 category

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "category",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 category

Type: belongs_to

Related object: L<Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "Schema::Result::Category",
  { id => "category" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->has_many( clothing_outfits => 'Schema::Result::ClothingOutfit',
					  'clothing');
__PACKAGE__->many_to_many( outfits => 'clothing_outfits', 'outfit');

1;
