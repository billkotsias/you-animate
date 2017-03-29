package ui
{
	import flash.events.Event;
	import tools.IContext;
	import tools.Tool;

	public class ContextIcons extends Icons
	{
		private var _contextTool:Tool;
		
		public function ContextIcons()
		{
			super();
		}

		public function get contextTool():Tool { return _contextTool }
		public function set contextTool(value:Tool):void
		{
			_contextTool = value;
			_contextTool.addEventListener(Tool.SELECTED, contextSelected, false, 0, true);
			_contextTool.addEventListener(Tool.DESELECTED, contextDeselected, false, 0, true);
		}
		
		protected function contextSelected(e:Event):void {
			visible = true;
			for (var i:int = 0; i < numChildren; ++i) {
				var tool:IContext = getChildAt(i) as IContext;
				if (tool) tool.contextSelected(_contextTool);
			}
		}
		protected function contextDeselected(e:Event):void {
			visible = false;
			for (var i:int = 0; i < numChildren; ++i) {
				var tool:IContext = getChildAt(i) as IContext;
				if (tool) tool.contextDeselected();
			}
		}
	}
}