/*
 * Project Nebraska Compare Map Application
 *
 * This is the main entry point for the Compare Maps
 * application.  It also includes some code specific to
 * the Input and Output maps.  For the code common to
 * both maps, see CompareMap.js.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Compare === undefined) NX.Nebraska.Compare = {};
if(NX.Nebraska.Compare.Main === undefined) NX.Nebraska.Compare.Main = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  NX.Nebraska.Util.callOnLoad(function(){
  
    var inputMap = new NX.Nebraska.Compare.Map('input', document.getElementById('map_default_input').value);
    var outputMap = new NX.Nebraska.Compare.Map('output', document.getElementById('map_default_output').value);
    var algoList = new NX.Nebraska.Compare.AlgoList();
    algoList.add(new NX.Nebraska.Compare.Algo.SmallestFirst);
    algoList.add(new NX.Nebraska.Compare.Algo.LargestFirst);
    algoList.add(new NX.Nebraska.Compare.Algo.Optimal);
    
    inputMap.assoicateMaps(outputMap);
    inputMap.placeConfigChangeCB = function() { algoList.findBestFit(inputMap, outputMap); return false; };
    inputMap.statConfigChangeCB = function() { algoList.findBestFit(inputMap, outputMap); return false; };
    outputMap.disableStateSelection();
    outputMap.statConfigChangeCB = function() { algoList.findBestFit(inputMap, outputMap); return false; };
    
    function disableStatsWithMismatchingUnits()
    {
      /*
       * disable stats in the input.
       */
      var have_units = {};
      var i;
      var stat;
      for(i in outputMap.statById)
      {
        stat = outputMap.statById[i];
        have_units[stat.units] = true;
      }
      var len = inputMap.statsSelector.options.length;
      var option;
      for(i=0; i<len; i++)
      {
        option = inputMap.statsSelector.options[i];
        stat = inputMap.statById[option.value];
        if(have_units[stat.units])
          option.disabled = false;
        else
          option.disabled = true;
      }
    };
    
    /*
     * mapConfigChangeCB
     * WHEN called when the input map is changed
     *  (e.g. from Australia to USA, etc)
     */
    inputMap.mapConfigChangeCB = function()
    {
      outputMap.clearAll();
      inputMap.changeStatsCB(inputMap.statsSelector);
      disableStatsWithMismatchingUnits();
      return false;
    };
    
    /*
     * mapConfigChangeCB
     * WHEN: called when the output map is changed
     *  (e.g. from Australia to USA, etc)
     * FUNCTION: update the stats selector for both
     *  input and output maps and findBestFit if 
     *  there are states selected in the input map.
     * ALSO: disable any stats in the input map
     *  which use units that are not found in stats
     *  in the output map.
     */
    outputMap.mapConfigChangeCB = function()
    {
      /*
       * remove stats in the output that don't belong
       * (this is the same as when a stat is selected 
       * on the input map, hence the funny call of a
       * CB function here).
       */
      inputMap.statsUpdateCB(inputMap.statsSelector, inputMap.selectedStat);
      
      /*
       * get values for each state 
       */
      outputMap.updateValues(
        function() {
          algoList.findBestFit(inputMap, outputMap);
        }
      );
      
      disableStatsWithMismatchingUnits();
      return false;
    };
    
    document.getElementById('select_all').onclick = function()
    {
      inputMap.iteratePlaces(function(aPlace) { aPlace.selectOn(); aPlace.option.selected = true; });
      inputMap.updatePostSelect();
      algoList.findBestFit(inputMap, outputMap);
      return false;
    };
    
    document.getElementById('toggle').onclick = function()
    {
      inputMap.iteratePlaces(function(aPlace) { aPlace.toggle(); aPlace.option.selected = aPlace.isSelected(); });
      inputMap.updatePostSelect();
      algoList.findBestFit(inputMap, outputMap);
      return false;
    };
    
    document.getElementById('select_none').onclick = function()
    {
      inputMap.clearAll();
      algoList.findBestFit(inputMap, outputMap);
      return false;
    };
    
    document.getElementById('refresh_output').onclick = function()
    {
      algoList.findBestFit(inputMap, outputMap);
      return false;
    };
    
    /*
     * swap the input and output maps, transfering the selection
     * keeping the selection in the old output map (new input map)
     * where possible.
     *
     * we have a few speical cases to deal with.
     * 1. Chrome and IE with svgweb do not support changing
     *    the base map, so we have to reload the whole page, and
     *    we loose the selection.
     * 2. if the input and output maps are the same then setting
     *    the base maps (to the same value) is a nop and doesn't
     *    trigger a whole bunch of updates that we depend on in
     *    the normal case, so we go ahead and just swap the
     *    selections manually.
     * 3. The normal case is on Firefox when the maps are different.
     *    here we simulate what would happen when if the user
     *    selected each map one at a time, and then fill in the 
     *    old output maps selection on the new input map.
     */
    document.getElementById('swap_maps').onclick = function()
    {
      if(NX.Nebraska.Util.isKHTML()
      || NX.Nebraska.Util.isSvgweb())
      {
        window.location = '/app/compare?input_map_code=' + outputMap.map.getCode() + '&output_map_code=' + inputMap.map.getCode();
      }
      else
      {
        var saveSelection = [];
        outputMap.iteratePlaces(function(aPlace) {
          if(aPlace.selected)
            saveSelection.push(aPlace.id);
        });
        var saveIndex = inputMap.mainSelector.selectedIndex;
        inputMap.mainSelector.selectedIndex  = outputMap.mainSelector.selectedIndex;
        outputMap.mainSelector.selectedIndex = saveIndex;
        
        var newInputCode = outputMap.map.getCode();
        var newOutputCode = inputMap.map.getCode();
        
        var newOutputStat = inputMap.statsSelector.options[inputMap.statsSelector.selectedIndex].value;
        var newInputStat = outputMap.statsSelector.options[outputMap.statsSelector.selectedIndex].value
        
        if(newInputCode == newOutputCode)
        {
          inputMap.iteratePlaces(function(aPlace) {
            aPlace.selectOff();
          });
        
          var len=saveSelection.length;
          for(var i=0; i<len; i++)
          {
            var id = saveSelection[i];
            inputMap.placeById[id].selectOn();
          }
           
          len = inputMap.statsSelector.options.length;
          for(var i=0; i<len; i++)
          {
            if(inputMap.statsSelector.options[i].value == newInputStat)
              inputMap.statsSelector.selectedIndex = i;
          }
          
          len = outputMap.statsSelector.options.length;
          for(var i=0; i<len; i++)
          {
            if(outputMap.statsSelector.options[i].value == newOutputStat)
              outputMap.statsSelector.selectedIndex = i;
          }

          tmp = inputMap.selectedStat;
          inputMap.selectedStat = outputMap.selectedStat;
          outputMap.selectedStat = tmp;
          
          inputMap.updatePostSelect();
          algoList.findBestFit(inputMap,outputMap);
          return;
        }
        
        inputMap.disableControls();
        outputMap.disableControls();
        outputMap.map.setBase(newOutputCode, function(){ 
          outputMap.update(function(){
            outputMap.mapConfigChangeCB();
            
            inputMap.map.setBase(newInputCode,function(){
            
              inputMap.update(function(){
              
                var len = inputMap.statsSelector.options.length;
                for(var i=0; i<len; i++)
                {
                  if(inputMap.statsSelector.options[i].value == newInputStat)
                    inputMap.statsSelector.selectedIndex = i;
                }
                
                inputMap.selectedStat = inputMap.statById[newInputStat];
              
                inputMap.mapConfigChangeCB();
                
                len = outputMap.statsSelector.options.length;
                for(var i=0; i<len; i++)
                {
                  if(outputMap.statsSelector.options[i].value == newOutputStat)
                    outputMap.statsSelector.selectedIndex = i;
                }
                
                outputMap.selectedStat = outputMap.statById[newOutputStat];
                
                len=saveSelection.length;
                for(var i=0; i<len; i++)
                {
                  var id = saveSelection[i];
                  inputMap.placeById[id].selectOn();
                }
                
              });
            });
          });
        });
      }
    };
    
    /*
     * statsUpdateCB
     * WHEN: called when a new stat is selected in the stats
     *  selector on the input map is set.
     * FUNCTION: reconstruct the stat selector on the output
     *  map such that only stats with the same units are 
     *  selectable.
     */
    inputMap.statsUpdateCB = function(aSelect, aNewStat)
    {
      var keep_selected = false;      // flag indicating we should keep the currently
                                      // selected stat in the output map.
      var most_recent_stat = null;    // most recent stat from the other selector
      var most_recent_option = null;  // the <option> corresponding to that stat
      this.otherMap.statsSelector.innerHTML = '';
      for(var i in this.otherMap.statById)
      {
        var otherStat = this.otherMap.statById[i];
        if(aNewStat.units == otherStat.units)
        {
          var option = document.createElement('option');
          /*
           * prefer .text here, but it doesn't seem to
           * be supported under IE8
           */
          option.innerHTML = otherStat.getLabel();
          option.value = otherStat.id;
          this.otherMap.statsSelector.appendChild(option);
          if(this.otherMap.selectedStat === otherStat)
          {
            option.selected = true;
            keep_selected = true;
          }
          if(most_recent_stat == null
          || most_recent_stat.year < otherStat.year 
          || (most_recent_stat.year == otherStat.year && (otherStat.is_primary || !most_recent_stat.is_primary)))
          {
            most_recent_stat = otherStat;
            most_recent_option = option;
          }
        }
      }
      
      if(!keep_selected)
      {
        if(most_recent_stat != null)
        {
          this.otherMap.selectedStat = most_recent_stat;
          most_recent_option.selected = true;
          this.otherMap.updateValues();
        }
        else
        {
          this.otherMap.selectedStat = null;
        }
      }
      
      this.otherMap.statsSelector.style.display = 'block';
      
      return true;
    };
    
    outputMap.update(
      function()
      {
        inputMap.update(
          function()
          {
            inputMap.changeStatsCB(inputMap.statsSelector);
            disableStatsWithMismatchingUnits();
          }
        );
      }
    );
  });
  
  /*
   * ====================================================================
   */

})();
