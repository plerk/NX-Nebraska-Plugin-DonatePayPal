/*
 * Project Nebraska
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Debug === undefined) NX.Nebraska.Debug = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  var textArea;
  
  NX.Nebraska.Debug.say = function(aMsg)
  {
    //alert(aMsg);
    textArea.innerHTML += aMsg + "\n";
  }
  
  NX.Nebraska.Debug.print = function(aMsg)
  {
    //alert(aMsg);
    textArea.innerHTML += aMsg;
  }
  
  NX.Nebraska.Debug.clear = function()
  {
    textArea.innerHTML = '';
  }
  
  var old_init = window.onload;
  window.onload = function()
  {
    if(old_init != null)
      old_init();
    textArea = document.getElementById('debug');
    NX.Nebraska.Debug.clear();
  }
   
  /*
   * ====================================================================
   */

})();