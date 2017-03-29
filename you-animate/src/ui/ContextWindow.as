package ui
{
	import flash.events.Event;
	
	import tools.IContext;
	import tools.Tool;

	public class ContextWindow extends BasicWindow
	{
		private var _contextObjects:Array; // keep it simple stupid, by inserting children only in here
		
		private var _contextTool:Tool;
		
		public function ContextWindow()
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
			for each (var tool:IContext in _contextObjects) {
				tool.contextSelected(_contextTool);
			}
		}
		protected function contextDeselected(e:Event):void {
			visible = false;
			for each (var tool:IContext in _contextObjects) {
				tool.contextDeselected();
			}
		}

		public function get contextObjects():* { return _contextObjects }
		public function set contextObjects(value:*):void {
			if (!(value is Array)) value = [value];
			_contextObjects = value;
		}

	}
}