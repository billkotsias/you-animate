package fanlib.utils.js
{
	import flash.external.ExternalInterface;

	public class PreventClose
	{
		static public function Show(msg:String = "Your changes haven\'t been saved. Are you sure you want to leave this page?"):void {
			if( !ExternalInterface.available ) return;
			
			if (msg) {
				ExternalInterface.call('function() { window.onbeforeunload = function() { return "'+msg+'"; } }');
			} else {
				ExternalInterface.call('function() { window.onbeforeunload = null; }');
			}
		}
	}
}