package ui.list
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.TouchWindow;
	import fanlib.text.FTextField;
	import fanlib.ui.CheckButton;
	import fanlib.ui.TouchMenu;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import scene.Character;
	import scene.Crowd;
	import scene.ISObject;
	import scene.Scene;
	import scene.serialize.CharsSerializer;
	
	import tools.selectChar.SelectChar;
	
	import ui.CharContext;
	import ui.addChar.AddCrowdWindow;
	import ui.addChar.CrowdEditor;

	public class ListObjects extends CharContext
	{
		static public const BUTTON_VISIBLE_NAME:String = "buttonVisible";
		static public const TEXT_NAME:String = "txt";
		
		public var spaceY:Number;
		private var _addCrowdWindow:AddCrowdWindow;
		
		private const displayToISObject:Dictionary = new Dictionary(true);
		private var objIndex:int;
		private var selectedListObjectText:FTextField;
		
		public function ListObjects()
		{
			super();
			Scene.INSTANCE.addEventListener(Scene.SCENE_OBJECTS_CHANGED, update);
			CharsSerializer.EVENTS.addEventListener(CharsSerializer.CHAR_DESERIALIZED, update);
			addEventListener(TouchMenu.CHILD_SELECTED, textClicked, false, 0, true);
		}
		
		public function update(e:* = undefined):void {
			// count entries
			var sceneObjNum:uint = Scene.INSTANCE.characters.length + Scene.INSTANCE.crowds.length + Scene.INSTANCE.sobjects.length;
			Scene.INSTANCE.characters.forEach(function setCharacter(char:Character):void {
				if (char.crowdID) --sceneObjNum;
			});
			
			// make enough children for every scene object
			var cont:FSprite;
			while (sceneObjNum > numChildren) {
				cont = addChild(FSprite.FromTemplate("listObjectsTemp")) as FSprite;
				cont.getChildByName(BUTTON_VISIBLE_NAME).addEventListener(CheckButton.CHANGE, butVisChange, false, 0, true);
			}
			while (sceneObjNum < numChildren) {
				cont = removeChildAt(numChildren-1) as FSprite;
				cont.getChildByName(BUTTON_VISIBLE_NAME).removeEventListener(CheckButton.CHANGE, butVisChange);
				delete displayToISObject[cont];
			}
			
			// + characters
			objIndex = 0;
			Scene.INSTANCE.characters.forEach(function(char:Character):void {
				if (!char.crowdID) setObject(char);
			});
			
			// + crowds
			Scene.INSTANCE.crowds.forEach(setObject);
			
			// + rest
			Scene.INSTANCE.sobjects.forEach(setObject);
		}
		private function setObject(obj:ISObject):void {
			const cont:FSprite = getChildAt(objIndex) as FSprite;
			cont.y = objIndex * spaceY;
			(cont.getChildByName(TEXT_NAME) as FTextField).htmlText = obj.name;
			(cont.getChildByName(BUTTON_VISIBLE_NAME) as CheckButton).state = obj.visible;
			displayToISObject[cont] = obj;
			++objIndex;
		}
		
		private function textClicked(e:ObjEvent):void {
			const txt:FTextField = e.getObj() as FTextField;
			if (!txt) return;
			const isobj:ISObject = displayToISObject[txt.parent];
			if (isobj is Character)
			{
				_selectChar.selectedCharacter = isobj as Character;
				
			} else if (isobj is Crowd)
			{
				_selectChar.selectedCharacter = null;
				_addCrowdWindow.crowdSelected(isobj as Crowd);
				charSelected();
			}
		}
		
		private function butVisChange(e:Event):void {
			const but:CheckButton = e.currentTarget as CheckButton;
			(displayToISObject[but.parent] as ISObject).visible = but.state;
		}
		
		//
		
		override protected function charSelected(e:Event = null):void {
			const selectedCrowd:Crowd = _addCrowdWindow.getSelectedCrowd();
			charDeselected();
			
			const charOrCrowd:ISObject = _selectChar.selectedCharacter || selectedCrowd;
			if (charOrCrowd is Crowd) _addCrowdWindow.crowdSelected(charOrCrowd as Crowd); // reselect shit
			
			for (var obj:* in displayToISObject) {
				if (displayToISObject[obj] === charOrCrowd) {
					selectedListObjectText = ((obj as FSprite).getChildByName(TEXT_NAME) as FTextField);
					selectedListObjectText.background = true;
					break;
				}
			}
		}
		override protected function charDeselected(e:Event = null):void {
			if ( selectedListObjectText )
			{
				if (displayToISObject[selectedListObjectText.parent] is Crowd) _addCrowdWindow.crowdUnselected(); // last selection was crowd?
				
				if (selectedListObjectText) {
					selectedListObjectText.background = false;
					selectedListObjectText = null;
				}
			}
		}

		public function set addCrowdWindow(value:AddCrowdWindow):void
		{
			_addCrowdWindow = value;
			_addCrowdWindow.addEventListener(CrowdEditor.NO_CURRENT_CROWD, function(e:Event):void {
				if ( selectedListObjectText && (displayToISObject[selectedListObjectText.parent] is Crowd) ) {
					selectedListObjectText.background = false;
					selectedListObjectText = null;
				}
			});
		}

	}
}