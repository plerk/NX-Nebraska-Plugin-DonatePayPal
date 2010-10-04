/*
 * Project Nebraska Compare Map.
 *
 * For the Compare Map application, this class represents either
 * an Input or Output map.  All code common to both Input and Output
 * is in this file.  Code that is Input or Output specific is in
 * Compare.js.
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Compare === undefined) NX.Nebraska.Compare = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  var maps = {};
  
  NX.Nebraska.Compare.Map = function(aName, aBase)
  {
    var self = this;
    this.name = aName;
    this.map = new NX.Nebraska.Map('map_svg_' + aName, aBase);

    this.mainSelector = document.getElementById('map_select_' + aName);
    this.mainSelector.onchange = function() { self.changeBaseMapCB(this); }
    /*
     * When I hit reload in Firefox (at least) the map selectors keep
     * their values, although the maps restore to the ones specified
     * by the HTML, so we go back and fix the selector to match which
     * states are displayed.
     * On the first load this is redundant of course.
     */
    var len = this.mainSelector.options.length;
    for(var i=0; i<len; i++)
    {
      if(this.mainSelector.options[i].value == aBase)
        this.mainSelector.options[i].selected = true;
      else
        this.mainSelector.options[i].selected = false;
    }
    
    this.stateSelector = document.getElementById('map_states_' + aName);
    this.stateSelector.onchange = function() { self.changeStateCB(this); }
    
    /*
     * this stuff is only displayed for the output map,
     * but for now we don't differentiate here since the
     * <ul> element is not displayed for the input map.
     */
    this.list = document.getElementById('map_list_' + aName);
    this.list.style.display = 'none';
    this.listPopup = new NX.Nebraska.PopUp('empty');
    this.list.onmousemove = function(aEvent) 
    {
      var pos = NX.Nebraska.Util.getPositionFromEvent(aEvent);
      self.listPopup.show(pos.add(-133,+20));
    };
    this.list.onmouseout = function() { self.listPopup.hide(); };
    
    this.statsSelector = document.getElementById('map_stats_' + aName);
    this.statsSelector.onchange = function() { self.changeStatsCB(this); }
    this.statsUpdateCB = function() { return true; };
    
    this.weightDisplay = document.getElementById('maps_svg_weight_display_' + aName);
    this.weightDisplayPopup = new NX.Nebraska.PopUp();
 
    this.statesAreSelectableFlag = true;
    this.placeById = {};
    this.statById = {};
    this.selectedStat = null;
    this.otherMap = null;
    
    this.mapConfigChangeCB = function() { };
    this.placeConfigChangeCB = function() { };
    this.statConfigChangeCB = function()  { };
    
    maps[this.name] = this;
  }
  
  NX.Nebraska.Compare.Map.prototype.statesAreSelectable = function()
  {
    return this.statesAreSelectableFlag;
  }
  
  NX.Nebraska.Compare.Map.prototype.disableStateSelection = function()
  {
    this.statesAreSelectableFlag = false;
    this.stateSelector.style.display = 'none';
    this.list.style.display = 'block';
  }
  
  NX.Nebraska.Compare.Map.prototype.assoicateMaps = function(aOther)
  {
    if(aOther != null)
    {
      this.otherMap = aOther;
      aOther.otherMap = this;
    }
  }
  
  NX.Nebraska.Compare.Map.prototype.enableControls = function()
  {
    this.mainSelector.disabled = false;
    this.stateSelector.disabled = false;
    this.statsSelector.disabled = false;
  }
  
  NX.Nebraska.Compare.Map.prototype.disableControls = function()
  {
    this.mainSelector.disabled = true;
    this.stateSelector.disabled = true;
    this.statsSelector.disabled = true;
  }
  
  NX.Nebraska.Compare.Map.prototype.changeBaseMapCB = function(aSelect)
  {
    var self = this;
    var newCode = aSelect.options[aSelect.selectedIndex].value;
    if(newCode == this.map.getCode())
      return;
    if(NX.Nebraska.Util.isKHTML()
    || NX.Nebraska.Util.isSvgweb())
    {
      /*
       * workaround for the fact that we can't change the data 
       * (svg source file) field for a map in Google Chrome.
       *
       * !! FIXME !! it would be good if we could detect the 
       * behavior instead of detecting the browser, but it is 
       * not clear how.  See Map.js in this same directory for
       * more comments on this issue.
       *
       * !! FIXME !! it would be even better if there were a way
       * do do what I am doing in Firefox in Chrome.
       */
      var input_map_code;
      var output_map_code;
      if(this.name == 'input')
      {
        input_map_code = newCode;
        output_map_code = this.otherMap.map.getCode();
      }
      else
      {
        output_map_code = newCode;
        input_map_code = this.otherMap.map.getCode();
      }
      window.location = '/app/compare?input_map_code=' + input_map_code + '&output_map_code=' + output_map_code;
    }
    else
    {
      this.disableControls();
      //alert('in non chrome branch');
      this.map.setBase(newCode, 
        function() 
        { 
          self.update(
            function()
            {
              self.mapConfigChangeCB();
            }
          );
        }
      );
    }
  }
  
  NX.Nebraska.Compare.Map.prototype.changeStateCB = function(aSelect)
  {
    var len = aSelect.options.length;
    for(var i=0; i<len; i++)
    {
      var place = this.placeById[aSelect[i].value];
      if(aSelect.options[i].selected)
        place.selectOn();
      else
        place.selectOff();
    }
    this.updatePostSelect();
    this.placeConfigChangeCB();
  }
  
  
  NX.Nebraska.Compare.Map.prototype.changeStatsCB = function(aSelect)
  {
    /*
     * if unselected
     */
    if(aSelect.selectedIndex == -1)
    {
      alert('no selection');
      this.selectedStat = null;
      return;
    }
    
    /*
     * else if selected
     */
    var newStat = this.statById[aSelect.options[aSelect.selectedIndex].value];
    /*
     * stop here if the object in question is already selected.
     */
    //if(newStat === this.selectedStat)
    //  return;
    if(this.statsUpdateCB(aSelect,newStat))
    {
      this.selectedStat = newStat;
      this.updateValues();
    }
  }
  
  NX.Nebraska.Compare.Map.prototype.updatePostSelect = function(aAlgoResult)
  {
    this.updateWeightDisplay(aAlgoResult);
    this.updateList();
  }
  
  NX.Nebraska.Compare.Map.prototype.updateWeightDisplay = function(aAlgoResult)
  {
    if(this.selectedStat == null)
    {
      this.weightDisplay.style.color = 'black';
      this.weightDisplay.innerHTML = '0';
      this.weightDisplay.onmousemove = function() { };
      this.weightDisplay.onmouseout = function() { };
      return;
    }
    var weight = NX.Nebraska.Util.integerToHumanReadableNumber(this.getWeight());
    this.weightDisplay.innerHTML = weight + ' ' + this.selectedStat.units;
    if(aAlgoResult != null)
    {
      var self = this;
      this.weightDisplay.style.color = aAlgoResult.distanceColour();
      this.weightDisplayPopup.setHTML(
        'Used ' + aAlgoResult.getAlgo().getName() + ' algorithm<br/>' +
        'Output selection is ' + aAlgoResult.distanceDirection() + ' ' +
        NX.Nebraska.Util.integerToHumanReadableNumber(aAlgoResult.distanceFromIdeal()) + 
        ' ' + this.selectedStat.units + ' input selection, or ' +
        NX.Nebraska.Util.percentToHumanReadable(aAlgoResult.percentDistanceFromIdeal())
      );
      this.weightDisplay.onmousemove = function(aEvent)
      {
        var pos = NX.Nebraska.Util.getPositionFromEvent(aEvent);
        self.weightDisplayPopup.show(pos.add(-133,+20));
      };
      this.weightDisplay.onmouseout = function() { self.weightDisplayPopup.hide(); };
    }
    else
    {
      this.weightDisplay.style.color = 'black';
      this.weightDisplay.onmousemove = function() { };
      this.weightDisplay.onmouseout = function() { };
    }
  }
  
  NX.Nebraska.Compare.Map.prototype.updateList = function()
  {
    this.list.innerHTML = '';
    var i;
    var place;
    var li;
    var count = 0;
    var nameList = [];
    for(i in this.placeById)
    {
      place = this.placeById[i];
      if(place.isSelected())
      {
        count++;
        if(count <= 6)
        {
          li = document.createElement('li');
          if(count == 6)
            li.innerHTML = '...';
          else
            li.innerHTML = place.name;
          this.list.appendChild(li);
        }
        nameList.push(place.name);
      }
    }
    this.listPopup.setHTML('<b>regions selected</b>: ' + count + '<br/>' + nameList.join(', '));
  }
  
  NX.Nebraska.Compare.Map.prototype.updatePlacesCB = function(aRaw)
  {
    this.stateSelector.innerHTML = '';
    this.list.innerHTML = '';
    this.placeById = {};
    var payload = JSON.parse(aRaw);
    var len = payload.length;
    for(var i=0; i<len; i++)
    {
      // for each payload element we have:
      // name ~ eg 'New Mexico'
      // code ~ eg 'NM'
      // id ~ eg 47
      // flag ~ eg 'us-nm.png';
      option = document.createElement('option');
      /*
       * I was originally using .text instead of
       * innerHTML here, but that seems to break
       * IE8
       */
      option.innerHTML = payload[i].name;
      option.value = payload[i].id;
      option.readonly = true;
      this.stateSelector.appendChild(option);
      this.placeById[payload[i].id] = new NX.Nebraska.Compare.Place(this, payload[i].id, payload[i].name, payload[i].code, payload[i].flag, option);
    }
    this.stateSelector.disabled = false;
  }
  
  NX.Nebraska.Compare.Map.prototype.updateStatsCB = function(aRaw)
  {
    this.statsSelector.innerHTML = '';
    this.statById = {};
    this.selectedStat = null;
    var payload = JSON.parse(aRaw);
    var len = payload.length;
    var option;
    for(var i=0; i<len; i++)
    {
      // for each payload element we have:
      // id ~ eg 23:2010
      // name ~ eg 'water area (sq mi)'
      // year ~ eg 2010
      // units ~ eg sq mi
      // is_primary ~ eg 1
      option = document.createElement('option');
      /*
       * see comment above about .text vs. .innerHTML
       */
      option.innerHTML = payload[i].name + ' ' + payload[i].year;
      option.value = payload[i].id;
      this.statsSelector.appendChild(option);
      this.statById[payload[i].id] = new NX.Nebraska.Compare.Stat(payload[i].id, payload[i].name, parseInt(payload[i].year), payload[i].units, payload[i].is_primary);
    }
    this.statsSelector.disabled = false;
  }
  
  NX.Nebraska.Compare.Map.prototype.getAjaxURL = function(aFunction)
  {
    return '/map/id/' + this.map.getCode() + '/' + aFunction;
  }
  
  NX.Nebraska.Compare.Map.prototype.update = function(aWhenDoneCallback)
  {
    var done_count = 0;
    var self = this;
    function when_done()
    {
      if(done_count == 2)
      {
        if(aWhenDoneCallback != null)
          aWhenDoneCallback();
        self.mainSelector.disabled = false;
      }
    }
    NX.Nebraska.Ajax.get(this.getAjaxURL('places'),
      function(aRaw) 
      {
        self.updatePlacesCB(aRaw);
        done_count++;
        when_done();
      }
    );
    NX.Nebraska.Ajax.get(this.getAjaxURL('statistics'), 
      function(aRaw) 
      {
        self.updateStatsCB(aRaw);
        done_count++;
        when_done();
      }
    );
  }
  
  NX.Nebraska.Compare.Map.prototype.iteratePlaces = function(aFunction)
  {
    for(var id in this.placeById)
    {
      aFunction(this.placeById[id]);
    }
  }
  
  NX.Nebraska.Compare.Map.prototype.clearAll = function()
  {
    this.iteratePlaces(function(aPlace) { aPlace.selectOff(); aPlace.option.selected = false; });
    this.updatePostSelect();
  }
  
  NX.Nebraska.Compare.Map.prototype.updateValuesCB = function(aRaw)
  {
    this.iteratePlaces(function(aPlace) { aPlace.clearStatAndValue(); });
    
    var payload = JSON.parse(aRaw);
    var len = payload.length;
    for(var i=0; i<len; i++)
    {
      // for each payload element we have:
      // place_id ~ eg 17
      // value ~ eg 47324
      var place = this.placeById[payload[i].place_id];
      var value = parseInt(payload[i].value);
      place.setStatAndValue(this.selectedStat, value);
    }
  }
  
  NX.Nebraska.Compare.Map.prototype.updateValues = function(aWhenDoneCallback)
  {
    var self = this;
    if(this.selectedStat == null)
      return;
    NX.Nebraska.Ajax.get(this.getAjaxURL('values') + '/' + this.selectedStat.id,
      function(aRaw)
      {
        self.updateValuesCB(aRaw);
        if(aWhenDoneCallback != null)
          aWhenDoneCallback();
        self.updatePostSelect();
        self.statConfigChangeCB();
      }
    );
  }
  
  NX.Nebraska.Compare.Map.prototype.getWeight = function()
  {
    var weight = 0;
    this.iteratePlaces(function(aPlace){
      if(aPlace.isSelected())
        weight += aPlace.getValue();
    });
    return weight;
  }
  
  /*
   * ====================================================================
   */

})();
