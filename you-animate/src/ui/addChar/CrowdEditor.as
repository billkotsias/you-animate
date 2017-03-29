package ui.addChar
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.math.Maths;
	
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import scene.Crowd;
	import scene.Scene;
	import scene.action.BNode;
	import scene.action.Node;
	import scene.action.NodeTouchInfo;
	import scene.sobjects.SObject;
	
	import tools.Tool;
	
	import ui.BasicWindow;
	

	public class CrowdEditor extends EventDispatcher
	{
		static public const CROWD_BUTTON_GROUP:String = "crowd";
		static public const NO_CURRENT_CROWD:String = "NO_CURRENT_CROWD";
		static public var INSTANCE:CrowdEditor;
		
		public var viewportHitArea:FSprite;
		
		private var window:AddCrowdWindow;
		private var editCrowdPathTool:Tool;
		private var expandCrowdPathTool:Tool;
		public var editParams:Boolean;
		
		private var _currentCrowd:Crowd;
		private var mouseCollision:MouseCollision;
		private var overNode:NodeTouchInfo;
		private var currentSobject:SObject;
		
		private const unlistener:Unlistener = new Unlistener();
		private const unlistenerDrag:Unlistener = new Unlistener();
		
		public function CrowdEditor(_window:AddCrowdWindow)
		{
			super();
			window = _window;
			INSTANCE = this;
		}
		
		public function setTools(ctools:BasicWindow):void {
			(ctools.findChild("editCrowdParams") as Tool).addEventListener(Tool.SELECTED, editCrowdParams);
			( (editCrowdPathTool = ctools.findChild("editCrowdPath")) as Tool).addEventListener(Tool.SELECTED, editCrowdPath);
			( (expandCrowdPathTool = ctools.findChild("expandCrowdPath")) as Tool).addEventListener(Tool.SELECTED, expandCrowdPath);
			(ctools.findChild("deleteCrowd") as Tool).addEventListener(Tool.SELECTED, deleteSomething);
		}
		
		public function editCrowdParams(e:Event):void {
			editParams = true;
			window.contextTool.selected = true;
			editParams = false;
			(e.currentTarget as Tool).selected = false;
		}
		
		static public function RandomizeOffsets(crowd:Crowd):void {
			const len:uint = crowd.getCharsNum();
			const offs:Vector.<Vector3D> = new Vector.<Vector3D>(len);
			for (var i:int = 0; i < len; ++i)
			{
				var dist:Number = Maths.random(Crowd.RADIUS_MIN, crowd.radius);
				var angle:Number = i / len * 2*Math.PI;
				offs[i] = new Vector3D( dist * Math.cos(angle), 0, dist * Math.sin(angle) );
			}
			crowd.setOffsets(offs);
		}
		
		public function createNew():void {
			const crowd:Crowd = currentCrowd = new Crowd();
			crowd.name = getNewCrowdName(); // 1ST!
			Scene.INSTANCE.addCrowd(crowd); // 2ND!
			
			UpdateCrowdFromWindow(crowd, window);
			expandCrowdPathTool.selected = true;
			
			Scene.INSTANCE.history.newStateList(currentCrowd.id, currentCrowd.getNoState());
		}
		public function getNewCrowdName():String {
			var maxIndex:uint = Scene.INSTANCE.crowds.length + 1;
			Scene.INSTANCE.crowds.forEach(function(crowd:Crowd):void {
				const index:uint = uint(crowd.name.slice( Crowd.CROWD_STR.length + 1 ));
				if (index >= maxIndex) maxIndex = index + 1;
			});
			const maxIndexStr:String = (maxIndex === 1) ? "" : String(maxIndex);
			return Crowd.CROWD_STR + maxIndexStr;
		}
		
		public function updateCurrent():void {
			UpdateCrowdFromWindow(currentCrowd, window);
			currentCrowd.update();
			currentCrowd.setTime();
			Scene.INSTANCE.history.addState(currentCrowd.id, currentCrowd.getHistoryState());
		}
		
		static public function UpdateCrowdFromWindow(crowd:Crowd, window:AddCrowdWindow):void {
			crowd.setChars( window.getCharNames() );
			crowd.radius = window.radius.result;
			crowd.speed = window.speed.result;
			crowd.setDirs( window.getDirs() );
			if (!crowd.offsets || crowd.offsets.length !== crowd.characters.length || window.rerandomize.state) RandomizeOffsets(crowd);
		}
		
		// editing
		
		// + delete
		public function deleteSomething(e:Event = null):void {
			endEditing();
			
			var selNodes:Vector.<Node>;
			var deleteCrowd:Boolean;
			if (currentCrowd && (selNodes = currentCrowd.selectedNodes).length)
			{
				for each (var node:Node in selNodes) {
					deleteCrowd = currentCrowd.deleteNode(node);
				}
			}
			
			if (deleteCrowd || !selNodes || !selNodes.length) {
				Scene.INSTANCE.history.addState(currentCrowd.id, currentCrowd.getNoState());
				Scene.INSTANCE.removeCrowd(currentCrowd);
				currentCrowd = null;
				dispatchEvent(new Event(NO_CURRENT_CROWD));
			} else {
				if (currentCrowd) currentCrowd.update();
				Scene.INSTANCE.history.addState(currentCrowd.id, currentCrowd.getHistoryState());
			}
			Tool.DeselectCurrent(CROWD_BUTTON_GROUP);
		}
		
		// + edit current path
		public function editCrowdPath(e:Event = null):void {
			endEditing();
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, editCrowdPathMove);
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, editCrowdPathDown);
		}
		public function editCrowdPathMove(e:MouseEvent):void {
			const newOverNode:NodeTouchInfo = (e) ? currentCrowd.getNodeUnderPoint2D(Stg.Get(), e.stageX, e.stageY) : null;
			
			var oldNode:Node, newNode:Node;
			if (overNode) oldNode = overNode.node;
			if (newOverNode) newNode = newOverNode.node;
			
			if (oldNode !== newNode) {
				if (oldNode) oldNode.unhighlight();
				if (newNode) newNode.highlight();
			}
			overNode = newOverNode; // the "abstract node" (abNode) may have changed!
		}
		public function editCrowdPathDown(e:MouseEvent):void {
			if (e && overNode) {
				const node:Node = overNode.node;
				currentCrowd.selectNode(node);
				
				mouseCollision = new MouseCollision();
				if (node.sobject) {
					mouseCollision.addCollisionWith(node.sobject.pivot3D);
				} else {
					// no belonging sobject, try ALL
					Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); });
				}
				
				unlistener.removeListener(viewportHitArea, MouseEvent.MOUSE_MOVE, editCrowdPathMove);
				unlistenerDrag.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, dragPoint);
				unlistenerDrag.addListener(viewportHitArea, MouseEvent.ROLL_OUT, stopDragPoint);
				unlistenerDrag.addListener(viewportHitArea, MouseEvent.MOUSE_UP, stopDragPoint);
			}
		}
		private function dragPoint(e:MouseEvent):void {
			if (mouseCollision.test(e.stageX, e.stageY, true, true)) {
				var pos:Vector3D = mouseCollision.data[0].point;
				overNode.abNode.setPosition(pos);
				currentCrowd.update();
				currentCrowd.setTime();
			}
		}
		private function stopDragPoint(e:MouseEvent = null):void {
			unlistenerDrag.removeAll();
			if (e) unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, editCrowdPathMove);
			Scene.INSTANCE.history.addState(currentCrowd.id, currentCrowd.getHistoryState());
		}
		
		// + add to path
		public function expandCrowdPath(e:Event):void {
			const lasty:Node = currentCrowd.getLastActionNode();
			const newNode:Node = currentCrowd.newNode();
			if (lasty) {
				newNode.setPosition(lasty.getPosition());
			} else {
				newNode.setPosition(new Vector3D(0, 0, 25 - Math.random() * 5));
			}
			
			endEditing();
			mouseCollision = new MouseCollision();
			Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); });
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, expandMove);
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, expandDown);
			unlistener.addListener(viewportHitArea, MouseEvent.RIGHT_MOUSE_DOWN, endExpandCrowdPath);
			Walk3D.KEYS.listen(Keyboard.ENTER, endExpandCrowdPath, this);
		}
		
		private function expandMove(e:MouseEvent):void {
			if (mouseCollision.test(e.stageX, e.stageY, true, true, false)) {
				var colInfo:CollisionInfo = mouseCollision.data[0];
				currentSobject = SObject.GetFromMesh(colInfo.mesh);
				
				const nodeLastIndex:uint = currentCrowd.getNodesNum() - 1;
				const nodeLast:BNode = currentCrowd.getNodeAt(nodeLastIndex) as BNode;
				nodeLast.sobject = currentSobject;
				nodeLast.setPosition( colInfo.point );
				
				if (nodeLastIndex >= 1) {
					const affectPreviousNode:Boolean = (nodeLastIndex === 1);
					BNode.AlignControls(nodeLast, currentCrowd.getNodeAt(nodeLastIndex - 1) as BNode, true, affectPreviousNode);
				}
				
				currentCrowd.update();
				currentCrowd.setTime(Infinity);
			}
		}
		
		private function expandDown(e:MouseEvent):void {
			if (!mouseCollision.data.length) return;
			Scene.INSTANCE.history.addState(currentCrowd.id, currentCrowd.getHistoryState());
			
			const newNode:BNode = currentCrowd.newNode() as BNode;
			newNode.setPosition( mouseCollision.data[0].point );
			newNode.sobject = currentSobject;
		}
		
		private function endExpandCrowdPath(e:Event):void {
			currentCrowd.deleteNode( currentCrowd.getLastActionNode() );
			Walk3D.KEYS.unlisten(Keyboard.ENTER, endExpandCrowdPath);
			Tool.DeselectCurrent(CROWD_BUTTON_GROUP);
			endEditing();
			editCrowdPathTool.selected = true;
		}
		
		//
		
		private function endEditing(e:Event = null):void {
			currentCrowd.update();
			currentCrowd.setTime(Infinity);
			
			unlistener.removeAll();
			unlistenerDrag.removeAll();
		}

		public function get currentCrowd():Crowd { return _currentCrowd }
		public function set currentCrowd(crowd:Crowd):void {
			if (_currentCrowd) _currentCrowd.pathVisible = false;
			
			_currentCrowd = crowd;
			if (_currentCrowd) {
				_currentCrowd.pathVisible = true;
			} else {
				unlistener.removeAll();
				unlistenerDrag.removeAll();
			}
		}

	}
}