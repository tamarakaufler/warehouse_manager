use strict;
use warnings;

use WardrobeManagerApi;

my $app = WardrobeManagerApi->apply_default_middlewares(WardrobeManagerApi->psgi_app);
$app;

