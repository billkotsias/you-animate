package fanlib.gfx {
	
	import fanlib.io.MLoader;
	import fanlib.utils.Enum;
	import fanlib.utils.IChange;
	import fanlib.utils.ICopy;
	import fanlib.utils.ILexiRef;
	import fanlib.utils.Utils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	public class FBitmap extends Bitmap implements IAlpha, IAlign, ILexiRef, IChange, ICopy, ICacheToBmp {
		
		protected var _alignX:Enum;
		protected var _alignY:Enum;
		private const alignP:Point = new Point();
		private const pos:Point = new Point(); // increases precision too!
		
		static public var GLOBAL_SCALE:Number = 1;
		
		public var testMap:BitmapData = null; // 24-bit greyscale alpha test-map!
		
		private var latestDataRef:String; // lexicon & lazy bmp loading
		
		// track (multiple) changes logic
		public var trackChanges:Boolean = true;
		
		// cache to bitmap
		private var _cacheToBitmap:Enum = null;
		
		public function FBitmap(_bitmapData:BitmapData = null, _alX:Enum = null, _alY:Enum = null,
								_smoothing:Boolean = true, _pixelSnapping:String = "auto") {
			super(_bitmapData, _pixelSnapping, _smoothing);
			
			scaleX = 1; // i.e * GLOBAL_SCALE
			scaleY = 1;
			align(_alX, _alY);
		}
		
		override public function set bitmapData(b:BitmapData):void {
			var _smoothing:Boolean = smoothing; // SUPER FLASH BUG
			super.bitmapData = b;
			smoothing = _smoothing;
			align(alignX, alignY); // NOTE : NEW ADDITION 26/8/11
			childChanged(this);
		}
		
		// lazy BitmapData loading
		static public function LazyBitmapData(file:String, obj:Bitmap, group:String = ""):void {
			if (obj is FBitmap) (obj as FBitmap).latestDataRef = file;
			var loader:MLoader = new MLoader(file, LazyFileLoaded, obj, group);
		}
		static private function LazyFileLoaded(l:MLoader):void {
			var dat:BitmapData;
			try { dat = l.files[0].bitmapData; } catch (e:Error) {}
			var file:String = l.names[0];
			
			var bmp:Bitmap = l.data as Bitmap;
			if (bmp is FBitmap && (bmp as FBitmap).latestDataRef != file) return; // !!!
			bmp.bitmapData = dat;
		}
		public function set lazyBitmapData(file:String):void {
			LazyBitmapData(file, this);
		}
		public function lazyBitmapDataGroup(file:String, group:String):void {
			LazyBitmapData(file, this, group);
		}
		
		// lexicon
		public function languageChanged(newRefs:*):void {
			latestDataRef = newRefs;
			new MLoader(new Array(latestDataRef), newDataLoaded, latestDataRef);
		}
		private function newDataLoaded(l:MLoader):void {
			if (l.data != latestDataRef) return; // changed again in the meantime; will ya make up ya mind
			try {
				bitmapData = l.files[0].bitmapData;
				childChanged(this);
			} catch(e:Error) {}
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
		
		public function get alignXNum():Number { return alignP.x; }
		public function get alignYNum():Number { return alignP.y; }
		
		public function offset(_x:Number, _y:Number):void {
			x += _x;
			y += _y;
		}
		
		public function set parent(newParent:DisplayObjectContainer):void {
			if (newParent) {
				newParent.addChild(this);
			} else {
				if (parent) parent.removeChild(this);
			}
		}

		// - alpha functions
		public function getAlphaGlobal(p:Point, minMask:int = 0):int {
			return getAlphaLocal(this.globalToLocal(p), minMask);
		}
		
		public function getAlphaLocal(p:Point, minMask:int = 0):int {
			
			if (p.x < 0 || p.y < 0) return -1;
			
			var alfa:int;
			
			// no 'testMap'
			if (testMap == null) {
				
				if (bitmapData == null ||
					p.x >= bitmapData.width || p.y >= bitmapData.height) return -1;
				
				if (!bitmapData.transparent) return 0xff;
				
				alfa = (bitmapData.getPixel32(p.x, p.y)) >>> 24;
				if (alfa <= minMask) return -1; // "mask" alpha
				return alfa;
			}
			
			// 'testMap' is here
			if (p.x >= testMap.width || p.y >= testMap.height) return -1;
			
			alfa = (testMap.getPixel(p.x, p.y)) & 0xff; // red component suffices
			if (alfa <= minMask) return -1; // "mask" alpha
			return alfa;
		}
		
		// make "invisible", both 'alpha' and 'visible', useful for fade-in
		public function invisible():void {
			visible = false;
			alpha = 0;
		}
		
		// scrollRect bug
		override public function set scrollRect(value:Rectangle):void {
			super.scrollRect = value;
			var bmpData:BitmapData = new BitmapData(1, 1);
			bmpData.draw(this);
		}
		
		public function set scrollRectangle(arr:Array):void {
			scrollRect = new Rectangle(arr[0],arr[1],arr[2],arr[3]);
			childChanged(this);
		}
		
		// track children changes !
		// override to catch event, but call super.childChanged in order NOT to cut the event off
		public function childChanged(obj:IChange):void {
			if (!trackChanges) return;
			align(alignX, alignY);
			if (parent is IChange) (parent as IChange).childChanged(obj);
			dispatchEvent(new Event(Event.CHANGE)); // for non-ancestors interested in us
		}
		
		override public function set transform(t:Transform):void {
			super.transform = t;
			updateFromTransform();
		}
		public function updateFromTransform():void {
			pos.x = super.x;
			pos.y = super.y;
		}
		
		// getters & setters
		override public function get scaleX():Number {
			return super.scaleX / GLOBAL_SCALE;
		}
		override public function get scaleY():Number {
			return super.scaleY / GLOBAL_SCALE;
		}
		override public function set scaleX(value:Number):void {
			super.scaleX = value * GLOBAL_SCALE;
		}
		override public function set scaleY(value:Number):void {
			super.scaleY = value * GLOBAL_SCALE;
		}
		
		// create copy : usefull for templates
		public function copy(baseClass:Class = null):* {
			// TODO : support parameters for "baseClass"!
			const obj:FBitmap = (baseClass) ? new baseClass() : new (Utils.GetClass(this));
			obj.name = this.name;
			obj.bitmapData = this.bitmapData;
			obj.filters = this.filters;
			obj.transform = this.transform;
			obj.alpha = this.alpha;
			
			// align
			obj.alignP.x = this.alignP.x;
			obj.alignP.y = this.alignP.y;
			obj._alignX = this._alignX;
			obj._alignY = this._alignY;
			obj.pos.x = this.pos.x;
			obj.pos.y = this.pos.y;
			
//			obj.x = this.x;
//			obj.y = this.y;
//			obj.scaleX = this.scaleX;
//			obj.scaleY = this.scaleY;
//			obj.rotation = this.rotation;
//			obj.align(this.alignX, this.alignY);
			
			obj.blendMode = this.blendMode;
			obj.scrollRect = this.scrollRect;
			obj.cacheToBitmap = this.cacheToBitmap;
			
			return obj;
		}
		
		public function get cacheToBitmap():Enum { return _cacheToBitmap }
		public function set cacheToBitmap(value:Enum):void { _cacheToBitmap = value }

		public function set template(key:*):void {
			if (!key) key = name; // NOTE!
			FSprite.TEMPLATES[key] = this;
		}
		public function set templateOnly(key:*):void {
			template = key;
			parent = null;
		}
	}
	
}
