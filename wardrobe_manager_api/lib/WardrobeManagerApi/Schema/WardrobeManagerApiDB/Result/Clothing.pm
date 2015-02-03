use utf8;
package WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Clothing;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Clothing

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

=head1 TABLE: C<clothing>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_cat_uniq>

=over 4

=item * L</name>

=item * L</category>

=back

=cut

__PACKAGE__->add_unique_constraint("name_cat_uniq", ["name", "category"]);

=head1 RELATIONS

=head2 category

Type: belongs_to

Related object: L<WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::Category",
  { id => "category" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-01-21 19:04:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oar0AjEVRFF4wb4/VrK+RA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->has_many(clothing_outfits => 'WardrobeManagerApi::Schema::WardrobeManagerApiDB::Result::ClothingOutfit',
                                          'clothing');
__PACKAGE__->many_to_many(outfits => 'clothing_outfits', 'outfit');

=head3 get_summary

convenience method to access all instance related information

IN:     Clothing object
        Catalyst object
OUT:    information massaged into a structure suitable for API output

=cut

sub get_summary {
    my ($self, $c) = @_;

    my @outfits = $self->outfits();
    my $category = $self->category;

    my $self_output = { id   => $self->id,
                        name => $self->name,
                        link => $c->uri_for("/api/clothing/id/" . $self->id)->as_string,
                        docs => $c->uri_for("/docs/clothing")->as_string };

    $self_output->{ category } = { id   => $category->id, 
                                   name => $category->name,
                                   link => $c->uri_for("/api/category/id/" . $category->id)->as_string,
                                   docs => $c->uri_for("/docs/category")->as_string };

    my @outfit_output = (); 
    for my $outfit (@outfits) {
        push @outfit_output, {  id   => $outfit->id,
                                name => $outfit->name,
                                link => $c->uri_for("/api/outfit/id/" . $outfit->id)->as_string,
                                docs => $c->uri_for("/docs/outfit")->as_string };
    }
    $self_output->{ outfit } = \@outfit_output;

    return $self_output;
}

__PACKAGE__->meta->make_immutable;


1;
