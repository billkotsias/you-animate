package fanlib.ui
{
	import fanlib.event.GroupEventDispatcher;
	import fanlib.gfx.TSprite;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	// swaps between 1st and 2nd child; may have more, but doesn't care
	// will only work if it has at least 2 FButton2 children 
	public class CheckButton extends GroupEventDispatcher
	{
		static public const CHANGE:String = "CheckButtonChange";
		
		public var onButton:FButton2;
		public var offButton:FButton2;
		
		private var _enabled:Boolean;
		
		public function CheckButton()
		{
		}
		
		// by default, "on" is 1st 'FButton2' and "off" is 2nd 'FButton2'
		override public function addChild(d:DisplayObject):DisplayObject {
			if (d is FButton2) {
				d.addEventListener(FButton2.CLICKED, buttonClicked, false, 0, true);
				if (!onButton) {
					onButton = d as FButton2;
				} else if (!offButton) {
					offButton = d as FButton2;
				}
			}
			return super.addChild(d);
		}
		
		private function buttonClicked(e:MouseEvent):void {
			state = !state;
			dispatchEvent(new Event(CHANGE));
		}
		
		/**
		 * True if 1st child is visible. By convention, true = checked = on.
		 */
		public function get state():Boolean
		{
			return onButton.visible;
		}
		public function set state(s:Boolean):void {
			onButton.visible = s;
			offButton.visible = !s;
		}
		
		public function get enabled():Boolean { return _enabled; }
		public function set enabled(e:Boolean):void {
			_enabled = e;
			onButton.enabled = e;
			offButton.enabled = e;
		}
		
		// create copy : useful for templates
		override public function copy(baseClass:Class = null):* {
			var obj:CheckButton = super.copy(baseClass);
			obj.enabled = this.enabled;
			obj.state = this.state;
			
			return obj;
		}
	}
}