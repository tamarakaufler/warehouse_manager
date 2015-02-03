use utf8;
package WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Outfit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Outfit

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

=head1 TABLE: C<outfit>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_uniq>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name_uniq", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-01-21 19:04:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1TvHDLQpVdVMSyJByzglTQ

# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->has_many(clothing_outfits => 'WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::ClothingOutfit',
                                          'outfit');
__PACKAGE__->many_to_many(clothings => 'clothing_outfits', 'clothing');


__PACKAGE__->meta->make_immutable;
1;
