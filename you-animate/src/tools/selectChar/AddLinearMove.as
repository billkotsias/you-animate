package tools.selectChar
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.AbstractMoveAction;
	import scene.action.ActionInfo;
	import scene.action.BNode;
	import scene.action.LinearMove;
	import scene.action.Node;
	import scene.sobjects.SObject;
	
	import tools.Tool;
	
	public class AddLinearMove extends SelectCharContext
	{
		static public const MOVE_DEFAULT_ID:String = "walk";
		/**
		 * Sets whether Move Actions are added at the front or the rear of the Character's path
		 */
		public var expandHead:Boolean;
		public var viewportHitArea:FSprite;
		
		protected var mouseCollision:MouseCollision;
		private var collisions:Vector.<CollisionInfo>;
		
		protected const lastMoveID:Dictionary = new Dictionary(true);
		protected var currentAction:AbstractMoveAction;
		protected var currentNode:Node;
		protected var currentSobject:SObject;
		
		protected var unlistener:Unlistener = new Unlistener();
		
		/**
		 * NOTE : 'currentNode', 'expandHead' not implemented!!!
		 */
		public function AddLinearMove()
		{
			super();
		}
		
		public function addMove(moveID:String = null):void {
			const char:Character = _selectChar.selectedCharacter;
			const actionInfo:ActionInfo = char.getValidMoveActionInfo( moveID );
			if (actionInfo) lastMoveID[ char ] = actionInfo.id;
			selected = true;
		}
		
		override protected function charSelected(e:Event = null):void {
			if (_selectChar.selectedCharacter.info.moves.length > 0)
				super.charSelected(e);
			else
				charDeselected(e); // :-P
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			selected2();
		}
		
		//
		
		protected function selected2():void {
			// TODO: THIS IS ALL VERY OLD, WON'T WORK, MUST BE UPDATED.
			var char:Character = _selectChar.selectedCharacter;
			if (selected) {
				const node0:Node = char.getLastActionNode();
				if (!node0.actionsNum) (node0 as BNode).hideCtrlNodes = true;
				
				const node1:BNode = char.newNode(node0.getPosition()) as BNode;
				node1.sobject = node0.sobject;
				node1.hideCtrlNodes = true;
				
				currentAction = char.addLinearMove(lastMoveID[char], node0, node1);
				char.selectNode(node0);
				
				// mouse collision
				mouseCollision = new MouseCollision();
				Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); });
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
//				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown);
			} else {
				char.deselectNodes();
				if (currentAction.nodesNum) {
					char.deleteNode(currentAction.getLastNode());
					char.setTime(currentAction.getTimeOffset() + currentAction.duration);
				} else {
					char.setTime(0);
				}
				unlistener.removeAll();
				mouseCollision = null;
			}
		}
		
		protected function closePath(e:Event = null):void {
			if (_selectChar) _selectChar.selected = true;
		}
		
		protected function mVPortMove(e:MouseEvent):void {
			if (currentAction.nodesNum == 0) {
				selected = false;
				selected = true;
				return;
			}
			if (mouseCollision.test(e.stageX, e.stageY, true, true)) {
				var colInfo:CollisionInfo = mouseCollision.data[0];
				var char:Character = _selectChar.selectedCharacter;
				var node:Node = currentAction.getLastNode();
				node.setPosition(colInfo.point);
				char.setTime(currentAction.getTimeOffset() + currentAction.duration);
			}
		}
		private function mVPortDown(e:MouseEvent):void {
			if (currentAction.nodesNum == 0) {
				selected = false;
				selected = true;
				return;
			}
			if (mouseCollision.test(e.stageX, e.stageY, true, true)) {
				var colInfo:CollisionInfo = mouseCollision.data[0];
				var char:Character = _selectChar.selectedCharacter;
				var lastNode:Node = currentAction.getLastNode();
				char.selectNode(lastNode);
				
				var newNode:BNode = char.newNode(colInfo.point) as BNode;
				newNode.sobject = lastNode.sobject;
				newNode.hideCtrlNodes = true;
				currentAction.pushNode( newNode );
			}
		}

	}
}