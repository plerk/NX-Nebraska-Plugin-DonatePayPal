use strict;
use warnings;
use Test::More tests => 3;

use_ok 'Catalyst::Test', 'NX::Nebraska';
use_ok 'NX::Nebraska::Controller::News';
ok( request('/news')->is_success, 'Request should succeed' );
