package WardrobeManagerApi;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.90;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

# Add Cache Plugin for caching
use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple

    Session
    Session::Store::FastMmap
    Session::State::Cookie
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in wardrobemanagerapi.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'WardrobeManagerApi',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header

    ENCODING     => 'utf-8',

#    'Plugin::Cache' => { backend => {
#        				class   => "Cache::Memcached",
#        				servers => ['127.0.0.1:11211'],
#        				debug   => 2,
#				    },
#		       },
);

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

WardrobeManagerApi - Catalyst based application

=head1 SYNOPSIS

    script/wardrobemanagerapi_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<WardrobeManagerApi::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Tamara Kaufler,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
