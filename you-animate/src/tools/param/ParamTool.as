package tools.param
{
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Gfx;
	import fanlib.text.FTextField;
	
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.getQualifiedClassName;
	
	import scene.Character;
	import scene.action.Action;
	import scene.action.ActionManager;
	
	import tools.CheckButtonTool;
	import tools.selectChar.SelectChar;
	
	import ui.BasicWindow;
	import ui.LabelInput;
	
	public class ParamTool extends CheckButtonTool
	{
		protected var _selectChar:SelectChar;
		private var selectedCharacter:Character;
		
		private var _paramWindows:FSprite;
		
		public function ParamTool()
		{
			super();
		}
		
		public function get paramWindows():FSprite { return _paramWindows }
		public function set paramWindows(value:FSprite):void
		{
			_paramWindows = value;
			checkWindowsVisible();
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			checkWindowsVisible();
		}
		
		public function checkWindowsVisible():void {
			if (paramWindows) paramWindows.visible = selected && enabled;
		}
		
		// TODO : Create "ParamActionTool" extends "ParamTool"...
		
		public function get selectChar():SelectChar { return _selectChar }
		public function set selectChar(value:SelectChar):void
		{
			_selectChar = value;
			_selectChar.addEventListener(SelectChar.CHAR_SELECTED, charSelected, false, 0, true);
			_selectChar.addEventListener(SelectChar.CHAR_DESELECTED, charDeselected, false, 0, true);
		}
		
		private function charSelected(e:Event = null):void {
			selectedCharacter = _selectChar.selectedCharacter;
			selectedCharacter.addEventListener(ActionManager.ACTION_SELECTION, actionSelection, false, 0, true);
			actionSelection();
		}
		private function charDeselected(e:Event = null):void {
			selectedCharacter.removeEventListener(ActionManager.ACTION_SELECTION, actionSelection);
			enabled = false;
			checkWindowsVisible();
		}
		
		private function actionSelection(e:Event = null):void {
			if (selectedCharacter.selectedActionIndex >= 0) {
				enabled = true;
				
				const action:Action = selectedCharacter.getAction(selectedCharacter.selectedActionIndex);
				const window:ParamWindow = ParamWindow.GetWindow(action.params);
				window.iParamObj = action;
				paramWindows.addChild(window); // NOTE : in case it's new!
				Gfx.OneChildVisible(paramWindows, window);
				
			} else {
				enabled = false;
			}
			
			checkWindowsVisible();
		}
	}
}