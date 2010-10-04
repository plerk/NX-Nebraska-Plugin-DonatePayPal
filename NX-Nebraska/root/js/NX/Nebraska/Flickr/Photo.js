/*
 * Project Nebraska
 * 
 * Some utility functions that don't really belong anywhere else.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Flickr === undefined) NX.Nebraska.Flickr = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  NX.Nebraska.Flickr.Photo = function(aArgs)
  {
    this.url = aArgs.url;
    this.id = aArgs.id;
    this.title = aArgs.title;
    if(aArgs.photoUrls != null)
      this.photoUrls = aArgs.photoUrls;
    else if(aArgs.photo_urls != null)
    {
      this.photoUrls = {};
      var len = aArgs.photo_urls.length;
      for(var i=0; i<len; i++)
        this.photoUrls[aArgs.photo_urls[i].type] = new NX.Nebraska.Flickr.PhotoURL(aArgs.photo_urls[i]);
    }
    else
      this.photoUrls = {};
  };
  
  NX.Nebraska.Flickr.Photo.prototype.getUrl = function() { return this.url; };
  NX.Nebraska.Flickr.Photo.prototype.getId = function() { return this.id; };
  NX.Nebraska.Flickr.Photo.prototype.getTitle = function() { return this.title; };
  NX.Nebraska.Flickr.Photo.prototype.getPhotoUrls = function() { return this.photoUrls; };
  
  NX.Nebraska.Flickr.Photo.prototype.render = function(aType, aMaxWidth, aMaxHeight, aId) 
  {
    return '<a href="' + this.getUrl() + '">' + 
           this.photoUrls[aType].render(this.getTitle(), aMaxWidth, aMaxHeight, aId) + 
           '</a>'; 
  };
  
  /*
   * At the moment this is unnecessary, but if we ever add any
   * fields to this class I don't want them going over the wire
   * unless I explicitly add them here.
   */
  NX.Nebraska.Flickr.Photo.prototype.toJSON = function()
  {
    var obj = {};
    obj.url = this.getUrl();
    obj.id = this.getId();
    obj.title = this.getTitle();
    obj.photo_url = this.getPhotoUrls();
    return obj;
  };
  
  /*
   * ====================================================================
   */

})();