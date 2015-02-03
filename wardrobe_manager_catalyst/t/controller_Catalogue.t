use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'WardrobeManager' }
BEGIN { use_ok 'WardrobeManager::Controller::Catalogue' }

ok( request('/catalogue')->is_success, 'Request should succeed' );
done_testing();
