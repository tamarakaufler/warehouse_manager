use strict;
use warnings;

use WardrobeManager;

my $app = WardrobeManager->apply_default_middlewares(WardrobeManager->psgi_app);
$app;

