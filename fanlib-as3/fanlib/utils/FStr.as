package fanlib.utils {
	
	import flash.utils.ByteArray;
	
	public class FStr {
		
		// bytes <-> String
		static public function BytesToString(bytes:ByteArray, from:uint = 0):String {
			if (!bytes) return null;
			
			var origPos:uint = bytes.position;
			bytes.position = from;
			var str:String = bytes.readUTFBytes(bytes.length - bytes.position);
			bytes.position = origPos; // leave ByteArray "untouched"
			return str;
		}
		
		static public function StringToBytes(string:String):ByteArray {
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(string);
			bytes.position = 0;
			return bytes;
		}

		// misc String functions
		static public function FalseToEmpty(val:*):String {
			if (val) return String(val);
			return "";
		}
		
		/**
		 * If value is "whole", it is returned as is, not in fixed form (<b>digits</b> is ignored)
		 * @param val
		 * @param digits
		 * @return int or fixed String
		 */		
		static public function RoundToString(val:Number, digits:int):String {
			if (int(val) !== val) return val.toFixed(digits); // don't convert to "fixed" if it is a "whole" number
			return val.toString();
		}
		
		static public function SecsToMins(val:Number, secsFixedDigits:int):String {
			const secs:Number = val % 60;
			const roundTo:Number = 10 * secsFixedDigits;
			var secsStr:String = (Math.round(secs*roundTo) < 10*roundTo) ? "0" : "";
			secsStr += secs.toFixed(secsFixedDigits);
			return int(val / 60).toString() + ":" + secsStr;
		}
		
		static public function RepeatChar(char:int, times:int):String {
			var res:String = "";
			for (var i:int = times; i > 0; --i) {
				res += String.fromCharCode(char);
			}
			return res;
		}
		
		static public function AddLeadingChars(string:String, char:int, requiredLength:uint):String {
			var extra:int;
			if ( (extra = requiredLength - string.length) <= 0 ) return string;
			return RepeatChar(char, extra) + string;
		}
		
		// Whitespace
		static public const WHITESPACE:Array = BuildWhitespace();
		static private function BuildWhitespace():Array {
			const wchars:Array = [9,10,11,12,13,32,133,160]; /// chars considered whitespace
			const white:Array = []; // chars to "bool"
			for (var i:int = wchars.length - 1; i >= 0; --i) {
				white[wchars[i]] = true;
			}
			return white;
		}
		
		static public function IsWSPC(i:int):Boolean {
			return Boolean(WHITESPACE[i]);
		}
		
		// remove whitespace from start and end of string
		static public function TrimWSPC(str:String):String {
			if (str == null) return null;
			return str.replace(/^\s+|\s+$/g, "");
		}
		
		static public function Concat(separator:String = " ",...params):String {
			var str:String = "";
			for (var i:int = 0; i < params.length; ++i) {
				str += String(params[i]);
				if (i !== params.length - 1) str += separator;
			}
			return str;
		}
	}
	
}
