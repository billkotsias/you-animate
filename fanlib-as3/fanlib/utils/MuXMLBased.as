package fanlib.utils {
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.EventDispatcher; /// may be needed by sub-classes
	
	// Like XMLBased, but with different callbacks for every XML file ("Multiple XMLBased")
	// NOTE : callback function must accept a single 'XML' parameter
	public class MuXMLBased extends EventDispatcher {

		private const callbacks:Array = new Array();
		
		public function MuXMLBased() {
			// constructor code
		}
		
		public function loadXML(file:String, callback:Function):void {
			var loader:URLLoader = new URLLoader();
			callbacks.push( new LoaderCallBackPair(loader, callback) );
			
			loader.addEventListener(Event.COMPLETE, _xmlLoaded);
			loader.load(new URLRequest(file));
		}
		
		private function _xmlLoaded(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			var lc:LoaderCallBackPair = callbacks.removeEqual( new LoaderCallBackPair(loader) );
			
			loader.removeEventListener(Event.COMPLETE, _xmlLoaded);
			(lc.value as Function)(new XML(loader.data));
		}

	}
	
}

import fanlib.utils.Pair;
import flash.net.URLLoader;

class LoaderCallBackPair extends Pair {
	
	public function LoaderCallBackPair(l:URLLoader, c:Function = null) {
		super(l, c);
	}
}
