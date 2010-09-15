use inc::Module::Install;

name 'NX-Nebraska-Plugin-DonatePayPal';
version_from 'lib/NX/Nebraska/Plugin/DonatePayPal.pm';
requires 'NX::Nebraska' => '0.05';
abstract 'Provide a donate via PayPal button Project Nebraska website';
license 'bsd';
perl_version '5.010';
WriteAll;
