package NX::Nebraska::Controller::Trip;

use Moose;
use feature qw( :5.10 );
use namespace::autoclean;
use NX::Nebraska;
use List::Util (); # for shuffle
use JSON::XS ();

BEGIN {extends 'Catalyst::Controller'; }

use constant JS => [ map { "/js/NX/Nebraska/$_.js" } qw( 
  Debug 
  Map 
  PopUp 
  Ajax 
  PageLocation 
  Util
  JSON
  Flickr/Main
  Flickr/Photo
  Flickr/PhotoURL
  Flickr/Picker
  Trip/Factoid
  Trip/Visit
  Trip/Place
  Trip/Map
  Trip/Main
) ];

sub index :Chained('/') :PathPart('app/trip') :Args(0)
{
  my $self = shift;
  my $c = shift;
  $c->response->redirect('/app/trip/edit');
}

sub view :Chained('/') :PathPart('app/trip/view') :Args(3)
{
  my $self = shift;
  my $c = shift;
  my $realm_name = shift;
  my $user_name = shift;
  my $map_id = shift;
  
  my $cache_data;
  my $cache_key = join(':', app => 'trip', $realm_name, $user_name, $map_id);
  if(my $tmp = $c->memd->get($cache_key))
  {
    if(ref $tmp eq 'ARRAY')
    {
      $cache_data = $tmp;
    }
    else
    {
      warn "bad user/realm cache\n";
      $c->stash($c->ziyal('404'));
      $c->response->status(404);
      return;
    }
  }
  else
  {
    my $view_user;
    eval {
      die "anon user" if $realm_name eq 'anonymous';
      my $realm = $c->model('User::Realm')->search({ name => $realm_name })->first;
      die "bad realm" unless defined $realm;
      $view_user = $c->model('User::User')->search({ name => $user_name })->first;
      die "bad user" unless defined $view_user;
    };
    if($@)
    {
      warn "$@\n";
      # negative cacheing for a half hour
      $c->memd->set($cache_key => 'BAD', 30*60);
      $c->stash($c->ziyal('404'));
      $c->response->status(404);
      return;
    }
    
    my @cache_data;
    push @cache_data, username => $view_user->name,
                      realmname => $view_user->realm->name;
    push @cache_data, js => [ map { "/js/NX/Nebraska/$_.js" } qw( Util PageLocation Debug PopUp Map Flickr/Photo Flickr/PhotoURL Trip/View )];
  
    push @cache_data, available_maps => [ map { { id => $_->id, name => $_->name } } $c->model('DB::MapWithTripPlace')->all ];
    my @visit_data;
    my @small_list;
    
    foreach my $visit ($c->model('User::TripVisit')->search({ user_id => $view_user->id })->all)
    {
      my $trip_place_map = $c->model('DB::TripPlaceMap')->search({ 
        trip_place_id => $visit->trip_place_id, 
        map_id => $map_id
      })->first;
    
      next unless defined $trip_place_map;
      
      my $place = $c->model('DB::TripPlace')->search({ id => $visit->trip_place_id })->first;
      
      my $h = {
        place => {
          map_code => $trip_place_map->map_code,
          name => $place->name,
          small => $trip_place_map->small,
        },
        visit => {
          user_comment => $visit->user_comment,
        },
      };
      
      if($place->flag)
      {
        if(defined $place->region_code)
        {
          $h->{place}->{flag} = lc($place->country_code . '-' . $place->region_code . ".png");
        }
        else
        {
          $h->{place}->{flag} = lc($place->country_code . ".png");
        }
      }
      
      $h->{visit}->{youtube_video_id} = $visit->youtube_video_id
        if defined $visit->youtube_video_id;

      $h->{visit}->{flickr_photo} = $visit->flickr_photo->to_json_hash
          if defined $visit->flickr_photo;
      
      push @visit_data, $h;
      
      if($trip_place_map->small)
      {
        push @small_list, {
          map_code => $trip_place_map->map_code,
          name => $place->name,
        };
      }
    }
    
    push @cache_data, visit_data => JSON::XS::encode_json(\@visit_data),
                      small_list => \@small_list;
    $cache_data = \@cache_data;
    # positive cacheing for 5 minutes
    $c->memd->set($cache_key => $cache_data, 60*5);
  }
  
  my $place_map_code;
  $place_map_code = $1 if defined $c->request->param('place_map_code') && $c->request->param('place_map_code') =~ /^([a-zA-Z]+)$/;
  
  $c->stash(
    @$cache_data,
    map_code => $map_id,
    template => 'app/trip/view.tt2',
    place_map_code => $place_map_code,
    icon_name => 'trip',
    icon_url => '/app/trip',
  );
}

