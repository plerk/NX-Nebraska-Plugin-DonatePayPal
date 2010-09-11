use strict;
use warnings;
use Test::More tests => 3;

use_ok 'Catalyst::Test', 'NX::Nebraska';
use_ok 'NX::Nebraska::Controller::Place';
ok( request('/place')->is_success, 'Request should succeed' );
