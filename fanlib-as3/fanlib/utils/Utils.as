package fanlib.utils {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	public class Utils {

		public function Utils() {
			// constructor code
		}
		
        static public function Clone(reference:*):* {
			if (reference === null) return null;
			
			const aliasName:String = getQualifiedClassName(reference);
			try {
				const alias:Class = getClassByAlias(aliasName);
			} catch (e:Error) { registerClassAlias(aliasName, Class(getDefinitionByName(aliasName))) }
			
            const clone:ByteArray = new ByteArray();
            clone.writeObject(reference);
            clone.position = 0;
            return clone.readObject();
        }
		
		static public function GetClass(obj:*):Class {
			return Class(getDefinitionByName(getQualifiedClassName(obj)));
		}
		
		static public function IsEmpty(d:Object):Boolean {
			for (var obj:* in d) {
				return false; // at least one object in "d", hence this line's execution
			}
			return true;
		}
		
		static public function CountDynamicProperties(d:Object):int {
			var x:int = 0;
			for (var obj:* in d) ++x;
			return x;
		}
		
		static public function IsEmptyOfValues(d:Object):Boolean {
			for each (var obj:* in d) {
				if (obj == null) continue;
				return false; // at least one non-null object, hence this line's execution
			}
			return true;
		}
		
		/**
		 * Only works with dynamic objects 
		 * @param arr Object to "pretty-print"
		 * @param tab
		 * @param str
		 * @return String
		 */
		static public function PrettyString(arr:Object, tab:String = "", str:String = ""):String {
			for (var i:* in arr) {
				str += tab + i + " =";
				var val:* = arr[i];
				if (val is int || val is Number || val is Boolean || val is uint || val is String) {
					str += " " + val + "\n";
				} else if (val is Object) {
					str += "\n";
					var objToStr:String = PrettyString(val, tab + "\t");
					if (!objToStr.length && val) objToStr = val.toString() + "\n";
					str += objToStr;
				} else if (val === null) {
					str += " &null\n";
				} else if (val === undefined) {
					str += " &undefined\n";
				} else {
					str += String(val) + "\n";
				}
			}
			return str;
		}
		
		/**
		 * Works with non-dynamic properties ONLY 
		 * @param arr
		 * @param tab
		 * @param str
		 * @return String
		 */
		static public function PrettyStringND(arr:Object, tab:String = "", str:String = ""):String {
			for each (var i:* in Utils.GetReadableVars(arr)) {
				str += tab + i + " =";
				var val:* = arr[i];
				if (val is int || val is Number || val is Boolean || val is uint || val is String) {
					str += " " + val + "\n";
				} else if (val is Object) {
					str += "\n";
					var objToStr:String = PrettyStringND(val, tab + "\t");
					if (!objToStr.length && val) objToStr = val.toString() + "\n";
					str += objToStr;
				} else {
					str += " &undefined\n";
				}
			}
			return str;
		}
		
		// => clear a dictionary or dynamic Object
		static public function Clear(arr:Object):void {
			for (var i:* in arr) {
				delete arr[i];
			}
		}
		
		// apply function to !ALL! elements in object
		static public function Apply(arr:Object, f:Function):Object {
			for (var obj:* in arr) {
				arr[obj] = f(arr[obj]);
			}
			return arr;
		}
		
		// functions suitable to 'Apply' function above
		static public function ToInt(obj:*):int {
			return int(obj);
		}
		static public function ToNumber(obj:*):int {
			return Number(obj);
		}
		static public function ToBitmapData(obj:*):BitmapData {
			return (obj as Bitmap).bitmapData;
		}
		
		/**
		 * Return object in container or create if it doesn't exist
		 */
		static public function GetGuaranteed(container:Object, id:*, cclass:Class):* {
			var obj:* = container[id]; 
			if (!obj) {
				obj = new cclass;
				container[id] = obj;
			}
			return obj;
		}
		
		/**
		 * Return object in container or create if it doesn't exist
		 * @param container
		 * @param id
		 * @param func Function that returns the object. Hint: use 'Utils.DynamicConstructor' to "convert" a constructor to Function.
		 * @param args Comma-separated arguments passed to the Function.
		 * @return Previously- or newly-created object by Function.
		 */
		static public function GetGuaranteedByFunction(container:Object, id:*, func:Function, ...args:Array):* {
			var obj:* = container[id]; 
			if (!obj) {
				obj = func.apply(null, args);
				container[id] = obj;
			}
			return obj;
		}
		
		// copy generic Object to Typed
		static public function CopyDynamicProperties(dest:Object, source:Object, rejectNonValues:Boolean = true, supressErrors:Boolean = false, traceErrors:Boolean = false):* {
			var i:String;
			for (i in source) {
				try {
					var val:* = source[i];
//					trace("UTILS source",i,val);
					if (rejectNonValues && (val === null || val === undefined)) continue;
					if (val != null && typeof(val) === "object") {
						var destObject:Object = dest[i];
						if (!destObject) {
							var sourceObjClass:Class = GetClass(val);
							dest[i] = destObject = new sourceObjClass(); // try to create same object, hopefully with no constructor params
						}
						CopyDynamicProperties(destObject, val, rejectNonValues, supressErrors, traceErrors);
					} else {
						dest[i] = val;
						//trace(" UTILS ",dest[i]);
					}
				} catch(e:Error) {
					if (supressErrors) {
						if (traceErrors) trace("[Utils.CopyDynamicProperties]",e/*,e.getStackTrace()*/);
					} else throw e;
				}
			}
			
			return dest; // for convenience
		}
		
		static public function CopyProperties(destination:Object, source:Object):void {
			for each (var name:String in GetWritableVars(source)) {
				destination[name] = source[name];
			}
		}
		
		static public function GetWritableVars(obj:Object):Array {
			const xml:XML = describeType(obj);
			const vars:Array = [];
			var v:XML;
			// - get public vars
			for each (v in xml["variable"]) {
				vars.push(v.attribute("name"));
			}
			// - get writeable accessors
			for each (v in xml["accessor"]) {
				if (String(v.attribute("access")).indexOf("w") >= 0) vars.push(v.attribute("name")); // "w" -> smart-ass
			}
			
			return vars;
		}
		
		static public function GetReadableVars(obj:Object):Array {
			const xml:XML = describeType(obj);
			const vars:Array = [];
			var v:XML;
			// - get public vars
			for each (v in xml["variable"]) {
				vars.push(v.attribute("name"));
			}
			// - get readable accessors
			for each (v in xml["accessor"]) {
				if (String(v.attribute("access")).charAt() === "r") vars.push(v.attribute("name")); // not "writeonly"
			}
			
			return vars;
		}
//		static public function CopyDynamicProperties(dest:Object, source:Object, rejectUndefined:Boolean = true):* {
//			trace("Setting up",dest,"with",source);
//			var xml:XML = describeType(dest);
//			var v:XML;
//			var vars:Array = [];
//			// - get public vars
//			for each (v in xml["variable"]) {
//				vars.push(v.attribute("name"));
//			}
//			// - get writeable accessors
//			for each (v in xml["accessor"]) {
//				if (String(v.attribute("access")).indexOf("w") >= 0) vars.push(v.attribute("name"));
//			}
//			// -> perform the shit
//			for each (var varname:String in vars) {
//				var val:* = source[varname];
//				if (rejectUndefined && val === undefined) continue;
//				// check if "object" or primitive
//				if (!(val is Array) && typeof(val) == "object") {
//					trace("shit",dest,varname,"=",source[varname]);
//					CopyDynamicProperties(dest[varname], val, rejectUndefined);
//				} else {
//					dest[varname] = val;
//					trace(dest,varname,"=",source[varname]);
//				}
//			}
//			
//			return dest; // for convenience
//		}
		
		public static function DynamicConstructor(c:Class, args:Array):Object {
			switch (args.length)
			{
			case 0:
				return new c();
				break;
			case 1:
				return new c(args[0]);
				break;
			case 2:
				return new c(args[0], args[1]);
				break;
			case 3:
				return new c(args[0], args[1], args[2]);
				break;
			case 4:
				return new c(args[0], args[1], args[2], args[3]);
				break;
			case 5:
				return new c(args[0], args[1], args[2], args[3], args[4]);
				break;
			case 6:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5]);
				break;
			case 7:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
				break;
			case 8:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
				break;
			case 9:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
				break;
			case 10:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
				break;
			case 11:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);
				break;
			case 12:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);
				break;
			case 13:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);
				break;
			case 14:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);
				break;
			case 15:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14]);
				break;
			case 16:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15]);
				break;
			case 17:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16]);
				break;
			case 18:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17]);
				break;
			case 19:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18]);
				break;
			case 20:
				return new c(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19]);
				break;
			}
			
			return null;
		}
		
		/**
		 *   Create a Function that, when called, instantiates a class
		 *   @author Jackson Dunstan
		 *   @param c Class to instantiate
		 *   @return A function that, when called, instantiates a class with the
		 *           arguments passed to said Function or null if the given class
		 *           is null.
		 */
		public static function MakeConstructorFunction(c:Class):Function {
			if (c === null) return null;
			
			/**
			 *   The function to call to instantiate the class
			 *   @param args Arguments to pass to the constructor. There may be up to
			 *               20 arguments.
			 *   @return The instantiated instance of the class or null if an instance
			 *          couldn't be instantiated. This happens if the given class or
			 *          arguments are null, there are more than 20 arguments, or the
			 *          constructor of the class throws an exception.
			 */
			return function(...args:Array):Object {
				return DynamicConstructor(c, args);
			}
		}
		
		static public function ByteArrayToVector(bytes:ByteArray):Vector.<uint> {
			const clone:Vector.<uint> = new Vector.<uint>;
			if (bytes) {
				bytes.position = 0;
				while (bytes.bytesAvailable >= 4) {
					clone.push(bytes.readUnsignedInt());
				}
				if (bytes.bytesAvailable) {
					var lastBytes:uint, shift:int, increase:int;
					if (bytes.endian === Endian.BIG_ENDIAN) {
						shift = 8 * (bytes.bytesAvailable - 1); increase = -8;
					} else {
						shift = 0; increase = 8;
					}
					while (bytes.bytesAvailable > 0) {
						lastBytes |= (bytes.readUnsignedByte() << shift);
						shift += increase;
					}
					clone.push(lastBytes);
				}
				bytes.position = 0;
			}
			return clone;
		}
	}
}
