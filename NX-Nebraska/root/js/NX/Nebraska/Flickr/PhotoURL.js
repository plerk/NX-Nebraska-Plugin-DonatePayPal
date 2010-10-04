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
  
  NX.Nebraska.Flickr.PhotoURL = function(aArgs)
  {
    this.url = aArgs.url;
    this.width = aArgs.width;
    this.height = aArgs.height;
  };
  
  NX.Nebraska.Flickr.PhotoURL.prototype.getUrl = function() { return this.url; };
  NX.Nebraska.Flickr.PhotoURL.prototype.getWidth = function() { return this.width; };
  NX.Nebraska.Flickr.PhotoURL.prototype.getHeight = function() { return this.height; };
  
  NX.Nebraska.Flickr.PhotoURL.prototype.render = function(aAlt, aMaxWidth, aMaxHeight, aId)
  {
    var width = this.getWidth();
    var height = this.getHeight();
    
    if(aMaxWidth != null || aMaxHeight != null)
    {
      var oWidth = width;
      var oHeight = height;
    
      if(aMaxWidth == null)
        aMaxWidth = width;
      if(aMaxHeight == null)
        aMaxHeight = height;
    
      if(height > aMaxHeight)
      {
        height = aMaxHeight;
        width = oWidth * (  aMaxHeight / oHeight);
      }
    
      if(width > aMaxWidth)
      {
        width = aMaxWidth;
        height = oHeight * ( aMaxWidth / oWidth);
      }
    }
    
    var html = '<img';
    html += ' src="' + this.getUrl() + '"';
    if(aAlt != null)
      html += ' alt="' + aAlt + '"';
    html += ' width="' + width + '"';
    html += ' height="' + height + '"';
    if(aId != null)
      html += ' id="' + aId + '"';
    html += ' />';
    return html;
  };
  
  /*
   * At the moment this is unnecessary, but if we ever add any
   * fields to this class I don't want them going over the wire
   * unless I explicitly add them here.
   */
  NX.Nebraska.Flickr.PhotoURL.prototype.toJSON = function()
  {
    var obj = {};
    obj.url = this.getUrl();
    obj.width = this.getWidth();
    obj.height = this.getHeight();
    return obj;
  };
  
  /*
   * ====================================================================
   */

})();