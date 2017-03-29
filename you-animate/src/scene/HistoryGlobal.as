package scene
{
	import fanlib.event.ObjEvent;
	import fanlib.utils.Utils;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class HistoryGlobal extends EventDispatcher
	{
		static public const UNDO_AVAILABLE:String = "UNDO_AVAILABLE";
		static public const REDO_AVAILABLE:String = "REDO_AVAILABLE";
		
		private const idToHSList:Dictionary = new Dictionary(true);
		
		private var levels:uint;
		private const history:Vector.<HistoryStateList> = new Vector.<HistoryStateList>();
		private var position:int = -1;
		
		public function HistoryGlobal(levels:uint)
		{
			this.levels = levels;
		}
		
		public function hasStateList(stateObjectID:*):Boolean {
			return idToHSList[stateObjectID];
		}
		
		public function newStateList(stateObjectID:*, state:HistoryState):void {
			const hslist:HistoryStateList = idToHSList[stateObjectID] = new HistoryStateList();
			hslist.addState(state);
		}
		
		public function addState(stateObjectID:*, state:HistoryState):void {
			const hslist:HistoryStateList = idToHSList[stateObjectID];
			if (!hslist) return;
			hslist.addState(state);
			
			if (position === levels) {
				history.shift().shift(); // shift 1st list too, for RAM reasons only really (and looks beautiful)
			} else {
				++position;
				history.length = position; // destroy any "redo" levels
			}
			history[position] = hslist;
			dispatchAvailability();
		}
		
		public function undo():void {
//			trace(this,"--undo",position);
			if (position >= 0) {
//				trace(history[position-1],history[position-1].position);
				history[position--].undo();
				dispatchAvailability();
			}
//			trace(this,"undo--",position);
		}
		
		public function redo():void {
//			trace(this,"--redo",position);
			if (position < history.length-1) {
				history[++position].redo();
				dispatchAvailability();
			}
//			trace(this,"redo--",position);
		}
		
		public function reset():void {
			position = -1;
			history.length = 0;
			Utils.Clear(idToHSList);
			dispatchAvailability();
		}
		
		public function dispatchAvailability():void {
			dispatchEvent(new ObjEvent(position >= 0, UNDO_AVAILABLE));
			dispatchEvent(new ObjEvent(position < history.length-1, REDO_AVAILABLE));
		}
	}
}