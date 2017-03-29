package fanlib.gfx
{	
	import fanlib.utils.Enum;
	import fanlib.utils.FArray;
	import fanlib.utils.IChange;
	import fanlib.utils.ICopy;
	import fanlib.utils.Utils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.utils.Dictionary;

	//import fanlib.utils.Debug;
	
	// debugs Flash Sprite :
	// - apply REAL 'rotation'
	// - return TRUE bounds of a 'scrollRect'ed Sprite
	// - immediate effect of 'scrollRect' changes
	public class FSprite extends Sprite implements IAlign, IChange, ICopy, ICacheToBmp {

		static public const MOUSE_CONT_DOWN:String = "MOUSE_CONT_DOWN";
		static public const INVERT_SPR_NAME:String = "FSprite_invert";

		static internal const TEMPLATES:Dictionary = new Dictionary(false);
		static public function FromTemplate(key:*):* {
			return (TEMPLATES[key] as ICopy).copy();
		}
		
		protected var _alignX:Enum;
		protected var _alignY:Enum;
		private const alignP:Point = new Point();
		private const pos:Point = new Point(); // increases precision too!
		
		private var eMouseContDown:MouseEvent;
		
		// publicly set attributes
//		public var _rotPointX:Number = 0;
//		public var _rotPointY:Number = 0;

		// private vars
		private var _rotation:Number = 0;
		
		// track (multiple) changes logic
		public var trackChanges:Boolean = true;
		
		// cache to bitmap
		private var _cacheToBitmap:Enum = null; // required to be getter/setter for ICacheToBmp
		
		public var _assignChildren:Array; // for easy copying around
		
		// background
		protected var backShp:FSprite;
		protected var backSpr:FSprite;
		
		// filters
		protected var _filters:Array;
		
		public function FSprite() {
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true); // for 'MOUSE_CONT_DOWN' event
		}
		private function mouseDown(e:MouseEvent):void {
			eMouseContDown = e.clone() as MouseEvent;
			Stg.Get().addEventListener(Event.ENTER_FRAME, dispatchMouseContDown);
			addEventListener(MouseEvent.MOUSE_UP, stopMouseDown);
			addEventListener(MouseEvent.ROLL_OUT, stopMouseDown);
			dispatchMouseContDown();
		}
		private function dispatchMouseContDown(e:Event = null):void {
			dispatchEvent(new MouseEvent(MOUSE_CONT_DOWN, eMouseContDown.bubbles, eMouseContDown.cancelable,
										 eMouseContDown.localX, eMouseContDown.localY, eMouseContDown.relatedObject,
										 eMouseContDown.ctrlKey, eMouseContDown.altKey, eMouseContDown.shiftKey,
										 eMouseContDown.buttonDown, eMouseContDown.delta));
		}
		private function stopMouseDown(e:MouseEvent):void {
			Stg.Get().removeEventListener(Event.ENTER_FRAME, dispatchMouseContDown);
			removeEventListener(MouseEvent.MOUSE_UP, stopMouseDown);
			removeEventListener(MouseEvent.ROLL_OUT, stopMouseDown);
		}
		
		// align
		public function get alignX():Enum { return _alignX; }
		public function get alignY():Enum { return _alignY; }
		
		public function align(idX:Enum = null, idY:Enum = null):void {
			var rect:Rectangle;
			
			if (idX !== null) {
				_alignX = idX;
				rect = getBounds(this);
				if (idX == Align.LEFT) {
					alignP.x = - rect.x;
				} else if (idX == Align.RIGHT) {
					alignP.x = - rect.x - width;
				} else if (idX == Align.CENTER) {
					alignP.x = - rect.x - width / 2;
				} else if (idX == Align.NONE) {
					alignP.x = 0;
				} else {
					Align.WRONG_ENUM();
				}
				x = x;
			}
			
			if (idY !== null) {
				_alignY = idY;
				if (!rect) rect = getBounds(this);
				if (idY == Align.TOP) {
					alignP.y = - rect.y;
				} else if (idY == Align.BOTTOM) {
					alignP.y = - rect.y - height;
				} else if (idY == Align.CENTER) {
					alignP.y = - rect.y - height / 2;
				} else if (idY == Align.NONE) {
					alignP.y = 0;
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
		public function get finalX():Number { return super.x; }
		public function get finalY():Number { return super.y; }

		public function moveBy(_x:Number, _y:Number):void {
			x += _x;
			y += _y;
		}

		// misc
		// - remove all children
		override public function removeChildren(beginIndex:int=0, endIndex:int=int.MAX_VALUE):void {
			super.removeChildren(beginIndex, endIndex);
			childChanged(this);
		}
		
		public function set parent(newParent:DisplayObjectContainer):void {
			if (newParent) {
				newParent.addChild(this);
			} else {
				if (parent) parent.removeChild(this);
			}
		}
		
		override public function get rotation():Number {
			return _rotation;
		}
		
		override public function set rotation(r:Number):void {
			_rotation = r;
			super.rotation = _rotation;
			
//			var newMatrix:Matrix = new Matrix(1,0,0,1,-_rotPointX,-_rotPointY);
//			newMatrix.scale(this.scaleX, this.scaleY);
//			newMatrix.rotate(_rotation * Math.PI / 180);
//			newMatrix.translate(_rotPointX + this.x, _rotPointY + this.y);
//			this.transform.matrix = newMatrix;
//			updateFromTransform();
		}
		
		override public function set transform(t:Transform):void {
			super.transform = t;
			updateFromTransform();
		}
		public function updateFromTransform():void {
			pos.x = super.x;
			pos.y = super.y;
			_rotation = super.rotation;
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
			bmpData.dispose();
		}
		
		public function get scrollRectangle():Array { return [scrollRect.x, scrollRect.y, scrollRect.width, scrollRect.height] }
		public function set scrollRectangle(arr:Array):void {
			scrollRect = new Rectangle(arr[0],arr[1],arr[2],arr[3]);
			childChanged(this);
		}
		
		// hierarchy
		override public function addChild(c:DisplayObject):DisplayObject {
			c = super.addChild(c);
			childChanged(this);
			return c;
		}
		
		public function findChild(n:String):* {
			return FindChild(this, n);
		}
		
		public function findChildren(n:String):Array {
			return FindChildren(this, n);
		}
		
		static public function FindChild(o:DisplayObjectContainer, n:String):* {
			var toSearch:Array = new Array();
			toSearch.push(o); // start with-a-me, Mario
			
			do {
				var container:DisplayObjectContainer = toSearch.shift();
				// searching is done on per-level basis: children first, then grand-children etc...
				for (var i:int = container.numChildren - 1; i >= 0; --i) {
					var child:DisplayObject = container.getChildAt(i);
					if (child.name === n) return child;
					if (child is DisplayObjectContainer) toSearch.push(child);
				}
			} while(toSearch.length > 0);
			return null; // sorry, not found
		}
		
		static public function FindChildren(o:DisplayObjectContainer, n:String):Array {
			var toReturn:Array = new Array();
			var toSearch:Array = new Array();
			toSearch.push(o); // start with-a-me, Mario
			
			do {
				var container:DisplayObjectContainer = toSearch.shift();
				for (var i:int = container.numChildren - 1; i >= 0; --i) {
					var child:DisplayObject = container.getChildAt(i);
					if (child.name === n) toReturn.push(child);
					if (child is DisplayObjectContainer) toSearch.push(child);
				}
			} while(toSearch.length > 0);
			
			return toReturn;
		}
		
		// => x,y,width,height,visible(default=false),colour,alpha
		// main purpose is to add INVISIBLE but CLICKABLE background, so is optimized and differs from 'FShape'..!
		public function set addBackground(params:Array):void {
			removeBackground();
			backShp = new FSprite();
			var bounds:Rectangle = getRect(this);
			backShp.graphics.beginFill(params[5],params[6]);
			backShp.graphics.drawRect(params[0], params[1], params[2], params[3]);
			addChildAt(backShp, 0);
			backShp.visible = params[4]; // !
			var backSpr:FSprite = new FSprite();
			backSpr.name = "";
			backSpr.hitArea = backShp;
			addChildAt(backSpr,0);
		}
		
		public function removeBackground():void {
			if (backSpr) backSpr.parent = null;
			if (backShp) backShp.parent = null;
		}
		
		public function set invertContent(enable:Boolean):void {
			// remove old anyway
			var invert:FSprite = getChildByName(INVERT_SPR_NAME) as FSprite;
			if (invert) removeChild(invert);
			
			if (enable) {
				invert = new FSprite();
				invert.name = INVERT_SPR_NAME;
				invert.mouseEnabled = false;
				const gfx:Graphics = invert.graphics;
				const rect:Rectangle = getRect(this);
				gfx.beginFill(0xffffff);
				gfx.drawRect(rect.x,rect.y,rect.width,rect.height);
				gfx.endFill();
				invert.blendMode = BlendMode.INVERT;
				addChild(invert);
			}
		}
		public function get invertContent():Boolean {
			return getChildByName(INVERT_SPR_NAME) as FSprite;
		}
		
		/**
		 * 
		 * @param assignTo Variables holder object
		 * @param parent FSprite children parent
		 * @param names Children names, 1-to-1 accordance with variables
		 * 
		 */
		static public function AssignChildren(assignTo:Object, parent:FSprite, names:Array):void {
			for (var i:int = names.length - 1; i >= 0; --i) {
				var name:String = names[i];
				assignTo[name] = parent.findChild(name);
			}
		}
		public function set assignChildren(names:*):void {
			if (names is String) names = [names]; // String -> Array
			if (_assignChildren === null) _assignChildren = [];
			_assignChildren = _assignChildren.concat(names);
			AssignChildren(this, this, names);
		}
		
		// redundant!
		public function addChildCentered(o:DisplayObject, offset:Point = null):void {
			addChildCenteredAt(o, numChildren, offset);
		}
		
		public function addChildCenteredAt(o:DisplayObject, index:int, offset:Point = null):void {
			if (!offset) offset = new Point();
			
			addChildAt(o, index);
			
			// reset scaling to all our ancestors because if one has zero scaling, we are fucked
			var scales:Array = new Array();
			var current:DisplayObject = o;
			while (current != null && current != root) {
				scales.push( {obj:current, sx:current.scaleX, sy:current.scaleY} );
				current.scaleX = 1;
				current.scaleY = 1;
				current = current.parent;
			}
			
			var rect:Rectangle = o.getRect(this);
			o.x = - rect.width / 2 - rect.x + offset.x;
			o.y = - rect.height / 2 - rect.y + offset.y;
			
			// set previous scalings back
			while (scales.length) {
				var scale:Object = scales.shift();
				scale.obj.scaleX = scale.sx;
				scale.obj.scaleY = scale.sy;
			}
		}
		// redundant!
		
		// track children changes !
		// override to catch event, but call super.childChanged in order NOT to cut the event off
		public function childChanged(obj:IChange):void {
			if (!trackChanges) return;
			align(alignX, alignY);
			if (parent is IChange) (parent as IChange).childChanged(obj);
			dispatchEvent(new Event(Event.CHANGE)); // for non-ancestors interested in us
		}
		
		// static functions
		
		// get full bounds regardless 'scrollRect' property
		public static function getFullBounds(displayObject:DisplayObject):Rectangle {
			var bounds:Rectangle, transform:Transform, toGlobalMatrix:Matrix, currentMatrix:Matrix;
			
			transform = displayObject.transform;
			currentMatrix = transform.matrix;
			toGlobalMatrix = transform.concatenatedMatrix;
			toGlobalMatrix.invert();
			transform.matrix = toGlobalMatrix;
			
			bounds = transform.pixelBounds.clone();
			
			transform.matrix = currentMatrix;
			
			return bounds;
		}
		
		// filters management
		override public function set filters(arr:Array):void {
			_filters = arr;
			super.filters = _filters;
		}
		override public function get filters():Array {
			return _filters;
		}
		
		// create copy : useful for templates
		public function copy(baseClass:Class = null):* {
			// TODO : support parameters for "baseClass"!
			const obj:FSprite = (baseClass) ? new baseClass() : new (Utils.GetClass(this));
			obj.name = this.name;
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
			
			obj.blendMode = this.blendMode;
			obj.scrollRect = this.scrollRect;
			obj.buttonMode = this.buttonMode;
			obj.mouseEnabled = this.mouseEnabled;
			obj.trackChanges = this.trackChanges;
			obj.cacheToBitmap = this.cacheToBitmap; // XMLParser2 should do the cache after adding 'obj' to its parent
			obj.graphics.copyFrom(this.graphics);
			
			// children
			var copied:*;
			for (var i:int = 0; i < numChildren; ++i) {
				var copyable:ICopy = this.getChildAt(i) as ICopy;
				if (copyable) {
					copied = copyable.copy();
					obj.addChild(copied);
					var cachable:ICacheToBmp = copied as ICacheToBmp;
					if (cachable && cachable.cacheToBitmap) CacheToBmp.Cache(cachable as DisplayObject, cachable.cacheToBitmap);
				}
			}
			// TODO : this is wrong!
//			obj.backShp = this.backShp;
//			obj.backSpr = this.backSpr;
			
			if (this._assignChildren) obj.assignChildren = this._assignChildren;
			
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
	}
}
