/*
 * Project Nebraska Trip Journal Trip Place
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Trip === undefined) NX.Nebraska.Trip = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  var flickr_picker = null;
  
  
  NX.Nebraska.Trip.Visit = function(aId, aTripPlaceId, aUserComment, aYouTubeId, aFlickrPhoto)
  {
    this.id = aId;
    this.tripPlaceId = aTripPlaceId;
    this.userComment = aUserComment;
    this.youTubeId = aYouTubeId;
    this.flickrPhoto = aFlickrPhoto;
    if(aId == null)
      this.setDirty();
    else
      this.clearDirty();
  };
  
  NX.Nebraska.Trip.Visit.prototype.getId = function() { return this.id; };
  NX.Nebraska.Trip.Visit.prototype.setId = function(aNewId) { this.id = aNewId; }; 
  NX.Nebraska.Trip.Visit.prototype.getTripPlaceId = function() { return this.tripPlaceId; };
  NX.Nebraska.Trip.Visit.prototype.getUserComment = function() { return this.userComment; };
  NX.Nebraska.Trip.Visit.prototype.isDirty = function() { return this.dirty; };
  NX.Nebraska.Trip.Visit.prototype.clearDirty = function() { this.dirty = false; };
  NX.Nebraska.Trip.Visit.prototype.getYouTubeId = function() { return this.youTubeId; };
  NX.Nebraska.Trip.Visit.prototype.getFlickrPhoto = function() { return this.flickrPhoto; };
  
  NX.Nebraska.Trip.Visit.prototype.setDirty = function()
  {
    NX.Nebraska.Trip.Main.triggerUpdate();
    this.dirty = true;
  };
  
  NX.Nebraska.Trip.Visit.prototype.setUserComment = function(aNewValue)
  {
    if(aNewValue != this.userComment)
    {
      this.userComment = aNewValue;
      this.setDirty();
    }
  };
  
  NX.Nebraska.Trip.Visit.prototype.toJSON = function()
  {
    var obj = {};
    if(this.getId() != null)
      obj.id = this.getId();
    obj.trip_place_id = this.getTripPlaceId();
    obj.user_comment = this.getUserComment();
    if(this.getYouTubeId() != null)
      obj.youtube_video_id = this.getYouTubeId();
    if(this.getFlickrPhoto() != null)
      obj.flickr_photo = this.getFlickrPhoto();
    return obj;
  };
  
  NX.Nebraska.Trip.Visit.prototype.guiAddVideo = function()
  {
    NX.Nebraska.Flickr.Main.hidePicker();
    var video_id = prompt("Please enter the YouTube video ID or URL","");
    if(video_id == null)
      return;
    if(video_id == '')
    {
      alert('Empty ID or URL');
      return;
    }
    video_id = video_id.replace(/^.*=/,'');
    if(video_id.match(/^[a-zA-Z0-9\-]+$/))
    {
      this.youTubeId = video_id;
      this.setDirty();
      this.guiDisplayVideo();
    }
    else
    {
      alert('Bad ID or URL');
      return;
    }
  };
  
  NX.Nebraska.Trip.Visit.prototype.guiRemoveVideo = function()
  {
    this.youTubeId = null;
    this.setDirty();
    this.guiDisplayVideo();
  };
  
  var VIDEO_WIDTH = 280*4/5;
  var VIDEO_HEIGHT = 170*4/5;
  var button_display = 'block';
  
  NX.Nebraska.Trip.Visit.prototype.guiDisplayVideo = function()
  {
    if(this.getYouTubeId() == null)
    {
      document.getElementById('youtube_video_div').innerHTML = '';
      document.getElementById('youtube_video_button_add').style.display = button_display;
      document.getElementById('youtube_video_button_remove').style.display = 'none';
      return;
    }
    
    document.getElementById('youtube_video_button_add').style.display = 'none';
    document.getElementById('youtube_video_button_remove').style.display = button_display;
    
    var div = document.getElementById('youtube_video_div');
    div.innerHTML = '<object width="' + VIDEO_WIDTH + '" height="' + VIDEO_HEIGHT + '">' +
                      '<param name="movie" value="http://www.youtube.com/v/' + this.getYouTubeId() + '?fs=1&amp;hl=en_US&amp;rel=0"></param>' +
                      '<param name="allowFullScreen" value="true"></param>' +
                      '<param name="allowscriptaccess" value="always"></param>' +
                      '<embed src="http://www.youtube.com/v/' + this.getYouTubeId() + '?fs=1&amp;hl=en_US&amp;rel=0" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="' + VIDEO_WIDTH + '" height="' + VIDEO_HEIGHT + '"></embed>' +
                    '</object>';
  };
  
  NX.Nebraska.Trip.Visit.prototype.guiAddPicture = function()
  {
    var self = this;
    NX.Nebraska.Flickr.Main.getRecentPhotos(function(aPhotoList)
    {
      var picker = new NX.Nebraska.Flickr.Picker(aPhotoList, function(aPhoto)
      {
        self.flickrPhoto = aPhoto;
        self.setDirty();
        self.guiDisplayPicture();
      });
      
      picker.show();
    });
  };
  
  NX.Nebraska.Trip.Visit.prototype.guiRemovePicture = function()
  {
    this.flickrPhoto = null;
    this.setDirty();
    this.guiDisplayPicture();
  };
  
  var has_flickr_account = null;
  
  NX.Nebraska.Trip.Visit.prototype.guiDisplayPicture = function()
  {
    if(has_flickr_account == null)
    {
      if(parseInt(document.getElementById('has_flickr_account').value) == 0)
        has_flickr_account = false;
      else
        has_flickr_account = true;
    }
    
    if(!has_flickr_account)
    {
      document.getElementById('flickr_picture_div').innerHTML = '';
      document.getElementById('flickr_picture_button_add').style.display = 'none';
      document.getElementById('flickr_picture_button_remove').style.display = 'none';
      return;
    }
  
    if(this.getFlickrPhoto() == null)
    {
      document.getElementById('flickr_picture_div').innerHTML = '';
      document.getElementById('flickr_picture_button_add').style.display = button_display;
      document.getElementById('flickr_picture_button_remove').style.display = 'none';
      return;
    }
    
    document.getElementById('flickr_picture_button_add').style.display = 'none';
    document.getElementById('flickr_picture_button_remove').style.display = button_display;
    
    document.getElementById('flickr_picture_div').innerHTML = this.getFlickrPhoto().render('s', 250, 200, 'flickr_picture_img');
    document.getElementById('flickr_picture_img').style.marginTop = (220-document.getElementById('flickr_picture_img').height) + 'px';
    
  };
  
  /*
   * ====================================================================
   */

})();