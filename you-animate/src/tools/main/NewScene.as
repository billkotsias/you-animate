package tools.main
{
	import scene.Scene;
	import tools.Tool;

	public class NewScene extends Tool
	{
		public function NewScene()
		{
			super();
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			if (!selected) return;
			
			Scene.INSTANCE.newScene();
//			selected = false;
		}
	}
}