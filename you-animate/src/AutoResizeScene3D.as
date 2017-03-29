package
{
	import fanlib.gfx.Stg;
	
	import flare.basic.Scene3D;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class AutoResizeScene3D extends Scene3D
	{
		public var viewportDO:DisplayObject; // follow this orientation
		
		public function AutoResizeScene3D(container:DisplayObjectContainer, file:String="")
		{
			super(container, file);
			Stg.Get().addEventListener(Event.RESIZE, stageResized, false, 0, true);
		}
		
		private function stageResized(e:Event):void {
			var newViewport:Rectangle = viewportDO.getRect(Stg.Get());
			setViewport(newViewport.x, newViewport.y, newViewport.width, newViewport.height, antialias);
		}
	}
}