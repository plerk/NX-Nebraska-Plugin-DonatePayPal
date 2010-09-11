/*
 * Project Nebraska
 *
 * Smallest First Algorithm ~ starting with the smallest region,
 * adds each region in so long as it fits.
 */
if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Algo === undefined) NX.Nebraska.Algo = {};

(function ()
{

  /*
   * ====================================================================
   */
   
  NX.Nebraska.Algo.SmallestFirst = function()
  {
  }
  
  NX.Nebraska.Algo.SmallestFirst.prototype.getName = function()
  {
    return "smallest first";
  }
  
  NX.Nebraska.Algo.SmallestFirst.prototype.execute = function(aIdealWeight, aPlaceList)
  {
    var result = new NX.Nebraska.AlgoResult(this, aIdealWeight);
    
    var len = aPlaceList.length;
    var weight = 0;
    for(var i=0; i<len; i++)
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