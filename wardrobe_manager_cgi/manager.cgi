#!/usr/bin/perl -T

=pod 

=head1 manager.cgi

script for online management of clothes:

=head2 Provides following functionalities

=over 4

=item search by name of a clothing

=item adding clothes to the database through an uploaded csv file

=item tagging by associating clothes with outfits

=item adding new outfits

=back

=head2 Required modules

=over 4

=item CGI

=item Template

=item Controller::Manager

=item Controller::Helper

=back

=cut 

use strict;
use warnings;
use lib qw( lib );

use CGI;
use Template;
use CGI::Carp qw( fatalsToBrowser warningsToBrowser );

use Controller::Manager;
use Controller::Helper;

## TT variables for display of informative/error messages
my $tt_vars = {};
$tt_vars->{ title } = 'Wardrobe Manager';

my $cgi     = CGI->new();
## limit file uploads
$CGI::POST_MAX = 1024 * 5000;    # 5 Mb

my $manager = Controller::Manager->new();
my $tt      = Template->new(
                            {
                                INCLUDE_PATH => 'lib/View',
                                WRAPPER => 'wrapper.tt',
                            }
                          ) || die Template->error();

my $mode = sanitize($cgi->param( 'mode' ));    
$tt_vars->{ mode } = $mode;

print $cgi->header(-charset=>'utf-8');

## actions to support business requirements
if ( $mode eq 'search' ) {

	print STDERR "=== " . $cgi->param( 'clothing_name' ) . "\n";

    ( $tt_vars->{ clothings },
      $tt_vars->{ outfits } ) = $manager->search( $cgi->param( 'clothing_name' ));

} elsif( $mode eq 'upload' ) {
    $manager->upload($cgi);

} elsif( $mode eq 'tag' ) {
    $manager->tag($cgi);

} elsif( $mode eq 'add_outfit' ) {
    $manager->add_outfit($cgi->param( 'outfit_name' ));

}

## Display the page
$tt_vars->{ message } = $manager->{ message };
$tt_vars->{ error }   = $manager->{ error };
$tt->process('index.tt', $tt_vars) or die Template->error();


