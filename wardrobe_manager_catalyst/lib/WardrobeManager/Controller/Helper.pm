package WardrobeManager::Controller::Helper;

=head1 WardrobeManager::Controller::Helper

provides helper methods

=cut

use strict;
use warnings;
use v5.018;
use utf8;
use open ':encoding(utf8)';
use feature 'unicode_strings';
use Encode qw(encode decode);

use Text::CSV::Encoded;

use base qw(Exporter);

our @EXPORT = qw(   sanitize
                    aggregate_data 
                    add_to_catalogue 
                    retag_clothing
                    massage4output );

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
    $text =~ s#[\\/<>`|!\$*()~{}'"?]+##g;        # ! $ ^ & * ( ) ~ [ ] \ | { } ' " ; < > ?
    $text =~ s/\s{2,}/ /g;

    return $text;
}

=head3 aggregate_data

    input parameters:   filehandle of the uploaded file
    output parameters:  array of two arrayrefs: clothing names
                                                category names


=cut

sub aggregate_data {
    my ( $fh ) = shift;
    my ( @clothings, @categories );

    my $csv = Text::CSV::Encoded->new ({
        encoding_in  => "utf-8", 
        encoding_out => "utf-8", 
    });

    my $i = 0;
    while ( my $row = $csv->getline( $fh ) ) {

        ## allow only valid values to be stored, alternatively sanitize
        if ( ( $row->[0] && $row->[0] =~ /[a-zA-Z0-9_\- ]+/ && $row->[0] !~ /^\s*name/ ) &&
             ( $row->[1] && $row->[1] =~ /[a-zA-Z0-9_\- ]+/ && $row->[1] !~ /^\s*category/ )    ) {
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

    input parameters:   manager object
                        arrayref of clothing names
                        arrayref of category names


=cut

sub add_to_catalogue {
    my ( $c, $clothings_ref, $categories_ref ) = @_;
        
    ## Whether or not to use a transaction depends on the business logic (also affects 
    ## the database design
    $c->model('DB')->txn_do( sub {
        ## add category if does not exist
        ## add the clothing
        my $i = 0;
        foreach my $cat_name ( @$categories_ref ) {
            my $category = $c->model('DB::Category')->find_or_create(
                                                                {   name => $cat_name  });
            my $clothing = $c->model('DB::Clothing')->create(
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

=head3 retag_clothing

    retags the specified item of clothing:
                  replaces by new association or removes all associations in clothing_outfit

    parameters:   c object
                  clothing id
                  arrayref of outfit ids

=cut

sub retag_clothing {

    my ( $c, 
         $clothing_id, $outfit_ids_ref ) = @_;

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

    ## get the clothing object
    my $clothing = $c->model('DB::Clothing')->find( $clothing_id ) or do {
        $message{ error } = 
                "An error happened when recovering the clothing (id $clothing_id) from the database";
        return %message;
    };
    
    ## retag
    if ( scalar @{ $outfit_ids_ref } ) {
        my @selected_outfits = $c->model('DB::Outfit')
                                 ->search({ id => { '-in' => $outfit_ids_ref } } ) 
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

=head3 massage4output

    massage DBIC data into a Perl structure
    The reason is to encode entity name's Perl internal encoding from iso-8859-1 into utf8 (not sure why this is needed)
    (to avoid wide-character warning and showing the special replacement character on the web page and in the terminal)

=cut

sub massage4output {
    my ($clothings_rs, $outfits_rs) = @_;

    my $clothings = [];
    my $outfits   = [];

    while (my $clothing = $clothings_rs->next) {
        say STDERR $clothing->name;
        my $category = $clothing->category;
        
        push @$clothings, { id => $clothing->id, name => encode('utf8', $clothing->name),  
                            category => { 
                                            id   => $clothing->category->id, 
                                            name => encode('utf8', $clothing->category->name), 
                                        },
                          };
    }
    while (my $outfit = $outfits_rs->next) {
        push @$outfits, { id => $outfit->id, name => encode('utf8', $outfit->name), };
    }

    return ($clothings, $outfits);
}

1;
