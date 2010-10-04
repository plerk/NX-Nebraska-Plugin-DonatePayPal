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
  
  var COLOUR_NONE           = '#d3d3d3';
  var COLOUR_SELECT         = '#007f00';
  var COLOUR_VISIT          = '#00007f';
  var COLOUR_SELECT_VISIT   = '#007f7f';
  var COLOUR_HOVER          = '#00ff00';
  var COLOUR_HOVER_VISIT    = '#00ffff';

  var selectedPlace = null;
  var callBeforeDeSelect = null;
  var popup = null;
  
  NX.Nebraska.Util.callOnLoad(function()
  {
    popup = new NX.Nebraska.PopUp('');
  });
  
  NX.Nebraska.Trip.Place = function(aCountryCode, aRegionCode, aFlag, aName, aFactoids, aMapCode, aId, aSvgMap, aTripMap, aSmall)
  {
    this.countryCode = aCountryCode;
    this.regionCode = aRegionCode;
    this.flag = aFlag;
    this.name = aName;
    this.mapCode = aMapCode;
    this.id = aId;
    this.mouseOver = false;
    this.svgMap = aSvgMap;
    this.visit = null;
    this.tripMap = aTripMap;
    if(aSmall == "0")
      this.small = false;
    else
      this.small = true;
    
    this.factoids = [];
    var len = aFactoids.length;
    for(var i=0; i<len; i++)
    {
      this.factoids.push(new NX.Nebraska.Trip.Factoid(aFactoids[i].text, aFactoids[i].url));
    }
  };
  
  NX.Nebraska.Trip.Place.prototype.getName = function() { return this.name; };
  NX.Nebraska.Trip.Place.prototype.getCountryCode = function() { return this.countryCode; };
  NX.Nebraska.Trip.Place.prototype.getRegionCode = function() { return this.regionCode; };
  NX.Nebraska.Trip.Place.prototype.getFlag = function() { return this.flag; };
  NX.Nebraska.Trip.Place.prototype.getFactoids = function() { return this.factoids; };
  NX.Nebraska.Trip.Place.prototype.getMapCode = function() { return this.mapCode; };
  NX.Nebraska.Trip.Place.prototype.getId = function() { return this.id; };
  NX.Nebraska.Trip.Place.prototype.isMouseOver = function() { return this.mouseOver; };
  NX.Nebraska.Trip.Place.prototype.getVisit = function() { return this.visit; };
  NX.Nebraska.Trip.Place.prototype.isVisited = function() { return this.visit != null; };
  NX.Nebraska.Trip.Place.prototype.isSelected = function() { return selectedPlace != null && this.getId() == selectedPlace.getId(); };
  NX.Nebraska.Trip.Place.prototype.isSmall = function() { return this.small; };
  
  NX.Nebraska.Trip.Place.prototype.getNextFactoid = function()
  {
    var factoid = this.factoids.shift();
    this.factoids.push(factoid);
    return factoid;
  }
  
  NX.Nebraska.Trip.Place.prototype.doPaint = function()
  {
    if(this.isMouseOver())
    {
      if(this.isVisited())
        this.paint(COLOUR_HOVER_VISIT);
      else
        this.paint(COLOUR_HOVER);
    }
    else if(this.isSelected())
    {
      if(this.isVisited())
        this.paint(COLOUR_SELECT_VISIT);
      else
        this.paint(COLOUR_SELECT);
    }
    else if(this.isVisited())
    {
      this.paint(COLOUR_VISIT);
    }
    else
    {
      this.paint(COLOUR_NONE);
    }
  };
  
  NX.Nebraska.Trip.Place.prototype.setVisit = function(aNewVisit) 
  { 
    this.visit = aNewVisit;
    this.doPaint();
  };
  
  NX.Nebraska.Trip.Place.prototype.deleteVisit = function()
  {
    this.visit = null;
    this.doPaint();
  };
  
  NX.Nebraska.Trip.Place.prototype.selectRegion = function()
  {
    var self = this;
    this.prepareDeselect();
    document.getElementById('youtube_video_div').innerHTML = '';
    document.getElementById('place_intro').style.display = 'block';
    if(this.flag != null)
    {
      document.getElementById('place_flag_png').src = '/flags/' + this.flag;
      document.getElementById('place_flag_png').style.display = 'inline';
    }
    else
    {
      document.getElementById('place_flag_png').style.display = 'none';
    }
    document.getElementById('place_name').innerHTML = this.getName();
    document.getElementById('place_factoid').innerHTML = this.getNextFactoid().render();
    
    if(this.isVisited())
    {
      document.getElementById('place_visit').style.display = 'block';
      document.getElementById('place_no_visit').style.display = 'none';
      
      var visit = this.getVisit();
      var userComment = visit.getUserComment();
      if(userComment == null)
        userComment = '';
      
      document.getElementById('place_textarea').onchange = function() { };
      document.getElementById('place_textarea').value = userComment;
      
      var onChange = function() 
      { 
        //alert("set user comment = " + document.getElementById('place_textarea').value);
        visit.setUserComment(document.getElementById('place_textarea').value);
      };
      callBeforeDeSelect = function() 
      { 
        //alert('callBeforeDeSelect'); 
        visit.setUserComment(document.getElementById('place_textarea').value);
      };
      document.getElementById('place_textarea').onchange = onChange;
      
      document.getElementById('place_button_remove_visit').onclick = function()
      {
        if(!confirm("Are you sure?  All data assoicated with this region will be lost"))
          return;
        var visit = self.visit;
        visit.setDirty();
        self.tripMap.deleteVisit(visit);
        self.deleteVisit();
        self.selectRegion();
        return false;
      };
      
      document.getElementById('youtube_video_button_add').onclick = function() { visit.guiAddVideo(); };
      document.getElementById('youtube_video_button_remove').onclick = function() { visit.guiRemoveVideo(); };
      visit.guiDisplayVideo();
      
      document.getElementById('flickr_picture_button_add').onclick = function() { visit.guiAddPicture(); };
      document.getElementById('flickr_picture_button_remove').onclick = function() { visit.guiRemovePicture(); };
      visit.guiDisplayPicture();
    }
    else
    {
      document.getElementById('place_visit').style.display = 'none';
      document.getElementById('place_no_visit').style.display = 'block';
      document.getElementById('place_button_add_visit').onclick = function()
      {
        var visit = new NX.Nebraska.Trip.Visit(null, self.getId(), '');
        self.tripMap.addVisit(visit);
        self.setVisit(visit);
        self.selectRegion();
        return false;
      };
    }
    
    var oldSelectedPlace = selectedPlace;
    selectedPlace = this;
    this.tripMap.setSelectedPlace(selectedPlace);
    if(oldSelectedPlace != null)
      oldSelectedPlace.doPaint();
    this.doPaint();
  };

  NX.Nebraska.Trip.Place.prototype.prepareDeselect = function()
  {
    if(callBeforeDeSelect != null)
      callBeforeDeSelect();
    callBeforeDeSelect = null;
    NX.Nebraska.Flickr.Main.hidePicker();
  }
  
  NX.Nebraska.Trip.Place.prototype.unSelectRegion = function()
  {
    this.prepareDeselect();
    
    document.getElementById('place_intro').style.display = 'none';
    document.getElementById('place_visit').style.display = 'none';
    document.getElementById('place_no_visit').style.display = 'none';
    document.getElementById('youtube_video_div').innerHTML = '';
    
    var oldSelectedPlace = selectedPlace;
    selectedPlace = null;
    this.tripMap.setSelectedPlace(selectedPlace);
    if(oldSelectedPlace != null)
      oldSelectedPlace.doPaint();
  };
  
  NX.Nebraska.Trip.Place.prototype.onMouseMove = function(aPos)
  {
    this.mouseOver = true;
    this.doPaint();
    popup.show(aPos.add(-133,+20));
  };
  
  NX.Nebraska.Trip.Place.prototype.onMouseClick = function(aPos)
  {
    if(this.isSelected())
      this.unSelectRegion();
    else
      this.selectRegion();
  };
  
  NX.Nebraska.Trip.Place.prototype.onMouseOut = function(aPos)
  {
    this.mouseOver = false;
    this.doPaint();
    popup.hide();
  };
  
  NX.Nebraska.Trip.Place.prototype.onMouseOver = function(aPos)
  {
    var html = '<p><b>' + this.getName() + '</b></p>';
    
    if(this.isVisited() && this.getVisit().getUserComment() != null && this.getVisit().getUserComment() != '')
    {
      html += '<p>' + NX.Nebraska.Util.escapeHTML(this.getVisit().getUserComment()) + '</p>';
    }
    else
    {
      html += '<p>' + this.getNextFactoid().render() + '</p>';
    }
    
    var img = null;
    if(this.isVisited() && this.getVisit().getFlickrPhoto() != null)
    {
      img = this.getVisit().getFlickrPhoto().render('t');
    }
    else if(this.getFlag() != null)
    {
      img = '<img src="/flags/' + this.getFlag() + '" height="50" alt="[flag]" />';
    }
    
    if(img != null)
    {
      html = '<table><tr><td>' + img + '</td><td>' + html + '</td></tr></html>';
    }
    
    popup.setHTML(html);
    popup.show(aPos.add(-133,+20));
  }
  
  NX.Nebraska.Trip.Place.prototype.paint = function(aNewColour)
  {
    var exists = this.svgMap.exists(this.getMapCode());
    if(exists)
      this.svgMap.paint(this.getMapCode(), aNewColour);
    if(!exists || this.isSmall())
    {
      var li = document.getElementById('small_region_' + this.getMapCode());
      if(li != null)
        li.style.color = aNewColour;
    }
  };
  
  /*
   * ====================================================================
   */

})();