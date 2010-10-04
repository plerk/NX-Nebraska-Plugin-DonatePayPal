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
  
  var createCallback = function(aPicker, aI, aPhoto)
  {
    return function() { aPicker.pick(aI, aPhoto); return false; };
  }
  
  NX.Nebraska.Flickr.Picker = function(aPhotoList, aCallback, aCallbackCancel)
  {
    this.div = document.getElementById('flickr_picker_div');
    this.callback = aCallback;
    this.callbackCancel = aCallbackCancel;
    this.photoList = aPhotoList;
    
    NX.Nebraska.Flickr.Main.hidePicker();
    NX.Nebraska.Flickr.Main.updatePicker(this);
    
    var max = document.getElementById('flickr_picker_max').value;
    
    var self = this;
    var i=0;
    var len = aPhotoList.length;
    while(i < len)
    {
      var photo = aPhotoList[i];
      document.getElementById('flickr_pickr_a_' + i).onclick = createCallback(this, i, photo);
      document.getElementById('flickr_pickr_img_' + i).src = photo.getPhotoUrls().sq.getUrl();
      document.getElementById('flickr_pickr_img_' + i).alt = photo.getTitle();
      i++;
    }
    
    while(i < max)
    {
      document.getElementById('flickr_pickr_a_' + i).onclick = function() { return false; };
      document.getElementById('flickr_pickr_img_' + i).src = '/png/blank_sq.png';
      document.getElementById('flickr_pickr_img_' + i).alt = '[EMPTY]';
      i++;
    }
    
    document.getElementById('flickr_picker_cancel').onclick = function()
    {
      self.hide();
      if(self.callbackCancel != null)
        self.callbackCancel();
      return false;
    };
  }
  
  NX.Nebraska.Flickr.Picker.prototype.show = function()
  {
    this.div.style.visibility = 'visible';
  }
  
  NX.Nebraska.Flickr.Picker.prototype.hide = function()
  {
    this.div.style.visibility = 'hidden';
  }
  
  NX.Nebraska.Flickr.Picker.prototype.pick = function(aI, aPhoto)
  {
    this.hide();
    if(this.callback != null)
      this.callback(aPhoto);
  }
  
  /*
   * ====================================================================
   */

})();