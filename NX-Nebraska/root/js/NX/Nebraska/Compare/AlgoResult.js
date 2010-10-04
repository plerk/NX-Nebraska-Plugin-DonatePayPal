/*
 * Project Nebraska
 *
 * Class to store the result of a given findBestFit algorithm.  This allows
 * AlgoList.findBestFit() to choose the closest fit and apply it to the
 * Output map.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Compare === undefined) NX.Nebraska.Compare = {};

(function ()
{

  /*
   * ====================================================================
   */
   
  NX.Nebraska.Compare.AlgoResult = function(aAlgo, aIdealWeight)
  {
    this.algo = aAlgo;
    this.list = [];
    this.weight = 0;
    this.idealWeight = aIdealWeight;
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.distanceFromIdeal = function()
  {
    return Math.abs(this.idealWeight - this.weight);
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.getIdealWeight = function()
  {
    return this.idealWeight;
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.percentDistanceFromIdeal = function()
  {
    return 100 * this.distanceFromIdeal() / this.getIdealWeight();
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.distanceColour = function()
  {
    var percent = this.percentDistanceFromIdeal();
    if(percent < 5)
    {
      return 'green';
    }
    else if(percent < 10)
    {
      return 'yellow';
    }
    else if(percent < 20)
    {
      return 'orange';
    }
    else
    {
      return 'red';
    }
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.distanceDirection = function()
  {
    if(this.idealWeight < this.weight)
      return 'larger by';
    else if(this.idealWeight == this.weight)
      return 'exactly at';
    else
      return 'smaller by';
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.getWeight = function()
  {
    return this.weight;
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.getAlgo = function()
  {
    return this.algo;
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.addPlace = function(aPlace)
  {
    this.list.push(aPlace);
    this.weight += aPlace.getValue();
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.applyResultToMap = function(aMap)
  {
    aMap.iteratePlaces(function(aPlace) { aPlace.selectOff(); });
    this.iteratePlaces(function(aPlace) { aPlace.selectOn(); });
    aMap.updatePostSelect(this);
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.mergeResults = function(aAlgoResult)
  {
    var self = this;
    aAlgoResult.iteratePlaces(function(aPlace) { self.addPlace(aPlace); });
  }
  
  NX.Nebraska.Compare.AlgoResult.prototype.iteratePlaces = function(aFunction)
  {
    var len = this.list.length;
    for(var i=0; i<len; i++)
    {
      aFunction(this.list[i]);
    }
  }
  
  /*
   * ====================================================================
   */

})();
