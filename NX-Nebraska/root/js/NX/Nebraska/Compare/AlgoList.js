/*
 * Project Nebraska
 *
 * List of algorithms used by the site to find the best fit.  Basically
 * we itterate through each algorithm, try it, keep it if it is th best
 * we've seen so far and toss it if not.  At the end we apply the closest
 * fit to the output map.
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
  
  NX.Nebraska.Compare.AlgoList = function()
  {
    this.list = [];
  }
  
  NX.Nebraska.Compare.AlgoList.prototype.add = function(aAlgo)
  {
    this.list.push(aAlgo);
  }
  
  NX.Nebraska.Compare.AlgoList.prototype.findBestFit = function(aInputMap, aOutputMap)
  {
    var idealWeight = aInputMap.getWeight();
    NX.Nebraska.Debug.clear();
    
    /*
     * short cut if nothing is selected on input,
     * then deselect everything in output.
     */
    if(idealWeight == 0)
    {
      aOutputMap.clearAll();
      NX.Nebraska.Debug.say("ideal weight is zero.  deselecting output map");
      return;
    }
    
    var placesList = [];
    aOutputMap.iteratePlaces(function(aPlace) { placesList.push(aPlace); });
    placesList.sort(function(aPlaceA, aPlaceB) { return aPlaceA.getValue() - aPlaceB.getValue(); });
    
    var len = this.list.length;
    var best;
    var maybe;
    for(var i=0; i<len; i++)
    {
      maybe = this.list[i].execute(idealWeight, placesList);
      NX.Nebraska.Debug.say('#' + i + ' ' + maybe.getAlgo().getName() + ' ~> distance = ' + NX.Nebraska.Util.integerToHumanReadableNumber(maybe.distanceFromIdeal()));
      if(best == null || maybe.distanceFromIdeal() < best.distanceFromIdeal())
        best = maybe;
    }
    
    if(maybe == null)
    {
      alert('no algos!');
      return;
    }
    
    NX.Nebraska.Debug.say('===========================================');
    NX.Nebraska.Debug.say('algo used: ' + best.getAlgo().getName());
    NX.Nebraska.Debug.say('distance:  ' + NX.Nebraska.Util.integerToHumanReadableNumber(best.distanceFromIdeal()));
    best.applyResultToMap(aOutputMap);
  }
  
  /*
   * ====================================================================
   */

})();
