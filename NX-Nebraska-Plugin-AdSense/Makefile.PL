use inc::Module::Install;

name 'NX-Nebraska-Plugin-AdSense';
version_from 'lib/NX/Nebraska/Plugin/AdSense.pm';
requires 'NX::Nebraska' => '0.05';
abstract 'Provide AdSense ads to Project Nebraska website';
license 'bsd';
perl_version '5.010';
WriteAll;
