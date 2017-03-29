package fanlib.utils {
	
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.utils.getDefinitionByName;
	import flash.display.Bitmap;
	import fanlib.io.MLoader;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.text.StyleSheet;
	import fanlib.tween.TVector2;
	import fanlib.gfx.IAlign;
	import fanlib.gfx.Align;
	import flash.filters.GradientBevelFilter;
	import flash.filters.BevelFilter;
	
	public class XMLParser {

		// 'buildObjectTree' function variables
		private var obj:Object = null; // object under creation
		
		private var xml:XML = null;
		private var callBack:Function = null;
		private var parent:Object = null; // object 'parent'
		private var lexicon:Lexicon = null;
		
		private var childName:String = null;
		private var childList:XMLList = null;
		private var currentChild:int = -1; // current child being parsed
		private var assetsFolder:String;
		// 'buildObjectTree' function variables
		
		static public const nameToFilter:Array = nameToFilterInit();
		
		static public var LEXICON:Lexicon = null; // default used when none passed
		
		// instance needed for certain functions like 'buildObjectTree'
		public function XMLParser(_lexicon:Lexicon = null) {
			lexicon = _lexicon;
			if (lexicon == null) lexicon = LEXICON;
		}

		// filters
		static public function nameToFilterInit():Array {
			var arr:Array = new Array();
			arr["DropShadow"] = parseDropShadow;
			arr["Glow"] = parseGlow;
			arr["Bevel"] = parseBevel;
			//arr["GradientBevel"] = parseGradientBevel;
			return arr;
		}
		
		static public function parseDropShadow(params:Array):DropShadowFilter {
			var defParams:Array = new Array(4.0, 45, 0, 1.0, 4.0, 4.0, 1.0, 1, false, false, false);
			Parser.applyDefaultParams(params, defParams, true);
			return new DropShadowFilter(params[0], params[1], params[2], params[3], params[4], params[5], params[6], params[7],
										Parser.toBool(params[8]), Parser.toBool(params[9]), Parser.toBool(params[10]));
		}
		
		static public function parseGlow(params:Array):GlowFilter {
			var defParams:Array = new Array(0xFF0000, 1.0, 6.0, 6.0, 2, 1, false, false);
			Parser.applyDefaultParams(params, defParams, true);
			return new GlowFilter(params[0], params[1], params[2], params[3], params[4], params[5],
								  Parser.toBool(params[6]), Parser.toBool(params[7]));
		}
		
		static public function parseBevel(params:Array):BevelFilter {
			var defParams:Array = new Array(4, 45, 16777215, 1, 0, 1, 4, 4, 1, 1, "inner", false);
			Parser.applyDefaultParams(params, defParams, true);
			return new BevelFilter(params[0], params[1], params[2], params[3], params[4], params[5],
								   params[6], params[7], params[8], params[9], params[10], Parser.toBool(params[11]));
		}
		
		static public function parseGradientBevel(params:Array):GradientBevelFilter {
			var defParams:Array = new Array(4.0, 45, null, null, null, 4.0, 4.0, 1, 1, "inner", false);
			Parser.applyDefaultParams(params, defParams, true);
			return new GradientBevelFilter(params[0], params[1], params[2], params[3], params[4], params[5],
								  		   params[6], params[7], params[8], params[9], Parser.toBool(params[10]));
		}
				
		static public function parseFilters(str:String):Array {
			
			var instances:Array = new Array();
			if (str == null) return instances;
			
			var filters:Array = str.split('|');
			var i:int;
			for (i = 0; i < filters.length; ++i) {
				var fparams:Array = filters[i].split(',');
				var filter:String = fparams.shift(); // get and remove 1st param (filter ID)
				var fun:Function = nameToFilter[filter];
				if (fun != null) instances.push( fun(fparams) );
			}
			
			return instances;
		}
		
		static public function parseString(xml:XML, attr:String, def:String = null):String {
			var str:String;
			
			var _str:* = xml.attribute(attr);
			if (_str != undefined) {
				str = String(_str);
			} else {
				str = def;
			}
			return str;
		}
		
		static public function parseNumber(xml:XML, attr:String, def:Number = 0):Number {
			var num:Number = Number(xml.attribute(attr)[0]);
			if (isNaN(num)) num = def;
			return num;
		}
		
		static public function parse2D(xml:XML, attr:String, def:TVector2 = null):TVector2 {
			if (def == null) def = new TVector2();
			var coords:Array = String(xml.attribute(attr)).split(",");
			if (coords.length >= 2) def.y = coords[1];
			if (coords.length >= 1) def.x = coords[0];
			return def;
		}

		// build a Flash Object, possibly consisted of children objects
		// NOTE : function is not re-entrant! A new 'XMLParser' instance must be created!
		public function buildObjectTree(_xml:XML, _callBack:Function = null, folder:String = "",
										_childName:String = "obj", _parent:Object = null):void {
			if (xml != null) return; // not re-entrant

			xml = _xml;
			parent = _parent;
			callBack = _callBack;
			childName = _childName;
			childList = xml.child(childName);
			assetsFolder = folder;

			var classArr:Array = (xml.attribute("class")[0].toString()).split(',');
			var _class:Class = flash.utils.getDefinitionByName(classArr.shift()) as Class;
			
			// if 1 data is required, it's passed directly
			// if more is required, the whole parameters array is passed
			if (classArr.length == 0) {
				obj = new _class();
			} else if (classArr.length == 1) {
				obj = new _class(classArr[0]);
			} else {
				obj = new _class(classArr);
			}
			
			// object created! Check for special cases:
			var attr:*;
			var ref:String;
			
			if (obj is Bitmap) {
				
				// load image
				var imagePath:String = null;
				attr = xml.attribute("lexicon");
				if (attr != undefined) {
					ref = attr[0];
					imagePath = lexicon.getCurrentRef(ref);
					if (obj is ILexiRef) lexicon.autoUpdateRefs(obj as ILexiRef, ref);
				} else {
					attr = xml.attribute("image");
					if (attr != undefined) imagePath = folder + attr[0];
				}
				if (imagePath != null) {
					new MLoader(new Array(imagePath), bmpImageLoaded);
				} else {
					buildNextObjectChild(); // no image, just a placeholder
				}
				return; // end for now
				
			} else if (obj is TextField) {
				
				// build 'TextFormat'
				var tfield:TextField = obj as TextField;
				var fArr:Array;
				var _fontName:String;
				var format:TextFormat;
				if (xml.attribute("format") != undefined) {
					fArr = (xml.attribute("format")[0].toString()).split(',');
					_fontName = Parser.getFontName(Parser.toStr(fArr[0]));
					format = new TextFormat(_fontName, Parser.toStr(fArr[1]), Parser.toStr(fArr[2]),
														   Parser.toBool(fArr[3]), Parser.toBool(fArr[4]), Parser.toBool(fArr[5]),
														   Parser.toStr(fArr[6]), Parser.toStr(fArr[7]), Parser.toStr(fArr[8]),
														   Parser.toStr(fArr[9]), Parser.toStr(fArr[10]), Parser.toStr(fArr[11]),
														   Parser.toStr(fArr[12]));
					tfield.defaultTextFormat = format;
				}
				
				// build css 'StyleSheet'
				if (xml.attribute("css")[0] != undefined) {
					var css:StyleSheet = new StyleSheet();
					css.parseCSS(xml.attribute("css")[0].toString());
					tfield.styleSheet = css;
				}
				
				// build text string
				attr = xml.attribute("lexicon");
				if (attr != undefined) {
					
					ref = attr[0];
					var strRef:String = lexicon.getCurrentRef(ref);
					if (strRef) { // debug
						tfield.htmlText = strRef;
					} else {
						throw ("Lexicon reference '" + ref +"' not found");
					}
					if (obj is ILexiRef) lexicon.autoUpdateRefs(obj as ILexiRef, ref);
					
				} else {
					
					var i:int = 0;
					var txt:String = "";
					var xmlTxts:XMLList = xml.text();
					while (xmlTxts[i] != undefined) {
						txt += xmlTxts[i];
						++i;
					}
					tfield.htmlText = txt;
				}
				
				buildNextObjectChild();
				return;
			}
			
			buildNextObjectChild();
		}
		
		private function bmpImageLoaded(l:MLoader):void {
			var bmp:Bitmap = obj as Bitmap;
			try { bmp.bitmapData = (l.files[0] as Bitmap).bitmapData; } catch(e:Error) {
				if (l && l.names) trace(e, l.names[0]) else trace(e);
			}
			bmp.smoothing = true; // by default
			
			buildNextObjectChild();
		}
		
		private function buildNextObjectChild(dummy:Object = null):void {
			
			++currentChild;
			
			if (childList[currentChild] == undefined) { // no more children for this object
			
				buildObjectFinal();
				
			} else {
			
				var childXML:XML = childList[currentChild];
				new XMLParser(lexicon).buildObjectTree( childXML, buildNextObjectChild, assetsFolder, childName, obj); // next
			}
		}
		
		private function parseValue(v:String):* {
			var varValue:*;
			
			// special values
			var arr:Array = v.split(',');
			if ( arr.length > 1 && !(v.slice(0,1) == "'" && v.slice(-1,1) == "'") ) {
				
				// - array
				varValue = new Array();
				while (arr.length) {
					varValue.push( parseValue( arr.shift() ) );
				}
				
			} else if (v.slice(0,5) == "Bool:") {
				
				// - parse as Boolean
				varValue = Parser.toBool(v.slice(5));
				
			} else if (parent && v.slice(0,7) == "Parent:") {
				
				// - parse as parent variable
				varValue = parent[ v.slice(7) ]; // TODO : multiple parents!
				
			} else {
				
				varValue = v;
			}
			
			return varValue;
		}
		
		private function buildObjectFinal():void {
			
			var i:int;
			
			// add to parent before 'vars', as 'vars' may depend on parent existing
			if (parent != null) parent.addChild(obj);
			var attr:*;
			
			// set vars
			attr = xml.attribute("vars");
			if (attr != undefined) {
				var vArr:Array = (attr[0].toString()).split('|');
				for (i = 0; i < vArr.length; ++i) {
					var params:Array = (vArr[i] as String).split('='); // the first '=' separates variable name from value
					var varName:String = params.shift();
					obj[ varName ] = parseValue( params.join("=") );
					//trace(obj, varName, obj[varName]);
				}
			}
			
			// set align; NOTE : takes into consideration previous co-ords (set in 'vars' attribute)
			var alX:Enum;
			var alY:Enum;
			attr = xml.attribute("alignX");
			if (attr != undefined) {
				switch (attr[0].toString()) {
					case "left":
						alX = Align.LEFT;
						if (!(obj is IAlign)) obj.x = 0;
						break;
					case "right":
						alX = Align.RIGHT;
						if (!(obj is IAlign)) obj.x += - obj.width;
						break;
					case "center":
						alX = Align.CENTER;
						if (!(obj is IAlign)) obj.x += - obj.width / 2;
						break;
				}
			}
			attr = xml.attribute("alignY");
			if (attr != undefined) {
				switch (attr[0].toString()) {
					case "top":
						alY = Align.TOP;
						if (!(obj is IAlign)) obj.y = 0;
						break;
					case "bottom":
						alY = Align.BOTTOM;
						if (!(obj is IAlign)) obj.y += - obj.height;
						break;
					case "center":
						alY = Align.CENTER;
						if (!(obj is IAlign)) obj.y += - obj.height / 2;
						break;
				}
			}
			if (obj is IAlign) (obj as IAlign).align(alX, alY); // object handles alignment itself (may want to remember it)
			
			// set filters
			attr = xml.attribute("filters");
			if (attr != undefined) {
				obj.filters = parseFilters(attr[0].toString());
			}
			
			// finished
			if (callBack != null) callBack(obj);
			
			// "cleanup" to make function re-entrant, in case this is needed
			xml = null;
		}
		
	}
	
}
