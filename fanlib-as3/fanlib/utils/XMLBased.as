package fanlib.utils {
	
	import fanlib.io.Server;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

 /// may be needed by sub-classes
	
	public class XMLBased extends EventDispatcher {

		public function XMLBased() {
			// constructor code
		}
		
		public function loadXML(file:String):void {
			Server.UncacheURL(file);
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, _xmlLoaded);
			loader.load(new URLRequest(file));
		}
		
		private function _xmlLoaded(e:Event):void {
			var loader:URLLoader = e.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, _xmlLoaded);
			xmlLoaded(new XML(loader.data));
		}
		
		// override this to parse XML data
		protected function xmlLoaded(xml:XML = null):void {
			// override this
		}
		

	}
	
}
