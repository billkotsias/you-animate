package tools.main
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.math.Maths;
	
	import flare.collisions.CollisionInfo;
	import flare.collisions.MouseCollision;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import scene.CharManager;
	import scene.Character;
	import scene.HistoryState;
	import scene.Scene;
	import scene.action.AbstractMoveAction;
	import scene.action.Action;
	import scene.action.ActionInfo;
	import scene.action.BNode;
	import scene.action.Node;
	import scene.serialize.CharsSerializer;
	import scene.sobjects.SObject;
	
	import tools.Tool;
	import tools.selectChar.AddLinearMove;
	
	public class AddCrowd extends Tool
	{
		static public const CHARACTERS:Array = ["Vasilis","Lito","Kaneshiro","Gerald","Steve","Junko"];
//		static public const CHARACTERS:Array = ["Vasilis","Vasilis","Vasilis","Vasilis","Vasilis","Vasilis"];
		static public const DIST_MAX:Number = 5;
		static public const DIST_MIN:Number = 2;
		
		public var viewportHitArea:FSprite;
		public var selectCharContext:Tool;
		
		private const unlistener:Unlistener = new Unlistener();
		
		private var mouseCollision:MouseCollision;
		private var chars:Array;
		private var offsets:Array
		private var actions:Array;
		private var curNodes:Array;
		
		protected var currentSobject:SObject;
		
		private var removeCharsFunc:Function; // UNDO
		
		public function AddCrowd()
		{
			super();
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			
			if (selected) {
				
				var char:Character;
				var offset:Vector3D;
				chars = [];
				offsets = [];
				actions = [];
				curNodes = [];
				const charInfos:Array = [];
				for each (var charName:String in CHARACTERS) { 
					charInfos.push( CharManager.INSTANCE.getCharacterInfoByName(charName) );
				}
				
				for (var i:int = 0; i < charInfos.length; ++i) {
					chars.push( (char = Scene.INSTANCE.addCharacter( charInfos[i] )) );
					const dist:Number = Maths.random(DIST_MIN, DIST_MAX);
					const angle:Number = i / charInfos.length * 2*Math.PI;
					
					offsets.push( offset = new Vector3D( dist * Math.cos(angle), 0, dist * Math.sin(angle) ) );
					const initNode:BNode = char.newNode( char.charPivot.getPosition(false).add( offset ) ) as BNode;
				}
					
				// mouse collision
				mouseCollision = new MouseCollision();
				Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); });
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove);
				unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown);
				
			} else {
				
				unlistener.removeAll();
				Walk3D.KEYS.unlisten(Keyboard.ENTER, closePath);
				for each (char in chars) {
					char.deleteNode( char.getLastActionNode() );
					char.setTime( Infinity );
					char.deselectNodes();
					char.pathVisible = false;
				}
				mouseCollision = null;
				chars = null;
				offsets = null;
				actions = null;
				curNodes = null;
			}
		}
		
		private function mVPortMove(e:MouseEvent):void {
			if (mouseCollision.test(e.stageX, e.stageY, true, true, false)) {
				var colInfo:CollisionInfo = mouseCollision.data[0];
				currentSobject = SObject.GetFromMesh(colInfo.mesh);
				for (var i:int = chars.length - 1; i >= 0; --i) {
					var char:Character = chars[i];
					var charNode:Node = char.getLastActionNode();
					charNode.sobject = currentSobject;
					charNode.setPosition( colInfo.point.add(offsets[i]) );
					char.setTime(0);
				}
			}
		}
		private function mVPortDown(e:MouseEvent = null):void {
			
			var char:Character;
			
			for (var i:int = chars.length-1; i >= 0; --i) {
				
				char = chars[i];
				
				const actionInfo:ActionInfo = char.getValidMoveActionInfo(AddLinearMove.MOVE_DEFAULT_ID);
				if (!actionInfo) {
					trace(this,"walk animation not found in",char.info.name);
					selected = false; // what happened?!
					return;
				}
				
				var node0:BNode,
				node1:BNode;
				node0 = char.getLastActionNode() as BNode;
				node1 = char.newNode(node0.getPosition()) as BNode; // new node
				node1.sobject = currentSobject;
				node0.hideCtrlNodes = false;
				char.selectNode(node0);
				const newActionIndex:int = char.getActionNum(); // that's zero, here, now
				actions[i] = char.addBezierMove(actionInfo, node0, node1, newActionIndex);
			}
			
			// -- UNDO
			const _chars:Array = chars.concat();
			removeCharsFunc = function():void {
				for each (var _char:Character in _chars) {
					Scene.INSTANCE.removeCharacterByID( _char.id );
				}
			}
			Scene.INSTANCE.history.newStateList( chars, new HistoryState(removeCharsFunc) );
			Scene.INSTANCE.history.addState( chars, getHistoryState() );
			// UNDO --
			
			// mouse collision
			mouseCollision = new MouseCollision();
			Scene.INSTANCE.sobjects.forEach(function(so:SObject):void { mouseCollision.addCollisionWith(so.pivot3D); }); // plain wrong
			unlistener.removeAll();
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_MOVE, mVPortMove2);
			unlistener.addListener(viewportHitArea, MouseEvent.MOUSE_DOWN, mVPortDown2);
			unlistener.addListener(viewportHitArea, MouseEvent.RIGHT_MOUSE_DOWN, closePath);
			Walk3D.KEYS.listen(Keyboard.ENTER, closePath, this);
		}
		
		protected function mVPortMove2(e:MouseEvent):void {
			
			if (mouseCollision.test(e.stageX, e.stageY, true, true)) {
				
				const colInfo:CollisionInfo = mouseCollision.data[0];
				for (var i:int = chars.length - 1; i >= 0; --i) {
					
					const char:Character = chars[i];
					const currentAction:Action = char.getLastAction();
					const currentNode:BNode = char.getLastActionNode() as BNode;
					
					currentNode.setPosition( colInfo.point.add( offsets[i] ) );
					const affectPreviousNode:Boolean = (currentAction.nodesNum === 2);
					BNode.AlignControls(currentNode, currentAction.getNodeByReverseIndex(1) as BNode, true, affectPreviousNode);
					char.setTime(currentAction.getTimeOffset() + currentAction.duration);
				}
				
			}
		}
		
		private function mVPortDown2(e:MouseEvent):void {
			if (mouseCollision.test(e.stageX, e.stageY, true, true)) {
				
				Scene.INSTANCE.history.addState( chars, getHistoryState() ); // UNDO
				
				const colInfo:CollisionInfo = mouseCollision.data[0];
				for (var i:int = chars.length - 1; i >= 0; --i) {
					
					const char:Character = chars[i];
					const currentAction:Action = char.getLastAction();
					
					char.selectNode( char.getLastActionNode() );
					var newNode:BNode = char.newNode( colInfo.point.add( offsets[i] ) ) as BNode;
					(char.getLastAction() as AbstractMoveAction).pushNode( newNode );
					newNode.sobject = currentSobject;
				}
			}
		}
		
		private function closePath(e:Event):void {
			selected = false;
		}
		
		// UNDO
		private function getHistoryState():HistoryState {
			const sobjects:Array = Scene.INSTANCE.sobjects.toArray();
			const charObjs:Array = [];
			const _removeCharsFunc:Function = removeCharsFunc;
			for (var i:int = 0; i < chars.length; ++i) {
				var char:Character = chars[i];
				charObjs.push( char.serialize( sobjects ) );
			}
			
			return new HistoryState(function():void {
				_removeCharsFunc();
				for each (var charObj:Object in charObjs) {
					CharsSerializer.DeserializeChar( charObj, sobjects, Infinity );	// create new
				}
			})
		}
	}
}