sub edit :Chained('/') :PathPart('app/trip/edit') :Args(0) 
{
  my $self = shift;
  my $c = shift;
  
  my($news_item) = $c->get_news(limit => 1);
  
  my($cache_data, $maps) = $c->app_extras({
    short_app_name => 'trip',
    js_list => JS,
    map_list_class => 'DB::MapWithTripPlace',
  });
  
  my $has_flickr_account = 0;
  if($c->user_exists)
  {
    my $flickr_user_id = eval { $c->user->get_object->user->flickr_user_id };
    $has_flickr_account = 1 if defined $flickr_user_id;
  }
  
  my $map_code = $c->request->param('map_code');
  
  my @rand_maps = map { $_->{id} } @$maps;
  
  unless(defined $map_code)
  {
    my $size = int @rand_maps;
    my $i = int rand $size;
    $map_code = splice @rand_maps, $i, 1;
  }
  
  die "bad map" unless $map_code =~ /^[a-z][a-z][12]$/;
  
  $c->stash(
    news_item => $news_item,
    map_code => $map_code,
    template => 'app/trip/edit.tt2',
    @$cache_data,
    icon_name => 'trip',
    icon_url => '/app/trip',
    has_flickr_account => $has_flickr_account,
  );
}

sub visits :Chained('/') :PathPart('app/trip/visits') :Args(1)
{
  my $self = shift;
  my $c = shift;
  my $map_id = shift;
  
  # this will give the user a 500 error when provided with a bogus
  # map id, but since the users shouldn't be using this interface 
  # directly anyway we consider this to not be a problem.
  die "invalid map name" unless $map_id =~ /^[a-z][a-z][0-9]$/;
  
  my $places;
  my $cache_key = 'app:trip:visits:' . $map_id;
  unless($places = $c->memd->get($cache_key))
  {
    $places = [map { $_->trip_place_id } $c->model('DB::TripPlaceMap')->search({ map_id => $map_id })->all];
    $c->memd->set($cache_key => $places, 60*60);
  }
  
  my $user_id = $c->trip_user_id;
  
  my @data;
  
  foreach my $trip_visit ($c->model('User::TripVisit')->search({ user_id => $user_id, trip_place_id => $places })->all)
  {
    my $h = {
      id => $trip_visit->id,
      trip_place_id => $trip_visit->trip_place_id,
      user_comment => $trip_visit->user_comment,
    };
    $h->{youtube_video_id} = $trip_visit->youtube_video_id
       if defined $trip_visit->youtube_video_id;
    $h->{flickr_photo} = $trip_visit->flickr_photo->to_json_hash
      if defined $trip_visit->flickr_photo;
    push @data, $h;
  }
  
  $c->stash(
    current_view => 'JSON',
    json_data => \@data,
  );
}

sub update :Chained('/') :PathPart('app/trip/update') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  use JSON ();
  my $update_list = JSON::from_json($c->request->param('update'));
  my $delete_list = JSON::from_json($c->request->param('delete'));
  
  my $trip_user_id = $c->trip_user_id;
  
  my $data = { update => [], delete => [], };
  
  foreach my $id (@{ $delete_list })
  {
    $c->model('User::TripVisit')->search({ id => $id, user_id => $trip_user_id })->delete;
    push @{ $data->{delete} }, $id;
  }
  
  foreach my $entry (@{ $update_list })
  {
    my $visit;
    
    my $youtube_video_id = $entry->{youtube_video_id};
    if(defined $youtube_video_id && $youtube_video_id !~ /^[A-Za-z0-9\-]+$/) # don't allow any funny characters
    {
      $youtube_video_id = undef;
    }
  
    if(defined $entry->{id})
    {
      $visit = $c->model('User::TripVisit')->search({ id => $entry->{id} })->first;
      if(defined $visit && $visit->user_id == $trip_user_id)
      {
        $visit->user_comment($entry->{user_comment});
        $visit->youtube_video_id($youtube_video_id);
        $visit->update;
      }
    }
    elsif(defined $entry->{trip_place_id} && $entry->{trip_place_id} =~ /^[0-9]+$/)
    {
      $visit = $c->model('User::TripVisit')->create({
        trip_place_id => $entry->{trip_place_id},
        user_comment => $entry->{user_comment},
        user_id => $trip_user_id,
        youtube_video_id => $youtube_video_id,
      });
    }
    
    my $flickr_user = $c->flickr_user;

    if(defined $flickr_user)
    {
      my $flickr_photo = $visit->flickr_photo;
      
      # IF there is a photo in the database, but it doesn't match the photo that we are updating,
      # OR there is a photo in the database, but the user has removed it
      # THEN remove the flickr_photo, its flickr_photo_urls and its reference
      if((defined $entry->{flickr_photo} && defined $flickr_photo && $flickr_photo->flickr_webservice_id ne $entry->{flickr_photo}->{id})
      || (!defined $entry->{flickr_photo}))
      {
        $visit->flickr_photo_id(undef);
        # we do not delete the photos immeidately from the database,
        # because they may be referenced from other visit object
        # (they shouldn't but there is really not way to easily
        # enforce that on the user).  We WILL however, periodically
        # purge the database of photos which are not referenced 
        # anywhere.
      }
    
      # IF there is no photo in the database (or it was just delted in the above block), but the user has selected a photo
      # THEN add the flickr_photo, its flickr_photo_urls and link it with the trip_visit
      if(defined $entry->{flickr_photo} && !defined $flickr_photo)
      {
        $flickr_photo = $c->model('User::FlickrPhoto')->search({
          flickr_webservice_id => $entry->{flickr_photo}->{id}
        })->first;
        
        unless(defined $flickr_photo)
        {
          $flickr_photo = $c->model('User::FlickrPhoto')->create({
            # should really check that this user has a linked flickr account
            user_id => $trip_user_id,
            flickr_webservice_id => $entry->{flickr_photo}->{id},
            title => $entry->{flickr_photo}->{title},
            url => $entry->{flickr_photo}->{url},
          });
          while(my($type, $photo_url) = each %{ $entry->{flickr_photo}->{photo_url} })
          {
            $c->model('User::FlickrPhotoUrl')->create({
              flickr_photo_id => $flickr_photo->id,
              type => $type,
              width => $photo_url->{width},
              height => $photo_url->{height},
              url => $photo_url->{url},
            });
          }
        }
        $visit->flickr_photo_id($flickr_photo->id);
        $visit->update;
      }
    
      # IF there is no photo in the database (or it was just deleted in the first block above), and the user has not selected a photo since,
      # THEN we don't have to do anything.
      if(0)
      {
        # This would be the perfect place for the ... operator IF we were using Perl 5.12
      }
    }
    
    if(defined $visit)
    {
      push @{ $data->{update} }, { 
        id => $visit->id, 
        trip_place_id => $visit->trip_place_id,
        user_comment => $visit->user_comment,
        youtube_video_id => $entry->{youtube_video_id},
      }
    }
    
  }
  
  $c->stash(
    current_view => 'JSON',
    json_data => $data,
  );
}

