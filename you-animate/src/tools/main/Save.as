package tools.main
{
	import scene.Scene;
	import tools.Tool;

	public class Save extends Tool
	{
		public function Save()
		{
			super();
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			if (select) {
				Scene.INSTANCE.save();
				super.selected = false;
			}
		}
	}
}