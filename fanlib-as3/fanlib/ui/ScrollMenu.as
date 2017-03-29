package fanlib.ui
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.TouchScroll;
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class ScrollMenu extends TouchScroll
	{
		static public const CHILD_SELECTED:String = "CHILD_SELECTED";
		
		public var accuracy:Boolean = false;
		public var scrollThreshold:Number = 20; // distance, in Stage pixels
		
		private var initPos:Point = new Point();
		private var newPos:Point = new Point();
		private var childSelected:DisplayObject;
		
		public function ScrollMenu()
		{
			super();
		}
		
		override protected function touched(e:MouseEvent):void {
			super.touched(e);
			childSelected = e.target as DisplayObject;
			initPos.x = x;
			initPos.y = y;
		}
		
		override protected function untouched(e:MouseEvent = null):void {
			super.untouched(e);
			if (accuracy) {
				if (e == null || e.target != childSelected) childSelected = null;
			}
			if (childSelected && childSelected.name) {
				dispatchEvent(new ObjEvent(childSelected, CHILD_SELECTED));
				childSelected = null;
			}
		}
		
		override protected function adjustScroll():void {
			super.adjustScroll();
			if (childSelected) {
				newPos.x = x;
				newPos.y = y;
				if (scrollThreshold < Point.distance(initPos, newPos)) childSelected = null;
			}
		}
	}
}