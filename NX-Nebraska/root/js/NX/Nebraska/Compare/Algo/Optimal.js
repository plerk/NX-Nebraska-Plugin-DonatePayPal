/*
 * Project Nebraska
 *
 * Optimal Algorithm ~ Tries every possible combination.
 * Since this is very slow with lots of regions we don't
 * use it unless there are only a small number of regions.
 */
 
if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Compare === undefined) NX.Nebraska.Compare = {};
if(NX.Nebraska.Compare.Algo === undefined) NX.Nebraska.Compare.Algo = {};

(function ()
{

  /*
   * ====================================================================
   */
   
  NX.Nebraska.Compare.Algo.Optimal = function()
  {
  }
  
  NX.Nebraska.Compare.Algo.Optimal.prototype.getName = function()
  {
    return "optimal";
  }
  
  function copyList(aList)
  {
    var result = [];
    var len = aList.length;
    for(var i=1; i<len; i++)
    {
      result.push(aList[i]);
    }
    return result;
  }
  
  NX.Nebraska.Compare.Algo.Optimal.prototype.execute = function(aIdealWeight, aPlaceList)
  {
    var result = new NX.Nebraska.Compare.AlgoResult(this, aIdealWeight);
    
    var place = aPlaceList[0];
    
    if(aPlaceList.length == 1)
    {
      if(Math.abs(aIdealWeight - place.getValue()) < aIdealWeight)
        result.addPlace(place);
    }
    else if(aPlaceList.length < 10) // don't attempt to run the optimal algorithm on maps with more than 8 regions.
    {
      var otherPlaces = copyList(aPlaceList);
      var result1 = this.execute(aIdealWeight, otherPlaces);
      var result2 = this.execute(aIdealWeight-place.getValue(), otherPlaces);
      if(Math.abs(aIdealWeight-result2.getWeight()-place.getValue()) < result1.distanceFromIdeal())
      {
        result1 = result2;
        result.addPlace(place);
      }
      result.mergeResults(result1);
    }
    else
    {
      NX.Nebraska.Debug.say('map has too many regions for Optimal algorithm ' + aPlaceList.length);
    }
    
    return result;
  }
  
  /*
   * ====================================================================
   */

})();
