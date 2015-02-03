#!/usr/bin/perl

package Schema::Result::CategoryTest;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

Schema::Result::CategoryTest

=cut

__PACKAGE__->table("category_test");

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

Related object: L<Schema::Result::ClothingTest>

=cut

__PACKAGE__->has_many(
  "clothings",
  "Schema::Result::ClothingTest",
  { "foreign.category" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
