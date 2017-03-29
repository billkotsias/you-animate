package fanlib.io.legacy {
	
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import fanlib.utils.FStr;
	
	public class Dataer {

		private var dataArray:Array;
		private var callback:Function;
		private var loader:URLLoader;
		
		public function Dataer(filepath:String, f:Function) {
			// constructor code
			dataArray = new Array();
			callback = f;
			
			loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaded);
			loader.load(new URLRequest(filepath));
		}
		
		public function loaded(e:Event):void {
			loader.removeEventListener(Event.COMPLETE, loaded);
			var file:String = e.target.data;
			
			// start parsing file
			var ptr:Array = new Array();
			ptr[0] = 0;
			var rootData:Data = newData(file, ptr); // wrapper 'ptr' (by reference)
			callback(rootData);
		}

		public function newData(file:String, ptr:Array):Data {
			var data:Data = new Data();
			dataArray.push(data);
			
			var name:String;
			var subptr:Array = new Array();
			var startPtr:int = ptr[0];
			while (ptr[0] < file.length) {
				if (file.charAt(ptr[0]) == "{") {
					
					name = getVarName(file.substr(startPtr, ptr[0] - startPtr));
					subptr[0] = 0;
					data.push(name, newData(file.substr(++ptr[0]), subptr));
					ptr[0] += subptr[0];
					startPtr = ptr[0];
					
				} else if (file.charAt(ptr[0]) == "=") {
					
					name = getVarName(file.substr(startPtr, ptr[0] - startPtr));
					subptr[0] = 0;
					var val:String = getVarVal(file.substr(++ptr[0]), subptr);
					data.push(name, val);
					ptr[0] += subptr[0];
					startPtr = ptr[0];
					
				} else if (file.charAt(ptr[0]) == "}") {
					
					dataArray.pop();
					++ptr[0];
					return data;
					
				} else {
					
					++ptr[0];
				}
			}
			
			return data;
		}
		
		public function getVarName(name:String):String {
			// get 1st non-wspc char
			var start:int = 0;
			while ( start < name.length && FStr.IsWSPC( name.charCodeAt(start) ) ) { ++start; }
			// get last non-wspc char
			var end:int = name.length - 1;
			while ( end > start && FStr.IsWSPC( name.charCodeAt(end) ) ) { --end; }
			return name.substr(start, end - start + 1);
		}
		
		public function getVarVal(val:String, ptr:Array):String {
			// value must be in "" or ''
			var endChar:String;
			var start:int;
			
			var sind1:uint = val.indexOf('"', 0);
			var sind2:uint = val.indexOf("'", 0);
			if (sind1 < sind2) {
				endChar = '"';
				start = sind1;
			} else {
				endChar = "'";
				start = sind2;
			}
			
			var end:int = val.indexOf(endChar, start+1);
			ptr[0] = end + 1;
			
			return val.substr(start+1,end-start-1);
		}
		
	}
	
}
