/*
 * map javascript routines for Project Nebraska
 *
 * This is a low level interface into the maps, which allow the higher
 * level code to interact with the map, highlight regions, etc.  For
 * the higher level code (including interacting with other widgets in
 * the page) see CompareMap.js
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};

(function ()
{

  /*
   * ====================================================================
   */
 
  NX.Nebraska.Map = function(aDomId,aId)
  {
    // the meta sub object is a place that applications
    // can stick controls and data onto that have to do
    // with this object, but shouldn't be stuck in the 
    // main object, thus reducing the chance of a namespace
    // collision.
    this.meta = {};
    
    this.htmlObject = document.getElementById(aDomId);
    if(this.htmlObject === null)
    {
      alert('unable to find html object for id ' + aDomId);
      return;
    }
    /*
     * when using svgweb we need to use
     * contentDocument instead of getSVGDocument()
     */
    if(typeof(this.htmlObject.getSVGDocument) == 'function')
      this.svgObject = this.htmlObject.getSVGDocument();
    else
      this.svgObject = this.htmlObject.contentDocument;
    if(this.svgObject === null)
    {
      alert('unable to find svg object for id ' + aDomId);
    }
    this.id = aId;
    if(this.htmlObject.style.display == 'none')
    {
      this.display_stype = 'block';
    }
    else
    {
      this.display_style = this.htmlObject.style.display;
    }
    
    if(NX.Nebraska.Util.isKHTML())
    {
      //var self = this;
      //this.svgObject.onload = function() { self.fixMapSizeOnKHTML() };
      //NX.Nebraska.Util.callOnLoad(function(){self.fixMapSizeOnKHTML();});
      this.fixMapSizeOnKHTML();
    }
  }
  
  /*
   * workarounds for Chrome
   */
  NX.Nebraska.Map.prototype.fixMapSizeOnKHTML = function()
  {
    if(!NX.Nebraska.Util.isKHTML())
      return;
      
    var svg = this.svgObject.rootElement;
    svg.setAttribute('width', this.htmlObject.width);
    svg.setAttribute('height', this.htmlObject.height);
  }
  
  /*
   * set the base map
   */
  
  NX.Nebraska.Map.prototype.setBase = function(aId, aWhenDoneCallback)
  {
    if(aId == this.id)
      return;
    this.id = aId;
    /*
     * !! FIXME !!
     * this has no effect in Chrome, and we depend on it
     * to be able to change the map in the page.
     *
     * to make things worse there doesn't seem to be a way
     * to detect this behavior since trying to change data
     * doesn't throw an exception, it simply updates the
     * field in the DOM and silently ignores it.
     */
    this.htmlObject.data = "/svg/" + aId + ".svg";
    this.htmlObject.src = "/svg/" + aId + ".svg";
    
    var map = this;
    var save = this.htmlObject.onload;
    this.htmlObject.onload = function()
    {
      if(typeof(map.htmlObject.getSVGDocument) == 'function')
        map.svgObject = map.htmlObject.getSVGDocument();
      else
        map.svgObject = map.htmlObject.contentDocument;
      if(aWhenDoneCallback != null)
        aWhenDoneCallback();
      map.htmlObject.onload = save;
    }
    
    return true;
  }
  
  NX.Nebraska.Map.prototype.getHTMLObject = function()
  {
    return this.htmlObject;
  }
  
  NX.Nebraska.Map.prototype.getCode = function()
  {
    return this.id;
  }
  
  /*
   * paint the given sub-region the given colour
   */
  
  NX.Nebraska.Map.prototype.paint = function(aId, aColour)
  {
    // it might be a province or a country, but here we call sub
    // objects states to avoid calling it the generic "element"
    // or what have you.
    var state = this.svgObject.getElementById(aId);
    if(state == null)
    {
      alert('could not find ' + aId + ' in map');
      return false;
    }
    state.setAttribute('style', 'fill: ' + aColour);
    return true;
  }
  
  /*
   * set a callback for mouse events related to sub-regions
   */
  
  // aEventName one of onmousemove onmouseout onclick
  NX.Nebraska.Map.prototype.addCallback = function(aId, aEventName, aFunc)
  {
    // it might be a province or a country, but here we call sub
    // objects states to avoid calling it the generic "element"
    // or what have you.
    var state = this.svgObject.getElementById(aId);
    
    /*
     * !! FIXME !! svgweb / IE8 HACK!
     *
     * we should probably be using addEventListener
     * instead of what we are doing down below for
     * non IE8 browsers, but for now I'm not going
     * to break what works.
     *
     * At some point I'll go through and change all
     * the calls to addCallback to exclude the 'on'
     * prefix, and well just call addEventListner.
     * just like that!
     */
    if(NX.Nebraska.Util.isSvgweb())
    {
      var eventName;
      if(aEventName == 'onmousemove')
        eventName = 'mousemove';
      if(aEventName == 'onmouseover')
        eventName = 'onmouseover';
      else if(aEventName == 'onmouseout')
        eventName = 'mouseout';
      else if(aEventName == 'onclick')
        eventName = 'click';
      else
        alert('unexpected event name ' + aEventName);
      state.addEventListener(eventName, function(aEvent) { 
        var event=window.event || aEvent; 
        return aFunc(aId, state, event); 
      }, false);
      return true;
    }
    
    // chain the handler if there is already one
    // triggered by this event.
    var oldEvent = state[aEventName];
    if(oldEvent != null)
    {
      state[aEventName] = function(event)
      {
        oldEvent();
        return aFunc(aId, state, event);
      }
    }
    else
    {
      state[aEventName] = function(event) { return aFunc(aId, state, event); };
    }
    return true;
  }
  
  NX.Nebraska.Map.prototype.exists = function(aId)
  {
    var state = this.svgObject.getElementById(aId);
    return state != null;
  }
  
  NX.Nebraska.Map.prototype.setDisplayStyle = function(newStyle)
  {
    this.display_style = newStyle;
    return true;
  }
 
  NX.Nebraska.Map.prototype.makeInvisible = function()
  {
    this.htmlObject.style.display = 'none';
    return true;
  }
  
  NX.Nebraska.Map.prototype.makeVisible = function()
  {
    this.htmlObject.style.display = this.display_style;
    return true;
  }
  
  /*
   * PREREQ: NX/Nebraska/PopUp.js
   * add some popup test to a given sub-region.  when you mouse over it pops up near
   * the mouse, removing the popup when the mouse moves outside of the sub-region.
   */
  
  NX.Nebraska.Map.prototype.addPopUp = function(aId, aHTML)
  {
    var pop = new NX.Nebraska.PopUp(aHTML);
    var htmlObject = this.htmlObject;
    this.addCallback(aId, 'onmouseover', function(aId,aState,aEvent) { ev = aEvent || window.event; pop.show(null, ev.pageX, ev.pageY+25); });
    this.addCallback(aId, 'onmouseout', function() { pop.hide(); });
    return pop;
  }
  
  NX.Nebraska.Map.prototype.getPositionFromEvent = function(aEvent)
  {
    var event = aEvent || window.event;
    var pos = new NX.Nebraska.PageLocation(event.clientX, event.clientY);
    pos.add(NX.Nebraska.Util.getPositionFromHTMLObject(this.getHTMLObject()));
    return pos;
  }
 
  /*
   * ====================================================================
   */

})();