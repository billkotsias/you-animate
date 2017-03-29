package tools.main
{
	import scene.Scene;
	import tools.Tool;

	public class Load extends Tool
	{
		public function Load()
		{
			super();
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			if (select) {
				Scene.INSTANCE.load();
				super.selected = false;
			}
		}
	}
}