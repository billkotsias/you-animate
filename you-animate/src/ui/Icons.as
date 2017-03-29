package ui
{
	import fanlib.utils.IChange;
	import fanlib.utils.IInit;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	public class Icons extends BasicWindow implements IInit
	{
		public var columns:uint = 1;
		public var spaceX:Number = 45;
		public var spaceY:Number = 45;
		
		public function Icons()
		{
			super();
			trackChanges = false;
		}
		
		public function initLast():void {
			trackChanges = true;
			rearrange();
		}
		
		public function rearrange():void {
			var j:int = 0; // child index
			var yy:Number = 0;
			while (j < numChildren) {
				var i:int = 0; // column index
				var xx:Number = 0;
				do {
					var obj:DisplayObject = getChildAt(j);
					obj.x = xx;
					obj.y = yy;
					xx += spaceX;
					if (++j >= numChildren) break;
				} while (++i < columns);
				yy += spaceY;
			}
			
			updateWindow();
		}
		
		override public function childChanged(obj:IChange):void {
			if (!trackChanges) return; // duplicate, but what can one fuck?
			rearrange();
			super.childChanged(obj);
		}
	}
}