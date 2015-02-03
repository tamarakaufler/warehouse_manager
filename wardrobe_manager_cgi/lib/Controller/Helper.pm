#!/usr/bin/perl -T

=head1 NAME

Controller::Helper

=head1 SYNOPSIS

use Controller::Helper;
$name = sanitize($name);

=head1 DESCRIPTION

provides helper methods

=over 4

=item sanitize

=item aggregate_data

=item add_to_catalogue

=back

To facilitate testing of the module, the schemas of tables are not hardcoded but decided upon whether the method is called within the test context or not

=cut

package Controller::Helper;

use strict;
use warnings;
use v5.18;

use Text::CSV::Encoded;

use base qw(Exporter);

our @EXPORT = qw( sanitize aggregate_data add_to_catalogue retag_clothing);

=head2 Public methods

=head3 sanitize

    untaints provided string

=cut

sub sanitize {
    my $text = shift;

    return '' if ! $text;    

    ## TODO: this needs to be done by allowing a range of characters rather than by removing unwanted ones
    $text =~ s/^\s+//;
    $text =~ s/\s+$//;
    $text =~ s#[\\/<>`|!\$*()~{}'"?]+##g;        # ! $ ^ * ( ) ~ [ ] \ | { } ' " ; < > ?
    $text =~ s/\s{2,}/ /g;
    $text =~ /^([\x00-\xFF]*)$/;

    return $1;
}

=head3 aggregate_data

    parameters:   filehandle of the uploaded file
    returns:         array of two arrayrefs: clothing names
                                          category names


=cut

sub aggregate_data {
    my ( $fh ) = shift;
    my ( @clothings, @categories );

    my $csv = Text::CSV::Encoded->new();
    $csv->encoding( 'utf8' );

    while ( my $row = $csv->getline( $fh ) ) {

        ## allow only valid values to be stored, alternatively sanitize
        if ( ( $row->[0] && $row->[0] =~ /[a-zA-Z0-9_\-]+/ && $row->[0] !~ /^\s*name/ ) &&
             ( $row->[1] && $row->[1] =~ /[a-zA-Z0-9_\-]+/ && $row->[1] !~ /^\s*category/ )    ) {
            $row->[0] =~ s/^\s+//; $row->[1] =~ s/^\s+//;
            $row->[0] =~ s/\s+$//; $row->[1] =~ s/\s+$//;
            push @clothings,  $row->[0];
            push @categories, $row->[1];

        } else {
            ## log error
        }
    }

    return ( \@clothings, \@categories );

}

=head3 add_to_catalogue

    adds categorized cloths to the database

    parameters:   manager object
                  arrayref of clothing names
                  arrayref of category names


=cut

sub add_to_catalogue {
    my ( $manager, 
         $clothings_ref, $categories_ref, 
         $test ) = @_;

    my ( $clothing_table, $category_table );
    if ( $test ) {
        $clothing_table = 'ClothingTest';
        $category_table = 'CategoryTest';
    } else {
        $clothing_table = 'Clothing';
        $category_table = 'Category';
    }

    ## Whether or not to use a transaction depends on the business logic (also affects 
    ## the database design
    $manager->schema->txn_do( sub {
        ## add category if does not exist
        ## add the clothing
        my $i = 0;
        foreach my $cat_name ( @$categories_ref ) {
            my $category = $manager->schema->resultset($category_table)->find_or_create(
                                                                {   name => $cat_name  });
            my $clothing = $manager->schema->resultset($clothing_table)->create(
                                                                { 
                                                                    name     => $clothings_ref->[$i],
                                                                    category => $category->id,
                                                                });
            $i++;
        }
            
    } );

    return if $@;
    return 1;

}

=head2 retag_clothing

    retags the specified item of clothing:
                  replaces by new association or removes all associations

    parameters:   manager object
                  clothing id
                  arrayref of outfit ids

=cut

sub retag_clothing {

    my ( $manager, 
         $clothing_id, $outfit_ids_ref, 
         $test ) = @_;

    my %message = ();

    ## check the input parameters
    do {
        $message{ error } = 'Internal error - not enough parameters passed into retag_clothing subroutine';
        return %message; 
    } if scalar @_ < 3; 

    do {
        $message{ error } = 'Internal error - Invalid clothing id';
        return %message; 
    } if ! $clothing_id; 

    ## set up the correct access to tables based on whether we are testing or not
    my ( $clothing_table, $outfit_table );
    if ( $test ) {
        $clothing_table = 'ClothingTest';
        $outfit_table   = 'OutfitTest';
    } else {
        $clothing_table = 'Clothing';
        $outfit_table   = 'Outfit';
    }

    ## get the clothing object
    my $clothing = $manager->schema->resultset($clothing_table)->find( $clothing_id ) or do {
        $message{ error } = 
                "An error happened when recovering the clothing (id $clothing_id) from the database";
        return %message;
    };
    
    ## retag
    if ( scalar @{ $outfit_ids_ref } ) {
        my @selected_outfits = $manager->schema
                                    ->resultset($outfit_table)
                                    ->search({ id => 
                                                    { '-in' => $outfit_ids_ref } } ) 
                             or do {
                                        $message{ error } = 
                                        "An error happened when recovering selected outfits from the database";
                                        return %message;
                                   };
        !$clothing->set_outfits( \@selected_outfits )
                             or do {
                                        $message{ error } = 
                                        "An error happened when adding tags to the database";
                                        return %message;
                                   };

    } else {
        map { 
                $clothing->remove_from_outfits($_) or do {
                                    $message{ error } = "An error happened when adding tags to the database";
                                    return %message;
                               }; 
            } $clothing->outfits;

    }

    $message{ message } = 'The clothing item "' . $clothing->name . '" has been retagged';

    return %message;    

}

1;
