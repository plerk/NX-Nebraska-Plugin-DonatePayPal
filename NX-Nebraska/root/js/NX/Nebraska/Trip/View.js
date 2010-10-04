/*
 * Project Nebraska Trip Journal Application
 *
 * This is the main entry point for the View (read only) Trip Journal
 * application.
 */


if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Trip === undefined) NX.Nebraska.Trip = {};
if(NX.Nebraska.Trip.View === undefined) NX.Nebraska.Trip.View = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  NX.Nebraska.Util.callOnLoad(function()
  {
    /* 
     * we're going a little crazy here with the using functions to create
     * closures to make sure we don't mess up the namespace, but from
     * experience with the Compare Map app this is not really a bad thing.
     * Closures are fun.
     */
    var svgMap;  /* this is the NX.Nebraska.Map object which we use to  *
                  * interface with the SVG map on the page              */
    
    /*
     * 1. Merge any anonymous user data with the logged in user data if necessary.
     * 2. Create the NX.Nebraska.Map object.  
     * 3. Do any other basic setup necessary that doesn't belong in its own closure.
     */
    (function()
    {
      var map_code_default = document.getElementById('map_code_default').value;
      svgMap = new NX.Nebraska.Map('map_svg', map_code_default);
    })();
    
    /*
     * First thing we need to do is fix the map selector, because
     * if you hit the reload button it is probably wrong.
     */
    (function()
    {
      var map_code_default = document.getElementById('map_code_default').value;
      var map_select = document.getElementById('map_select');
      var len = map_select.options.length;
      for(var i=0; i<len; i++)
      {
        if(map_select.options[i].value == map_code_default)
          map_select.options[i].selected = true;
        else
          map_select.options[i].selected = false;
      }
    })();
    
    /*
     * In the view mode we simply redirect to the new page.
     */
    (function()
    {
      document.getElementById('map_select').onchange = function()
      {
        var newMapId = this.options[this.selectedIndex].value;
        window.location = document.getElementById('base_url').value + '/' + newMapId;
      };
    })();
    
    var username = null;
    var realmname = null;
    /*
     * get the username and realm name from the HTML
     */
    (function()
    {
      username  = document.getElementById('username').value;
      realmname = document.getElementById('realmname').value;
    })();
    
    var COLOUR_VISIT          = '#00007f';
    var COLOUR_SELECT_VISIT   = '#007f7f';
    var COLOUR_HOVER_VISIT    = '#00ffff';
    
    var selectedVP = null;
    
    NX.Nebraska.Trip.View.VisitPlace = function(aData)
    {
      this.place = aData.place;
      this.visit = aData.visit;
      this.li = document.getElementById('small_li_' + this.place.map_code);
      this.a = document.getElementById('small_a_'  + this.place.map_code);
      this.mouseOver = false;
      
      if(this.visit.flickr_photo != null)
      {
        this.visit.flickr_photo = new NX.Nebraska.Flickr.Photo(this.visit.flickr_photo);
      }
      
      this.pop = new NX.Nebraska.PopUp(this.generatePopHtml());
    };
    
    NX.Nebraska.Trip.View.VisitPlace.prototype.generatePopHtml = function()
    {
      var html = username + ' has visited <b>' + this.place.name + '</b>';
      
      var comment = this.visit.user_comment;
      if(comment != null && !comment.match(/^\s*$/))
      {
        html += '<p>' + NX.Nebraska.Util.escapeHTML(comment) + '</p>';
      }
      
      var img = null;
      
      if(this.visit.flickr_photo != null)
      {
        img = this.visit.flickr_photo.render('t');
      }
      else if(this.place.flag != null)
      {
        img = '<img src="/flags/' + this.place.flag + '" height="50" alt="[flag]" />';
      }
      
      if(img != null)
      {
        html = '<table><tr><td>' + img + '</td><td>' + html + '</td></tr></table>';
      }
      
      return html;
    }
    
    NX.Nebraska.Trip.View.VisitPlace.prototype.paint = function()
    {
      var colour = COLOUR_VISIT;
      
      if(selectedVP != null && selectedVP.place.map_code == this.place.map_code)
        colour = COLOUR_SELECT_VISIT;
      else if(this.mouseOver)
        colour = COLOUR_HOVER_VISIT;
      
      if(svgMap.exists(this.place.map_code))
        svgMap.paint(this.place.map_code, colour);
      if(this.li != null)
      {
        this.li.style.color = colour;
        this.a.style.color = colour;
      }
    };
    
    NX.Nebraska.Trip.View.VisitPlace.prototype.onMouseOver = function(aPos)
    {
      this.mouseOver = true;
      this.paint();
    };
    
    NX.Nebraska.Trip.View.VisitPlace.prototype.onMouseMove = function(aPos)
    {
      this.pop.show(aPos.add(-133,+20));
    };
    
    NX.Nebraska.Trip.View.VisitPlace.prototype.onMouseOut = function(aPos)
    {
      this.mouseOver = false;
      this.paint();
      this.pop.hide();
    };
    
    var VIDEO_WIDTH = 500;
    var VIDEO_HEIGHT = 303;
    
    NX.Nebraska.Trip.View.VisitPlace.prototype.doSelect = function()
    {
      selectedVP = this;
      this.paint();
      document.getElementById('place_visit_name').innerHTML = this.place.name;
      
      /*
       * we reduce the max width slightly of the picture if we have a flag 
       * just so they won't be competing for horizontal space.
       */
      var maxWidth = 500;
      if(this.place.flag != null)
        maxWidth = 400;
      
      if(this.visit.flickr_photo != null)
        document.getElementById('place_visit_img').innerHTML = this.visit.flickr_photo.render('m', maxWidth, 250);
      else
        document.getElementById('place_visit_img').innerHTML = '';
      
      var comment = this.visit.user_comment;
      if(comment != null && !comment.match(/^\s*$/))
      {
        document.getElementById('place_visit_comment').innerHTML = NX.Nebraska.Util.escapeHTML(this.visit.user_comment);
      }
      else
      {
        document.getElementById('place_visit_comment').innerHTML = username + ' has visited <b>' + this.place.name + '</b>.';
      }
      
      if(this.place.flag != null)
      {
        document.getElementById('place_visit_flag_img').src = '/flags/' + this.place.flag;
        document.getElementById('place_visit_flag_img').style.display = 'block';
      }
      else
      {
        document.getElementById('place_visit_flag_img').style.display = 'none';
      }
      
      if(this.visit.youtube_video_id != null)
      {
        document.getElementById('place_visit_video').innerHTML = 
          '<object width="' + VIDEO_WIDTH + '" height="' + VIDEO_HEIGHT + '">' +
            '<param name="movie" value="http://www.youtube.com/v/' + this.visit.youtube_video_id + '?fs=1&amp;hl=en_US&amp;rel=0"></param>' +
            '<param name="allowFullScreen" value="true"></param>' +
            '<param name="allowscriptaccess" value="always"></param>' +
            '<embed src="http://www.youtube.com/v/' + this.visit.youtube_video_id + '?fs=1&amp;hl=en_US&amp;rel=0" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="' + VIDEO_WIDTH + '" height="' + VIDEO_HEIGHT + '"></embed>' +
          '</object>'
      }
      else
      {
        document.getElementById('place_visit_video').innerHTML = '';
      }
      
      document.getElementById('place_visit_div').style.visibility = 'visible';
    }
    
    NX.Nebraska.Trip.View.VisitPlace.prototype.onMouseClick = function(aPos)
    {
      var oldSelectedVP = selectedVP;
      selectedVP = null;
      if(oldSelectedVP != null)
      {
        oldSelectedVP.paint();
        document.getElementById('place_visit_div').style.visibility = 'hidden';
        if(oldSelectedVP.place.map_code == this.place.map_code)
          return;
      }
      
      this.doSelect();
    };
    
    var addCallbacks = function(aVP)
    {
      var mapCode = aVP.place.map_code;
      if(svgMap.exists(mapCode))
      {
        svgMap.addCallback(mapCode, 'onmouseover', function(aId, aState, aEvent) {
          if(aEvent == null) return true;
          aVP.onMouseOver(svgMap.getPositionFromEvent(aEvent));
        });
        svgMap.addCallback(mapCode, 'onmousemove', function(aId, aState, aEvent) {
          if(aEvent == null) return true;
          aVP.onMouseMove(svgMap.getPositionFromEvent(aEvent));
        });
        svgMap.addCallback(mapCode, 'onmouseout', function(aId, aState, aEvent) {
          if(aEvent == null) return true;
          aVP.onMouseOut(svgMap.getPositionFromEvent(aEvent));
        });
        svgMap.addCallback(mapCode, 'onclick', function(aId, aState, aEvent) {
          if(aEvent == null) return true;
          aVP.onMouseClick(svgMap.getPositionFromEvent(aEvent));
        });
      }
      
      if(aVP.a != null)
      {
        aVP.a.onmouseover = function(aEvent) {
          aVP.onMouseOver(NX.Nebraska.Util.getPositionFromEvent(aEvent));
          return false;
        };
        aVP.a.onmousemove = function(aEvent) {
          aVP.onMouseMove(NX.Nebraska.Util.getPositionFromEvent(aEvent));
          return false;
        };
        aVP.a.onmouseout = function(aEvent) {
          aVP.onMouseOut(NX.Nebraska.Util.getPositionFromEvent(aEvent));
          return false;
        };
        aVP.a.onclick = function(aEvent) {
          aVP.onMouseClick(NX.Nebraska.Util.getPositionFromEvent(aEvent));
          return false;
        };
      }
    };
    
    /*
     * parse the imbeded JSON code and add all the callbacks necessary.
     */
    (function()
    {
      var visit_data = JSON.parse(document.getElementById('visit_data').value);
      var len = visit_data.length;
      for(var i=0; i<len; i++)
      {
        var vp = new NX.Nebraska.Trip.View.VisitPlace(visit_data[i]);
        
        if(document.getElementById('place_map_code') != null
        && vp.place.map_code == document.getElementById('place_map_code').value)
        {
          vp.doSelect();
        }
        
        vp.paint(COLOUR_VISIT);
        addCallbacks(vp);
      }
    })();
  
  });
  
  /*
   * ====================================================================
   */

})();