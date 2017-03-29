package tools.selectChar
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	
	import flare.collisions.MouseCollision;
	
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.Action;
	import scene.action.Node;
	import scene.action.NodeTouchInfo;
	import scene.sobjects.SObject;

	public class NodeHeight extends SelectCharContext
	{
		private const unlistener:Unlistener = new Unlistener();
		private const unlistenerDrag:Unlistener = new Unlistener();
		
		private var overNode:NodeTouchInfo;
//		private var surfacesCollision:MouseCollision;
		
		public var viewportHitArea:FSprite;
		
		public function NodeHeight()
		{
			super();
		}
		
		override public function set selected(select:Boolean):void {
			if (select == selected) return;
			super.selected = select;
			
			if (selected) {
				// mouse collision
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown);
				
			} else {
				unlistener.removeAll();
				unlistenerDrag.removeAll();
//				surfacesCollision = null;
			}
		}
		
		private function mVPortMove(e:MouseEvent):void {
			const newOverNode:NodeTouchInfo = _selectChar.selectedCharacter.getNodeOffsetUnderPoint2D(root, e.stageX, e.stageY);
			
			var oldNode:Node, newNode:Node;
			if (overNode) oldNode = overNode.node;
			if (newOverNode) newNode = newOverNode.node;
			
			if (oldNode !== newNode) {
				if (oldNode) oldNode.unhighlight();
				if (newNode) newNode.highlight();
				overNode = newOverNode;
			}
		}
		
		private function mVPortDown(e:MouseEvent = null):void {
			// 2D - select, drag & drop
			if (overNode) {
				const node:Node = overNode.node;
				_selectChar.selectedCharacter.selectNode(node);
				const action:Action = node.getAction(0);
				if (action) _selectChar.selectedCharacter.setTime(action.getTimeOffset() + action.getNodeTimeOffset(node));
				
//				surfacesCollision = new MouseCollision();
//				// TODO : add xy-plane at Node position
//				surfacesCollision.addCollisionWith(node.sobject.pivot3D);
				
				unlistener.removeListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
				unlistenerDrag.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, dragPoint);
				unlistenerDrag.addListener(viewportHitArea, MouseEvent.ROLL_OUT, stopDragPoint);
				unlistenerDrag.addListener(viewportHitArea, MouseEvent.MOUSE_UP, stopDragPoint);
				return;
			}
		}
		
		private function dragPoint(e:MouseEvent):void {
			overNode.abNode.setOffsetPositionFrom2D(e.stageX, e.stageY);
			const action:Action = overNode.node.getAction(0);
			if (action) {
				_selectChar.selectedCharacter.setTime(action.getTimeOffset() + action.getNodeTimeOffset(overNode.node)*0.999);
			} else {
				_selectChar.selectedCharacter.setTime(0);
			}
		}
		private function stopDragPoint(e:MouseEvent = null):void {
			unlistenerDrag.removeAll();
			if (e) unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
		}
		
	}
}