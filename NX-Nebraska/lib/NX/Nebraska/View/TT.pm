package NX::Nebraska::View::TT;

use strict;
use warnings;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
  TEMPLATE_EXTENSION => '.tt2',
  render_die => 1,
  INCLUDE_PATH => [
    NX::Nebraska->path_to('tmpl'),
  ],
);

1;