sub places :Chained('/') :PathPart('app/trip/places') :Args(1) 
{
  my $self = shift;
  my $c = shift;
  my $map_id = shift;
  
  # this will give the user a 500 error when provided with a bogus
  # map id, but since the users shouldn't be using this interface 
  # directly anyway we consider this to not be a problem.
  die "invalid map name" unless $map_id =~ /^[a-z][a-z][0-9]$/;
  
  my $cache_key = 'app:trip:places:' . $map_id;
  
  my $data;
  
  unless($data = $c->memd->get($cache_key))
  {
    my @data;
    my $map = $c->model('DB::Map')->search({ id => $map_id })->first;
    foreach my $trip_place_map ($map->trip_place_maps)
    {
      my $map_code = $trip_place_map->map_code;
      my $trip_place = $trip_place_map->trip_place;
      
      my $h = {
        id => $trip_place->id,
        country_code => $trip_place->country_code,
        region_code => $trip_place->region_code,
        name => $trip_place->name,
        map_code => $map_code,
        small => $trip_place_map->small,
        factoid => [],
      };
      push @data, $h;
      
      if($trip_place->flag)
      {
        if(defined $trip_place->region_code)
        {
          $h->{flag} = lc $trip_place->country_code . "-" . lc $trip_place->region_code . ".png";
        }
        else
        {
          $h->{flag} = lc $trip_place->country_code . ".png";
        }
      }
      
      foreach my $factoid (List::Util::shuffle($trip_place->factoids))
      {
        push @{ $h->{factoid} }, { text => $factoid->factoid, url => $factoid->url };
      }
    }
    $data = \@data;
    $c->memd->set($cache_key => $data, 60*60);
  }
  
  $c->stash(
    current_view => 'JSON',
    json_data => $data,
  );
}

sub merge :Chained('/') :PathPart('app/trip/merge') :Args(0)
{
  my $self = shift;
  my $c = shift;
  
  my $real_user_id = $c->trip_user_id({try_real_user => 1});
  my $anon_user_id = $c->trip_user_id({try_real_user => 0});
  
  my $data = {
    real_user_id => $real_user_id,
    anon_user_id => $anon_user_id,
    merged => 0,
    dropped => 0,
  };
  
  if($real_user_id != $anon_user_id)
  {
    foreach my $trip_place1 ($c->model('User::TripVisit')->search({ user_id => $anon_user_id })->all)
    {
      my $trip_place2 = $c->model('User::TripVisit')->search({ 
        user_id => $real_user_id,
        trip_place_id => $trip_place1->trip_place_id,
      })->first;
      if(defined $trip_place2)
      {
        $data->{dropped}++;
        $trip_place1->delete;
      }
      else
      {
        $data->{merged}++;
        $trip_place1->user_id($real_user_id);
        $trip_place1->update;
      }
    }
    $c->trip_user_id({ recycle => 1 });
  }

  $c->stash(
    current_view => 'JSON',
    json_data => $data,
  );
}

__PACKAGE__->meta->make_immutable;

1;
