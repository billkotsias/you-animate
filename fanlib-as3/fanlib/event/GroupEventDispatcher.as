package fanlib.event
{
	import fanlib.containers.List;
	import fanlib.gfx.TSprite;
	import fanlib.utils.FArray;
	import fanlib.utils.Utils;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class GroupEventDispatcher extends TSprite
	{
		static private const GROUP_EVENTS:Dictionary = new Dictionary(true);
		static public function GroupEvents(uniqueID:*):EventDispatcher {
			return Utils.GetGuaranteed(GROUP_EVENTS, uniqueID, EventDispatcher);
		}
		
		static private const GROUP_BUTTONS:Dictionary = new Dictionary(true);
		static internal function GroupButtons(uniqueID:*):Dictionary {
			return Utils.GetGuaranteedByFunction(GROUP_BUTTONS, uniqueID, Utils.DynamicConstructor, Dictionary, [true]);
		}
		
		static public function GetByValueIn(group:*, valName:String, val:*):GroupEventDispatcher {
			return FArray.FindByValue(GroupButtons(group), valName, val);
		}
		
		static public function GetByClassIn(group:*, cl:Class):GroupEventDispatcher {
			for each (var ged:GroupEventDispatcher in GroupButtons(group)) {
				if (ged is cl) return ged;
			}
			return null;
		}
		
		private const currentGroups:List = new List();
		
		public function GroupEventDispatcher()
		{
			super();
		}
		
		public function dispatchGroupEvent(e:Event):void {
			currentGroups.forEach(function(groupID:*):void {
				GroupEvents(groupID).dispatchEvent(e);
			});
		}
		
		public function set ungroup(groupID:*):void {
			currentGroups.remove(groupID);
			delete GroupButtons(groupID)[this];
		}
		/**
		 * <b>Add</b> this to groups
		 * @param groupID
		 */
		public function set group(groupID:*):void {
			currentGroups.push(groupID);
			GroupButtons(groupID)[this] = this;
		}
		/**
		 * <b>Add</b> properties of a <b>container</b> to groups
		 * @param groupIDs Container
		 */
		public function set groups(groupIDs:*):void {
			if (groupIDs is String) groupIDs = [groupIDs];
			for each (var groupID:* in groupIDs) {
				group = groupID;
			}
		}
		public function get groups():Array { return currentGroups.toArray() }
		
		override public function copy(baseClass:Class = null):* {
			var obj:GroupEventDispatcher = super.copy(baseClass);
			currentGroups.forEach(function(groupID:*):void {
				obj.group = groupID;
			});
			return obj;
		}
	}
}