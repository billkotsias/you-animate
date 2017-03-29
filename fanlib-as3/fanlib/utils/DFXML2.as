package fanlib.utils {
	
	import fanlib.event.ObjEvent;
	import fanlib.utils.XMLBased;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	public class DFXML2 extends XMLBased {
		
		private var container:Object;
		private var lexicon:ILexicon;
		private var xml:XML;
		private var folder:String; // DFXML resources path
		private var file:String;
		private var defaultClass:String;
		private var parser2:XMLParser2;
		
		public function get sourceFile():String { return file; }
		
		public function DFXML2(_file:String, _container:Object = null, weakRef:Function = null, _lexicon:* = null, _folder:String = "",
							   defClass:String = null) {
			
			defaultClass = defClass;
			
			if (weakRef != null) addEventListener(Event.COMPLETE, weakRef, false, 0, true);
			
			file = _file;
			container = _container;
			folder = _folder;
			
			loadXML(_file);
			
			if (_lexicon is String) {
				
				var lex:Lexicon2 = new Lexicon2();
				lex.load(_lexicon);
				lex.whenComplete(lexiconReady);
				
			} else if (!(_lexicon as ILexicon)) {
				
				lexiconReady( new ObjEvent(new Lexicon2(), "") );
				
			} else {
				
				lexiconReady( new ObjEvent(_lexicon, "") );
			}
		}

		// lexicon is ready
		private function lexiconReady(e:ObjEvent = null):void {
			lexicon = e.getObj() as ILexicon;
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
			// - DON'T FUCKING GC ME!
			parser2 = new XMLParser2(lexicon, defaultClass);
			parser2.buildObjectTree(xml, finished, folder, container);
		}
		
		private function finished(o:Object):void {
			dispatchEvent(new ObjEvent(o, Event.COMPLETE));
			parser2 = null;
		}
		
		// getters
		
		public function get xmlParser():XMLParser2 { return parser2 }
		public function get nameToObject():Object { return parser2.nameToObject }
	}
	
}
