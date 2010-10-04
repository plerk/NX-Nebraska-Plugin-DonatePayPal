/*
 * Project Nebraska Trip Journal Trip Factoid
 */

if(NX === undefined) var NX = {};
if(NX.Nebraska === undefined) NX.Nebraska = {};
if(NX.Nebraska.Trip === undefined) NX.Nebraska.Trip = {};

(function ()
{

  /*
   * ====================================================================
   */
  
  NX.Nebraska.Trip.Factoid = function(aText, aUrl)
  {
    this.text = aText;
    this.url = aUrl;
    this.rendered = null;
  };
  
  NX.Nebraska.Trip.Factoid.prototype.render = function()
  {
    if(this.rendered == null)
    {
      this.rendered = this.text;
      if(this.url != null && this.url != '')
      {
        this.rendered = this.rendered.replace('[', '<a href="' + this.url + '">')
                                     .replace(']', '</a>');
      }
      else
      {
        this.rendered = this.rendered.replace('[', '').replace(']', '');
      }
    }
    return this.rendered;
  }
  
  /*
   * ====================================================================
   */

})();