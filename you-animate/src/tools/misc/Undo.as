package tools.misc
{
	import fanlib.event.ObjEvent;
	import fanlib.ui.FButton2;
	import fanlib.utils.IInit;
	
	import flash.events.MouseEvent;
	
	import scene.HistoryGlobal;
	import scene.Scene;
	
	import tools.ToolButton;
	
	public class Undo extends ToolButton implements IInit
	{
		private var history:HistoryGlobal;
		
		public function Undo()
		{
			super();
			addEventListener(FButton2.MOUSE_DOWN, mDown);
		}
		
		public function initLast():void {
			history = Scene.INSTANCE.history;
			history.addEventListener(HistoryGlobal.UNDO_AVAILABLE, availability, false, 0, true);
			history.dispatchAvailability();
		}
		
		private function mDown(e:MouseEvent):void {
			history.undo();
		}
		
		private function availability(o:ObjEvent):void {
			if (o.getObj()) enabled = true; else enabled = false;
		}
	}
}