package scene.camera.anim
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.Distributor;
	import fanlib.text.FTextField;
	import fanlib.ui.FButton2;
	import fanlib.ui.numText.NumTextDrag;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	
	import scene.Scene;
	
	public class ZoomSpotUI extends AbstractZoomKeyUI
	{
		private const _inputs:Array = [];
		private const _buttons:Array = [];
		
		public function ZoomSpotUI() {
			super();
		}
		
		private function butClicked(e:Event):void {
			const but:FButton2 = e.currentTarget as FButton2;
			switch (but.name) {
				case "delete":
					userDeleted = true; // FOR UNDO CHECKING!!!
					Scene.INSTANCE.zoomMan.removeKey(_zoomKey);
					break;
			}
		}
		
		private function ntdUpdated(e:Event):void {
			const input:NumTextDrag = e.currentTarget as NumTextDrag;
//			trace(this,input.name, input.num);
			_zoomKey[input.name] = input.num;
			Scene.INSTANCE.zoomMan.update();
		}
		
		private function ntdUpdateEnd(e:Event):void {
			dispatchEvent(new ObjEvent(e.currentTarget, DRAG_END));
		}
		//
		
		public function set inputs(arr:Array):void {
			_inputs.push.apply(null, arr);
			for each (var inputName:String in _inputs) {
				const input:NumTextDrag = /*this[inputName] =*/ findChild(inputName);
				input.addEventListener(NumTextDrag.UPDATED, ntdUpdated, false, 0, true);
				input.addEventListener(NumTextDrag.DRAG_END, ntdUpdateEnd, false, 0, true);
			}
		}
		
		public function set buttons(_arr:*):void {
			const arr:Array = (_arr is Array) ? _arr : [_arr]; 
			_buttons.push.apply(null, arr);
			for each (var butName:String in _buttons) {
				const but:FButton2 = /*this[butName] =*/ findChild(butName);
				if (!but) {
//					trace(this,"button not found:",butName);
				} else {
					but.addEventListener(FButton2.CLICKED, butClicked, false, 0, true);
				}
			}
		}
		
		override public function set zoomKey(value:AbstractZoomKey):void
		{
			super.zoomKey = value;
			for each (var inputName:String in _inputs) {
				(getChildByName(inputName) as NumTextDrag).num = _zoomKey[inputName];
			}
		}
		
		override public function setTabIndices(tab:uint):uint {
			for each (var inputName:String in _inputs) {
				((getChildByName(inputName) as NumTextDrag).getChildByName("input") as InteractiveObject).tabIndex = tab++;
			}
			return tab;
		}
		
		override public function copy(baseClass:Class = null):* {
			const obj:ZoomSpotUI = super.copy(baseClass);
			obj.inputs = this._inputs;
			obj.buttons = this._buttons;
			return obj;
		}
	}
}