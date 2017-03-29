package fanlib.utils {
	
	import fanlib.filters.Color;
	import fanlib.gfx.Align;
	import fanlib.gfx.CacheToBmp;
	import fanlib.gfx.IAlign;
	import fanlib.gfx.ICacheToBmp;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TBitmap;
	import fanlib.io.MLoader;
	import fanlib.tween.TVector2;
	import fanlib.utils.Enum;
	import fanlib.utils.ILexiRef;
	import fanlib.utils.Parser;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.filters.GradientBevelFilter;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	
	public class XMLParser2 {

		// 'buildObjectTree' function variables
		private var obj:Object = null; // object under creation
		
		private var xml:XML;
		private var callBack:Function;
		private var parent:Object; // object 'parent'
		private var lexicon:ILexicon;
		public var nameToObject:Object; // 19/10/14 : changed to 'public' for hacking purposes!
		
		private var currentChildIndex:int = -1;
		private var childName:String;
		private var childList:XMLList;
		private var assetsFolder:String;
		private var defaultClass:String; // so that you don't define it all the time if using the same everywhere
		private var addToParent:Boolean = true;
		private var finalized:Boolean;
		// 'buildObjectTree' function variables
		
		static public const nameToFilter:Object = nameToFilterInit();
		
		static public var LEXICON:ILexicon = null; // default used when none passed
		
		// instance needed for certain functions like 'buildObjectTree'
		public function XMLParser2(_lexicon:ILexicon = null, defClass:String = null) {
			lexicon = _lexicon;
			if (lexicon == null) lexicon = LEXICON;
			
			defaultClass = defClass;
		}

		// filters
		static public function nameToFilterInit():Object {
			var arr:Object = {};
			arr["DropShadow"] = parseDropShadow;
			arr["Glow"] = parseGlow;
			arr["Bevel"] = parseBevel;
			arr["Desaturate"] = parseDesaturate;
			arr["Sepia"] = parseSepia;
			arr["Blur"] = parseBlur;
			//arr["GradientBevel"] = parseGradientBevel;
			return arr;
		}
		
		static public function parseBlur(params:Array):BlurFilter {
			var defParams:Array = new Array(4, 4, 1);
			Parser.applyDefaultParams(params, defParams, true);
			return new BlurFilter(params[0], params[1], params[2]);
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
		
		static public function parseDesaturate(params:Array):ColorMatrixFilter {
			var defParams:Array = [1]; // desaturation amount (1 = 100%)
			Parser.applyDefaultParams(params, defParams, true);
			return Color.DesaturationFilter(params[0]);
		}
		
		static public function parseSepia(params:Array):ColorMatrixFilter {
			var defParams:Array = [1]; // brightness (1 = 100%)
			Parser.applyDefaultParams(params, defParams, true);
			return Color.SepiaFilter(params[0]);
		}
		
		static public function parseGradientBevel(params:Array):GradientBevelFilter {
			var defParams:Array = new Array(4.0, 45, null, null, null, 4.0, 4.0, 1, 1, "inner", false);
			Parser.applyDefaultParams(params, defParams, true);
			return new GradientBevelFilter(params[0], params[1], params[2], params[3], params[4], params[5],
								  		   params[6], params[7], params[8], params[9], Parser.toBool(params[10]));
		}
				
		static public function parseFilters(str:String):Array {
			
			var instances:Array = [];
			if (str === null || str.length === 0) return instances;
			
			var filters:Array = str.split('|');
			var i:int;
			for (i = 0; i < filters.length; ++i) {
				var fparams:Array = filters[i].split(',');
				var filter:String = fparams.shift(); // get and remove 1st param (filter ID)
				var fun:Function = nameToFilter[filter];
				if (fun !== null) instances.push( fun(fparams) ); else trace("XMLParser2 filter",filter,"not recognized");
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
		// NOTE : function is not re-entrant! A new 'XMLParser2' instance must be created!
		// <= true = the object was fully finalized before function returned
		// TODO : Add Global Variables GVARS="name:(Bool):value", Global Variables, accessed in vars with "varname=GVAR:gvarname"
		public function buildObjectTree(_xml:XML, _callBack:Function = null, folder:String = "", _parent:Object = null):Boolean {
			if (xml !== null) return finalized; // not re-entrant
			finalized = false;
			
			if (!nameToObject) nameToObject = {};
			if (_parent) nameToObject[_parent.name] = _parent;

			xml = _xml;
			parent = _parent;
			callBack = _callBack;
			childList = xml.elements();
			assetsFolder = folder;

			var classArr:Array;
			
			// resolve "class" attribute
			var classXML:* = xml.attribute("class")[0];
			var classStr:String;
			if (classXML) {
				classStr = classXML.toString();
			} else {
				classStr = defaultClass;
			}
			
			// direct class definition
			const directConstruct:Function = function():* {
				// passing comma-separated constructor arguments 
				classArr = classStr.split(',');
				var _class:Class = flash.utils.getDefinitionByName(classArr.shift()) as Class;
				obj = Utils.DynamicConstructor(_class, classArr);
			}
			
			// check special object construction (copy, etc.)
			classArr = classStr.split(":");
			if (classArr.length > 1) {
				
				switch (classArr[0]) {
					case "Copy":
						// NOTE : copied object must implement ICopy!
						const baseClassStr:String = classArr[2];
						const baseClass:Class = (baseClassStr) ? getDefinitionByName(baseClassStr) as Class : null;
						obj = (nameToObject[classArr[1]] as ICopy).copy(baseClass);
						break;
					case "Object":
						obj = nameToObject[classArr[1]];
						addToParent = false; // simply modify object, don't alter order by re-adding to parent 
						break;
					case "Child":
						obj = parent.getChildByName(classArr[1]);
						addToParent = false;
						break;
					case "Find":
						obj = parent.findChild(classArr[1]);
						addToParent = false;
						break;
					case "Parent":
						obj = parent;
						addToParent = false;
						break;
					default:
						directConstruct();
						break;
				}
				
			} else {
				
				directConstruct();
			}
			
			// set object name NOW (at last, implemented)
			try { obj.name = _xml.localName(); } catch(e:Error) {} // fuck Timeline shit
			nameToObject[obj.name] = obj;
			
			// object created! Check for special cases:
			var attr:*;
			var ref:String;
			var i:int;
				
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
					if (attr != undefined) {
						imagePath = attr[0];
						if (folder && imagePath.slice(0, 7) != "http://") imagePath = folder + imagePath;
					}
				}
				if (imagePath !== null) {
					new MLoader(new Array(imagePath), bmpImageLoaded);
					return finalized; // function exits now; there is chance this is 'true', too!
				}
				
			} else if (obj is TextField) {
				
				// build 'TextFormat'
				var tfield:TextField = obj as TextField;
				var fVars:Array;
				var fArr:Array;
				var _fontName:String;
				var format:TextFormat;
				if (xml.attribute("format") != undefined) {
					fVars = (xml.attribute("format")[0].toString()).split('|');
					fArr = (fVars.shift() as String).split(',');
					_fontName = Parser.getFontName(Parser.toStr(fArr[0]));
					format = new TextFormat(_fontName, Parser.toStr(fArr[1]), Parser.toStr(fArr[2]),
														   Parser.toBool(fArr[3], null), Parser.toBool(fArr[4], null), Parser.toBool(fArr[5], null),
														   Parser.toStr(fArr[6]), Parser.toStr(fArr[7]), Parser.toStr(fArr[8]),
														   Parser.toStr(fArr[9]), Parser.toStr(fArr[10]), Parser.toStr(fArr[11]),
														   Parser.toStr(fArr[12]));
					setVars(format, fVars);
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
					
					i = 0;
					var txt:String;
					var xmlTxts:XMLList = xml.text();
					if (xmlTxts[0] !== undefined) {
						txt = "";
						while (xmlTxts[i] !== undefined) {
							txt += xmlTxts[i++];
						}
						tfield.htmlText = txt;
					}
				}
				
			}
			
			buildChildren();
			return finalized;
		}
		
		private function bmpImageLoaded(l:MLoader):void {
			var bmp:Bitmap = obj as Bitmap;
			try { bmp.bitmapData = (l.files[0] as Bitmap).bitmapData; } catch(e:Error) {
				if (l && l.names) trace(e, l.names[0]) else trace(e);
			}
			bmp.smoothing = true; // by default
			
			buildChildren();
		}
		
		private function buildChildren(dummy:* = undefined):void {
			var childXML:*;
			while ((childXML = childList[++currentChildIndex]) != undefined) {
				var xmlp2:XMLParser2 = new XMLParser2(lexicon, defaultClass);
				xmlp2.nameToObject = this.nameToObject; // ha!
				var immediateCreation:Boolean = xmlp2.buildObjectTree(childXML, null, assetsFolder, obj); // next
				if (!immediateCreation) {
					xmlp2.callBack = buildChildren;
					return;
				}
			}
			finalizeObject();
		}
		
		private function finalizeObject():void {
			
			// add to parent before 'vars', as 'vars' may depend on parent existing
			if (parent != null && addToParent) parent.addChild(obj);
			var attr:*;
			
			// set vars
			attr = xml.attribute("vars");
			if (attr != undefined) setVars(obj, (attr[0].toString()).split('|'));
			
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
					case "none":
						alX = Align.NONE;
						break;
					default:
						Align.WRONG_ENUM();
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
					case "none":
						alY = Align.NONE;
						break;
					default:
						Align.WRONG_ENUM();
				}
			}
			if (obj is IAlign) (obj as IAlign).align(alX, alY); // object handles alignment itself (may want to remember it)
			
			// set filters
			attr = xml.attribute("filters");
			if (attr != undefined) {
				obj.filters = parseFilters(attr[0].toString());
			}
			
			// is initializable?
			if (obj is IInit) (obj as IInit).initLast();
			
			// NEW : cache to bitmap?
			attr = xml.attribute("cacheToBitmap");
			if (attr != undefined) {
				if (String(attr)) CacheToBmp.Cache(obj as DisplayObject, CacheToBmp[attr]);
			} else if (obj is ICacheToBmp) {
				var type:Enum = (obj as ICacheToBmp).cacheToBitmap;
				if (type) {
					CacheToBmp.Cache(obj as DisplayObject, type);
				}
			}
			
			// "cleanup" to make function re-entrant, in case this is needed
			xml = null;
			
			// finished
			finalized = true;
			if (callBack != null) callBack(obj);
		}
		
		// set array of 'x=y' vars to object
		private function setVars(object:Object, vArr:Array):void {
			for (var i:int = 0; i < vArr.length; ++i) {
				var params:Array = (vArr[i] as String).split('='); // the first '=' separates variable name from value
				var varName:String = params.shift();
				object[ varName ] = parseValue( params.join("="), varName );
			}
		}
		
		private function parseValue(v:String, varName:String):* {
			var varValue:*;
			var temp:String;
			
			// special values
			var arr:Array = v.split(',');
			if ( arr.length > 1 && !(v.slice(0,1) == "'" && v.slice(-1,1) == "'") ) {
				
				varValue = new Array();
				while (arr.length) {
					varValue.push( parseValue(arr.shift(), varName) );
				}
				
			} else {
				var varArr:Array = v.split(':');
				if (varArr.length > 1) {
					switch (varArr[0]) {
						case "Bool":
							varValue = Parser.toBool(varArr[1]);
							break;
						case "Object":
							varValue = nameToObject[varArr[1]];
							break;
						case "Find":
							varValue = obj.findChild(varArr[1]);
							break;
						case "Child":
							varValue = obj.getChildByName(varArr[1]);
							break;
						case "Copy":
							var property:String = (varArr.length > 2) ? varArr[2] : varName; // automatically copy same named property if undefined!
							varValue = nameToObject[ varArr[1] ][property];
							break;
						case "Stage":
							varValue = Stg.Get()[varArr[1]];
							break;
						case "Parent":
							varValue = parent[ varArr[1] ];
							break;
						case "Null":
							varValue = null;
							break;
						case "":
							varArr.shift();
							varValue = varArr.join(":"); // in case you want ":" in value, e.g. "var=::yeah:" returns ":yeah:"
							break;
						default:
							varValue = v;
							break;
					}
				} else {
					varValue = v;
				}
			}
			
			return varValue;
		}
	}
}
