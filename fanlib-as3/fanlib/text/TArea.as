package fanlib.text {
	
	import fl.controls.TextArea;
	
	public class TArea extends TextArea implements ITextComponent {
		
		private var focusMan:FocusMan;

		public function TArea() {
			setStyle("focusRectSkin", TInput.EmptySkin);
		}
		
		public function set size(arr:Array):void {
			setSize(arr[0], arr[1]);
		}
		
		public function set focusGroup(name:String):void {
			focusMan = FocusMan.AddFocusable(name, this);
		}

	}
	
}
