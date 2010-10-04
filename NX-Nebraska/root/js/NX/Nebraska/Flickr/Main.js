/*
 * Project Nebraska
 * 
 * Some utility functions that don't really belong anywhere else.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Flickr === undefined) NX.Nebraska.Flickr = {};
if(NX.Nebraska.Flickr.Main === undefined) NX.Nebraska.Flickr.Main = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  NX.Nebraska.Flickr.Main.getRecentPhotos = function(aCallback)
  {
    NX.Nebraska.Ajax.get('/api/flickr/recent', function(aRaw)
    {
      var payload = JSON.parse(aRaw);
      var len = payload.length;
      var photos = [];
      for(var i=0; i<len; i++)
      {
        /*
         * foreach entry we get:
        * "url":"http://www.flickr.com/photos/plicease/3374174422",
         * "id":"3374174422",
         * "title":"bog",
         * "m":{
         *   "width":"500",
         *   "url":"http://farm4.static.flickr.com/3579/3374174422_deaf30d089.jpg",
         *   "height":"375"
         * },
         * "sq":{
         *   "width":"75",
         *   "url":"http://farm4.static.flickr.com/3579/3374174422_deaf30d089_s.jpg",
         *   "height":"75"
         * },
         * "s":{
         *   "width":"240",
         *   "url":"http://farm4.static.flickr.com/3579/3374174422_deaf30d089_m.jpg",
         *   "height":"180"
         * },
         * "t":{
         *   "width":"100",
         *   "url":"http://farm4.static.flickr.com/3579/3374174422_deaf30d089_t.jpg",
         *   "height":"75"
         * }
         */
        photos.push(new NX.Nebraska.Flickr.Photo({
          'url'     : payload[i].url,
          'id'      : payload[i].id,
          'title'   : payload[i].title,
          photoUrls : {
            'm'     : new NX.Nebraska.Flickr.PhotoURL(payload[i].m),
            'sq'    : new NX.Nebraska.Flickr.PhotoURL(payload[i].sq),
            's'     : new NX.Nebraska.Flickr.PhotoURL(payload[i].s),
            't'     : new NX.Nebraska.Flickr.PhotoURL(payload[i].t)
          }
        }));
      }
      if(aCallback != null)
        aCallback(photos);
    });
  };
  
  
  var thePicker = null;
  
  NX.Nebraska.Flickr.Main.updatePicker = function(aNewPicker)
  {
    thePicker = aNewPicker;
  }
  
  NX.Nebraska.Flickr.Main.hidePicker = function()
  {
    if(thePicker != null)
      thePicker.hide();
  };
  
  /*
   * ====================================================================
   */

})();