package tools.selectChar
{
	import fanlib.gfx.Stg;
	
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.ActionInfo;
	import scene.action.BNode;
	import scene.action.BezierMove;
	import scene.action.Node;
	import scene.sobjects.SObject;

	public class AddBezierMove extends AddLinearMove
	{
		public function AddBezierMove()
		{
			super();
		}
		
		override protected function selected2():void {
			var char:Character = _selectChar.selectedCharacter;
			if (selected) {
				
				// 1st of all, check that move Actions do exist
				var moveID:String = lastMoveID[ char ];
				if (moveID === null) moveID = MOVE_DEFAULT_ID;
				const actionInfo:ActionInfo = char.getValidMoveActionInfo(moveID);
				if (!actionInfo) {
					selected = false; // what happened?!
					return;
				}
				moveID = actionInfo.id;
				
				var node0:BNode,
					node1:BNode;
				if (expandHead) {
					node1 = char.getFirstActionNode() as BNode;
					currentSobject = node1.sobject;
					
					node0 = char.newNode(node1.getPosition()) as BNode;
					node0.sobject = currentSobject;
					node1.hideCtrlNodes = false;
					char.selectNode(node1);
					currentNode = node0;
				} else {
					node0 = char.getLastActionNode() as BNode;
					currentSobject = node0.sobject;
					
					node1 = char.newNode(node0.getPosition()) as BNode;
					node1.sobject = currentSobject;
					node0.hideCtrlNodes = false;
					char.selectNode(node0);
					currentNode = node1;
				}
				
				const newActionIndex:int = (expandHead) ? 0 : char.getActionNum();
				currentAction = char.addBezierMove(actionInfo, node0, node1, newActionIndex);
				
				// mouse collision
				mouseCollision = new MouseCollision();
				// TODO : this is wrong. We must check for 'currentSobject' collision PLUS currentSobject+other intersecting SObjects (intersection-only areas)
				// When touching an intersection area, then the character is allowed to change 'currentSobject' with intersecting!
				Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); });
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_OUT, mVPortOut);
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown);
				unlistener.addListener(viewportHitArea, MouseEvent.RIGHT_MOUSE_DOWN, closePath);
				Walk3D.KEYS.listen(Keyboard.ENTER, closePath, this);
				// DEBUG
//				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_UP, mVPortUp);
//				unlistener.addListener(viewportHitArea, MouseEvent.CLICK, mVPortClick);
				
			} else {
				
				char.deselectNodes();
				if (currentAction.nodesNum) {
					if (currentNode) char.deleteNode(currentNode);
					if (expandHead) {
						char.joinMoveActions(0);
						char.setTime(0);
					} else {
						const setTimeTo:Number = currentAction.getTimeOffset() + currentAction.duration;
						char.joinMoveActions(char.getActionNum()-2);
						char.setTime(setTimeTo);
					}
				} else {
					char.setTime(0);
				}
				
				unlistener.removeAll();
				Walk3D.KEYS.unlistenGroup(this);
				mouseCollision = null;
			}
		}
		
		override protected function mVPortMove(e:MouseEvent):void {
			if (currentAction.nodesNum == 0) { // in case point was deleted
				selected = false;
				selected = true;
				return;
			}
			
			if (mouseCollision.test(e.stageX, e.stageY, true, true)) {
				
				const colInfo:CollisionInfo = mouseCollision.data[0];
				if (!currentNode) {
					insertNewNode(colInfo.point);
				} else {
					currentNode.setPosition(colInfo.point);
				}
				
				const char:Character = _selectChar.selectedCharacter;
				var affectPreviousNode:Boolean = (currentAction.nodesNum === 2);
				if (expandHead) {
					BNode.AlignControls(currentAction.getNodeByIndex(1) as BNode, currentNode as BNode, affectPreviousNode, true);
					char.setTime(0);
				} else {
					BNode.AlignControls(currentNode as BNode, currentAction.getNodeByReverseIndex(1) as BNode, true, affectPreviousNode);
					char.setTime(currentAction.getTimeOffset() + currentAction.duration);
				}
				
			}
		}
		private function mVPortClick(e:MouseEvent):void {
//			trace(getTimer(),new Error().getStackTrace());
		}
		private function mVPortUp(e:MouseEvent):void {
//			trace(getTimer(),new Error().getStackTrace());
		}
		
		private function mVPortDown(e:MouseEvent):void {
//			trace(getTimer(),new Error().getStackTrace());
			if (currentAction.nodesNum == 0) {
				selected = false;
				selected = true;
				return;
			}
			if (mouseCollision.test(e.stageX, e.stageY, true, true)) {
				const char:Character = _selectChar.selectedCharacter;
				Scene.INSTANCE.history.addState(char.id, char.getHistoryState()); // UNDO
				var colInfo:CollisionInfo = mouseCollision.data[0];
				insertNewNode(colInfo.point);
			}
		}
		
		private function mVPortOut(e:MouseEvent):void {
			if (currentNode) {
				const char:Character = _selectChar.selectedCharacter;
				char.deleteNode(currentNode);
				currentNode = null;
				if (expandHead) {
					char.setTime(0);
				} else {
					char.setTime(currentAction.getTimeOffset() + currentAction.duration);
				}
			}
		}
		
		private function insertNewNode(pos:Vector3D):Node {
			var char:Character = _selectChar.selectedCharacter;
			var newNode:BNode = char.newNode(pos) as BNode;
			if (expandHead) {
				currentAction.unshiftNode( newNode );
			} else {
				currentAction.pushNode( newNode );
			}
			newNode.sobject = currentSobject;
			
			if (currentNode) char.selectNode(currentNode);
			currentNode = newNode;
			
			return newNode;
		}
	}
}