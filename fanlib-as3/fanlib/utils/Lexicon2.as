package fanlib.utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	public class Lexicon2 extends EventDispatcher implements ILexicon {
		
		static public const REFS_OBJECT:String = "refs";
		static public const METADATA_OBJECT:String = "metadata";
		static private const LEXICONS:Array = [];
		
		static private var _DefaultLanguage:String;
		static public function GetDefaultLanguage():String { return _DefaultLanguage }
		static public function SetDefaultLanguage(defLang:String):void {
			_DefaultLanguage = defLang;
			_CurrentLanguage ||= _DefaultLanguage; // set default as current, if not already set
		}
		
		static private var _CurrentLanguage:String;
		static public function GetCurrentLanguage():String { return _CurrentLanguage }
		static public function SetCurrentLanguage(value:String):void {
			_CurrentLanguage = value;
			for each (var lex2:Lexicon2 in LEXICONS) {
				lex2.languageChanged();
			}
		}
		
		private var _complete:Boolean;
		private var _refs:Object = {};
		
		//
		
		private const ilexiRefs:Dictionary = new Dictionary(true);
		
		public function Lexicon2()
		{
			super(null);
			LEXICONS.push(this);
		}
		
		public function getCurrentRef(ref:String):* {
			return getRef(ref, _CurrentLanguage);
		}
		
		public function getRef(ref:String, lang:String):* {
			var mainRef:* = _refs[ref];
			if (mainRef === undefined) return "ref:"+ref;
			
			var langRef:* = mainRef[lang];
			if (langRef === undefined) langRef = mainRef[_DefaultLanguage];
			if (langRef === undefined) langRef = "ref:"+lang+":"+_DefaultLanguage+":"+ref;
			
			return langRef;
		}
		
		public function getRefs(refs:Array, lang:String):Array {
			const newRefValues:Array = [];
			for (var i:int = 0; i < refs.length; ++i) {
				newRefValues.push( getRef(refs[i], lang) );
			}
			return newRefValues;
		}
		
		public function autoUpdateRefs(auto:ILexiRef, ... refs):void {
			ilexiRefs[auto] = refs;
		}
		private function languageChanged():void {
			for (var ilex:* in ilexiRefs) {
				
				const newRefValues:Array = getRefs( ilexiRefs[ilex], _CurrentLanguage );
				
				if (newRefValues.length === 1)
					(ilex as ILexiRef).languageChanged( newRefValues[0] ); // convenience to the user
				else
					(ilex as ILexiRef).languageChanged( newRefValues );
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function clearRefs():void {
			Utils.Clear(_refs);
		}
		
		/**
		 * The new input is <b>merged</b> with any previous loaded 
		 * @param input JSON, URL (String) or URLRequest
		 */
		public function load(input:*):void {
			_complete = false;
			
			if (input is String) {
				try {
					parseJSON(input);
					return;
				} catch (e:Error) {
					loadJSON(new URLRequest(input));
				}
				
			} else if (input is URLRequest) {
				loadJSON(input);
				
			} else {
				throw this+": unhandled input type: "+input;
			}
		}
		
		//
		
		private function loadJSON(url:URLRequest):void {
			new QuickLoad(url, parseJSON);
		}
		
		private function parseJSON(input:String):void {
			const json:Object = JSON.parse(input);
			
			const metadata:Object = json[METADATA_OBJECT];
			if (metadata) {
				// Default language is per project, not per JSON! // was: DefaultLanguage = metadata["defaultLanguage"] || DefaultLanguage;
			}
			
			const __refs:Object = json[REFS_OBJECT];
			if (__refs) {
				Utils.CopyDynamicProperties(_refs, __refs);
				_complete = true;
				dispatchEvent(new Event(Event.COMPLETE));
				languageChanged();
			} else {
				throw this+": no refs found in file: "+input;
			}
		}
		
		public function whenComplete(func:Function):void {
			if (_complete) {
				func();
			} else {
				addEventListener(Event.COMPLETE, function complete2(e:Event):void {
					removeEventListener(Event.COMPLETE, complete2);
					func();
				});
			}
		}

		public function get complete():Boolean
		{
			return _complete;
		}


	}
}