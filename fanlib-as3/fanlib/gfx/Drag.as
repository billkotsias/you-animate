package fanlib.gfx
{
	import fanlib.event.Unlistener;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Drag
	{
		static public const DEFAULT_STAGE_STOP_EVENTS:Array = [ MouseEvent.MOUSE_UP, MouseEvent.RELEASE_OUTSIDE ];
		static public const RIGHT_STAGE_STOP_EVENTS:Array = [ MouseEvent.RIGHT_MOUSE_UP, Event.MOUSE_LEAVE ];
		
		protected var stg:Stage;
		
		protected var unlistener:Unlistener = new Unlistener();
		public var forceMouseLeave:Boolean;
		
		public function Drag(stopDragEvents:Array = null, forceMouseLeave:Boolean = true)
		{
			if (!stopDragEvents) stopDragEvents = DEFAULT_STAGE_STOP_EVENTS;
			this.forceMouseLeave = forceMouseLeave;
			
			stg = Stg.Get();
			unlistener.addListener(stg, MouseEvent.MOUSE_MOVE, mouseMove);
			
			for each (var eventName:String in stopDragEvents) {
				unlistener.addListener(stg, eventName, stopDrag);
			}
		}
		
		/**
		 * @param e
		 * @return <b>false</b>: The mouse is out of bounds so drag has stopped (<i>forceMouseLeave === true</i>)
		 */
		protected function mouseMove(e:MouseEvent):Boolean {
			if (forceMouseLeave && (
				stg.mouseX <= 0 ||
				stg.mouseY <= 0 ||
				stg.mouseX >= stg.stageWidth ||
				stg.mouseY >= stg.stageHeight)) {
				stopDrag();
				return false;
			}
			return true;
		}
		
		public function stopDrag(e:* = undefined):void {
			unlistener.removeAll();
			unlistener = null;
			stg = null;
		}
	}
}