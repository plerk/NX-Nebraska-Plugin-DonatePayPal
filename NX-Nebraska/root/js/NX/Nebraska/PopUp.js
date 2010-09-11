/*
 * map javascript routines for tooltip style popups.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  /*
   * Create a new popup.
   * usage: var popup = new NX.Nebraska.PopUp('<p>some html here!</p>', 'optionalClassName');
   */
  
  NX.Nebraska.PopUp = function(aHTML, aClass)
  {
    this.div = document.createElement('div');
    this.div.innerHTML = aHTML;
    
    if(aClass == null)
    {
      this.div.className = 'popup';
    }
    else
    {
      this.div.className = aClass;
    }

    document.body.appendChild(this.div);
  }
  
  /*
   * Get the inner HTML as a string.
   * usage: popup.getHTML();
   */
  
  NX.Nebraska.PopUp.prototype.getHTML = function()
  {
    return this.div.innerHTML;
  }
  
  /*
   * Set the HTML for the popup
   * usage: popup.setHTML('<p>some html here</p>');
   */
  NX.Nebraska.PopUp.prototype.setHTML = function(aHTML)
  {
    this.div.innerHTML = aHTML;
    return true;
  }
  
  /*
   * Get the <div> element for the popup
   * usage: var div = popup.getContainer();
   */
  NX.Nebraska.PopUp.prototype.getContainer = function()
  {
    return this.div;
  }
  
  /*
   * display the popup at the coordinates given, relative to the given
   * DOM object, or (if not provided) the page itself.
   * usage: popup.show(null, 0, 25);
   */
  NX.Nebraska.PopUp.prototype.show = function (aPos)
  {
    this.div.style.left = aPos.x + 'px';
    this.div.style.top = aPos.y + 'px';
    this.div.style.visibility = 'visible';
    this.div.style.display = 'block';
  }
  
  /*
   * erase the popup from the display.
   * usage: popup.hide();
   */
  NX.Nebraska.PopUp.prototype.hide = function ()
  {
    this.div.style.visibility = 'hidden';
    this.div.style.display = 'none';
  }
  
  /*
   * ====================================================================
   */

})();