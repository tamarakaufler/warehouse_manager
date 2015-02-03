#!/usr/bin/perl -T

=head1 NAME

Controller::Manager

=head1 SYNOPSIS

my $manager = Controller::Manager->new();

=head1 DESCRIPTION

provides actions for manager.cgi

To facilitate testing of the module, the schemas of tables are not hardcoded but decided upon whether the method is called within the test context or not

=cut

package Controller::Manager;

use strict;
use warnings;
use v5.18;

use Model::DB;
use Controller::Helper;

use base qw( Class::Accessor );
__PACKAGE__->mk_ro_accessors( qw(schema) );

$ENV{DBIC_TRACE} = 1;

=head1 Public methods

=over 4

=item new

=item search

=item upload

=item tag

=item add_outfit

=back

=cut


=head2 new method

=cut

sub new {
    my $proto = shift or die "I need a class";
    my $class = ref $proto ? ref $proto : $proto;

    my $self  = {};

    my $db = Model::DB->instance();
    $self->{ schema } = $db->schema;

    bless $self, $class;

}

=head2 search method

parameters: 
        name (string) that will be used to find clothes with this string in their names 
        test (either not supplied, empty,string or 0/1)

returns:
        array of two arrayrefs:
                                of clothing objects
                                of outfit objects

=cut

sub search {
    my $self = shift;
    my $name = shift;
    my $test = shift;

    $name = sanitize($name);    

    my ( $clothing_table, $outfit_table );
    if ( $test ) {
        $clothing_table = 'ClothingTest';
        $outfit_table   = 'OutfitTest';
    } else {
        $clothing_table = 'Clothing';
        $outfit_table   = 'Outfit';
    }

    my ( @clothings, @outfits );
    @clothings = $self->schema
                         ->resultset( $clothing_table )
                         ->search(
                                     { 'me.name' => { 'like', "%$name%" } },
                                     { prefetch => 'category',
                                       order_by => [ qw/ me.name / ] }
                                 )->all;
    @outfits   = $self->schema
                         ->resultset( $outfit_table )
                         ->search(
                                     {},
                                     { order_by => [qw/ name /] }
                                 );

    return ( \@clothings, \@outfits );
}

=head2 upload method

parameters: 
        cgi object 
        test (either not supplied, empty,string or 0/1)

new clothes are inserted into the database, based on the contents of the uploaded CSV file

=cut

sub upload {
    my $self = shift;
    my $cgi  = shift;
    my $test = shift;

    my $filename = $cgi->param('file');
    unless ( $filename ) {
        if ( not $test && $filename !~ /^([a-zA-Z0-9_.]+)$/ ) {
            $self->{ error } = 'Provided filename was either empty or contained suspicious characters.';
            return;
        }
    }

    my $type = $cgi->uploadInfo($filename)->{'Content-Type'};

    #print Data::Dumper::Dumper($cgi);

    unless ($type eq 'text/csv') {
        $self->{ error } = 'Provided file is not CSV file.';
        return;
    }

    my $tmpfilename = $cgi->tmpFileName($filename);
    unless ( -s $tmpfilename ) {
        $self->{ error } = 'Provided file is empty.';
        return;
    }

    open my $tmp_fh, "<", $tmpfilename;

    ## aggregate clothings and categories into 2 arrays
    my ( $clothing_array_ref, $category_array_ref ) = aggregate_data( $tmp_fh );

    if ( ! scalar @$clothing_array_ref ) {
        $self->{ message } = 'No additions to the catalogue - 
                                  problems with parsing the csv filename';
        return;
    }
    
    ## add to catalogue
    if ( ! add_to_catalogue( $self, 
                             $clothing_array_ref, $category_array_ref,
                             $test ) ) {
        $self->{ error }   = 'No additions to the catalogue - 
                                  problems with adding to the database';

    } else {
        $self->{ message } = 'New clothes added to the database.';

    }

    return 1;
}

=head2 tag method

parameters: 
        cgi object 
        test (either not supplied, empty,string or 0/1)

replaces existing outfit tags with new ones

=cut

sub tag {
    my $self = shift;
    my ( $cgi, $test ) = @_;

    my ( $clothing_id, @outfit_ids );

    ## get selected info and sanitize selected_outfit_ids
    $clothing_id = $cgi->param('clothing');
       $clothing_id =~ s/\D+//g;
       $clothing_id =~ /^(\d+)$/;
    $clothing_id = $1;    

    my @selected_outfit_ids = $cgi->param('outfits');
    my @sanitized_outfit_ids = ();
    foreach my $id ( @selected_outfit_ids ) {
        $id =~ s/\D+//g;
        $id =~ /^(\d+)$/;
        push @sanitized_outfit_ids, $1;

    }

    my %message = retag_clothing( $self, 
                                     $clothing_id, \@sanitized_outfit_ids,
                                    $test
                                );

    if ( exists $message{ message } ) {
        $self->{ message } = $message{ message };
        return 1;


    } elsif ( exists $message{ error } ) {
        $self->{ error } = $message{ error };
        return 0;
    }

}

=head2 add_outfit method

creates a new outfit if it does not already exist

parameters: 
        name (string) 
        test (either not supplied, empty,string or 0/1)

=cut

sub add_outfit {
    my $self   = shift;
    my ( $name, $test ) = @_;

    $name = sanitize($name) if $name;    

    my ( $outfit_table );
    if ( $test ) {
        $outfit_table   = 'OutfitTest';
    } else {
        $outfit_table   = 'Outfit';
    }

    if ( ! $name ) {
        $self->{ error } = "The outfit name was empty.";
        return;
    }

    $self->schema ->resultset($outfit_table)
                  ->find_or_create( { 'name' => "$name" } ) or do {
                            $self->{ error } = "An error happened when adding an outfit to the database";
                            return;
                          };
    $self->{ message } = "A new outfit was added to the database if it did not already exist.";

    return 1;

}

=head2 Private methods

none

=cut

1;

