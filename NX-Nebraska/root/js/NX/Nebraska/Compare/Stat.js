/*
 * Project Nebraska
 *
 * Class to represent a stat.  Something like "population"
 * or "area".  It is NOT the value.  That is stored in the Place
 * objects.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Compare === undefined) NX.Nebraska.Compare = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  NX.Nebraska.Compare.Stat = function(aId, aName, aYear, aUnits, aIsPrimary)
  {
    this.id = aId;
    this.name = aName;
    this.year = aYear;
    this.units = aUnits;
    if(aIsPrimary == 1)
      this.is_primary = true;
    else
      this.is_primary = false;
  }
  
  NX.Nebraska.Compare.Stat.prototype.getLabel = function()
  {
    return this.name + ' ' + this.year;
  }
  
  /*
   * ====================================================================
   */

})();
