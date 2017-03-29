package fanlib.starling {
	
	import fanlib.gfx.Align;
	import fanlib.gfx.IAlign;
	import fanlib.gfx.IAlpha;
	import fanlib.io.MLoader;
	import fanlib.utils.Enum;
	import fanlib.utils.IChange;
	import fanlib.utils.ICopy;
	import fanlib.utils.ILexiRef;
	import fanlib.utils.Utils;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.utils.Dictionary;
	
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class FBitmap extends Image implements IAlpha, IAlign, ILexiRef, IChange, ICopy {
		
		static private const BitmapDataToTexture:Dictionary = new Dictionary(true);
		
		protected var _alignX:Enum;
		protected var _alignY:Enum;
		private const alignP:Point = new Point();
		private const pos:Point = new Point(); // increases precision too!
		private var _rotation:Number = 0;
		
		public var testMap:BitmapData = null;
		
		private var _bitmapData:BitmapData;
		private var latestDataRef:String; // lexicon & lazy bmp loading
		
		// track (multiple) changes logic
		public var trackChanges:Boolean = true;
		
		public function FBitmap(__bitmapData:BitmapData, _alX:Enum = null, _alY:Enum = null) {
			_bitmapData = __bitmapData;
			var _texture:Texture = ConvertBitmapDataToTexture(_bitmapData);
			super(_texture);
			align(_alX, _alY);
		}
		
		static public function ConvertBitmapDataToTexture(b:BitmapData):Texture {
			if (!b) {
				return Texture.empty(1,1);
			}
			if (!BitmapDataToTexture[b]) {
				var _texture:Texture = Texture.fromBitmapData(b);
				BitmapDataToTexture[b] = _texture;
				return _texture;
			}
			return BitmapDataToTexture[b];
		}
		public function set bitmapData(b:BitmapData):void {
			_bitmapData = b;
			texture = ConvertBitmapDataToTexture(b);
			readjustSize();
			align(alignX, alignY);
			childChanged(this);
		}
		public function get bitmapData():BitmapData {
			return _bitmapData;
		}
		
		// lazy BitmapData loading
		static public function LazyBitmapData(file:String, obj:FBitmap, group:String = ""):void {
			if (obj is FBitmap) (obj as FBitmap).latestDataRef = file;
			var loader:MLoader = new MLoader(file, LazyFileLoaded, obj, group);
		}
		static private function LazyFileLoaded(l:MLoader):void {
			var dat:BitmapData;
			try { dat = l.files[0].bitmapData; } catch (e:Error) {}
			var file:String = l.names[0];
			
			var bmp:FBitmap = l.data as FBitmap;
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
		
		public function get finalX():Number { return super.x }
		public function get finalY():Number { return super.y }
		
		public function offset(_x:Number, _y:Number):void {
			x += _x;
			y += _y;
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
		
		// track children changes !
		// override to catch event, but call super.childChanged in order NOT to cut the event off
		public function childChanged(obj:IChange):void {
			if (!trackChanges) return;
			align(alignX, alignY);
			if (parent is IChange) (parent as IChange).childChanged(obj);
			dispatchEvent(new Event(Event.CHANGE)); // for non-ancestors interested in us
		}
		
		public function set transform(t:Matrix):void {
			super.transformationMatrix = t;
			updateFromTransform();
		}
		public function updateFromTransform():void {
			pos.x = super.x;
			pos.y = super.y;
		}
		
		override public function get rotation():Number {
			return _rotation;
		}
		
		override public function set rotation(r:Number):void {
			_rotation = r;
			super.rotation = _rotation * Math.PI / 180;
		}
		
		// create copy : usefull for templates
		public function copy(baseClass:Class = null):* {
			// TODO : support parameters for "baseClass"!
			const obj:FBitmap = (baseClass) ? new baseClass() : new (Utils.GetClass(this));
			obj.name = this.name;
			obj.bitmapData = this.bitmapData;
			obj.transform = this.transformationMatrix;
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
			return obj;
		}

	}
	
}
