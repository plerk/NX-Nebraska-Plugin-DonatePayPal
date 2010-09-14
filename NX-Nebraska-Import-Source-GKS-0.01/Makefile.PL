use inc::Module::Install;

name 'NX-Nebraska-Import-Source-GKS';
version_from 'lib/NX/Nebraska/Import/Source/GKS.pm';
requires 'NX::Nebraska' => 0.05;
requires 'Spreadsheet::ParseExcel';
abstract 'Import source for Russian values in Project Nebraska database';
license 'bsd';
perl_version '5.010';
WriteAll;
