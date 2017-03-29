package tools.selectChar
{
	import fanlib.event.Unlistener;
	import fanlib.ui.Keys;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.Node;
	
	import tools.Tool;
	
	public class DeleteSelected extends SelectCharContext
	{
		private var _contextTool:Tool;
		private var selectCharContextIsSelected:Boolean;
		
		public function DeleteSelected()
		{
			super();
		}
		
		public function get contextTool():Tool { return _contextTool }
		public function set contextTool(value:Tool):void
		{
			_contextTool = value;
			value.addEventListener(Tool.SELECTED, selectCharContextSelected);
			value.addEventListener(Tool.DESELECTED, selectCharContextDeselected);
		}

		private function selectCharContextSelected(e:Event):void {
			selectCharContextIsSelected = true;
			checkKeys();
		}
		private function selectCharContextDeselected(e:Event):void {
			selectCharContextIsSelected = false;
			checkKeys();
		}
		
		override public function set enabled(e:Boolean):void {
			super.enabled = e;
			checkKeys();
		}
		
		private function checkKeys():void {
			if (_enabled && selectCharContextIsSelected) {
				Walk3D.KEYS.listen(Keyboard.DELETE, deleteKey);
			} else {
				Walk3D.KEYS.unlisten(Keyboard.DELETE, deleteKey);
			}
		}

		private function deleteKey(e:KeyboardEvent):void {
			selected = true;
		}
		
		override public function set selected(select:Boolean):void {
			if (!select) return;
			const char:Character = _selectChar.selectedCharacter;
			
			var deleteCharacter:Boolean;
			
			// action selected?
			const selectedActionIndex:int = char.selectedActionIndex;
			if (selectedActionIndex >= 0) {
				char.selectedActionIndex = -1; // deselect Action
				deleteCharacter = char.deleteAction(char.getAction(selectedActionIndex), false);
				if (selectedActionIndex > 0) char.joinMoveActions(selectedActionIndex-1);
				
			} else {
				const selectedNodes:Vector.<Node> = char.selectedNodes;
				deleteCharacter = (selectedNodes.length == 0); // if no Nodes selected to delete, delete ALL >:-)
				if (!deleteCharacter) {
					for each (var node:Node in selectedNodes) {
						deleteCharacter = char.deleteNode(node);
					}
				}
			}
			
			if (deleteCharacter) {
				for each (var groupID:* in _selectChar.groups) {
					Tool.DeselectCurrent(groupID);
				}
				Scene.INSTANCE.removeCharacter(char);
				Scene.INSTANCE.history.addState( char.id, char.getNoState() ); // UNDO
				
			} else {
				char.setTime(char.getDuration());
				Scene.INSTANCE.history.addState( char.id, char.getHistoryState() ); // UNDO
			}
		}
		
	}
}