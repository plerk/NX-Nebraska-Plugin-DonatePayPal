/*
 * Project Nebraska Trip Journal Application
 *
 * This is the main entry point for the Trip Journal
 * application.
 */


if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Trip === undefined) NX.Nebraska.Trip = {};
if(NX.Nebraska.Trip.Main === undefined) NX.Nebraska.Trip.Main = {};

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
    var tripMap; /* this is the NX.Nebraska.TripMap object which we use *
                  * to keep track of the place data and such            */
    
    /*
     * 1. Merge any anonymous user data with the logged in user data if necessary.
     * 2. Create the NX.Nebraska.Map object.  
     * 3. Do any other basic setup necessary that doesn't belong in its own closure.
     */
    (function()
    {
      var map_code_default = document.getElementById('map_code_default').value;
      svgMap = new NX.Nebraska.Map('map_svg', map_code_default);
      
      NX.Nebraska.Ajax.get('/app/trip/merge', function(aRaw)
      {
        tripMap = new NX.Nebraska.Trip.Map(map_code_default, svgMap);
      
        var payload = JSON.parse(aRaw);
        //alert(JSON.stringify(payload));
        
        var merged = parseInt(payload.merged);
        var dropped = parseInt(payload.dropped);
        if(merged > 0 && dropped > 0)
        {
          alert("Some entries you made before you logged in\n" +
                "have been merged with your account, and some\n" +
                "that conflicted with your account have been\n" +
                "dropped.");
        }
        else if(merged > 0)
        {
          alert("Some entries you made before you logged in\n" +
                "have been merged with your account.\n");
        }
        else if(dropped > 0)
        {
          alert("Some entries you made before you logged in\n" +
                "conflict with what is in your account and have\n" +
                "been dropped.\n");
        }
        
        
      });
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
     * handle it when the user changes the map
     * In Firefox and Opera things are happy and we
     * can simply set the <object> element to the new
     * map.  This means extra work for us because we 
     * have to cleanup after the old map and load in
     * the data we need for the new map.  In IE and
     * Chrome and Safari things are sad and we have
     * to reload the entire page!
     */
    (function()
    {
      if(NX.Nebraska.Util.isKHTML()
      || NX.Nebraska.Util.isSvgweb())
      {
        document.getElementById('map_select').onchange = function()
        {
          var newMapId = this.options[this.selectedIndex].value;
          tripMap.postUserDataToWebsite(function()
          {
            window.location = '/app/trip?map_code=' + newMapId;
          });
        };
      }
      else
      {
        document.getElementById('map_select').onchange = function()
        {
          var newMapId = this.options[this.selectedIndex].value;
          tripMap.postUserDataToWebsite(function()
          {
            tripMap.changeMap(newMapId);
          });
        };
      }
    })();
    
    /*
     * handle the <SYNC> button on the web page which is used for debugging
     * only.
     */
    (function()
    {
      var button = document.getElementById('sync_button');
      button.onclick = function()
      {
        tripMap.postUserDataToWebsite();
      };
    })();
    
    /*
     * Handle the "Share button" ... basically just display the dialog.
     */
    (function()
    {
      if(document.getElementById('share_button') != null)
      {
        document.getElementById('share_button').onclick = function()
        {
          if(tripMap.getSelectedPlace() != null && tripMap.getSelectedPlace().isVisited())
          {
            document.getElementById('share_url_place').value = 
              document.getElementById('share_base_url').value + '/' + 
              tripMap.getMapId() + 
              '?place_map_code=' + tripMap.getSelectedPlace().getMapCode();
            document.getElementById('share_url_place_name').innerHTML = tripMap.getSelectedPlace().getName();
            document.getElementById('share_div_place_div').style.visibility = 'visible';
          }
          else
          {
            document.getElementById('share_div_place_div').style.visibility = 'hidden';
          }
          document.getElementById('share_url').value = document.getElementById('share_base_url').value + '/' + tripMap.getMapId();
          document.getElementById('share_div').style.visibility = 'visible';
        };
        document.getElementById('share_close').onclick = function()
        {
          document.getElementById('share_div_place_div').style.visibility = 'hidden';
          document.getElementById('share_div').style.visibility = 'hidden';
        };
      }
    })();
    
    /*
     * handle updates in the background.
     */
    var triggerTimer = null;
    var triggerTimeOut = 500;
    NX.Nebraska.Trip.Main.triggerUpdate = function()
    {
      if(triggerTimer == null)
      {
        triggerTimeOut = 500;
        triggerTimer = setTimeout('NX.Nebraska.Trip.Main.trigger()', triggerTimeOut);
      }
    };
    
    NX.Nebraska.Trip.Main.trigger = function()
    {
      tripMap.postUserDataToWebsite(
        /*
         * on success
         */
        function()
        {
          var dirty = false;
          tripMap.iterateVisits(function(aVisit)
          {
            if(aVisit.isDirty())
              dirty = true;
          });
          triggerTimer = null;
          if(dirty)
            NX.Nebraska.Trip.Main.triggerUpdate();
        },
        /*
         * on failure
         */
        function()
        {
          triggerTimeOut = triggerTimeOut * 4;
        
          if(triggerTimeOut > 60000)
          {
            document.getElementById('disconnect_error_retry').onclick = function()
            {
              triggerTimer = null;
              NX.Nebraska.Trip.Main.triggerUpdate();
              document.getElementById('disconnect_error_div').style.visibility = 'hidden';
            };
            document.getElementById('disconnect_error_cancel').onclick = function()
            {
              document.getElementById('disconnect_error_div').style.visibility = 'hidden';
            };
            document.getElementById('disconnect_error_div').style.visibility = 'visible';
            return;
          }
          
          
          NX.Nebraska.Debug.say('error, new timeout is ' + triggerTimeOut);
          triggerTimer = setTimeout('NX.Nebraska.Trip.Main.trigger()', triggerTimeOut);
        }
      );
    };
  
  });
  
  /*
   * ====================================================================
   */

})();