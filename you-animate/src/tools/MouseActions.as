package tools
{
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;

	public class MouseActions
	{
		static public function ListenToTouchDrag(iobj:InteractiveObject, callback:Function, endCallback:Function = null):void {
			
			const removeActionListener:Function = function(e:MouseEvent):void {
				iobj.removeEventListener(MouseEvent.MOUSE_MOVE, callback);
				iobj.removeEventListener(MouseEvent.ROLL_OUT, removeActionListener);
				iobj.removeEventListener(MouseEvent.MOUSE_UP, removeActionListener);
				
				if (endCallback !== null) endCallback(e);
			}
			
			iobj.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				callback(e);
				iobj.addEventListener(MouseEvent.MOUSE_MOVE, callback);
				iobj.addEventListener(MouseEvent.ROLL_OUT, removeActionListener);
				iobj.addEventListener(MouseEvent.MOUSE_UP, removeActionListener);
			});
		}
	}
}