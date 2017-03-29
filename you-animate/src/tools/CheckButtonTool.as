package tools
{
	import fanlib.ui.CheckButton;
	import fanlib.ui.IToolTip;
	import fanlib.ui.Tooltip;
	import fanlib.utils.XMLParser2;
	
	import flash.events.Event;
	
	public class CheckButtonTool extends CheckButton implements ITool, IToolTip
	{
		private var _selected:Boolean;
		
		protected var _tip:String;
		protected var _toolTipName:String;
		
		public function CheckButtonTool()
		{
			super();
		}
		
		public function set icon(file:*):void {
			trackChanges = false;
			
			var parser:XMLParser2 = new XMLParser2();
			var xml:XML;
			if (file is Array) {
				xml = XML('' +
					'<'+name+' class="Parent:">' +
						'<'+name+'On class="tools.ToolButton" vars="tip=|icon='+file[0]+'"/>' +
						'<'+name+'Off class="tools.ToolButton" vars="tip=|icon='+file[1]+'"/>' +
					'</'+name+'>');
			} else {
				xml = XML('' +
					'<'+name+' class="Parent:">' +
						'<'+name+'On class="tools.ToolButton" vars="tip=|icon='+file+'" filters="DropShadow,4,45,0,1,8,8,1,1,true"/>' +
						'<'+name+'Off class="tools.ToolButton" vars="tip=|icon='+file+'"/>' +
					'</'+name+'>');
			}
			parser.buildObjectTree(xml, iconsLoaded, ToolButton.IconsFolder, this);
		}
		protected function iconsLoaded(o:CheckButtonTool):void {
			enabled = enabled;
			trackChanges = true;
			childChanged(this);
		}
		
		override public function set state(s:Boolean):void {
			selected = s;
		}
		
		public function get selected():Boolean { return _selected }
		public function set selected(select:Boolean):void
		{
			_selected = select;
			
			// deselect previously selected tool of same group
			var groupID:*;
			if (select) {
				for each (groupID in groups) {
					Tool.DeselectCurrent(groupID);
					Tool.CURRENT_SELECTED[groupID] = this;
				}
				dispatchEvent(new Event(Tool.SELECTED));
				super.state = true;
			} else {
				for each (groupID in groups) {
					if (Tool.CURRENT_SELECTED[groupID] === this) delete Tool.CURRENT_SELECTED[groupID]; // none selected
				}
				dispatchEvent(new Event(Tool.DESELECTED));
				super.state = false;
			}
		}
		
		// IToolTip
		
		override public function set name(value:String):void {
			if (_tip === null || _tip === name) tip = value;
			super.name = value;
		}
		
		public function set toolTipName(tName:String):void {
			const previousTooltip:Tooltip = Tooltip.INSTANCES[_toolTipName];
			if (previousTooltip) previousTooltip.unregister(this);
			
			_toolTipName = tName;
			if (_toolTipName !== null) {
				const toolTip:Tooltip = Tooltip.INSTANCES[_toolTipName];
				if (toolTip) toolTip.register(this);
			}
		}
		
		public function set tip(value:String):void {
			_tip = value;
			if (!_tip) {
				toolTipName = null;
			} else {
				if (!_toolTipName) toolTipName = Tooltip.DefaultTooltipName; // set if not
			}
		}
		
		public function get tip():String { return _tip }
	}
}