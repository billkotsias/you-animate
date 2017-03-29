package tools
{
	import fanlib.ui.FButton2;
	import fanlib.ui.IToolTip;
	import fanlib.ui.Tooltip;
	import fanlib.utils.Debug;
	import fanlib.utils.XMLParser2;
	
	public class ToolButton extends FButton2 implements IToolTip
	{
		static public var IconsFolder:String = "";
		
		protected var _tip:String;
		protected var _toolTipName:String;
		
		public function ToolButton()
		{
			super();
		}
		
		public function set icon(file:String):void {
			trackChanges = false;
			
			var parser:XMLParser2 = new XMLParser2();
			var xml:XML = XML('' +
				'<'+name+' class="Parent:">' +
					'<normalState class="fanlib.gfx.FBitmap" image="'+file+'"/>' +
					'<overState class="Copy:normalState" filters="Glow,0xffff00,1,6,6,2,1,true"/>' +
					'<downState class="Copy:normalState" filters="DropShadow,4,45,0,1,8,8,1,1,true|Glow,0x000000,1,2,2,2,1,true"/>' +
					'<disabledState class="Copy:normalState" filters="Sepia,0.7|Desaturate,1|Blur,2,2"/>' +
				'</'+name+'>');
			parser.buildObjectTree(xml, iconsLoaded, IconsFolder, this);
		}
		protected function iconsLoaded(o:ToolButton):void {
			enabled = enabled;
			trackChanges = true;
			childChanged(this);
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