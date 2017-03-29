package fanlib.utils {
	
	import fanlib.event.ObjEvent;
	
	import flash.events.Event;
	
	public class Lexicon extends XMLBased implements ILexicon {
		
		static private const LEXICONS:Array = [];
		static public function Get(file:String):Lexicon { return LEXICONS[file]; }
		
		private var _language:String = "";				// current language set
		private var defaultLang:String = "";			// return this language if nothing found for current
		private const autoChanged:Array = new Array();	// ILexicon objects + their references

		private const lexicon:Array = new Array();
		
		public function Lexicon(file:String = null, listener:Function = null) {
			load(file, listener);
		}
		
		public function load(file:String = null, listener:Function = null):void {
			if (listener != null) addEventListener(Event.COMPLETE, listener, false, 0, true);
			if (file) {
				LEXICONS[file] = this;
				loadXML(file);
			}
		}
		
		public function autoUpdateRefs(auto:ILexiRef, ... refs):void {
			autoChanged.push(new AutoChanged(auto, refs));
		}
		
		public function get language():String { return _language; };
		public function set language(l:String):void {
			_language = l;
			
			for (var i:int = autoChanged.length - 1; i >= 0; --i) {
				var auto:AutoChanged = autoChanged[i];
				
				var newRefs:Array = new Array();
				for (var j:int = 0; j < auto.refs.length; ++j) {
					newRefs.push( getRef( auto.refs[j], _language ) );
				}
				
				if (newRefs.length == 1) {
					auto.obj.languageChanged(newRefs[0]); // convenience to the user
				} else {
					auto.obj.languageChanged(newRefs);
				}
			}
		}
		
		override protected function xmlLoaded(xml:XML = null):void {
			
			// get available languages
			var langsXML:XML = xml.child("langs")[0];
			var langs:Array = (langsXML.text()[0]).split(",");
			var i:int;
			for (i = 0; i < langs.length; ++i) {
				lexicon[ langs[i] ] = new Array();
			}
			
			// parce all leemas (references)
			var arr:Array;
			var refsXML:XMLList = xml.child("ref");
			for (i = refsXML.length() - 1; i >= 0; --i) {
				var refXML:XML = refsXML[i];
				var ref:String = refXML.attribute("id");
				for (var lang:String in lexicon) {
					arr = lexicon[lang];
					var refChildList:XMLList = refXML.child(lang);
					if (refChildList == null || refChildList.length() == 0) continue;
					var refChild:XML = refChildList[0];
					arr[ref] = refChild.text()[0];
				}
			}
			
			// set default
			if (xml.child("default")) {
				defaultLang = language = (xml.child("default")[0]).text();
			}
			
			dispatchEvent(new ObjEvent(this, Event.COMPLETE));
		}
		
		public function getRef(ref:String, lang:String):* {
			var langArr:Array = lexicon[lang];
			if (!langArr) langArr = [];
			
			var value:* = langArr[ref];
			if (value == undefined || value == null) {
				langArr = lexicon[defaultLang];
				if (!langArr) return ref;
				
				value = langArr[ref];
				if (!value) return ref;
			}
			return value;
		}
		
		public function getCurrentRef(ref:String):* {
			return getRef(ref, _language);
		}

	}
	
}

import fanlib.utils.ILexiRef;

class AutoChanged {
	
     public var obj:ILexiRef;
     public var refs:Array;
	 
	 public function AutoChanged(_obj:ILexiRef, _refs:Array) {
		 obj = _obj;
		 refs = _refs;
	 }
}
