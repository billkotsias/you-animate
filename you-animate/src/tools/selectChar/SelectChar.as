package tools.selectChar
{
	import fanlib.event.ObjEvent;
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import scene.Character;
	import scene.Scene;
	import scene.action.Action;
	import scene.action.Node;
	import scene.action.NodeTouchInfo;
	import scene.serialize.CharsSerializer;
	import scene.sobjects.SObject;
	
	import tools.IContext;
	import tools.Tool;

	/**
	 * Selects character but also edits (selected chatacter's) path!
	 * @author The chosen one
	 */
	public class SelectChar extends Tool implements IContext
	{
		static public const CHAR_SELECTED:String = "CHAR_SELECTED";
		static public const CHAR_DESELECTED:String = "CHAR_DESELECTED";
		
		static public const COLOR_SELECT:uint = 0xffffffff;
		static public const COLOR_OVER:uint = 0xffff0000;
		
		private var overNode:NodeTouchInfo;
		private var overCharacter:Character;
		private var _selectedCharacter:Character;
		
		private var charCollision:MouseCollision;
		private var surfacesCollision:MouseCollision;
		private var collisions:Vector.<CollisionInfo>;
		
		private const unlistener:Unlistener = new Unlistener();
		private const unlistenerDrag:Unlistener = new Unlistener();
		
		private var _viewportHitArea:FSprite;
		
		private var characterRemovedID:String;
		
		public function SelectChar()
		{
			super();
			Scene.INSTANCE.addEventListener(Scene.TO_BE_CLEARED, sceneToBeCleared);
			Scene.INSTANCE.addEventListener(Scene.CHARACTER_TO_BE_REMOVED, characterToBeRemoved);
			Scene.INSTANCE.addEventListener(Scene.CHARACTER_REMOVED_BY_ID, characterRemovedByID);
			CharsSerializer.EVENTS.addEventListener(CharsSerializer.CHAR_DESERIALIZED, charDeserialized, false, 0, true);
		}
		
		public function contextSelected(context:Tool):void {
			selected = true;
			// TODO : check if only 1 character in Scene, and select it automatically!
			// Context tools will have the chance to listen for this, if I just call 'mVPortDown'..!
		}
		
		public function contextDeselected():void {
			selected = true; // deselect any other Tools of the same group
			selected = false; // noone is selected
		}
		
		override public function set selected(select:Boolean):void {
//			if (select === selected) return;
			super.selected = select;
			
			if (selected) {
				// mouse collision
				charCollision = new MouseCollision();
				Scene.INSTANCE.characters.forEach(function(char:Character):void {
					if (!char.crowdID) charCollision.addCollisionWith(char.collisionPivot);
				});
				unlistener.addListener(_viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
				unlistener.addListener(_viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown);
				
				// TODO : check if only 1 character in Scene, and select it automatically!
				// Context tools will have the chance to listen for this, if I just call 'mStgDown'..!
			} else {
				unlistener.removeAll();
				unlistenerDrag.removeAll();
				charCollision = null;
				surfacesCollision = null;
			}
		}
		
		private function mVPortMove(e:MouseEvent = null):void {
			// 2D Nodes
			if (_selectedCharacter) {
				const newOverNode:NodeTouchInfo = (e) ? _selectedCharacter.getNodeUnderPoint2D(root, e.stageX, e.stageY) : null;
				
				var oldNode:Node, newNode:Node;
				if (overNode) oldNode = overNode.node;
				if (newOverNode) newNode = newOverNode.node;
				
				if (oldNode !== newNode) {
					if (oldNode) oldNode.unhighlight();
					if (newNode) newNode.highlight();
				}
				overNode = newOverNode; // the "abstract node" (abNode) may have changed!
			}
			
			// 3D Characters
			var newOverCharacter:Character;
			if (!overNode && e && charCollision.test(e.stageX, e.stageY, true, false)) {
				collisions = charCollision.data;
				for (var i:int = 0; i < collisions.length; ++i) {
					newOverCharacter = Character.MeshToCharacter[collisions[i].mesh];
					if (newOverCharacter !== selectedCharacter) break;
					newOverCharacter = null;
				}
			}
			if (overCharacter !== newOverCharacter) {
				if (overCharacter) overCharacter.boundingBoxColor = 0;
				overCharacter = newOverCharacter;
				if (overCharacter) overCharacter.boundingBoxColor = COLOR_OVER;
			}
		}
		private function mVPortDown(e:MouseEvent = null):void {
			// 2D - select, drag & drop
			if (e && overNode) {
				const node:Node = overNode.node;
				_selectedCharacter.selectNode(node);
				const action:Action = node.getAction(0);
				if (action) _selectedCharacter.setTime(action.getTimeOffset() + action.getNodeTimeOffset(node));
				
				surfacesCollision = new MouseCollision();
				if (node.sobject) {
					surfacesCollision.addCollisionWith(node.sobject.pivot3D);
				} else {
					// no belonging sobject, try ALL
					Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { surfacesCollision.addCollisionWith(so.pivot3D); });
				}
				
				unlistener.removeListener(_viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
				unlistenerDrag.addListener(_viewportHitArea, MouseEvent.MOUSE_MOVE, dragPoint);
				unlistenerDrag.addListener(_viewportHitArea, MouseEvent.ROLL_OUT, stopDragPoint);
				unlistenerDrag.addListener(_viewportHitArea, MouseEvent.MOUSE_UP, stopDragPoint);
				return;
			}
			
			// 3D - deselect previous, if any
			if (_selectedCharacter !== overCharacter) {
				if (_selectedCharacter) {
					_selectedCharacter.boundingBoxColor = 0;
					_selectedCharacter.pathVisible = false;
					_selectedCharacter.deselectNodes();
					dispatchEvent(new Event(CHAR_DESELECTED));
				}
			}
			
			// - select new one, if any
			_selectedCharacter = overCharacter;
			if (_selectedCharacter) {
				// TODO: check for "selectedCharacter" in "collisions" and make "overCharacter" the next one in line!
				overCharacter = null;
				_selectedCharacter.boundingBoxColor = COLOR_SELECT;
				_selectedCharacter.pathVisible = true;
				dispatchEvent(new Event(CHAR_SELECTED));
			}
		}
		
		private function dragPoint(e:MouseEvent):void {
			if (surfacesCollision.test(e.stageX, e.stageY, true, true)) {
				var pos:Vector3D = surfacesCollision.data[0].point;
				overNode.abNode.setPosition(pos);
				var action:Action = overNode.node.getAction(0);
				if (action) {
					_selectedCharacter.setTime(action.getTimeOffset() + action.getNodeTimeOffset(overNode.node)*0.999);
				} else {
					_selectedCharacter.setTime(0);
				}
			}
		}
		private function stopDragPoint(e:MouseEvent = null):void {
			unlistenerDrag.removeAll();
			if (e) unlistener.addListener(_viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
		}
		
		//
		
		private function sceneToBeCleared(e:Event):void {
			selectedCharacter = null;
		}
		
		private function characterToBeRemoved(e:ObjEvent):void {
			const char:Character = e.getObj();
			
			if ( _selectedCharacter && _selectedCharacter === char ) {
				selectedCharacter = null;
				selected = true;
			}
		}
		
		// all shit below just to select an "undone" or "redone" character...
		private function characterRemovedByID(e:ObjEvent):void {
			characterRemovedID = e.getObj();
		}
		private function charDeserialized(e:ObjEvent):void {
			const char:Character = e.getObj();
			if (characterRemovedID === char.id) {
				selectedCharacter = char;
			}
			characterRemovedID = null;
		}
		
		//
		
		public function set selectedCharacter(char:Character):void {
			overCharacter = char;
			mVPortDown();
			overNode = null;
			mVPortMove();
		}
		public function get selectedCharacter():Character
		{
			return _selectedCharacter;
		}

		public function set viewportHitArea(value:FSprite):void
		{
			_viewportHitArea = value;
		}

	}
}