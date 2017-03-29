package scene.action
{
	import fanlib.containers.List;
	import fanlib.event.ObjEvent;
	import fanlib.event.PausableEventDispatcher;
	import fanlib.gfx.FSprite;
	import fanlib.utils.FArray;
	import fanlib.utils.Pair;
	
	import flare.core.Pivot3D;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.getQualifiedClassName;
	
	import scene.Character;

	public class ActionManager extends PausableEventDispatcher
	{
		static public const CHANGE:String = "AM_CHANGED";
		static public const DISPOSED:String = "DISPOSED";
		static public const ACTION_SELECTION:String = "ACTION_SELECTED";
		
		protected const actions:Vector.<Action> = new Vector.<Action>;
		protected const nodes:List = new List();
		
		protected const _nodesPivot:Pivot3D = new Pivot3D();
		protected const _nodes2D:FSprite = new FSprite();
		
		protected const _selectedNodes:Vector.<Node> = new Vector.<Node>;
		private var _selectedActionIndex:int = -1;
		
		private var _duration:Number = 0;
		
		public function ActionManager()
		{
			addEventListener(CHANGE, changed, false, 0, true);
		}
		
		internal function dispose(e:Event):void {
			removeEventListener(CHANGE, changed);
			actions.length = 0;
			nodes.clear(true);
			_selectedNodes.length = 0;
			
			dispatchEvent(new Event(DISPOSED));
		}
		
		/**
		 * Sum of all Actions' durations
		 */
		public function get duration():Number { return _duration }
		
		private function changed(e:Event):void {
			// update duration
			_duration = 0;
			for each (var action:Action in actions) {
				_duration += action.duration;
			}
		}
		
		public function insertAction(action:Action, index:int):void {
			if (index < 0) index = actions.length;
			
			actions.splice(index, 0, action);
			updateIndices(index, actions.length);
			
			for each (var node:Node in action.nodes) {
				nodes.push(node); // Node could already be inside
			}
			
			dispatchEvent(new ObjEvent(action, CHANGE));
		}
		protected function pushAction(action:Action):void {
			insertAction(action, actions.length);
		}
		protected function unshiftAction(action:Action):void {
			insertAction(action, 0);
		}
		
		/**
		 * Create a new Node
		 * @param initPos Global position.
		 * @param _class Default = BNode. Others: Node.
		 * @return The Node created.
		 */
		// TODO : Maybe bug will be fixed if "insertNode" or "unshiftNode" is frigging implemented
		public function newNode(initPos:Vector3D = null, _class:Class = null):Node {
			if (!_class) _class = BNode;
			var node:Node = new _class(_nodesPivot, _nodes2D);
			nodes.push(node);
			
			if (initPos) node.setPosition(initPos);
			return node;
		}
		
		public function splitMoveActionAtNode(node:Node):Array {
			const action:AbstractMoveAction = node.getAbstractMoveAction();
			if (!action) return null;
			return splitMoveActionAtIndex(action, action.nodes.indexOf(node));
		}
		/**
		 * @param action
		 * @param index Node's index IN ACTION at which to split!
		 * @return Array containing the 2 new Move Actions, or null if can't split
		 */
		public function splitMoveActionAtIndex(action:AbstractMoveAction, index:int):Array {
			const actionIndex:int = action.indexParentVector;
			const newActions:Array = action.splitAtIndex(index);
			if (!newActions) return null;
			
			eventsPauser.pause( splitMoveActionAtIndex );
			
			insertAction(newActions[0], actionIndex);
			insertAction(newActions[1], actionIndex+1);
			
			eventsPauser.unpause( splitMoveActionAtIndex );
			
			deleteAction(action, true); // may fire CHANGE event now
			
			return newActions;
		}
		
		/**
		 * Attempt to join 2 or more Move Actions in succeeding order.
		 * @param index Index of 1st Action, the second is at "index+1"
		 */
		public function joinMoveActions(index:int):void {
			if (index < 0) return;
			while (index < actions.length - 1) {
				const act1:AbstractMoveAction = actions[index] as AbstractMoveAction;
				const act2:AbstractMoveAction = actions[index+1] as AbstractMoveAction;
				if (!act1 || !act2) return;
				if (act1.id !== act2.id) return;
				
				const firstNode:Node = act2.nodes[0];
				if (act1.nodes[act1.nodes.length-1] !== firstNode) act1.pushNode(firstNode);
				for (var i:int = 1; i < act2.nodes.length; ++i) {
					act1.pushNode(act2.nodes[i]);
				}
				deleteAction(act2, true);
			}
		}
		
		public function getActionNum():uint { return actions.length; }
		
		public function getAction(index:int):Action {
			if (index < 0 || index >= actions.length) return null;
			return actions[index];
		}
		
		public function getLastAction():Action {
			return getAction(actions.length-1);
		}
		
		/**
		 * Call function for each <b>Action</b> that is of class <i>_class</i> 
		 * @param _class
		 * @param func
		 */
		public function forEachAction(_class:Class, func:Function):void {
			for (var i:int = actions.length - 1; i >= 0; --i) {
				var action:Object = actions[i] as _class;
				if (action) func(action);
			}
		}
		
		public function getLastActionNode():Node {
			if (actions.length) return actions[actions.length-1].getLastNode();
			if (nodes.length) return nodes.last; // in case no Action is around, return SOMETHING (a Node)
			return null;
		}
		
		public function getFirstActionNode():Node {
			if (actions.length) return actions[0].nodes[0];
			if (nodes.length) return nodes.getByIndex(0); // in case no Action is around, return SOMETHING (a Node)
			return null;
		}
		
		public function forEachNode(func:Function):void {
			nodes.forEach(func);
		}
		
		public function getNodesNum():uint { return nodes.length }
		public function getNodeAt(i:int):Node { return nodes.getByIndex(i) }
		
		/**
		 * Deletes a single-or-zero-Nodes Action immediately. Multi-Node Actions get their Nodes checked one by one and removed if non-multi-Action (WTF!).
		 * @param action Action to delete
		 * @param forceDelete Delete Action even if there is gonna be a gap in the Character's path
		 * @return True = No more Actions left in this ActionManager
		 */
		public function deleteAction(action:Action, forceDelete:Boolean = false):Boolean {
			var node:Node;
			
			var actionNodes:Vector.<Node> = action.nodes;
			if (actionNodes.length <= 1 || actions.length == 1 || forceDelete) {
				
				// DELETE Action
				action._dispose(); // must be called BEFORE removing any references as they are needed by the self-clean-up process!!!!!
				actions.splice(action.indexParentVector, 1);
				updateIndices(action.indexParentVector, actions.length);
				
				while (actionNodes.length) {
					node = actionNodes[actionNodes.length-1];
					action.removeNode(node); // cross-references removed
					if (node.actions.isEmpty() && nodes.length > 1) deleteNode(node); // don't delete empty Node if last!
				}
//				if (actionNodes.length == 1) {
//					node = actionNodes[0];
//					action.removeNode(node); // cross-references removed
//					if (node.actions.isEmpty() && nodes.length > 1) deleteNode(node); // don't delete empty Node if last!
//				}
				dispatchEvent(new ObjEvent(action, CHANGE));
				
			} else {
				// delete Nodes that contain only this Action
				var i:int = actionNodes.length - 1;
				while (i >= 0) {
					node = actionNodes[i];
					if (node.actions.length == 1)
						deleteNode(node);
					
					if (i >= actionNodes.length) // length may change in the meantime!
						i = actionNodes.length - 1;
					else
						--i;
				}
			}
			return actions.length === 0;
		}
		
		/**
		 * FixedActions on this Node get deleted.
		 * <p>If Node is the 1st of a double-Node Action, Action gets deleted.</p>
		 * <p>If Node is last of a multi-Node Action, it gets replaced with 1st Node of the Next Action in line.</p>
		 * @param node Node to delete
		 * @return True if no Nodes left, so ActionManager is "empty" (and should be deleted too)
		 */
		public function deleteNode(node:Node):Boolean {
			nodes.remove(node); // DELETE Node from this 'ActionManager'
			
			// remove misc references
			FArray.Remove(_selectedNodes, node, true);
			
			const actionsWithoutLink:Vector.<AbstractMoveAction> = new Vector.<AbstractMoveAction>; // that is, without link to next Action
			
			node.actions.forEach(function (action:Action):void {
				if ( actions.indexOf(action) < 0 ) return; // action in node belongs to ANOTHER 'ActionManager' !!!
				
				var nodeIndexInAction:int = action.removeNode(node); // cross-references removed
				var actionNodes:Vector.<Node> = action.nodes;
				if (actionNodes.length === 0) {
					// no Nodes left in Action, delete it
					deleteAction(action);
				} else if (nodeIndexInAction === 0 && actionNodes.length === 1) {
					// by convention, delete 2-Node Actions if 1st Node gets deleted
					deleteAction(action);
				} else if (nodeIndexInAction === actionNodes.length) {
					// by convention, replace LAST Node (if deleted) of a multi-Node Action with the 1st Node of the next Action in line
					if (action.indexParentVector < actions.length - 1) {
						actionsWithoutLink.push(action);
					} else {
						// no next Action? only 1 node in this Action? Go die
						if (nodeIndexInAction === 1) deleteAction(action);
					}
				}
			});
			if (node.actions.length === 0) {
				node.dispose(); // only "destroy" if has no purpose in life
			}
			
			// recreate "links" to next Actions
			for each (var amaction:AbstractMoveAction in actionsWithoutLink) {
				var nextAction:Action = getAction(amaction.indexParentVector+1);
				if (nextAction) {
					amaction.pushNode(nextAction.nodes[0]);
				} else {
					if (amaction.nodes.length <= 1) deleteAction(amaction); // this is the last Action, it ain't going anywhere, delete it!
				}
			}
			
			return nodes.length === 0;
		}
		
		/**
		 * @param from Inclusive
		 * @param to Exclusive
		 */
		public function updateIndices(from:int, to:int):void {
			for (var index:int = from; index < to; ++index) {
				actions[index].indexParentVector = index;
			}
		}
		
		/**
		 * Get Action at specific time. Note: crashes if there are no Actions!
		 * @param time Global time
		 * @return Pair: key = Action, value = Action local time!
		 */
		public function getActionAt(time:Number):Pair {
			for (var i:int = 0; i < actions.length; ++i) {
				var action:Action = actions[i];
				if (time > action.duration) {
					time -= action.duration;
				} else {
					return new Pair(action, time);
				}
			}
			// time is past last Action!
			return new Pair(action, action.duration);
		}
		
		// node selecting facility
		/**
		 * Deselect any other Nodes before selecting this one 
		 * @param node
		 */
		public function selectNode(node:Node):void {
			deselectNodes();
			_selectedNodes.push(node);
			node.select();
		}
		public function deselectNodes():void {
			for each (var node:Node in _selectedNodes) {
				node.deselect();
			}
			_selectedNodes.length = 0;
		}
		
		public function get selectedNodes():Vector.<Node> { return _selectedNodes.concat(); }
		/**
		 * If Node is already selected, it gets deselected, otherwise it gets added to the currently selected Nodes
		 * @param node
		 */
		public function multiselectNode(node:Node):void {
			var index:int = _selectedNodes.indexOf(node);
			if (index >= 0) {
				_selectedNodes.splice(index, 1);
				node.deselect();
			} else {
				_selectedNodes.push(node);
				node.select();
			}
		}
		
		public function get selectedActionIndex():int { return _selectedActionIndex }
		public function set selectedActionIndex(value:int):void {
			_selectedActionIndex = value;
			dispatchEvent(new Event(ACTION_SELECTION));
		}
		
		/**
		 * TODO : Cache Node under specific point for a single Frame... Too much work for nothin'gained 
		 * @param root The <b>root</b> object needed by stupid <i>isUnderPoint2D</i> function
		 * @param stageX Number
		 * @param stageY Number
		 * @return Node
		 */
		public function getNodeUnderPoint2D(root:DisplayObject, stageX:Number, stageY:Number):NodeTouchInfo {
			const rootPoint:Point = root.globalToLocal(new Point(stageX, stageY));
			stageX = rootPoint.x;
			stageY = rootPoint.y;
			const nodeRes:NodeTouchInfo = nodes.forEachBreakable(function (node:Node):NodeTouchInfo {
				return (node.isUnderPoint2D(stageX, stageY));
			});
			return nodeRes;
		}
		
		public function getNodeOffsetUnderPoint2D(root:DisplayObject, stageX:Number, stageY:Number):NodeTouchInfo {
			const rootPoint:Point = root.globalToLocal(new Point(stageX, stageY));
			stageX = rootPoint.x;
			stageY = rootPoint.y;
			var nodeRes:NodeTouchInfo = nodes.forEachBreakable(function (node:Node):NodeTouchInfo {
				return (node.isOffsetUnderPoint2D(stageX, stageY));
			});
			return nodeRes;
		}
		
		public function getDuration():Number {
			var action:Action = getLastAction();
			if (!action) return 0;
			return action.getTimeOffset() + action.duration;
		}
		
		// save
		
		/**
		 * @param dat Essential : Scene SObjects Array
		 * @return Serialized
		 */
		public function serialize(dat:* = undefined):Object {
			const sobjects:Array = dat;
			
			const obj:Object = {};
			
			// nodes
			var i:int;
			const arrNodes:Array = nodes.toArray();
			const serialArrNodes:Array = [];
			for (i = 0; i < arrNodes.length; ++i) {
				serialArrNodes.push( (arrNodes[i] as AbstractNode).serialize(sobjects) );
			}
			obj.n = serialArrNodes;
			
			// actions
			const arrActions:Array = [];
			for (i = 0; i < actions.length; ++i) {
				arrActions.push(actions[i].serialize(arrNodes));
			}
			obj.a = arrActions;
			
			return obj;
		}
	}
}