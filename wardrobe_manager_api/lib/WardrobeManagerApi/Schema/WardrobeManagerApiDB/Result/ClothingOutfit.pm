use utf8;
package WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::ClothingOutfit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::ClothingOutfit

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<clothing_outfit>

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

=head1 PRIMARY KEY

=over 4

=item * L</clothing>

=item * L</outfit>

=back

=cut

__PACKAGE__->set_primary_key("clothing", "outfit");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-01-21 19:04:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:li4iBu6jAhd3Cqbs0EMHhg

# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->belongs_to(
  "clothing",
  "WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Clothing",
  { id => "clothing" },
  { is_deferrable => 1, on_update => "CASCADE" },
);
__PACKAGE__->belongs_to(
  "outfit",
  "WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Outfit",
  { id => "outfit" },
  { is_deferrable => 1, on_update => "CASCADE" },
);


__PACKAGE__->meta->make_immutable;
1;
