package NX::Nebraska::Plugin::AdSense;

use strict;
use warnings;
use feature qw( :5.10 );

our $VERSION = '0.01';

sub new
{
  my $ob = shift;
  my $class = ref($ob) || $ob;
  my %args = @_;
  return bless {
    google_ad_client => $args{google_ad_client},
    google_ad_slot_wide => $args{google_ad_slot_wide},
    google_ad_slot_box => $args{google_ad_slot_box},
    google_ad_slot_rectangle => $args{google_ad_slot_rectangle},
  }, $class;
}

# 720x90px
sub ad_wide
{
  my $self = shift;
  my $google_ad_client = $self->{google_ad_client};
  my $google_ad_slot = $self->{google_ad_slot_wide};
  return <<END;
<script type="text/javascript"><!--
google_ad_client = "$google_ad_client";
google_ad_slot = "$google_ad_slot";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
END
}

sub ad_rectangle
{
  my $self = shift;
  my $google_ad_client = $self->{google_ad_client};
  my $google_ad_slot = $self->{google_ad_slot_rectangle};
  return <<END;
<script type="text/javascript"><!--
google_ad_client = "$google_ad_client";
google_ad_slot = "$google_ad_slot";
google_ad_width = 300;
google_ad_height = 250;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
END
}

sub ad_box
{
  my $self = shift;
  my $google_ad_client = $self->{google_ad_client};
  my $google_ad_slot = $self->{google_ad_slot_box};
  return <<END;
<script type="text/javascript"><!--
google_ad_client = "$google_ad_client";
google_ad_slot = "$google_ad_slot";
google_ad_width = 125;
google_ad_height = 125;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
END
}

1;
