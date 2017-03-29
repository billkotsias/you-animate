package tools.photo
{
	import flash.events.Event;
	
	import scene.Scene;
	
	import tools.Tool;

	public class PhotoViewport extends Tool
	{
		public var photoMain:Tool;
		
		public function PhotoViewport()
		{
			super();
			Scene.INSTANCE.addEventListener(Scene.BACKGROUND_CHANGE, backChanged, false, 0, true);
		}
		
		override public function set selected(select:Boolean):void {
			photoMain.selected = select;
			visible = false;
		}
		
		private function backChanged(e:Event):void
		{
			if (Scene.INSTANCE.background.bitmapData) visible = false; else visible = true;
		}
	}
}