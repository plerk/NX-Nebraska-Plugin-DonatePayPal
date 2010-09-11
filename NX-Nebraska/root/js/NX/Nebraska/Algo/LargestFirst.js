/*
 * Project Nebraska
 *
 * Largest First Algorithm ~ starting with the largest region,
 * adds each region in so long as it fits.  Sometimes finds a 
 * better result than Smallest First.
 */
 
if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Algo === undefined) NX.Nebraska.Algo = {};

(function ()
{

  /*
   * ====================================================================
   */
   
  NX.Nebraska.Algo.LargestFirst = function()
  {
  }
  
  NX.Nebraska.Algo.LargestFirst.prototype.getName = function()
  {
    return "largest first";
  }
  
  NX.Nebraska.Algo.LargestFirst.prototype.execute = function(aIdealWeight, aPlaceList)
  {
    var result = new NX.Nebraska.AlgoResult(this, aIdealWeight);
    
    var len = aPlaceList.length;
    var weight = 0;
    for(var i=len-1; i>=0; i--)
    {
      var place = aPlaceList[i];
      var value = place.getValue();
      var newWeight = weight + value;
      
      if(Math.abs(newWeight - aIdealWeight) < Math.abs(weight - aIdealWeight))
      {
        weight += value;
        result.addPlace(place);
      }
    }
    
    return result;
  }
  
  /*
   * ====================================================================
   */

})();