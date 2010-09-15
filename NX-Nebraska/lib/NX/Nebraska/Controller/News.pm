package NX::Nebraska::Controller::News;

use Moose;
use NX::Nebraska::NewsItem;
use feature qw( :5.10 );
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

# The /news location is the interface to the websites blog
# or news article function.

# /news prints the 10 most recent news items in
# order from most recent to least.
sub index :Path :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  $c->stash(
    title => 'Project News',
    news_items => [$c->get_news],
    template => 'news/index.tt2',
  );
}

sub working_news :Chained('base') :PathPart('working') :Args(0)
{
  my $self = shift;
  my $c = shift;
  $c->stash(
    title => 'Project News',
    news_items => [$c->get_news(include_working_news => 1)],
    template => 'news/index.tt2',
  );
}

# /news/rss provides a RSS feed of the ten most 
# recent news items.
sub rss :Chained('base') :PathPart('rss') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my $base_url = $c->uri_for('/');
  $base_url =~ s!/$!!;
  
  $c->stash(
    title => 'Project Nebraska',
    base_url => $base_url,
    description => 'Updates and news from Project Nebraska',
    last_build_date => NX::Nebraska::NewsItem->timerss(time),
    generator => 'NX::Nebraska',
    news_items => [$c->get_news],
    template => 'news/rss.tt2',
  );
  $c->response->content_type('text/xml');
  $c->forward($c->view('TT::XML'));
}

# /news/item/[id]/view prints the news item with the given
# [id]
sub view :Chained('item') :PathPart('view') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my($news_item) = $c->get_news(id => $c->stash->{item_id});
  
  $c->stash(
    title => 'Project Nebraska',
    news_item => $news_item,
    template => 'news/view.tt2',
  );
}

sub item :Chained('base') :PathPart('item') :CaptureArgs(1)
{
  my $self = shift;
  my $c = shift;
  my $id = shift;
  $c->stash(item_id => $id);
}

sub base :Chained('/') :PathPart('news') :CaptureArgs(0)
{
  my $self = shift;
  my $c = shift;
}

__PACKAGE__->meta->make_immutable;

1;
