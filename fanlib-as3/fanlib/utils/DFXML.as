package fanlib.utils {
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import fanlib.event.ObjEvent;
	import flash.display.DisplayObject;
	
	public class DFXML extends XMLBased {
		
		private var container:DisplayObjectContainer;
		private var lexicon:Lexicon;
		private var xml:XML;
		private var folder:String; // DFXML resources path
		private var file:String;
		public function get sourceFile():String { return file; }
		
		static public var ServerUnCache:Boolean = false;
		
		public function DFXML(_container:DisplayObjectContainer, _file:String, _lexicon:* = null, _folder:String = "") {
			
			file = _file;
			if (ServerUnCache) _file +=  "?" + int(Math.random() * 1000000);
			container = _container;
			folder = _folder;
			loadXML(_file);
			
			if (_lexicon is String) {
				
				var lex:Lexicon = new Lexicon();
				lex.addEventListener(Event.COMPLETE, lexiconReady);
				lex.loadXML(_lexicon);
				
			} else if (!_lexicon) {
				
				lexiconReady( new ObjEvent(new Lexicon(), "") );
				
			} else {
				
				lexiconReady( new ObjEvent(_lexicon as Lexicon, "") );
			}
		}

		// lexicon is ready
		private function lexiconReady(e:ObjEvent = null):void {
			lexicon = e.getObj() as Lexicon;
			checkAllLoaded();
		}
		
		// xml data is loaded
		override protected function xmlLoaded(_xml:XML = null):void {
			xml = _xml;
			checkAllLoaded();
		}
		
		// ready to proceed?
		private function checkAllLoaded():void {
			if (!lexicon || !xml) return;
			
			// proceed to populate DFXML object
			new XMLParser(lexicon).buildObjectTree(xml, finished, folder, "obj", container);
		}
		
		private function finished(o:Object):void {
			dispatchEvent(new ObjEvent(o, Event.COMPLETE));
		}
	}
	
}
