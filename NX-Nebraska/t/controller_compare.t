BEGIN { $ENV{DBIC_TRACE} = 0 }
use strict;
use warnings;
use Test::More tests => 5;

use_ok 'Catalyst::Test', 'NX::Nebraska';
use_ok 'NX::Nebraska::Controller::Compare';
ok( request('/app/compare')->is_success, 'Request should succeed' );

my $old_location = request('/compare');
ok( $old_location->is_redirect, "/compare redirects");

is($old_location->header('location'), '/app/compare', "/compare => /app/compare");