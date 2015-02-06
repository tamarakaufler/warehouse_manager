package WardrobeManager::Controller::Catalogue;

use base 'Catalyst::Controller';

use lib qw( .. );
use v5.018;
use utf8;
use open ':encoding(utf8)';
use feature 'unicode_strings';
use Encode qw(encode);

use WardrobeManager::Controller::Helper;

#$ENV{DBIC_TRACE} = 1;

=head1 NAME

WardrobeManager::Controller::Catalogue - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

=head1 METHODS

=cut


=head2 search

=cut

sub search : Path('search') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $name = sanitize( $c->req->param('clothing_name') );
    my $clothings_rs = $c->model('DB::Clothing')
                         ->search(
                                     { 'me.name' => { 'like', "%$name%" } },
                                     {  prefetch => 'category',
                                        order_by => [qw/ me.name /] }
                                 );
    my $outfits_rs   = $c->model('DB::Outfit')
                         ->search(
                                     {},
                                     { order_by => [qw/ name /] }
                                 );

    my ($clothings, $outfits) = massage4output($clothings_rs, $outfits_rs);

    $c->stash->{ clothings } = $clothings;
    $c->stash->{ outfits }   = $outfits;

    $c->stash->{ mode }      = 'search';
    $c->stash->{ template }  = 'index.tt';

}

=head2 upload

=cut

sub upload :Local {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'index.tt';

    ## show default page if the filename is empty or has bad characters
    
    unless ( $c->req->param('file') && $c->req->param('file') =~ /^([a-zA-Z0-9_.]*)$/ ) {
        $c->stash->{ error } = 'Provided filename was either empty or unclean and could not be processed.';
        $c->detach('/index');
    }

    ## try to upload the file
    my $upload = $c->req->upload('file');
    my $fh     = $upload->fh;

    if ($upload->type eq 'text/csv' ) {

        if ( ! $upload->size ) {
            $c->stash->{ error } = 'The supplied file is empty';
            $c->detach('/index');
        }

        ## aggregate clothings and categories
        my ( $clothing_array_ref, $category_array_ref ) = aggregate_data( $fh );

        if ( ! scalar @$clothing_array_ref ) {
            $c->stash->{ error } = 'No additions to the catalogue - 
                                      problems with parsing the csv file';
            $c->detach('/index');
        }

        ## aggregate clothings and categories into 2 arrays

        if ( ! add_to_catalogue( $c, $clothing_array_ref, $category_array_ref) ) {
            $c->stash->{ error } = 'No additions to the catalogue - 
                                      problems with adding items to the catalogue';
        }
        $c->stash->{ message }  = 'New clothing added to the database.';

    } else {
        $c->stash->{ error }    = 'Only CSV files can be uploaded';
    }

}


=head2 tag method

replaces existing outfit tags with new ones

=cut

sub tag :Local {
    my ( $self, $c ) = @_;

    my ( $clothing_id, @outfit_ids );

    $c->stash->{ template } = 'index.tt';

    ## get selected info and sanitize selected_outfit_ids
    $clothing_id = $c->req->param('clothing');
    $clothing_id =~ s/\D+//g;
    $clothing_id =~ /^(\d+)$/;
    $clothing_id = $1;    
    my @selected_outfit_ids = $c->req->param('outfits');
    my @sanitized_outfit_ids = ();
    foreach my $id ( @selected_outfit_ids ) {
        $id =~ s/\D+//g;
        $id =~ /^(\d+)$/;
        push @sanitized_outfit_ids, $1;
    }

    my %message = retag_clothing( $c, 
                                     $clothing_id, \@sanitized_outfit_ids);

    if ( exists $message{ message } ) {
        $c->stash->{ message } = $message{ message };
        $c->detach('/index');


    } elsif ( exists $message{ error } ) {
        $c->stash->{ error } = $message{ error };
        $c->detach('/index');
    }



    my $clothing = $c->model('DB::Clothing')
                     ->find( $clothing_id ) or do {
                                $c->stash->{ error } = 
                                        "An error happened when recovering the clothing (id $clothing_id) from the database";
                                $c->detach('/index');
                            };
    
    ## retag
    if ( scalar @sanitized_outfit_ids ) {
        my @selected_outfits = $c->model('DB::Outfit')
                                 ->search({ id => { '-in' => \@sanitized_outfit_ids } } ) or do {
                                        $c->stash->{ error } = 
                                        "An error happened when recovering selected outfits from the database";
                                        $c->detach('/index');
                                   };
        !$clothing->set_outfits( \@selected_outfits ) or do {
                                        $c->stash->{ error } = 
                                                    "An error happened when adding tags to the database";
                                        $c->detach('/index');
                                   };

    } else {
        map { 
                $clothing->remove_from_outfits($_) or do {
                                    $c->stash->{ error } = "2 An error happened when adding tags to the database";
                                    $c->detach('/index');
                               }; 
            } $clothing->outfits;

    }

    $c->stash->{ message } = 'The clothing item "' . encode('utf8', $clothing->name) . '" has been retagged';

}
=head2 add_outfit method

creates a new outfit if it does not alrready exist

=cut

sub add_outfit :Local {
    my ( $self, $c ) = @_;

    my $name = sanitize( $c->req->param('outfit_name') );

    $c->model('DB::Outfit')
      ->find_or_create( { 'name' => "$name" } ) or do {
                        $c->stash->{ error } = "An error happened when adding an outfit to the database";
                        $c->detach('/index');
                     };

    $c->stash->{ message }  = "A new outfit was added to the database if it did not already exist.";
    $c->stash->{ template } = 'index.tt';

}


=head2 Private methods

none

=cut


=head1 AUTHOR

Tamara Kaufler,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
