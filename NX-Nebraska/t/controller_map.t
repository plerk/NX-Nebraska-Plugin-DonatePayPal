use strict;
use warnings;
use feature qw( :5.10 );
use Test::More tests => 3;

use_ok 'Catalyst::Test', 'NX::Nebraska';
use_ok 'NX::Nebraska::Controller::Map';
ok( request('/map')->is_redirect, 'Request should succeed' );
