package NX::Nebraska::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
  schema_class => 'NX::Nebraska::Schema',
);

1;
