package upload.buttons
{
	import fanlib.ui.FButton2;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import ui.BasicWindow;
	import ui.ButtonText;
	
	/**
	 * NOTE : Contains code that handles the MiscParams Window!!!
	 * @author BillWork
	 */
	public class MiscParams extends ButtonText
	{
		public var miscParamsWindow:BasicWindow;
		
		public function MiscParams()
		{
			super();
			addEventListener(FButton2.CLICKED, clicked);
		}
		
		private function clicked(e:MouseEvent):void {
			enabled = false;
			miscParamsWindow.visible = true;
			(miscParamsWindow.findChild("closeBut") as Sprite).addEventListener(MouseEvent.MOUSE_DOWN, close); 
		}
		
		private function close(e:MouseEvent):void {
			miscParamsWindow.visible = false;
			enabled = true;
		}
	}
}