package WardrobeManagerApi::Controller::Tag;

use v5.018;
use utf8;

use Lingua::EN::Inflect     qw(PL);

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

use WardrobeManagerApi::Controller::Helper::Api qw(
                                                    tag_clothing
                                                    throws_error
                                              );

__PACKAGE__->config(default => 'application/json');

=head1 NAME

WardrobeManagerApi::Controller::Tag - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('in Tag index');
}

=head2 tag

tagging of clothing with outfits

tagging input can come from:
    supplied with -T/-d curl flags

=cut

sub clothes  :Path('clothing')   :ActionClass('REST') {
    my ($self, $c, @url_params) = @_;
}

sub clothes_POST {
    my ($self, $c) = @_;

    my $response_data = tag_clothing($c);
    throws_error($self, $c, $response_data);

    $self->status_created(
                        $c,
                        location => $response_data->{ location },
                        entity   => { ClothingTag => $c->req->data},
                    );
}


=encoding utf8

=head1 AUTHOR

Tamara Kaufler,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
