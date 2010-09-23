package NX::Nebraska::Model::User;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'NX::Nebraska::User',
);

1;
