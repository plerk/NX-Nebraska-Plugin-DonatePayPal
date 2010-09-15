package NX::Nebraska::View::TT::HTML;

use strict;
use warnings;

use base 'NX::Nebraska::View::TT';

__PACKAGE__->config(
  WRAPPER => 'wrapper.html.tt2',
);

1;
