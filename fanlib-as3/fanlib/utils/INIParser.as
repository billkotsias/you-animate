package fanlib.utils {
	
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import fanlib.utils.FArray;
	import fanlib.utils.FStr;
	import flash.events.EventDispatcher;
	import fanlib.event.ObjEvent;
	
	public class INIParser extends EventDispatcher {
		
		static public var PATH:String = "";

		static public var ServerUnCache:Boolean = false;
		
		public var data:FArray;
		public var dataOrder:Array;
		public var delimiter:*; // separator for tree-marking
		
		public function INIParser(file:String = null, _delimiter:* = undefined) {
			delimiter = _delimiter;
			if (file) parse(file);
		}
		
		public function parse(file:String):void {
			if (ServerUnCache) file +=  "?" + int(Math.random() * 1000000);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadError);
			loader.load(new URLRequest(PATH + file));
		}
		
		private function loadError(e:Event):void {
			trace(e);
		}
		
		private function loaded(e:Event):void {
			data = new FArray();
			dataOrder = new Array();
			var obj:FArray = data;
			var temp:Array;
			
			var lines:Array = String(e.target.data).split("\n");
			
			// parse each line
			for (var i:uint = 0; i < lines.length; ++i) {
				var line:String = FStr.TrimWSPC(String(lines[i]));
				
				switch (line.charAt(0)) {
					
					case ";":		// comment, ignore
						break;
						
					case "[":		// new data object
					
						obj = new FArray();
						
						var fullName:String = line.substr(1, line.length - 2);
						dataOrder.push(new Pair(fullName, obj)); // ordered data
						
						temp = fullName.split(delimiter);
						if (temp.length == 1) { // root-level object
							data[temp[0]] = obj;
						} else {
							(data[temp[0]])[temp[1]] = obj;
						}
						break;
						
					default:		// search for key-value pair, else ignore
					
						temp = line.split("=");
						if (temp.length == 2) {
							obj[ FStr.TrimWSPC(temp[0]) ] = FStr.TrimWSPC(temp[1]); // pair found
						}
						break;
				}
			}
			dispatchEvent(new ObjEvent(this, Event.COMPLETE));
		}

	}
	
}
