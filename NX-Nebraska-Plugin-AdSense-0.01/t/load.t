use strict;
use warnings;
use feature qw( :5.10 );
use Test::More tests => 8;

use_ok('NX::Nebraska::Plugin::AdSense');

my $ad = new NX::Nebraska::Plugin::AdSense(
  google_ad_client => 'pub-1',
  google_ad_slot_wide => '1234',
  google_ad_slot_box => '5678',
  google_ad_slot_rectangle => '9012',
);

isnt($ad, undef, "created AdSense object");

my $wide = eval { $ad->ad_wide };
my $rectangle = eval { $ad->ad_rectangle };
my $box = eval { $ad->ad_box };

isnt($wide, undef, 'wide is not undef');
isnt($wide, '', 'wide is not empty');

isnt($rectangle, undef, 'rectangle is not undef');
isnt($rectangle, '', 'rectangle is not empty');

isnt($box, undef, 'box is not undef');
isnt($box, '', 'box is not empty');
