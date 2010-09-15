package NX::Nebraska::Plugin::DonatePayPal;

use strict;
use warnings;
use NX::Nebraska;
use feature qw( :5.10 );

our $VERSION = 0.01;

sub new
{
  my $ob = shift;
  my $class = ref($ob) || $ob;
  my %args = @_;
  
  # This shouldn't get called more than once, but just in case
  # we make sure that we only make our modifications to NX::Nebraska
  # on only the first call.
  state $first = 1;
  if($first)
  {
    NX::Nebraska->nav([ '/doc/donate' => 'Donate' ]);  
    NX::Nebraska->ziyal_var->{paypal_hosted_button_id} = $args{hosted_button_id};
    $first = 0;
  }
  
  return bless {
    hosted_button_id => $args{hosted_button_id},
  }, $class;
}

sub donate_button
{
  my $self = shift;
  my $hosted_button_id = $self->{hosted_button_id};
  return <<END;
<form action="https://www.paypal.com/cgi-bin/webscr" method="post">
<input type="hidden" name="cmd" value="_s-xclick" />
<input type="hidden" name="hosted_button_id" value="$hosted_button_id" />
<input type="image" src="https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!" />
<img alt="" border="0" src="https://www.paypal.com/en_US/i/scr/pixel.gif" width="1" height="1" />
</form>
END
}

sub hosted_button_id
{
  shift->{hosted_button_id};
}

1;