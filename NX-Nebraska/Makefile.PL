#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'NX-Nebraska';
version_from 'lib/NX/Nebraska.pm';
license 'bsd';
author 'Project Nebraska Team <nx.nebraska@gmail.com>';
perl_version '5.010';
abstract 'Project Nebraska Website';

# Originally Catalyst generated this file 
# requiring the latest version on Debian
# squeeze 5.80025, where it was generated
# but I wanted to be able to run this on 
# Ubuntu 10.04 which only had 5.80022.
# Presumably 5.80022 is good enough?
requires 'Catalyst::Runtime' => '5.80022';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode::Encoding' => 1.1;
requires 'Catalyst::Plugin::StackTrace';

requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::PerUser';

requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::Model::DBIC::Schema';
requires 'File::HomeDir';
requires 'Text::CSV_XS';
requires 'SQL::Translator';
requires 'DBD::mysql';
requires 'DBD::SQLite';
requires 'Moose';
requires 'NX::Ziyal' => '0.03';
requires 'List::Util';
requires 'namespace::autoclean';
requires 'DateTime::Format::MySQL';
requires 'JSON::XS';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
test_requires 'Test::More' => '0.88';
#catalyst;

feature 'JavaScript compression',
  -default => 0,
  'Javascript::Closure' => 0,
  'YAML' => 0;

feature 'Cacheing using Cache::Memcached::Fast (recommended)',
  -default => 1,
  'Cache::Memcached::Fast' => 0;

feature 'User country code detection',
  -default => 0,
  'Geo::IP' => 0;

feature 'Flickr authentication and pictures',
  -default => 0,
  'Flickr::API' => 0,
  'NX::Flickr' => 0;

eval "use Cache::Memcached::Fast";
if($@)
{

  feature 'Cacheing using Cache::Memcached (only used in the absence of Cache::Memcached::Fast)',
    -default => 0,
    'Cache::Memcached' => 0;

  feature 'Cacheing using Cache::Memcached::Mock (only used in the absence of Cache::Memcached and ::Fast)',
    -default => 0,
    'Cache::Memcached::Mock' => 0;
}

install_script glob('script/nx_nebraska_{cgi,fastcgi,import,server,jspack,trip_setup}');
auto_install;
WriteAll;
