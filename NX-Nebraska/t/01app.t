use strict;
use warnings;
use Test::More tests => 3;

use_ok 'Catalyst::Test', 'NX::Nebraska';

ok( request('/')->is_redirect, '/ redirect' );
ok( request('/compare')->is_success, '/compare Request should succeed' );
