package WardrobeManagerApi::Controller::Helper::Docs;

=head2 WardrobeManagerApi::Controller::Helper::Docs

helper class for Controller Docs

=cut

use v5.018;
use utf8;
use open ':encoding(UTF-8)';

use Moose;
use namespace::autoclean;

# --------------------------------- PUBLIC ACCESSORS ---------------------------------

=head2 Public methods
                       clothing_api_doc 
                       category_api_doc 
                       outfit_api_doc 
                       clothing_outfit_api_doc 
=cut

has clothing_api_doc => (
                            is      => 'ro',
                            isa     => 'HashRef',
                            builder  => 'clothing_doc',
                        );

has category_api_doc => (
                            is      => 'ro',
                            isa     => 'HashRef',
                            builder  => 'category_doc',
                        );

has outfit_api_doc   => (
                            is      => 'ro',
                            isa     => 'HashRef',
                            builder  => 'outfit_doc',
                        );

has clothing_outfit_api_doc => (
                            is      => 'ro',
                            isa     => 'HashRef',
                            builder  => 'clothing_outfit_doc',
                        );


=head3 clothing_doc

=cut

sub clothing_doc {
    my ($self) = @_;

    my $get_examples =  [
                            "curl -X GET  http://localhost:3010/api/clothing/id/3",
                            "curl -X GET  http://localhost:3010/api/clothing/outfit/3",
                            "curl -X GET  http://localhost:3010/api/clothing/name/iRun%20White%20Trainers",
                        ];
    my $post_examples = [
                            "curl -X POST -F 'file=\@clothing.csv'  http://localhost:3010/api/clothing",
                            "curl -X POST -F 'file=\@clothing.json' http://localhost:3010/api/clothing",
                        ];

    my $help = {
                    "GET requests:"  => $get_examples,
                    "POST requests:" => $post_examples,
               };
}


=head3 category_doc

=cut

sub category_doc {
    my ($self) = @_;

    my $get_examples =  [
                            "curl -X GET  http://localhost:3010/api/category/id/3",
                            "curl -X GET  http://localhost:3010/api/category/name/Shoes",
                        ];
    my $post_examples = [
                            "curl -X POST -F 'file=\@clothing.csv'  http://localhost:3010/api/clothing",
                            "curl -X POST -F 'file=\@clothing.json' http://localhost:3010/api/category",
                        ];

    my $help = {
                    "GET requests:"  => $get_examples,
                    "POST requests:" => $post_examples,
               };
}

=head3 outfit_doc

=cut

sub outfit_doc {
    my ($self) = @_;

    my $get_examples =  [
                            "curl -X GET  http://localhost:3010/api/outfit/id/3",
                            "curl -X GET  http://localhost:3010/api/outfit/name/Smart%20times",
                        ];
    my $post_examples = [
                        ];

    my $help = {
                    "GET requests:"  => $get_examples,
                    "POST requests:" => $post_examples,
               };

}

=head3 clothingi_outfit_doc

=cut

sub clothing_outfit_doc {
    my ($self) = @_;

    my $get_examples =  [
                            "curl -X GET  http://localhost:3010/api/clothing/outfit/3",
                        ];
    my $post_examples = [
                        ];

    my $help = {
                    "GET requests:"  => $get_examples,
                    "POST requests:" => $post_examples,
               };
}

1;
