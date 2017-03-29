package ui
{
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.ui.IToolTip;
	import fanlib.ui.Tooltip;
	import fanlib.utils.IInit;
	
	import flash.events.Event;
	
	public class LabeledUI extends FSprite implements IInit, IToolTip
	{
		static public const CHANGE:String = "labeledChange";
		
		static public const LABEL_NAME:String = "label";
		private var _label:FTextField;
		
		protected var _tip:String;
		protected var _toolTipName:String;
		
		public function LabeledUI()
		{
			super();
		}
		
		public function initLast():void {
			if (!_label) _label = findChild(LABEL_NAME);
		}
		
		public function get label():String { return _label.text }
		public function set label(txt:String):void { _label.htmlText = txt }
		
		override public function copy(baseClass:Class = null):* {
			const lui:LabeledUI = super.copy(baseClass);
			lui.initLast();
			return lui;
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