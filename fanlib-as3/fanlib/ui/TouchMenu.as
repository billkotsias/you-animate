package fanlib.ui
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.TouchWindow;
	import fanlib.tween.TVector2;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class TouchMenu extends TouchWindow
	{
		static public const CHILD_SELECTED:String = "CHILD_SELECTED";
		
		public var accuracy:Boolean = false;
		public var scrollThreshold:Number = 20; // distance, in Stage pixels
		public var ignoreUnnamedChildren:Boolean = true;
		
		private var initPos:Point = new Point();
		private var newPos:Point = new Point();
		private var childSelected:DisplayObject;
		
		private var _mouseWheel:Number;
		private var _mouseWheelObject:InteractiveObject;
		
		public function TouchMenu()
		{
			super();
			_mouseWheelObject = this;
		}
		
		public function get mouseWheelObject():InteractiveObject { return _mouseWheelObject }
		public function set mouseWheelObject(obj:InteractiveObject):void {
			const curFactor:Number = _mouseWheel;
			mouseWheel = 0;
			_mouseWheelObject = obj;
			mouseWheel = curFactor;
		}
		
		public function get mouseWheel():Number { return _mouseWheel }
		/**
		 * @param factor Set to 0 or NaN to disable mouse wheel for this UI element
		 */
		public function set mouseWheel(factor:Number):void {
			_mouseWheel = factor;
			if (_mouseWheel) {
				_mouseWheelObject.addEventListener(MouseEvent.MOUSE_WHEEL, mWheel, false, 0, true);
			} else {
				_mouseWheelObject.removeEventListener(MouseEvent.MOUSE_WHEEL, mWheel);
			}
		}
		private function mWheel(e:MouseEvent):void {
			addToWindowOffset(new TVector2(0, -e.delta * _mouseWheel));
		}
		
		/**
		 * Give EMPTY names to children you don't want to hear about! 
		 * @param e
		 */
		override protected function touched(e:MouseEvent):void {
			super.touched(e);
			childSelected = e.target as DisplayObject;
			if ( (!ignoreUnnamedChildren || childSelected.name) && scrollRect ) {
				initPos.x = scrollRect.x;
				initPos.y = scrollRect.y;
			} else {
				childSelected = null;
			}
		}
		
		override protected function untouched(e:MouseEvent = null):void {
			super.untouched(e);
			if (accuracy) {
				if (e === null || e.target !== childSelected) childSelected = null;
			}
			if (childSelected) {
				dispatchEvent(new ObjEvent(childSelected, CHILD_SELECTED));
				childSelected = null;
			}
		}
		
		override public function set scrollRect(value:Rectangle):void {
			super.scrollRect = value;
			if (childSelected && scrollRect) {
				newPos.x = scrollRect.x;
				newPos.y = scrollRect.y;
				if (scrollThreshold < Point.distance(initPos, newPos)) childSelected = null;
			}
		}
	}
}