#!/usr/bin/perl

=head1 NAME

manager.t

=head2 SYNOPSIS

in the parent dir of t dir:
                            prove t/manager.t
                            make test

=head2 DESCRIPTION

test for the Controller::Manager module

=cut

use strict;
use warnings;
use utf8;

use lib qw( ./lib ../lib );
use 5.10.0;

use Test::More tests => '24';
use Test::MockObject::Extends;

use DBI;
use CGI;
use Data::Dumper qw( Dumper );

my $dbh = DBI->connect('dbi:mysql:dbname=wardrobe', 'wardrobe', 'test');
{
    local $/ = ";\n";
    ## make sure NO BLANK LINES are present in the DATA section, otherwise MySQL will complain
    $dbh->do( $_ ) while <DATA>;
}

my $module = 'Controller::Manager';
use_ok($module);

my $manager = $module->new();

isa_ok($manager, $module);
can_ok($manager, 'new');
can_ok($manager, 'search');
can_ok($manager, 'upload');
can_ok($manager, 'tag');
can_ok($manager, 'add_outfit');

## search method
##--------------

## search for a word in the clothing name
my @search_results = $manager->search( 'Trainers', 1 );
is(scalar @search_results, 2, 'Search for "Trainers" returned 2 arrayrefs');
# clothing
is(scalar @{$search_results[0]}, 2, 'Search for "Trainers" returned 2 items of clothing');
# outfit
is(scalar @{$search_results[1]}, 6, 'Search for "Trainers" returned 6 outfits');

my $clothing = $search_results[0]->[0];
is($clothing->category->name, 'Shoes', 'Clothing item category retrieved correctly');

my @outfits = $clothing->outfits;
is(scalar @outfits, 0 , 'No outfits');

## search to pull out every item of clothing
@search_results = $manager->search( '', 1 );
# clothing
is(scalar @{$search_results[0]}, 9, 'Search returned 9 items of clothing');
# outfit
is(scalar @{$search_results[1]}, 6, 'Search returned 6 outfits');

$clothing = $search_results[0]->[0];
is($clothing->name, 'Elégant Handcrafted Clogs', 'Clothing item retrieved correctly');
$clothing = $search_results[0]->[3];
is($clothing->name, 'iSwim Summer Bikini', 'Clothing item retrieved correctly');

is($clothing->category->name, 'Bikinis', 'Clothing item category retrieved correctly');

my $outfit = $search_results[1]->[2];
is($outfit->name, 'Casual outfit 3', 'Outfit retrieved correctly');

## tag method
##-----------

my $cgi = CGI->new();
$cgi = Test::MockObject::Extends->new( $cgi );
isa_ok($cgi, 'CGI', 'mock $cgi is CGI object');

$cgi->mock( 'param', sub { 
                              my $field = shift; 
                              if ( $field eq 'clothing' ) {
                                return '6';
                              } else {
                                return (4,5,6);
                              }
                         } );
$clothing = $search_results[0]->[7];
is($clothing->name, 'Nice™ Green T', 'Clothing item retrieved correctly');
is($clothing->id, 6, 'Clothing id 6');
$manager->tag( $cgi, 1 );
@outfits = $clothing->outfits;
is(scalar @outfits, 3 , 'Clothing belongs to 3 outfits now');

## upload method
##--------------

my $upload_file;
if ( -e './documents/clothing.csv' ) {
    $upload_file = './documents/clothing.csv';
} elsif ( -e '../documents/clothing.csv' ) {
    $upload_file = '../documents/clothing.csv';
} else {
    die "Cannot find cvs upload file => dying";
}

$cgi->mock( 'param'       , sub { shift; return $upload_file } );
$cgi->mock( 'uploadInfo'  , sub { shift; return { 'Content-Type' => 'text/csv' } } );
$cgi->mock( 'tmpFileName' , sub { shift; return $upload_file } );

#--------------------------------------------------
# $cgi = CGI->new({ 
#                      file => "$upload_file",
#                       $upload_file => { 'Content-Type' => 'text/csv' },
#                 });
#-------------------------------------------------- 

$manager->upload( $cgi, 1 );
## search to pull out every item of clothing
@search_results = $manager->search( '', 1 );
# clothing
is(scalar @{$search_results[0]}, 18, 'Search returned 18 items of clothing after upload');

## add_outfit method
##------------------

$manager->add_outfit( 'Test outfit', 1 );
@outfits = $manager->schema
                   ->resultset('OutfitTest')
                   ->search(); 
is(scalar @outfits, 7, 'Number of outfits is 7 after adding one')


__END__
START TRANSACTION;
    DROP TABLE IF EXISTS clothing_test;
    DROP TABLE IF EXISTS category_test;
    DROP TABLE IF EXISTS outfit_test;
    DROP TABLE IF EXISTS clothing_outfit_test;
    CREATE TABLE category_test (
           id          INT  NOT NULL PRIMARY KEY AUTO_INCREMENT,
           name        VARCHAR(255) NOT NULL,
           INDEX (name)
    ) ENGINE=InnoDB;
    CREATE TABLE clothing_test (
           id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
           name        VARCHAR(255) NOT NULL,
           category    INT NOT NULL,
           FOREIGN KEY (category) references category_test(id),
           INDEX (name)
    ) ENGINE=InnoDB;
    CREATE TABLE outfit_test (
           id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
           name        VARCHAR(255) NOT NULL,
           INDEX (name)
    ) ENGINE=InnoDB;
    CREATE TABLE clothing_outfit_test (
           clothing     INT NOT NULL,
           outfit       INT NOT NULL,
           PRIMARY KEY (clothing, outfit)
    ) ENGINE=InnoDB;
    INSERT INTO `category_test` VALUES (1,'Bikinis'),(3,'Dresses'),(5,'Shoes'),(4,'Tops'),(2,'Trousers');
    INSERT INTO `clothing_test` VALUES (1,'iSwim Summer Bikini',1),(2,'iWalk Blue Jeans',2),(3,'iWalk Dress Trousers',2),(4,'iWalk Long White Dress',3),(5,'Nice™ Yellow Shirt',4),(6,'Nice™ Green T',4),(7,'iRun Black Trainers',5),(8,'iRun White Trainers',5),(9,'Elégant Handcrafted Clogs',5);
    INSERT INTO outfit_test VALUES (NULL, 'Casual outfit 1');
    INSERT INTO outfit_test VALUES (NULL, 'Casual outfit 2');
    INSERT INTO outfit_test VALUES (NULL, 'Casual outfit 3');
    INSERT INTO outfit_test VALUES (NULL, 'Smart outfit 1');
    INSERT INTO outfit_test VALUES (NULL, 'Smart outfit 2');
    INSERT INTO outfit_test VALUES (NULL, 'Smart outfit 3');
COMMIT;
