package fanlib.gfx
{
	import fanlib.math.Maths;
	import fanlib.math.Vector2D;
	import fanlib.tween.TVector2;
	import fanlib.utils.IChange;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	/**
	 * Main difference with TouchWindow is that this one DOESN'T use 'scrollRect', so it's faster with shitty smart-ass-phones.
	 * But doesn't do any cropping, so...
	 * @author BIG Mathafacka
	 */
	public class TouchScroll extends TSprite
	{
		public var allowXScroll:Boolean = false;
		public var allowYScroll:Boolean = true;
		public var deceleration:Number = 0.01;
		
		private const _scrollArea:Rectangle = new Rectangle();
		private const pMin:Point = new Point();
		private const pMax:Point = new Point();
		
		private var touchPos:TVector2 = new TVector2();
		private var speed:Vector2D = new Vector2D();
		private var lastTimer:uint;
		private var scrollOffset:TVector2 = new TVector2();
		
		public function TouchScroll()
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
			//trace("touched",e.currentTarget.name);
			touchPos.x = e.stageX;
			touchPos.y = e.stageY;
			lastTimer = getTimer();
			addEventListener(MouseEvent.MOUSE_UP, untouched, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, untouched, false, 0, true);
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
			scrollOffset = scrollOffset.add(displacement) as TVector2;
			if (displacement.x != 0 || displacement.y != 0) {
				adjustScroll();
			}
		}
		
		protected function untouched(e:MouseEvent = null):void {
			//trace("untouched",e.currentTarget.name);
			removeEventListener(MouseEvent.MOUSE_UP, untouched);
			removeEventListener(MouseEvent.ROLL_OUT, untouched);
			removeEventListener(Event.ENTER_FRAME, touchedFrame);
			addEventListener(Event.ENTER_FRAME, untouchedFrame, false, 0, true);
		}
		private function untouchedFrame(e:Event):void {
			var timeSinceLast:uint = getTimer() - lastTimer;
			lastTimer += timeSinceLast;
			var decelVec:TVector2 = speed.direction.mulN(deceleration) as TVector2;
			// s = s0 + v * t - 1/2 * g * t^2;
			scrollOffset = scrollOffset.add(speed.components.mulN(timeSinceLast)).sub(decelVec.mulN(timeSinceLast*timeSinceLast*deceleration/2)) as TVector2;
			if (!speed.decelerate(deceleration * timeSinceLast)) removeEventListener(Event.ENTER_FRAME, untouchedFrame);
			adjustScroll();
		}
		
		override public function childChanged(obj:IChange):void {
			calcMinMax();
			adjustScroll();
			super.childChanged(obj);
		}
		protected function adjustScroll():void {
			if (allowXScroll) {
				x = scrollOffset.x = Maths.bound2(scrollOffset.x, pMin.x, pMax.x);
			}
			if (allowYScroll) {
				y = scrollOffset.y = Maths.bound2(scrollOffset.y, pMin.y, pMax.y);
			}
		}

		// => a bit like scrollRec:, x0,y0,width,height! If you don't want x-scroll, width = 0!
		public function set scrollArea(value:Array):void
		{
			_scrollArea.setTo(value[0],value[1],value[2],value[3]);
			scrollOffset.x = x;
			scrollOffset.y = y;
			calcMinMax();
			adjustScroll();
		}
		
		private function calcMinMax():void {
			pMax.setTo(_scrollArea.x,_scrollArea.y);
			pMin.setTo(_scrollArea.x + _scrollArea.width - this.width, _scrollArea.y + _scrollArea.height - this.height);
			if (pMin.x > pMax.x) pMin.x = pMax.x;
			if (pMin.y > pMax.y) pMin.y = pMax.y;
		}

	}
}