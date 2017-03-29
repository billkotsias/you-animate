package fanlib.gfx
{
	import fanlib.event.Unlistener;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;

	public class DragDObj extends Drag
	{
		private var obj:DisplayObject;
		private var point:Point;
		
		public function DragDObj(obj:DisplayObject, stopDragEvents:Array = null, forceMouseLeave:Boolean = true)
		{
			super(stopDragEvents, forceMouseLeave);
			
			this.obj = obj;
			point = obj.parent.globalToLocal(new Point(stg.mouseX, stg.mouseY));
		}
		
		override protected function mouseMove(e:MouseEvent):Boolean {
			if (!super.mouseMove(e)) return false;
			
			const newPoint:Point = obj.parent.globalToLocal(new Point(stg.mouseX, stg.mouseY));
			obj.x += newPoint.x - point.x;
			obj.y += newPoint.y - point.y;
			point = newPoint;
			
			return true;
		}
		
		override public function stopDrag(e:* = undefined):void {
			obj = null;
			point = null;
			super.stopDrag();
		}
	}
}