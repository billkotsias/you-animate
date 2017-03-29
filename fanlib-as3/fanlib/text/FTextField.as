package fanlib.text {
	
	import fanlib.gfx.Align;
	import fanlib.gfx.IAlign;
	import fanlib.gfx.ICacheToBmp;
	import fanlib.utils.Enum;
	import fanlib.utils.IChange;
	import fanlib.utils.ICopy;
	import fanlib.utils.ILexiRef;
	import fanlib.utils.Utils;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	public class FTextField extends TextField implements IAlign, ILexiRef, IChange, ICopy, ICacheToBmp {
		
		static private const TEMPLATES:Dictionary = new Dictionary(false);
		static public function FromTemplate(key:*):FTextField {
			return (TEMPLATES[key] as ICopy).copy();
		}

		/**
		 * Dispatched when field is type "input" and user presses <b>ENTER</b> or changes focus
		 */
		static public const FINALIZED:String = "FINALIZED";
		
		private var origHTMLText:String = "";
		private var origCSS:StyleSheet;
		private var origFormat:TextFormat;

		protected var _alignX:Enum;
		protected var _alignY:Enum;
		private const alignP:Point = new Point();
		private const pos:Point = new Point(); // increases precision too!
		private var _autoSizeMaxWidth:Number;
		
		private var withholdEvent:Boolean = false; // prevent multiple event dispatching
		
		// track (multiple) changes logic
		public var trackChanges:Boolean = true;
		
		// cache to bitmap
		private var _cacheToBitmap:Enum = null;
		
		private var textChanged:Boolean;
		
		public function FTextField() {
			super();
			//cacheAsBitmap = true; // !?
			origFormat = super.defaultTextFormat;
			needsSoftKeyboard = true;
		}
		
		// lexicon
		public function languageChanged(newRefs:*):void {
			htmlText = newRefs;
		}
		
		// align
		public function get alignX():Enum { return _alignX; }
		public function get alignY():Enum { return _alignY; }
		
		public function align(idX:Enum = null, idY:Enum = null):void {
			if (idX != null) {
				_alignX = idX;
				if (idX == Align.LEFT) {
					alignP.x = 0;
				} else if (idX == Align.RIGHT) {
					alignP.x = - width;
				} else if (idX == Align.CENTER) {
					alignP.x = - width / 2;
				} else {
					Align.WRONG_ENUM();
				}
				x = x;
			}
			
			if (idY != null) {
				_alignY = idY;
				if (idY == Align.TOP) {
					alignP.y = 0;
				} else if (idY == Align.BOTTOM) {
					alignP.y = - height;
				} else if (idY == Align.CENTER) {
					alignP.y = - height / 2;
				} else {
					Align.WRONG_ENUM();
				}
				y = y;
			}
			
			if (!withholdEvent) {
				dispatchEvent(new Event(Event.CHANGE));
				childChanged(this);
			}
		}
			
		override public function get x():Number { return pos.x; }
		override public function get y():Number { return pos.y; }
		override public function set x(_x:Number):void {
			pos.x = _x;
			super.x = pos.x + alignP.x;
		}
		override public function set y(_y:Number):void {
			pos.y = _y;
			super.y = pos.y + alignP.y;
		}
		
		// Flash TextField bug fixes :
		override public function get styleSheet():StyleSheet {
			return origCSS;
		}
		override public function set styleSheet(css:StyleSheet):void {
			origCSS = css;
			super.styleSheet = css;
		}
		
		override public function set defaultTextFormat(format:TextFormat):void {
			super.styleSheet = null;
			super.defaultTextFormat = format;
			origFormat = super.defaultTextFormat;
			super.styleSheet = origCSS;
		}
		override public function get defaultTextFormat():TextFormat {
			return origFormat;
		}
		
		override public function set htmlText(value:String):void {
			// override FLASH MOTHERC BUG ARGHHHHHHHH
			super.htmlText = ""; // every single frigging line is needed!!!
			if (super.styleSheet) super.styleSheet = null; // this one
			super.defaultTextFormat = origFormat; // this one too
			super.styleSheet = origCSS; // yeah, that's right
			origHTMLText = value; // frig YEAH
			super.htmlText = value;
			
			if (autoSize !== TextFieldAutoSize.NONE && _autoSizeMaxWidth) {
				wordWrap = false;
				if (width > _autoSizeMaxWidth) {
					width = _autoSizeMaxWidth;
					wordWrap = true;
				}
			}
			
			var temp:Boolean = withholdEvent;
			withholdEvent = true;
			align(alignX, alignY); // !!!!!!
			withholdEvent = temp;
			if (!withholdEvent) {
				//trace("OLE",this,this.name,value);
				dispatchEvent(new Event(Event.CHANGE));
				childChanged(this);
			}
		}
		
		public function get originalHTMLText():String { return origHTMLText }
		
		override public function set multiline(value:Boolean):void {
			super.multiline = value;
			super.htmlText = origHTMLText;
		}
		
		// track children changes !
		// override to catch event, but call super.childChanged in order NOT to cut the event off
		public function childChanged(obj:IChange):void {
			if (!trackChanges) return;
			if (parent is IChange) (parent as IChange).childChanged(obj);
		}
		
		override public function set transform(t:Transform):void {
			super.transform = t;
			updateFromTransform();
		}
		public function updateFromTransform():void {
			pos.x = super.x;
			pos.y = super.y;
		}
		
		// make "invisible", both 'alpha' and 'visible', useful for fade-in
		public function invisible():void {
			visible = false;
			alpha = 0;
		}
		
		public function set parent(newParent:DisplayObjectContainer):void {
			if (newParent) {
				newParent.addChild(this);
			} else {
				if (parent) parent.removeChild(this);
			}
		}
		
		// Input related
		
		override public function set type(value:String):void {
			super.type = value;
			if (value === TextFieldType.INPUT) {
				addEventListener(KeyboardEvent.KEY_DOWN, inputKeyDown, false, 0, true);
				addEventListener(FocusEvent.FOCUS_OUT, focusOut, false, 0, true);
				addEventListener(Event.CHANGE, textEntered, false, 0, true);
			} else {
				removeEventListener(KeyboardEvent.KEY_DOWN, inputKeyDown);
				removeEventListener(FocusEvent.FOCUS_OUT, focusOut);
				removeEventListener(Event.CHANGE, textEntered);
			}
		}
		private function textEntered(e:Event):void {
			textChanged = true;
		}
		private function focusOut(e:FocusEvent):void {
			if (textChanged) inputFinalized(e);
		}
		private function inputKeyDown(e:KeyboardEvent):void {
			if (e.keyCode === 13) inputFinalized(e);
		}
		private function inputFinalized(e:Event):void {
			textChanged = false;
			dispatchEvent(new Event(FINALIZED));
			if (stage && stage.focus === this) stage.focus = null;
		}
		
		// TODO : under research...
		public function strike(start:int,end:int):void {
			var startLine:int = getLineIndexOfChar(start);
			var endLine:int = getLineIndexOfChar(end);
			
			if (endLine > startLine){ //multiline strike
				var lineLength:int = getLineLength(startLine) - 1;
				var lastChar:int = lineLength + getLineOffset(startLine);
				drawStrike(start, lastChar); //start to end of first line
				strike(lastChar + 1, end); //recurse with rest of lines
			} else if (endLine == startLine) { //single
				drawStrike(start, end);
			}
		}
		private function drawStrike(start:int, end:int):void {
			var startPt:Point = new Point(getCharBoundaries(start).x, getCharBoundaries(start).y);
			var endPt:Point = new Point(getCharBoundaries(end).right, 0);
			var h:Number = getLineMetrics(0).height - getLineMetrics(0).leading;
			var s:Shape = new Shape();
			//addChild(s)
			s.x = x;
			s.y = y;
			s.graphics.lineStyle(3);
			s.graphics.moveTo(startPt.x,startPt.y+h/2);
			s.graphics.lineTo(endPt.x,startPt.y+h/2);
		}
		
		// create copy : useful for templates
		public function copy(baseClass:Class = null):* {
			// TODO : support parameters for "baseClass"!
			const obj:FTextField = (baseClass) ? new baseClass() : new (Utils.GetClass(this));
			obj.name = this.name;
			obj.width = this.width;
			obj.height = this.height;
			obj.autoSize = this.autoSize;
			obj.embedFonts = this.embedFonts;
			obj.mouseEnabled = this.mouseEnabled;
			obj.wordWrap = this.wordWrap;
			obj.multiline = this.multiline;
			obj.selectable = this.selectable;
			obj.background = this.background;
			obj.backgroundColor = this.backgroundColor;
			obj.border = this.border;
			obj.borderColor = this.borderColor;
			obj.defaultTextFormat = this.defaultTextFormat;
			obj.styleSheet = this.styleSheet;
			
			obj.transform = this.transform;
			obj.alignP.x = this.alignP.x;
			obj.alignP.y = this.alignP.y;
			obj._alignX = this._alignX;
			obj._alignY = this._alignY;
			obj.pos.x = this.pos.x;
			obj.pos.y = this.pos.y;
			// was:
//			obj.x = this.x;
//			obj.y = this.y;
//			obj.scaleX = this.scaleX;
//			obj.scaleY = this.scaleY;
//			obj.rotation = this.rotation;
//			obj.align(this.alignX, this.alignY);
			
			obj.type = this.type;
			obj.restrict = this.restrict;
			obj.maxChars = this.maxChars;
			obj.displayAsPassword = this.displayAsPassword;
			obj.htmlText = this.originalHTMLText; // NOTE: doesn't have any difference to this.htmlText, since the format is identical anyway!
			obj.filters = this.filters;
			obj.cacheToBitmap = this.cacheToBitmap;
			
			return obj;
		}
		
		public function set template(key:*):void {
			if (!key) key = name; // NOTE!
			TEMPLATES[key] = this;
		}
		public function set templateOnly(key:*):void {
			template = key;
			parent = null;
		}
		
		public function get cacheToBitmap():Enum { return _cacheToBitmap }
		public function set cacheToBitmap(value:Enum):void { _cacheToBitmap = value }

		public function get autoSizeMaxWidth():Number { return _autoSizeMaxWidth }
		public function set autoSizeMaxWidth(value:Number):void
		{
			_autoSizeMaxWidth = value;
			htmlText = origHTMLText;
		}

	}
	
}