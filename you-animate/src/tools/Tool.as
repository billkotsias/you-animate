package tools
{
	import fanlib.event.ObjEvent;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import scene.Scene;

	public class Tool extends ToolButton implements ITool
	{  
		static public const SELECTED:String = "SELECTED";
		static public const DESELECTED:String = "DESELECTED";
		static public const CURRENT_SELECTED:Dictionary = new Dictionary(true);
		
		private var _selected:Boolean;
		
		public function Tool()
		{
			super();
			buttonMode = true;
			enabled = true;
		}
		
		override protected function mouseDown(e:MouseEvent):void {
			selected = true;
			dispatchMouseEvent(e, MOUSE_DOWN);
		}

		override public function set enabled(e:Boolean):void {
			_enabled = e;
			if (_enabled && !selected) {
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
				addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
				addEventListener(MouseEvent.ROLL_OVER, setStateOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
				state = (NORMAL);
				originalButtonMode = _buttonMode;
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
				removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
				removeEventListener(MouseEvent.ROLL_OVER, setStateOver);
				removeEventListener(MouseEvent.ROLL_OUT, rollOut);
				state = (!_enabled) ? DISABLED : DOWN;
				originalButtonMode = false;
			}
		}
		
		public function get selected():Boolean { return _selected }
		public function set selected(select:Boolean):void
		{
			// Bit of hack to put this here, but NO time to put it in EVERY place where the scene is changed!
			Scene.INSTANCE.isSaved = false;
			
			if (_selected === select) return; // fuck off
			_selected = select;
			enabled = _enabled;
			
			// deselect previously selected tool of same group
			var groupID:*;
			if (select) {
				for each (groupID in groups) {
					DeselectCurrent(groupID);
					CURRENT_SELECTED[groupID] = this;
				}
				const selectEvent:Event = new ObjEvent(this, SELECTED);
				dispatchEvent(selectEvent);
				dispatchGroupEvent(selectEvent);
			} else {
				for each (groupID in groups) {
					if (CURRENT_SELECTED[groupID] === this) delete CURRENT_SELECTED[groupID]; // none selected
				}
				dispatchEvent(new Event(DESELECTED));
			}
		}
		static public function DeselectCurrent(buttonGroup:*):void {
			const previous:ITool = CURRENT_SELECTED[buttonGroup];
			delete CURRENT_SELECTED[buttonGroup];
			if (previous) previous.selected = false;
		}
	}
}