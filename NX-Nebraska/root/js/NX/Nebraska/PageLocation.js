/*
 * Project Nebraska
 *
 * Class to store page locations (x, y).  Used for popups mainly.
 * See PopUp.js
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  NX.Nebraska.PageLocation = function(aX, aY)
  {
    this.x = aX || 0;
    this.y = aY || 0;
  }
  
  NX.Nebraska.PageLocation.prototype.add = function(aOne, aTwo)
  {
    if(aTwo != null)
    {
      this.x += aOne;
      this.y += aTwo;
    }
    else
    {
      this.x += aOne.x
      this.y += aOne.y;
    }
    return this;
  }
  
  /*
   * ====================================================================
   */

})();