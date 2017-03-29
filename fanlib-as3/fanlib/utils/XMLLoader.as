package fanlib.utils {
	
	public class XMLLoader extends XMLBased {

		private var callback:Function;
		
		public function XMLLoader(file:String, call:Function) {
			callback = call;
			loadXML(file);
		}
		
		final override protected function xmlLoaded(xml:XML = null):void {
			callback(xml);
			callback = null;
		}

	}
	
}
