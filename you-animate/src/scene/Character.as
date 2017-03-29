package scene
{
	import fanlib.containers.List;
	import fanlib.gfx.FSprite;
	import fanlib.sound.Note;
	import fanlib.tween.TVector1;
	import fanlib.utils.Debug;
	import fanlib.utils.FArray;
	import fanlib.utils.Pair;
	import fanlib.utils.Utils;
	
	import flare.core.Boundings3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Texture3D;
	import flare.materials.Material3D;
	import flare.materials.NullMaterial;
	import flare.materials.Shader3D;
	import flare.modifiers.SkinModifier;
	import flare.primitives.Box;
	import flare.primitives.Cube;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	import mx.utils.UIDUtil;
	
	import scene.action.AbstractMoveAction;
	import scene.action.AbstractNode;
	import scene.action.Action;
	import scene.action.ActionInfo;
	import scene.action.ActionManager;
	import scene.action.BNode;
	import scene.action.BezierMove;
	import scene.action.FixedAction;
	import scene.action.LinearMove;
	import scene.action.Node;
	import scene.action.special.DriveAction;
	import scene.serialize.CharsSerializer;
	
	import skinning.CustomModifier3;
	import skinning.Frame;

	public class Character extends ActionManager implements ISObject
	{
		static public const INITIALIZED:String = "INITIALIZED";
		static public const SCALE_CHANGED:String = "SCALE_CHANGED";
		static public const DESERIALIZED:String = "DESERIALIZED";
		
//		[Embed(source='D:/Projects/Flash/Walk3D/embedded/bounds.png')]
//		static public const BMP_BOUNDS:Class;
		static public const MeshToCharacter:Dictionary = new Dictionary(true);
		
		static public const CLASS_PATH:String = "scene.action.special.";
		
		private var _info:CharacterInfo;
		private var _initialized:Boolean;
		
		private var _charPivot:Pivot3D;
		private var _loaderPivot:Pivot3D = new Pivot3D();
		private const _collisionPivot:Pivot3D = new Pivot3D();
		private const _boundsPivot:Pivot3D = new Pivot3D();
		private var _boundingBoxColor:uint;
		public const animatedPivots:Vector.<Pivot3D> = new Vector.<Pivot3D>;
		private var frames:Vector.<Frame>;
		
		private var _pathVisible:Boolean = true;
		
		private var _currentTime:Number = NaN;
		private var _currentAction:Action;
		
		private var _id:String;
		
		public var crowdID:String; // if belongs to a "crowd", lots of shit changes
		
		public function Character(info:CharacterInfo, pivot:Pivot3D, nodesCont:Pivot3D, nodesParent:FSprite, loader:FlareLoader) {
			_id = UIDUtil.createUID();
			_info = info;
			
			_charPivot = pivot;
			_charPivot.addChild(_collisionPivot);
			_charPivot.addChild(_boundsPivot);
			
			var origScale:Number = info.scale;
			_collisionPivot.setScale(origScale,origScale,origScale);
			_boundsPivot.setScale(origScale,origScale,origScale);
			// 'loader' is already scaled by same amount
			
			// Nodes 3D
			if (nodesCont) {
				_nodesPivot.parent = nodesCont;
			}
			// 2D
			if (nodesParent) _nodes2D.parent = nodesParent;
			_nodes2D.mouseEnabled = false;
			_nodes2D.mouseChildren = false;
			pathVisible = true;
			
			// loader
			if (loader.complete) {
				cloneLoader(loader);
			} else {
				var placeHolder:Mesh3D;
				_loaderPivot = _charPivot.addChild(new Pivot3D());
				_loaderPivot.addChild(placeHolder = Placeholder.Mesh());
				
				var bbox:BoundingBox;
				_boundsPivot.addChild(bbox = new BoundingBox(placeHolder.bounds));
				_boundsPivot.hide();
				bbox.setPosition(placeHolder.x, placeHolder.y, placeHolder.z);
				loader.addEventListener(Event.COMPLETE, loaderComplete);
			}
		}
		
		//
		
		/**
		 * Sets indirectly position, orientation and frame 
		 * @param time
		 * @return Coordination set.
		 */
		public function setTime(time:Number):void {
			_currentTime = time;
			
			if (actions.length) {
				
				// get current Action
				// NOTE : MAKE SURE CHAR CAN BE SEIZED EVEN IF POSITION IS SET BY ACTION LATER!!!
				const pair:Pair = getActionAt(time);
				const newAction:Action = pair.key;
				if (_currentAction !== newAction) {
					const newIndex:int = (newAction) ? newAction.indexParentVector : -1;
					if (_currentAction) _currentAction.surrenderCharacter(_currentAction.indexParentVector < newAction.indexParentVector);
					_currentAction = newAction;
					if (_currentAction) _currentAction.seizeCharacter();
				}
				time = pair.value; // 'time' is now "local Action time"!
				
				_currentAction.setCoordination(time);
				
			} else {
				
				// no Actions, do *something*
				if (_currentAction) {
					_currentAction.surrenderCharacter();
					_currentAction = null;
				}
				var node:Node = getLastActionNode();
				if (!node) return; // !!! are ya kidding me?
				
				// position
				const vec:Vector3D = node.getPosition();
				charPivot.setPosition(vec.x, vec.y, vec.z, 1, false);
				
				// direction
				if (node is BNode) {
					const bnode:BNode = node as BNode;
					bnode.getControlsDirection(vec);
					if (!vec.lengthSquared) vec.setTo(0,0,1);
				} else {
					node.mesh3D.getDir(false, vec); // last-y resort
				}
				vec.y = 0; // characters are always standing up-right, right?
				charPivot.setOrientation(vec);
				
				// frame
				_loaderPivot.gotoAndStop(0, 0); // blendFrames default = 0
			}
		}
		public function setTimeAnim(t:TVector1):void { setTime(t.x); }
		public function getTimeAnim():TVector1 { return new TVector1(_currentTime); }
		
		public function setMeshesFrame(frameNum:Number):void {
			trace(this,"setMeshesFrame",frameNum,frames ? frames.length : frames);
//			_loaderPivot.gotoAndStop(frameNum);
			for each (var frame:Frame in frames) {
				trace("fuckafuck!",frameNum);
				frame.setNormal(frameNum);
			}
		}
		
		public function setMeshesFrames(framePairs:Vector.<Pair>):void {
			trace(this,"setMeshesFrames");
			const defPair:Pair = FArray.GetByValueAndRemoveFast(framePairs, "key", "");
//			_loaderPivot.gotoAndStop(defPair.value);
			for each (var frame:Frame in frames) {
				const pair:Pair = FArray.GetByValueAndRemoveFast(framePairs, "key", frame.rootBoneName);
				frame.setNormal( Pair(pair || defPair).value ); // use default if frame with this name not found
			}
		}
		
		public function setAdvancedMeshesFrame(startFrame:Number, endFrame:Number, lerp:Number):void {
			trace(this,"setAdvancedMeshesFrame");
			for each (var frame:Frame in frames) {
				frame.setAdvanced(startFrame, endFrame, lerp);
			}
		}
		
		public function get visible():Boolean { return _charPivot.visible; }
		public function set visible(v:Boolean):void {
			if (v) {
				_loaderPivot.show();
				boundingBoxColor = _boundingBoxColor;
			} else {
				_loaderPivot.hide();
				_boundsPivot.hide();
			}
			_charPivot.visible = v;
			pathVisible = _pathVisible;
		}
		
		public function get name():String { return _charPivot.name; }
		
		public function get pathVisible():Boolean { return _pathVisible; }
		public function set pathVisible(v:Boolean):void {
			_pathVisible = v;
			v &&= _charPivot.visible;
			_nodes2D.visible = v;
			nodes.forEach(function(node:Node):void { node.visible = v; });
		}
		
		public function setScale(sc:Number):void {
			charPivot.setScale(sc,sc,sc);
			dispatchEvent(new Event(SCALE_CHANGED));
		}

		//
		
		private function loaderComplete(e:Event):void {
			var loader:FlareLoader = e.currentTarget as FlareLoader;
			loader.removeEventListener(Event.COMPLETE, loaderComplete);
			
			// remove any "placeholder" graphics
			while (_boundsPivot.children.length) _boundsPivot.removeChild(_boundsPivot.children[0]);
			
			cloneLoader(loader);
		}
		private function cloneLoader(loader:FlareLoader):void {
			// remove any "placeholder" graphics
			_loaderPivot.parent = null;
			_loaderPivot = _charPivot.addChild(loader.clone());
			_loaderPivot.gotoAndPlay(0); // } Bypass FUCKING Flare3D bug!!!
			_loaderPivot.gotoAndStop(0); // }
			
			_loaderPivot.forEach(function(pivot:Pivot3D):void {
				if ( pivot.frames && pivot.frames.length )
				{
					const mesh:Mesh3D = pivot as Mesh3D;
					if ( !mesh || !(mesh.modifier is CustomModifier3) ) { // check if bone-controlled
						animatedPivots.push(pivot);
					}
				}
			});
			
			// debug test
//			const boxaki:Pivot3D = new Box("",5,5,5,1);
//			const mesha:Mesh3D;// = _loaderPivot.getChildByName("OBJ_Vasilis01") as Mesh3D;
//			if (mesha) {
//				trace(this,"mesha");
//				BoneController.FollowBone(boxaki, mesha, "Bip001 R Finger0Nub");
//				(Scene.iScene3D as Pivot3D).addChild(boxaki.clone());
//			}
			// debug test
			
			// get meshes & fill "_collisionPivot"
			const thisCharacter:Character = this;
			_loaderPivot.forEach(function(mesh:Mesh3D):void
			{
				if (info.noBounds.indexOf(mesh.name) >= 0) {
					mesh.bounds = null; // TODO: yet another fucking bug!??? (must re-test)
				} else {
					var bounds:Boundings3D = mesh.bounds;
					var boxMesh:Box = new Box("", bounds.length.x, bounds.length.y, bounds.length.z, 1);
					boxMesh.setPosition(bounds.center.x, bounds.center.y, bounds.center.z);
					_collisionPivot.addChild(boxMesh);
					MeshToCharacter[boxMesh] = thisCharacter; // weak ref
					
					var box:BoundingBox = new BoundingBox(bounds);
					_boundsPivot.addChild(box);
				}
			}, Mesh3D);
			
			frames = CustomModifier3.GetFramesPerSkeleton(_loaderPivot);
			for each (var frame:Frame in frames) frame.setNormal(0);
			
			_collisionPivot.hide();
			_boundsPivot.hide();
			
			// update bounding box
			boundingBoxColor = boundingBoxColor;
			
			if (_currentTime === _currentTime) setTime(_currentTime); // update Coordination
			
			_initialized = true;
			dispatchEvent(new Event(INITIALIZED));
		}
		
		public function whenInitialized(func:Function):void {
			if (_initialized) {
				func(this);
			} else {
				const thisObj:Character = this;
				addEventListener(INITIALIZED, function listener(e:Event):void {
					removeEventListener(INITIALIZED, listener); // without 'this', 'removeEventListener' works FINE!!!
					func(thisObj);
				});
			}
		}
		
		internal function dispose():void {
			// delete all Actions
			while (actions.length) {
				deleteAction(actions[0], true);
			}
			// remove from 'Scene3D'
			_charPivot.parent = null;
			_nodesPivot.parent = null;
			_nodes2D.parent = null;
		}
		
		/**
		 * 
		 * @param value 32 bit uint. 0 = remove.
		 * 
		 */		
		public function set boundingBoxColor(color:uint):void
		{
			_boundingBoxColor = color;
			if (_boundingBoxColor) {
//				trace("fix shit",new Error().getStackTrace());
				_boundsPivot.show();
				for each (var box:BoundingBox in _boundsPivot.children) {
					box.setColor((color&255)/255, (color&65280)/65280, (color&16711680)/16711680, (color >>> 24)/255);
				}
			} else {
				_boundsPivot.hide();
			}
		}

		public function get boundingBoxColor():uint { return _boundingBoxColor; }
		public function get collisionPivot():Pivot3D { return _collisionPivot; }
		public function get charPivot():Pivot3D { return _charPivot; }
		public function get info():CharacterInfo { return _info; }
		public function get nodes2D():FSprite { return _nodes2D; }
		public function get currentTime():Number { return _currentTime; }
		public function get initialized():Boolean { return _initialized; }

		// Anim Factories
		public function addFixedActionAtNode(id:String, node:Node):FixedAction {
			eventsPauser.pause( addFixedActionAtNode );

			const actions:Array = splitMoveActionAtNode(node);
			var index:int;
			var amaction:AbstractMoveAction;
			
			if (actions) {
				index = (actions[1] as Action).getIndexParentVector();
			} else {
				amaction = node.getAbstractMoveAction();
				if (amaction) {
					index = amaction.getIndexParentVector();
					if (node === amaction.getLastNode()) ++index;
				}
			}
			
			eventsPauser.unpause( addFixedActionAtNode ); // dispatch only 1 event during whole process
			return createFixedAction(id, node, index);
		}
		public function addFixedAction(id:String, index:int = -1):FixedAction {
			var node:Node;
			if (index < 0 || index === actions.length) {
				node = getLastActionNode();
			} else {
				node = actions[index].getFirstNode();
			}
			return createFixedAction(id, node, index);
		}
		private function createFixedAction(id:String, node:Node, index:int):FixedAction {
			const actionData:ActionInfo = info.getFixedByID(id);
			const cclass:Class = getFixedClass(actionData);
			const action:FixedAction = new cclass(this, actionData, node);
			insertAction(action, index);
			return action;
		}
		private function getFixedClass(data:ActionInfo):Class {
			const className:String = data._class;
			if (className) return Class(getDefinitionByName(CLASS_PATH+className));
			return FixedAction; // default
		}
		
		// TODO : update!
		public function addLinearMove(id:String, node0:Node, node1:Node, atStart:Boolean = false):LinearMove {
			const action:LinearMove = new LinearMove(this, info.getMoveByID(id), node0, node1, _charPivot, _nodes2D);
			if (atStart)
				unshiftAction(action);
			else
				pushAction(action);
			return action;
		}
		
		/**
		 * Use this to get a valid Move ActionInfo, in case the one needed isn't available (at least one must exist for this to succeed)
		 * @param id ActionInfo id
		 * @return if 'id' ActionInfo not found, returns from the 1st available Move
		 */
		public function getValidMoveActionInfo(id:String):ActionInfo {
			var actionData:ActionInfo = info.getMoveByID(id);
			if (!actionData) {
				trace(this,id,"Move Action '"+id+"' not found, using first available instead...");
				actionData = info.moves[0];//info.moves[info.moves.length-1]; // info.moves[0];
				if (!actionData) {
					trace(this,id,"No Move Actions available!");
				}
			}
			return actionData;
		}
		
		public function addBezierMove(actionData:ActionInfo, node0:BNode, node1:BNode, index:int = -1):BezierMove {
			const cclass:Class = getMoveClass(actionData);
			const action:BezierMove = new cclass(this, actionData, node0, node1, _charPivot, _nodes2D);
			insertAction(action, index);
			return action;
		}
		private function getMoveClass(data:ActionInfo):Class {
			const className:String = data._class;
			if (className) return Class(getDefinitionByName(CLASS_PATH+className));
			return BezierMove; // default
		}
		
		// undo
		
		public function getNoState():HistoryState {
			return new HistoryState(
				function():void {
					Scene.INSTANCE.removeCharacterByID( _id ); // destroy character instance
				}
			);
		}
		
		public function getHistoryState():HistoryState {
			const sobjects:Array = Scene.INSTANCE.sobjects.toArray();
			const charObj:Object = serialize( sobjects );
			
			return new HistoryState(
				function():void {
					Scene.INSTANCE.removeCharacterByID( _id ); // destroy previous character instance
					CharsSerializer.DeserializeChar( charObj, sobjects, Infinity );	// create new
				}
			);
		}
		
		public function get id():String { return _id }
		
		/**
		 * Only call when Character is empty (just created) 
		 * @param other to copy
		 */
		public function copy(other:Character):void {
			// copy all nodes at once - change parents
			nodes.pushList( other.nodes );
			nodes.forEach(function(node:AbstractNode):void {
				node.setParents(_nodesPivot, _nodes2D);
			});
			
			const otherActions:Vector.<Action> = other.actions;
			for (var i:int = 0; i < otherActions.length; ++i) {
				
				const otherAction:Action = otherActions[i];
				const newInfo:ActionInfo = info.getSimilarActionInfo( otherAction );
				if (!newInfo) continue;
				
				if (otherAction is FixedAction) {
					addFixedAction(newInfo.id);
				} else {
					const otherActionNodes:Vector.<Node> = otherAction.nodes;
					const newMoveAction:BezierMove = addBezierMove(newInfo, otherActionNodes[0] as BNode, otherActionNodes[1] as BNode);
					var j:int = 2;
					while (j < otherActionNodes.length) {
						newMoveAction.pushNode( otherActionNodes[j] );
						++j;
					}
				}
			}
		}
		
		// save...
		
		/**
		 * @param dat Essential : Scene SObjects Array
		 * @return Serialized
		 */
		override public function serialize(dat:* = undefined):Object {
			const obj:Object = super.serialize(dat);
			obj.i = _info.name;	// used in CharSerializer
			obj.name = name;	// used below (new!)
			obj.id = _id;		// used below (new!)
			return obj;
		}
		
		public function deserialize(obj:Object, sobjects:Array):void {
			var i:int;
			
			// nodes
			const serialArrNodes:Array = obj.n;
			for (i = 0; i < serialArrNodes.length; ++i) {
				const nodeObj:Object = serialArrNodes[i];
				const nodeClass:Class = Class(getDefinitionByName(nodeObj.t));
				const node:Node = newNode(null, nodeClass);
				node.deserialize(nodeObj);
				node.sobject = sobjects[nodeObj.s];
			}
			
			// actions
			const arrActions:Array = obj.a;
			for (i = 0; i < arrActions.length; ++i) {
				const actionObj:Object = arrActions[i];
				var actionClassName:String = actionObj.t;
				do {
					const factory:Function = ActionFactories[actionClassName];
					// factory found
					if (factory !== null) {
						const action:Action = factory(this, actionObj);
						action.deserialize(actionObj);
						break;
					}
					// factory not found; try super-class
					const _class:Class = getDefinitionByName(actionClassName) as Class;
					actionClassName = getQualifiedSuperclassName(_class);
				} while(actionClassName);
			}
			
			if (obj.name) {
//				trace(this,_charPivot.name,obj.name);
				_charPivot.name = obj.name; // check in case of older file version!
			}
			if (obj.id) _id = obj.id;
			dispatchEvent(new Event(DESERIALIZED));
		}
		
		static private const ActionFactories:Object = function():Object {
			const Factories:Object = {};
			Factories[getQualifiedClassName(LinearMove)] = DeserializeLinearMove;
			Factories[getQualifiedClassName(BezierMove)] = DeserializeBezierMove;
			Factories[getQualifiedClassName(FixedAction)] = DeserializeFixed;
			return Factories;
		}();
		
		static private function DeserializeFixed(char:Character, actionObj:Object):FixedAction {
			const nodesIndices:Array = actionObj.n;
			const nodesSource:List = char.nodes;
			const node0:Node = nodesSource.getByIndex(nodesIndices[0]);
			const fixed:FixedAction = char.addFixedAction(actionObj.d, char.getActionNum());
//			fixed.duration = actionObj.dur; // moved to Action.deserialize()
			return fixed;
		}
		static private function DeserializeLinearMove(char:Character, actionObj:Object):AbstractMoveAction {
			return DeserializeMove(char, actionObj, char.addLinearMove);
		}
		static private function DeserializeBezierMove(char:Character, actionObj:Object):AbstractMoveAction {
			return DeserializeMove(char, actionObj, char.addBezierMove);
		}
		static private function DeserializeMove(char:Character, actionObj:Object, addMoveFunc:Function):AbstractMoveAction {
			const nodesIndices:Array = actionObj.n;
			const nodesSource:List = char.nodes;
			const node0:Node = nodesSource.getByIndex(nodesIndices[0]);
			const node1:Node = nodesSource.getByIndex(nodesIndices[1]);
			const move:AbstractMoveAction = addMoveFunc(char.getValidMoveActionInfo(actionObj.d), node0, node1, char.getActionNum());
			for (var i:int = 2; i < nodesIndices.length; ++i) {
				move.pushNode(nodesSource.getByIndex(nodesIndices[i]));
			}
			return move;
		}
	}
}