package fanlib.gfx
{
	import fanlib.event.ObjEvent;
	import fanlib.math.Vector2D;
	import fanlib.tween.TVector2;
	import fanlib.utils.IChange;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	public class TouchWindow extends TSprite
	{
		static public const SCROLL:String = "SCROLL";
		
		private var cont:DisplayObjectContainer;
		public function get container():DisplayObjectContainer { return cont; }
		public function set container(o:DisplayObjectContainer):void {
			if (cont) super.removeChild(cont);
			cont = o;
			if (cont) {
				super.addChild(cont);
				adjustRect();
			}
		}
		
		public var allowXScroll:Boolean = true;
		public var allowYScroll:Boolean = true;
		public var marginX:Number = 0; // pixels
		public var marginY:Number = 0;
		public var deceleration:Number = 0.01;
		
		private const touchPos:TVector2 = new TVector2();
		protected const speed:Vector2D = new Vector2D();
		private var _winOffset:TVector2 = new TVector2();
		private var lastTimer:uint;
		
		public function TouchWindow()
		{
			super();
			
			enabled = true;
		}
		
		public function set enabled(e:Boolean):void {
			if (e)
				addEventListener(MouseEvent.MOUSE_DOWN, touched, false, 0, true);
			else
				removeEventListener(MouseEvent.MOUSE_DOWN, touched);
		}
		
		protected function touched(e:MouseEvent):void {
			//trace("touched...",e.target.name);
			touchPos.x = e.stageX;
			touchPos.y = e.stageY;
			lastTimer = getTimer();
			addEventListener(MouseEvent.MOUSE_UP, untouched, false, 0, true);
			// fucking ROLL_OUT DOESN'T WORK : FUCKING FLASH BUG FOR COCK'S shake
			addEventListener(Event.ENTER_FRAME, touchedFrame, false, 0, true);
			removeEventListener(Event.ENTER_FRAME, untouchedFrame);
		}
		private function touchedFrame(e:Event):void {
			var timeSinceLast:uint = getTimer() - lastTimer;
			lastTimer += timeSinceLast;
			var smouseX:Number = Stg.Get().mouseX;
			var smouseY:Number = Stg.Get().mouseY;
			var displacement:TVector2 = new TVector2(smouseX - touchPos.x, smouseY - touchPos.y);
			touchPos.x = smouseX;
			touchPos.y = smouseY;
			
			speed.components = displacement.divN(timeSinceLast) as TVector2;
			_winOffset = _winOffset.sub(displacement) as TVector2;
			if (displacement.x != 0 || displacement.y != 0) {
				adjustRect();
				//trace(scrollRect," ",globalToLocal(new Point(smouseX, smouseY)));
				// WORKAROUND for ROLL_OUT BUG
				if (scrollRect && !(scrollRect.containsPoint(globalToLocal(new Point(smouseX, smouseY)))))
					untouched();
			}
		}
		
		protected function untouched(e:MouseEvent = null):void {
			//if (e) trace("...untouched",e.type,e.target.name) else trace("...untouched");
			removeEventListener(MouseEvent.MOUSE_UP, untouched);
			removeEventListener(Event.ENTER_FRAME, touchedFrame);
			addEventListener(Event.ENTER_FRAME, untouchedFrame, false, 0, true);
		}
		private function untouchedFrame(e:Event):void {
			var timeSinceLast:uint = getTimer() - lastTimer;
			lastTimer += timeSinceLast;
			var decelVec:TVector2 = speed.direction.mulN(deceleration) as TVector2;
			// s = s0 + v * t - 1/2 * g * t^2;
			_winOffset = _winOffset.sub(speed.components.mulN(timeSinceLast)).add(decelVec.mulN(timeSinceLast*timeSinceLast*deceleration/2)) as TVector2;
			if (!speed.decelerate(deceleration * timeSinceLast)) removeEventListener(Event.ENTER_FRAME, untouchedFrame);
			adjustRect();
		}
		
		override public function childChanged(obj:IChange):void {
			adjustRect();
			super.childChanged(obj);
		}
		private function adjustRect():void {
			if (!(cont && scrollRect)) return;
			
			const contRect:Rectangle = cont.getRect(this);
			if (contRect.width === 0 && contRect.height === 0) { // override yet another long-standing Flash bug!
				contRect.x = 0;
				contRect.y = 0;
			}
			
			// check if inside
			var maxX:Number = contRect.x + contRect.width - scrollRect.width + marginX,
				minX:Number = contRect.x - marginX,
				maxY:Number = contRect.y + contRect.height - scrollRect.height + marginY,
				minY:Number = contRect.y - marginY;
			
			if (allowXScroll) {
				if (_winOffset.x > maxX) {
					_winOffset.x = maxX;
					speed.components = new TVector2(0, speed.components.y);
				}
				if (_winOffset.x < minX) {
					_winOffset.x = minX;
					speed.components = new TVector2(0, speed.components.y);
				}
			} else {
				_winOffset.x = contRect.x - marginX;
			}
			if (allowYScroll) {
				if (_winOffset.y > maxY) {
					_winOffset.y = maxY;
					speed.components = new TVector2(speed.components.x, 0);
				}
				if (_winOffset.y < minY) {
					_winOffset.y = minY;
					speed.components = new TVector2(speed.components.x, 0);
				}
			} else {
				_winOffset.y = contRect.y - marginY;
			}
			
			// TODO : Still not sure if should be commented-out
//			if (scrollRect.x !== winOffset.x || scrollRect.y !== winOffset.y)
				scrollRect = new Rectangle(_winOffset.x, _winOffset.y, scrollRect.width, scrollRect.height);
				dispatchEvent(new ObjEvent( new Point( _winOffset.x/(maxX-minX), _winOffset.y/(maxY-minY) ), SCROLL ));
		}
		
		public function get windowOffset():TVector2 { return _winOffset.copy() as TVector2; }
		public function set windowOffset(w:TVector2):void {
			_winOffset = w;
			adjustRect();
		}
		public function addToWindowOffset(w:TVector2):void {
			_winOffset = _winOffset.add(w) as TVector2;
			adjustRect();
		}
		
		public function get scrollSpeed():TVector2 { return speed.components; }
		public function set scrollSpeed(s:TVector2):void {
			speed.components = s;
			lastTimer = getTimer();
			addEventListener(Event.ENTER_FRAME, untouchedFrame, false, 0, true);
		}
		
		public function rootAddChildAt(c:DisplayObject, i:int):DisplayObject {
			return super.addChildAt(c, i);
		}
		public function rootAddChild(c:DisplayObject):DisplayObject {
			return super.addChild(c);
		}
		public function rootRemoveChild(c:DisplayObject):DisplayObject {
			return super.removeChild(c);
		}
		
		// overrides
		override public function addChild(c:DisplayObject):DisplayObject {
			// pretty DFXML-compatible hack!
			if (cont) {
				c = cont.addChild(c);
			} else {
				container = c as DisplayObjectContainer;
			}
//			childChanged(this);
			return c;
		}
		override public function addChildAt(c:DisplayObject, i:int):DisplayObject {
			c = cont.addChildAt(c, i);
//			childChanged(this);
			return c;
		}
		override public function removeChild(c:DisplayObject):DisplayObject {
			c = cont.removeChild(c);
//			childChanged(this);
			return c;
		}
		override public function removeChildren(beginIndex:int=0, endIndex:int=int.MAX_VALUE):void {
			cont.removeChildren(beginIndex, endIndex);
		}
		override public function removeChildAt(i:int):DisplayObject {
			var c:DisplayObject = cont.removeChildAt(i);
//			childChanged(this);
			return c;
		}
		override public function getChildAt(i:int):DisplayObject {
			var c:DisplayObject = cont.getChildAt(i);
			return c;
		}
		override public function getChildByName(name:String):DisplayObject {
			const c:DisplayObject = cont.getChildByName(name);
			return c;
		}
		override public function get numChildren():int {
			if (cont) return cont.numChildren;
			return super.numChildren;
		}
		override public function getChildIndex(c:DisplayObject):int {
			var index:int;
			try {
				index = cont.getChildIndex(c);
			} catch (e:Error) {
				index = super.getChildIndex(c);
			}
			return index;
		}
		
	}
}