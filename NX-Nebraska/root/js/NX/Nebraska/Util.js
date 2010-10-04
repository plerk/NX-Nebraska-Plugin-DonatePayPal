/*
 * Project Nebraska
 * 
 * Some utility functions that don't really belong anywhere else.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Util === undefined) NX.Nebraska.Util = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  /*
   * GIVEN: an integer
   * RETURN: a string version of that number with commas seperating
   * each three digits, the way people are used to seeing numbers if
   * they want to be able to read them.
   */
  NX.Nebraska.Util.integerToHumanReadableNumber = function(num)
  {
    num = "" + num;                     // convert to string, if it isn't already.
    var list = num.split('.');
    num = list[0];                      // integer part
    var frac = list[1];                 // fraction part
    var digits = num.split('');
    var answer = new Array();
    while(digits.length > 3)
    {
      var a = digits.pop();
      var b = digits.pop();
      var c = digits.pop();
      answer.unshift(c+b+a);
    }
    answer.unshift(digits.join(''));
    if(frac != null)
      return answer.join(',') + '.' + frac;
    else
      return answer.join(',');
  }
  
  /*
   * GIVEN:  percent value 0-100 floating point
   * RETURN: a percent in the form of x.xx%, xx.xx% or 100.00%
   */
  NX.Nebraska.Util.percentToHumanReadable = function(percent)
  {
    var whole = Math.floor(percent);
    var fraction = Math.floor((percent-whole)*100);
    if(fraction < 10)
      return whole + '.0' + fraction + '%';
    else
      return whole + '.' + fraction + '%';
  }
  
  var startup_list = [];
  var already_started = false;
  
  if(NX.Nebraska.Util.using_svgweb_hack == null)
    NX.Nebraska.Util.using_svgweb_hack = false;
  
  NX.Nebraska.Util.callOnLoad = function(aFunction)
  {
    if(already_started)
    {
      alert('tried to call NX.Nebraska.Util.callOnLoad() after load!');
      aFunction();
      return;
    }
    
    if(NX.Nebraska.Util.using_svgweb_hack)
    {
      window.addEventListener('SVGLoad', aFunction, false);
    }
    else
    {
      startup_list.push(aFunction);
    }
  }
  
  var old_onload = window.onload;
  window.onload = function()
  {
    if(old_onload != null)
      old_onload();
    for(var i in startup_list)
    {
      startup_list[i]();
    }
    already_started = true;
  }
  
  var isKHTML = null;
  
  /*
   * Tries to detect if we are in a KHTML based browser, 
   * such as Chrome or Safari.  Both have somewhat different
   * behavior when it comes to SVG.
   */
  NX.Nebraska.Util.isKHTML = function()
  {
    if(isKHTML != null)
      return isKHTML;
    return isKHTML = navigator.userAgent.toLowerCase().indexOf('khtml, like gecko') > -1;
  }
  
  /*
   * Returns true if we are using svgweb instead of
   * native SVG support.  Should only be true if we
   * are running in IE8 or earlier.
   */
  NX.Nebraska.Util.isSvgweb = function()
  {
    return NX.Nebraska.Util.using_svgweb_hack;
  }
  
  /*
   * Yet another workaround for IE!  Yup.  You got it.
   * IE having to be different requires a calculation
   * to get the mouse position.
   *
   * You can probably date my comments in this code by
   * the degree of civility in my comments.  Early on
   * I was very neutral, but now that I am getting closer
   * to having this thing work in IE I've become more 
   * angry!
   */
  NX.Nebraska.Util.getPositionFromEvent = function(aEvent)
  {
    var event = aEvent || window.event;
    if (event.pageX || event.pageY) {
      return new NX.Nebraska.PageLocation(event.pageX, event.pageY)
    }
    else if (event.clientX || event.clientY) 
    {
      return new NX.Nebraska.PageLocation(
        event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft,
        event.clientY + document.body.scrollTop + document.documentElement.scrollTop
      );
    }
    alert('browser not supported');
  }
  
  NX.Nebraska.Util.getPositionFromHTMLObject = function(aObject)
  {
    var object = aObject;
    var x = y = 0;
    if (object.offsetParent)
    {
      do {
        x += object.offsetLeft;
        y += object.offsetTop;
      } while (object = object.offsetParent);
    }
    return new NX.Nebraska.PageLocation(x,y);
  }
  
  NX.Nebraska.Util.escapeHTML = function(aText)
  {
    return aText.replace(/&/g, '&amp;')
                .replace(/\</g, '&lt;')
                .replace(/\>/g, '&gt;');
  }
  
  /*
   * ====================================================================
   */

})();