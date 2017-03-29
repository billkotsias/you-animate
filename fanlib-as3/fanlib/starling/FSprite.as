package fanlib.starling {
	
	import fanlib.gfx.Align;
	import fanlib.gfx.IAlign;
	import fanlib.gfx.Stg;
	import fanlib.utils.Enum;
	import fanlib.utils.IChange;
	import fanlib.utils.ICopy;
	import fanlib.utils.Utils;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	//import fanlib.utils.Debug;
	
	// debugs Flash Sprite :
	// - apply REAL 'rotation'
	// - return TRUE bounds of a 'scrollRect'ed Sprite
	// - immediate effect of 'scrollRect' changes
	public class FSprite extends starling.display.Sprite implements IAlign, IChange, ICopy {

		static public const MOUSE_CONT_DOWN:String = "MOUSE_CONT_DOWN";
		
		protected var _alignX:Enum;
		protected var _alignY:Enum;
		private const alignP:Point = new Point();
		private const pos:Point = new Point(); // increases precision too!
		
		private var eMouseContDown:TouchEvent;
		private var _rotation:Number = 0;
		
		// track (multiple) changes logic
		public var trackChanges:Boolean = true;
		
		public function FSprite() {
			addEventListener(TouchEvent.TOUCH, mouseDown); // for 'MOUSE_CONT_DOWN' event
		}
		
		private function mouseDown(e:TouchEvent):void {
			eMouseContDown = e;
			var touch:Touch = e.getTouch(this);
			if (!touch) {
				return;
				trace("Is Starling fucked up or what?", e.type, e.touches, e.target);
			} else {
				switch (touch.phase) {
					case TouchPhase.BEGAN:
						addEventListener(EnterFrameEvent.ENTER_FRAME, dispatchMouseContDown);
						dispatchMouseContDown();
						break;
					case TouchPhase.ENDED:
						removeEventListener(EnterFrameEvent.ENTER_FRAME, dispatchMouseContDown);
						break;
				}
			}
		}
		private function dispatchMouseContDown(e:Event = null):void {
			dispatchEvent(new TouchEvent(MOUSE_CONT_DOWN, eMouseContDown.touches,
										 eMouseContDown.shiftKey, eMouseContDown.ctrlKey, eMouseContDown.bubbles));
		}
		
		// align
		public function get alignX():Enum { return _alignX; }
		public function get alignY():Enum { return _alignY; }
		
		public function align(idX:Enum = null, idY:Enum = null):void {
			var rect:Rectangle;
			
			if (idX != null) {
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
			
			if (idY != null) {
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

		public function offset(_x:Number, _y:Number):void {
			x += _x;
			y += _y;
		}

		// misc
		// - remove all children
		public function removeAllChildren():void {
			while (numChildren > 0) removeChildAt(numChildren - 1);
		}
		
		// set rotation point by symmetry
		// NOTE: MUST BE SET AFTER ALL CHILDREN HAVE BEEN ADDED and "FIRMLY" POSITIONED
//		public function setRotationPoint(idX:Enum = null, idY:Enum = null):void {
//			
//			var rect:Rectangle = getBounds(this);
//			
//			if (idX != null) {
//				if (idX.be(Align.LEFT)) {
//					_rotPointX = rect.x;
//				} else if (idX.be(Align.RIGHT)) {
//					_rotPointX = rect.x + rect.width;
//				} else if (idX.be(Align.CENTER)) {
//					_rotPointX = (rect.x + rect.width) / 2;
//				}
//			}
//			
//			if (idY != null) {
//				if (idY.be(Align.TOP)) {
//					_rotPointY = rect.y;
//				} else if (idY.be(Align.BOTTOM)) {
//					_rotPointY = rect.y + rect.height;
//				} else if (idY.be(Align.CENTER)) {
//					_rotPointY = (rect.y + rect.height) / 2;
//				}
//			}
//			
//			rotation = _rotation;
//		}
		
		override public function get rotation():Number {
			return _rotation;
		}
		
		override public function set rotation(r:Number):void {
			_rotation = r;
			super.rotation = _rotation * Math.PI / 180;
		}
		
		public function set transform(t:Matrix):void {
			super.transformationMatrix = t;
			updateFromTransform();
		}
		public function updateFromTransform():void {
			pos.x = super.x;
			pos.y = super.y;
			_rotation = super.rotation;
		}
		
		// scrollRect bug
//		public function set scrollRect(value:Rectangle):void {
//			super.scrollRect = value;
//			var bmpData:BitmapData = new BitmapData(1, 1);
//			bmpData.draw(this);
//		}
		
//		public function set scrollRectangle(arr:Array):void {
//			scrollRect = new Rectangle(arr[0],arr[1],arr[2],arr[3]);
//			childChanged(this);
//		}
		
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
				for (var i:int = container.numChildren - 1; i >= 0; --i) {
					var child:DisplayObject = container.getChildAt(i);
					if (child.name == n) return child;
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
					if (child.name == n) toReturn.push(child);
					if (child is DisplayObjectContainer) toSearch.push(child);
				}
			} while(toSearch.length > 0);
			
			return toReturn;
		}
		
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
			
			var rect:Rectangle = o.getBounds(this);
			o.x = - rect.width / 2 - rect.x + offset.x;
			o.y = - rect.height / 2 - rect.y + offset.y;
			
			// set previous scalings back
			while (scales.length) {
				var scale:Object = scales.shift();
				scale.obj.scaleX = scale.sx;
				scale.obj.scaleY = scale.sy;
			}
		}
		
		// track children changes !
		// override to catch event, but call super.childChanged in order NOT to cut the event off
		public function childChanged(obj:IChange):void {
			if (!trackChanges) return;
			align(alignX, alignY);
			if (parent is IChange) (parent as IChange).childChanged(obj);
			dispatchEvent(new Event(Event.CHANGE)); // for non-ancestors interested in us
		}
		
		// static functions
		
		// create copy : useful for templates
		public function copy(baseClass:Class = null):* {
			// TODO : support parameters for "baseClass"!
			const obj:FSprite = (baseClass) ? new baseClass() : new (Utils.GetClass(this));
			obj.name = this.name;
			obj.filter = this.filter;
			obj.transformationMatrix = this.transformationMatrix;
			obj.alpha = this.alpha;
			
			// align
			obj.alignP.x = this.alignP.x;
			obj.alignP.y = this.alignP.y;
			obj._alignX = this._alignX;
			obj._alignY = this._alignY;
			obj.pos.x = this.pos.x;
			obj.pos.y = this.pos.y;
			
			// children
			for (var i:int = 0; i < numChildren; ++i) {
				var copyable:ICopy = this.getChildAt(i) as ICopy;
				if (copyable) obj.addChild(copyable.copy());
			}
			return obj;
		}
	}
}
