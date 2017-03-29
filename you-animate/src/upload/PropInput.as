package upload
{
	import fanlib.event.ObjEvent;
	import fanlib.text.FTextField;
	import fanlib.ui.FButton2;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import tools.ToolButton;
	
	import ui.BasicWindow;
	import ui.LabelInput;
	import ui.LabeledUI;
	
	public class PropInput extends LabelInput
	{
		public var propMan:PropMan;
		private var _propWindow:PropWindow;
		
		private var addPropBut:ToolButton;
		
		public function PropInput()
		{
			super();
		}
		
		override public function initLast():void {
			super.initLast();
//			if (_input) _input.addEventListener(FTextField.FINALIZED, checkInput, false, 10, true); // NOTE : redundant!
			if (!addPropBut) {
				addPropBut = findChild("addProp");
				if (addPropBut) addPropBut.addEventListener(FButton2.CLICKED, addPropClicked);
			}
		}
		
		public function set propWindow(value:PropWindow):void
		{
			_propWindow = value;
			_propWindow.addEventListener(PropWindow.CLOSE, propWindowClose);
		}
		
		private function addPropClicked(e:MouseEvent):void {
			addPropBut.enabled = false;
			_propWindow.open(input);
		}
		private function propWindowClose(e:ObjEvent):void {
			addPropBut.enabled = true;
			
			const data:* = e.getObj();
			if (data === undefined) return; // no change
			
			const objData:ObjData = data;
			const _classLI:LabelInput = parent.getChildByName("_class") as LabelInput;
			const speedLI:LabelInput = parent.getChildByName("speed") as LabelInput;
			
			if (!objData) {
				input = "";
				_classLI.result = "";
				dispatchEvent(new Event(LabeledUI.CHANGE));
				return;
			}
			
			input = objData.id;// + " (" + objData.name + ")";
			
			// is vehicle?
			if (objData.data.type && objData.data.type === "vehicleData") {
				
				_classLI.result = "DriveAction";
				if (!Number(speedLI.result)) speedLI.result = "10"; // must have some speed, man!
				
			} else {
				
				// moving or not?
				const speed:Number = Number( speedLI.result );
				if (speed) {
					_classLI.result = "BezierPropMove";
				} else {
					_classLI.result = "FixedPropAction";
				}
				
			}
			
			propMan.propChanged(result);
			dispatchEvent(new Event(LabeledUI.CHANGE)); // register all changes
		}
		
//		override public function get result():* { return input }
//		override public function set result(t:*):void { input = (t === null) ? "" : t }
	}
}