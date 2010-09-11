use strict;
use warnings;
use Test::More tests => 4;

use_ok 'Catalyst::Test', 'NX::Nebraska';
use_ok 'NX::Nebraska::Controller::Root';

my $request_404 = request('/test/non_existent_page');

is( $request_404->code, 404, '404 Not Found' );

my $request_500 = request('/test/internal_error');

is( $request_500->code, 500, '500 Internal Error' );
