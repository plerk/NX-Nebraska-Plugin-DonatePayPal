/*
 * Project Nebraska Trip Journal TripMap
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Trip === undefined) NX.Nebraska.Trip = {};

(function ()
{

  /*
   * ====================================================================
   */
   
  NX.Nebraska.Trip.Map = function(aMapId, aSvgMap)
  {
    this.map_id = aMapId;
    this.svgMap = aSvgMap;
    this.placeById = {};
    this.visitById = {};
    this.newVisit = [];
    this.deleteVisitById = {};
    this.fetchData();
    this.selectedPlace = null;
  };
  
  NX.Nebraska.Trip.Map.prototype.getMapId = function() { return this.map_id; };
  NX.Nebraska.Trip.Map.prototype.getSvgMap = function() { return this.svgMap; };
  NX.Nebraska.Trip.Map.prototype.getSelectedPlace = function() { return this.selectedPlace; };
  NX.Nebraska.Trip.Map.prototype.setSelectedPlace = function(aNewPlace) { this.selectedPlace = aNewPlace; };
  NX.Nebraska.Trip.Map.prototype.addVisit = function(aNewVisit) { this.newVisit.push(aNewVisit); };
  
  NX.Nebraska.Trip.Map.prototype.deleteVisit = function(aOldVisit)
  {
    var id = aOldVisit.getId()
    if(id != null)
    {
      delete this.visitById[id];
      this.deleteVisitById[id] = aOldVisit;
    }
    else
    {
      aOldVisit.clearDirty();
    }
  }
  
  NX.Nebraska.Trip.Map.prototype.iteratePlaces = function(aFunction)
  {
    for(var id in this.placeById)
    {
      aFunction(this.placeById[id]);
    }
  };
  
  NX.Nebraska.Trip.Map.prototype.iterateVisits = function(aFunction)
  {
    for(var id in this.visitById)
    {
      aFunction(this.visitById[id]);
    }
    var len = this.newVisit.length;
    for(var i=0; i<len; i++)
    {
      aFunction(this.newVisit[i]);
    }
  };
  
  NX.Nebraska.Trip.Map.prototype.fetchData = function()
  {
    var self = this;
    self.getMapDataFromWebsite(function() {
      self.getUserDataFromWebsite(function() {
        for(var i in self.visitById)
        {
          var visit = self.visitById[i];
          self.placeById[visit.getTripPlaceId()].setVisit(visit);
        }
        self.addSvgMapCallbacks();
      });
    });
  };
  
  NX.Nebraska.Trip.Map.prototype.changeMap = function(aNewMapId)
  {
    /*
     * this only works in Firefox or Chrome,
     * so the main code should set window.location
     * for other browsers instead.
     */
     
    if(this.getSelectedPlace() != null)
      this.getSelectedPlace().unSelectRegion();
     
    var self = this;
    this.svgMap.setBase(aNewMapId, function()
    {
      /* call back once the new SVG is loaded */
      self.map_id = aNewMapId;
      self.fetchData();
    });
  };
  
  NX.Nebraska.Trip.Map.prototype.getMapDataFromWebsite = function(aAfterLoaded)
  {
    var self = this;
    NX.Nebraska.Ajax.get('/app/trip/places/' + this.getMapId(), function(aRaw)
    {
      self.placeById = {};
      var payload = JSON.parse(aRaw);
      var len = payload.length;
      for(var i=0; i<len; i++)
      {
        // for each trip_place we get: 
        // "factoid":[text:"Population estimate in 2009 was 505,377",url:""]
        // "map_code":"TAS"
        // "region_code":"TAS"
        // "country_code":"au"
        // "name":"Tasmania"
        // "flag":"au-tas.png"
        // "id":"6"
        // "small":"0"
        self.placeById[payload[i].id] = new NX.Nebraska.Trip.Place(
          // aCountryCode,         aRegionCode,            aFlag,           aName,           aFactoids,          aMapCode,            aId,           aSvgMap,     aTripMap, aSmall
          payload[i].country_code, payload[i].region_code, payload[i].flag, payload[i].name, payload[i].factoid, payload[i].map_code, payload[i].id, self.svgMap, self,     payload[i].small
        )
      }
      if(aAfterLoaded != null)
        aAfterLoaded();
    });
  };
  
  NX.Nebraska.Trip.Map.prototype.getUserDataFromWebsite = function(aAfterLoaded)
  {
    var self = this;
    NX.Nebraska.Ajax.get('/app/trip/visits/' + this.getMapId(), function(aRaw)
    {
      self.visitById = {};
      var payload = JSON.parse(aRaw);
      var len = payload.length;
      for(var i=0; i<len; i++)
      {
        // foreach trip_visit we get:
        // id: 1
        // trip_place_id: 40
        // user_comment: I grew up here
        // youtube_video_id: o1vjKbKZ60Y
        // flickr_photo: { .. }
        var flickr_photo = null;
        if(payload[i].flickr_photo != null)
        {
          flickr_photo = new NX.Nebraska.Flickr.Photo(payload[i].flickr_photo);
          //alert(payload[i].trip_place_id + ' has photo: ' + JSON.stringify(flickr_photo));
        }
        else
        {
          //alert(payload[i].trip_place_id + ' has no photo');
        }
        self.visitById[payload[i].id] = new NX.Nebraska.Trip.Visit(
          payload[i].id, payload[i].trip_place_id, payload[i].user_comment, payload[i].youtube_video_id, flickr_photo
        );
      }
      if(aAfterLoaded != null)
        aAfterLoaded();
    });
  };
  
  NX.Nebraska.Trip.Map.prototype.postUserDataToWebsite = function(aAfter, aError)
  {
    var self = this;
    var update_list = [];
    var delete_list = [];
    
    this.iterateVisits(function(aVisit)
    {
      if(aVisit.isDirty())
        update_list.push(aVisit);
    });
    
    for(var id in this.deleteVisitById)
    {
      delete_list.push(id);
    }
    
    /*
     * zero length list means we don't have anything to change
     */
    if(update_list.length == 0 && delete_list.length == 0)
    {
      if(aAfter != null)
        aAfter();
      return;
    }
    
    // alert('update_list = ' + JSON.stringify(update_list));
    
    var payload = 'update=' + encodeURIComponent(JSON.stringify(update_list)) + 
                 '&delete=' + encodeURIComponent(JSON.stringify(delete_list));
    
    var params = {};
    params.url = '/app/trip/update';
    params.data = payload;
    params.contentType = 'application/x-www-form-urlencoded';
    params.onComplete = function(aRaw)
    {
      var payload = JSON.parse(aRaw);
      
      // alert('payload.update = ' + JSON.stringify(payload.update));
      
      var len = payload.update.length;
      for(var i=0; i<len; i++)
      {
        var visit = self.placeById[payload.update[i].trip_place_id].getVisit();
        if(payload.update[i].id != null)
          visit.setId(payload.update[i].id);
        if(payload.update[i].user_comment == visit.getUserComment()
        && payload.update[i].youtube_video_id == visit.getYouTubeId())
          visit.clearDirty();
      }
      
      var delete_list = payload['delete'];
      len = delete_list.length;
      for(var i=0; i<len; i++)
      {
        var id = delete_list[i];
        delete self.deleteVisitById[id];
      }
      
      if(aAfter != null)
        aAfter();
    };
    
    var ajax = new NX.Nebraska.Ajax.Req();
    if(aError != null)
      ajax.die = aError;
    ajax.post(params);
  }
  
  NX.Nebraska.Trip.Map.prototype.addSvgMapCallbacks = function()
  {
    var svgMap = this.getSvgMap();
    
    var listCell = document.getElementById('list_cell');
    listCell.innerHTML = 'Some regions are small on the map and will be listed here:';
    var list = document.createElement('ul');
    listCell.appendChild(list);
    var countSmallRegions = 0;
    
    this.iteratePlaces(function(aPlace)
    {
      var mapCode = aPlace.getMapCode();
      var exists = svgMap.exists(mapCode);
      
      if(exists)
      {
        svgMap.addCallback(mapCode, 'onmousemove', function(aId, aState, aEvent) {
          aPlace.onMouseMove(svgMap.getPositionFromEvent(aEvent));
        });
        svgMap.addCallback(mapCode, 'onclick', function(aId, aState, aEvent) {
          aPlace.onMouseClick(svgMap.getPositionFromEvent(aEvent));
        });
        svgMap.addCallback(mapCode, 'onmouseout', function(aId, aState, aEvent) {
          aPlace.onMouseOut(svgMap.getPositionFromEvent(aEvent));
        });
        svgMap.addCallback(mapCode, 'onmouseover', function(aId, aState, aEvent) {
          aPlace.onMouseOver(svgMap.getPositionFromEvent(aEvent));
        });
      }
      
      if(!exists || aPlace.isSmall())
      {
        var li = document.createElement('li');
        list.appendChild(li);
        li.id = 'small_region_' + mapCode;
        li.innerHTML = aPlace.getName();
        li.style.color = '#d3d3d3';
        countSmallRegions++;
        
        li.onmousemove = function(aEvent) {
          aPlace.onMouseMove(NX.Nebraska.Util.getPositionFromEvent(aEvent));
          return false;
        };
        li.onclick = function(aEvent) {
          aPlace.onMouseClick(NX.Nebraska.Util.getPositionFromEvent(aEvent));
          return false;
        };
        li.onmouseout = function(aEvent) {
          aPlace.onMouseOut(NX.Nebraska.Util.getPositionFromEvent(aEvent));
          return false;
        };
        li.onmouseover = function(aEvent) {
          aPlace.onMouseOver(NX.Nebraska.Util.getPositionFromEvent(aEvent));
        };
      }
      
      aPlace.doPaint();
    });
    
    if(countSmallRegions == 0)
    {
      listCell.innerHTML = '';
    }
  };
  
  /*
   * ====================================================================
   */

})();
