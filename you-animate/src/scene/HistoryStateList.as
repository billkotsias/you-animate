package scene
{
	import fanlib.event.ObjEvent;
	
	import flash.events.EventDispatcher;

	public class HistoryStateList extends EventDispatcher
	{
		private const history:Vector.<HistoryState> = new Vector.<HistoryState>;
		private var _position:int = -1;
		
		public function HistoryStateList() {
		}
		
		public function addState(state:HistoryState):void {
			++_position;
			history.length = _position; // destroy any "redo" levels
			history[_position] = state;
		}
		
		private function setState(state:HistoryState):void {
			state.build();
		}
		
		public function undo():void {
			setState(history[--_position]);
		}
		
		public function redo():void {
			setState(history[++_position]);
		}
		
		public function shift():void {
			--_position;
			history.shift();
		}

		public function get position():int { return _position }

	}
}