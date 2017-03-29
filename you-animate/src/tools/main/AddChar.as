package tools.main
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	
	import flash.events.MouseEvent;
	
	import scene.CharManager;
	import scene.Character;
	import scene.CharacterInfo;
	import scene.HistoryState;
	import scene.Scene;
	import scene.action.BNode;
	import scene.action.Node;
	import scene.sobjects.SObject;
	
	import tools.Tool;
	import tools.selectChar.AddLinearMove;
	import tools.selectChar.SelectChar;
	
	import ui.addChar.GridItem;

	public class AddChar extends Tool
	{
		public var viewportHitArea:FSprite;
		public var selectCharContext:Tool;
		public var selectChar:SelectChar;
		public var addMoveAction:AddLinearMove;
		
		private const unlistener:Unlistener = new Unlistener();
		
		private var mouseCollision:MouseCollision;
		private var char:Character;
		
		public function AddChar()
		{
			super();
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			
			if (selected) {
				// ContextWindow automagically opened
			} else {
				unlistener.removeAll();
				mouseCollision = null;
				if (char) {
					Scene.INSTANCE.history.newStateList(char.id, char.getNoState());
					Scene.INSTANCE.history.addState(char.id, char.getHistoryState()); // UNDO
				}
			}
		}
		
		public function addByInfo(info:CharacterInfo):void {
			char = Scene.INSTANCE.addCharacter(info); // Player
			const initNode:BNode = char.newNode(char.charPivot.getPosition(false)) as BNode; // typical, 'AddChar' handles initial positioning
			
			// NOTE : is necessary? If hidden and no other point added, it's impossible to rotate the character!
//			initNode.hideCtrlNodes = true;
			
			// mouse collision
			mouseCollision = new MouseCollision();
			Scene.INSTANCE.sobjects.forEach( function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); } );
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown);
		}
		
		private function mVPortMove(e:MouseEvent):void {
			if (mouseCollision.test(e.stageX, e.stageY, true, true, false)) {
				var colInfo:CollisionInfo = mouseCollision.data[0];
				var charNode:Node = char.getLastActionNode();
				charNode.sobject = SObject.GetFromMesh(colInfo.mesh);
				charNode.setPosition(colInfo.point);
				char.setTime(0);
			}
		}
		private function mVPortDown(e:MouseEvent = null):void {
			selected = false;
			selectCharContext.selected = true;
			selectChar.selectedCharacter = char;
			if (addMoveAction.enabled) addMoveAction.selected = true;
			char = null;
		}
	}
}