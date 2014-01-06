#!/usr/bin/env perl
use inc::Module::Install;

name 'Catalyst-Authentication-Credential-FBConnect-Nebraska';
version_from 'lib/Catalyst/Authentication/Credential/FBConnect/Nebraska.pm';
license 'perl';
author 'Project Nebraska Team <nx.nebraska@gmail.com>';
abstract 'Facebook authentication for Project Nebraska website';
perl_version '5.010';

requires 'MooseX::Types';
requires 'MooseX::Types::Common';
requires 'namespace::autoclean';
requires 'WWW::Facebook::API';
requires 'Moose';
build_requires 'Catalyst::Runtime';
build_requires 'Test::WWW::Mechanize::Catalyst';
build_requires 'Test::More';
build_requires 'ok';

auto_install();
WriteAll();
