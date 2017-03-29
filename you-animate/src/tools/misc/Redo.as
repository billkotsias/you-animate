package tools.misc
{
	import fanlib.event.ObjEvent;
	import fanlib.ui.FButton2;
	import fanlib.utils.IInit;
	
	import flash.events.MouseEvent;
	
	import scene.HistoryGlobal;
	import scene.Scene;
	
	import tools.ToolButton;
	
	public class Redo extends ToolButton implements IInit
	{
		private var history:HistoryGlobal;
		
		public function Redo()
		{
			super();
			addEventListener(FButton2.MOUSE_DOWN, mDown);
		}
		
		public function initLast():void {
			history = Scene.INSTANCE.history;
			history.addEventListener(HistoryGlobal.REDO_AVAILABLE, availability, false, 0, true);
			history.dispatchAvailability();
		}
		
		private function mDown(e:MouseEvent):void {
			history.redo();
		}
		
		private function availability(o:ObjEvent):void {
			if (o.getObj()) enabled = true; else enabled = false;
		}
	}
}