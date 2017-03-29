package fanlib.utils {
	import flash.utils.getDefinitionByName;
	
	public class Parser {

		public function Parser() {
			throw "Static Class only";
		}
		
		// * -> String
		static public function toStr(obj:Object, nullIfEmpty:Boolean = true):* {
			if (obj == null) return null;
			
			var str:String = obj.toString();
			if (nullIfEmpty && str.length == 0) return null;
			return str;
		}
		
		// * -> Boolean
		// def = default value returned if "str" is 'undefined'
		static public function toBool(str:*, def:* = false):Boolean {
			if (str is Boolean) return str;
			if (str is String) {
				if (str === null || str.length === 0) return false;
				str = str.toLowerCase();
				if (str === "false" || str === "0" || str === "n") return false;
				return true;
			}
			if (str === undefined) return def;
			return Boolean(str);
		}
		
		// create meaningful path
		static public function parsePath(xml:XMLList):String {
			
			if (xml == null) return "..\\";
			
			var folder:String = xml[0];
			if (folder == null || folder.length == 0) {
				folder = "..\\";
			} else {
				var lastChar:String = folder.charAt(folder.length-1);
				if (lastChar != '\\' && lastChar != '/') folder += '/';
//				if (folder.indexOf('/') >= 0) { // it's a URL!
//					if (lastChar != '/') folder += '/';
//				} else if (lastChar != '\\') folder += '/';
			}
			
			return folder;
		}
		
		// check if provided string is a Flash Font Class REFERENCE
		static public function getFontName(f:String):String {
			if (f == null) return null;
			
			var font:String = null;
			var fontClass:Class;
			try {
				fontClass = flash.utils.getDefinitionByName(f) as Class;
			} catch(error:Error) {
				fontClass = null;
			}
			if (fontClass != null) font = new fontClass().fontName; // it's a reference!
			if (font != null && font.length == 0) font = null;
			
			if (font == null) font = f; // it's a direct font name
			
			return font;
		}
		
		// comma-separated values, returned as string
		// - if the 1st char of a value is '(', it's a sub-Array; it ends with a ')' as the last char of a value
		static public function parseCommaArray(str:String):Array {
			// TODO
			return null;
		}
		
		// apply default parameters
		// if 'aggressive', replace empty strings too
		static public function applyDefaultParams(params:Array, defParams:Array, aggressive:Boolean = false):void {
			for (var i:int = 0; i < defParams.length; ++i) {
				if (params[i] === undefined || params[i] === null || (aggressive && params[i] === "")) {
					params[i] = defParams[i];
				}
			}
		}

	}
	
}
