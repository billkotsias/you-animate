package ui.addChar
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.text.FTextField;
	import fanlib.ui.FButton2;
	import fanlib.utils.IInit;
	
	import flash.events.Event;
	
	import scene.Character;
	import scene.CharacterInfo;
	import scene.Scene;
	import scene.action.Action;
	
	import tools.Tool;
	import tools.main.AddChar;
	import tools.selectChar.DeleteSelected;
	import tools.selectChar.SelectChar;
	
	import ui.ContextWindow;
	import ui.LabelCheck;
	
	public class AddCharWindow extends ContextWindow
	{
		static public const MSG_1:String = "The following Actions cannot be replaced:\n\n<bb>";
		static public const MSG_2:String = "</bb>\n\nProceed anyway?";
		
		public var replaceSelectedCharBut:LabelCheck;
		public var charGrid:AddCharGrid;
		public var selectChar:SelectChar;
		public var selectCharContext:Tool;
		public var deleteSelected:DeleteSelected;
		public var replaceConfirmCont:FSprite;
		
		private var defaultReplaceLabel:String;
		private var replaceFunction:Function;
		
		public function AddCharWindow()
		{
			super();
		}
		
		override protected function contextSelected(e:Event):void {
			super.contextSelected(e);
			
			// one-time run
			if (!defaultReplaceLabel) {
				defaultReplaceLabel = replaceSelectedCharBut.label;
				(replaceConfirmCont.findChild("ok") as FButton2).addEventListener(FButton2.CLICKED, replaceOkClicked);
				(replaceConfirmCont.findChild("cancel") as FButton2).addEventListener(FButton2.CLICKED, replaceCancelClicked);
			}
			
			charGrid.addEventListener(AddCharGrid.ITEM_SELECTED, gridItemSelected);
			
			replaceSelectedCharBut.state = false;
			if (selectChar.selectedCharacter) {
				replaceSelectedCharBut.label = defaultReplaceLabel + " (" + selectChar.selectedCharacter.name + ")";
				replaceSelectedCharBut.enabled = true;
			} else {
				replaceSelectedCharBut.label = defaultReplaceLabel;
				replaceSelectedCharBut.enabled = false;
			}
		}

		private function gridItemSelected(e:ObjEvent):void {
			const newInfo:CharacterInfo = e.getObj();
			if (replaceSelectedCharBut.state) {
				replaceSelected(newInfo);
			} else {
				(contextTool as AddChar).addByInfo(newInfo);
				visible = false;
			}
		}
		
		override protected function contextDeselected(e:Event):void {
			super.contextDeselected(e);
			charGrid.removeEventListener(AddCharGrid.ITEM_SELECTED, gridItemSelected);
		}
		
		// don't have time to split code into logical classes, so... here it is!
		private function replaceSelected(newInfo:CharacterInfo):void {
			const oldChar:Character = selectChar.selectedCharacter;
			
			replaceFunction = function():void {
				const newChar:Character = Scene.INSTANCE.addCharacter(newInfo); // Player
				newChar.copy(oldChar);
				
				// delete oldChar
				oldChar.deselectNodes();
				oldChar.selectedActionIndex = -1;
				deleteSelected.selected = true;
				
				// select new
				selectChar.selectedCharacter = newChar;
				selectCharContext.selected = true;
				newChar.setTime(0);
				
				// add new character's state
				Scene.INSTANCE.history.newStateList(newChar.id, newChar.getNoState());
				Scene.INSTANCE.history.addState(newChar.id, newChar.getHistoryState()); // UNDO
				
				visible = false;
			}
			
			const desimilar:Array = newInfo.compare(oldChar);
			if (desimilar.length) {
				var message:String = "";
				for each (var action:Action in desimilar) {
					message += action.id + ", ";
				}
				replaceConfirmCont.visible = true;
				(replaceConfirmCont.findChild("message") as FTextField).htmlText = MSG_1 + message.slice(0, -2) + MSG_2;
			} else {
				replaceFunction();
			}
		}
		
		private function replaceOkClicked(e:Event):void {
			replaceFunction();
			replaceCancelClicked(null); // Cancel after OK: neat but crazy
		}
		
		private function replaceCancelClicked(e:Event):void {
			replaceFunction = null;
			replaceConfirmCont.visible = false;
		}
	}
}