/*
 * Project Nebraska
 *
 * Class to represent regions, or places in the map.  Usually these
 * will be states, territories, provinces, etc. whatever is appropriate
 * for the given map.
 *
 * This class also provides an interface for highlighting them on the
 * map, and stores the value of the selected statistic.  All of the
 * Places for each map are stored in the stateById[] array on the CompareMap
 * object (see CompareMap.js).
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Compare === undefined) NX.Nebraska.Compare = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  var last_event = null;
  
  NX.Nebraska.Compare.Place = function(aMap, aId, aName, aCode, aFlag, aOption)
  {
    this.id = aId;
    this.name = aName;
    this.code = aCode;
    this.selected = false;
    this.isIn = false;
    this.map = aMap.map;
    this.pop = new NX.Nebraska.PopUp(this.name);
    this.option = aOption;
    this.stat = null;
    this.value = 0;
    this.flag = aFlag;
    var place = this;
    
    if(!this.map.exists(aCode))
    {
      // small places sometimes do not appear in the map
      // e.g. DC in the USA map.
      NX.Nebraska.Debug.say("unable to find " + aCode + " in map");
      return;
    }
    
    place.map.paint(place.code, '#d3d3d3');
    
    this.map.addCallback(aCode, 'onmousemove', 
      function(aId, aState, aEvent) 
      {
        place.map.paint(place.code, '#00ff00');
        place.isIn = true;
        
        /*
         * Tried to get half the width of the <div> object that contains
         * the pop up text.  Unforunately, this commented out code
         * below sometimes returns 0, which causes annoying blinking!
         * So we just hope that 133 is the right width.
         */
        //var halfWidth = Math.floor(place.pop.getContainer().offsetWidth/2);
        var halfWidth = 133;
        var pos = place.map.getPositionFromEvent(aEvent);
        place.pop.show(pos.add(0-halfWidth, 20));
      }
    );
    
    this.map.addCallback(aCode, 'onmouseout',
      function(aId, aState, aEvent) 
      {
        if(place.selected)
          place.map.paint(place.code, '#007f00');
        else
          place.map.paint(place.code, '#d3d3d3');
        place.isIn = false;
        place.pop.hide();
      }
    );
    
    if(!aMap.statesAreSelectable())
    {
      this.map.addCallback(aCode, 'onclick',
        function()
        {
          alert('Cannot select regions in the ouput map.  Try' + "\n" +
                'selecting regions in the input map on the left.');
          return false;
        }
      );
    }
    else
    {
      this.map.addCallback(aCode, 'onclick', 
        function(aId, aState, aEvent) 
        {
          if(place.stat == null)
          {
            alert('unfortunately we do not have any values for' + "\n" +
                  place.name + ' for this statistic.  Please ' + "\n" +
                  'try another region.');
            return false;
          }
          
          place.toggle()
        
          /*
           * check to see if there is an <option> element
           * associated with this place, and select it
           * if so.
           */
          if(place.option != null)
          {
            last_event = aEvent;
            aEvent.returnValue = false;
            place.option.selected = place.selected;
          }
          
          aMap.placeConfigChangeCB();
          aMap.updatePostSelect();
          return false;
        }
      );
    }
  }
  
  NX.Nebraska.Compare.Place.prototype.setStatAndValue = function(aStat, aValue)
  {
    this.stat = aStat;
    this.value = aValue;
    var valueStr = NX.Nebraska.Util.integerToHumanReadableNumber(aValue);
    
    var newHTML = '<b>' + this.name + '</b><br/>' + this.stat.year + ' ' + this.stat.name + ': ' + valueStr;
    
    if(this.flag != null)
    {
      newHTML = '<table><tr><td><img src="/flags/' + this.flag + '" height="50" alt="[flag]" /></td><td>' + newHTML + '</td></tr></table>';
    }
    
    this.pop.setHTML(newHTML);
  }
  
  NX.Nebraska.Compare.Place.prototype.getValue = function()
  {
    return this.value;
  }
  
  NX.Nebraska.Compare.Place.prototype.getName = function()
  {
    return this.name;
  }
  
  NX.Nebraska.Compare.Place.prototype.isSelected = function()
  {
    return this.selected;
  }
  
  NX.Nebraska.Compare.Place.prototype.clearStatAndValue = function()
  {
    this.stat = null;
    this.value = 0;
    this.pop.setHTML('<b>' + this.name + '</b>');
  }
  
  NX.Nebraska.Compare.Place.prototype.selectOn = function()
  {
    if(this.selected)
      return;
    this.selected = true;
    if(!this.isIn && this.map.exists(this.code))
      this.map.paint(this.code, '#007f00');
  }
  
  NX.Nebraska.Compare.Place.prototype.selectOff = function()
  {
    if(!this.selected)
      return;
    this.selected = false;
    if(!this.isIn && this.map.exists(this.code))
      this.map.paint(this.code, '#d3d3d3');
  }
  
  NX.Nebraska.Compare.Place.prototype.toggle = function()
  {
    if(this.selected)
      this.selectOff();
    else
      this.selectOn();
  }
  
  /*
   * ====================================================================
   */

})();
