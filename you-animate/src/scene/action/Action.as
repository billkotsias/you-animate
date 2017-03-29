package scene.action
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.utils.Enum;
	import fanlib.utils.Utils;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import scene.Character;
	import scene.IParam;
	import scene.action.special.DriveAction;
	import scene.action.special.PropInfo;
	import scene.serialize.ISerialize;
	
	import tools.param.Param;

	/**
	 * 
	 * @author This is an Abstract Class
	 * 
	 */
	public class Action implements IParam, ISerialize { /* ISerialize currently useless, but keeps future compatibility */
		
		static public const Params:Vector.<Param> = new Vector.<Param>();
		
		static public const STOP:Enum = new Enum;
		static public const LOOP:Enum = new Enum;
		static public const PING_PONG:Enum = new Enum;
		
		// save-able
		protected var data:ActionInfo; // info
		public const nodes:Vector.<Node> = new Vector.<Node>; // f*ck AS3 access rights; no really. No, really. NO REALLY.
		
		protected var _duration:Number;
		/**
		 * Animation frame rate 
		 */
		protected var from:Number;
		protected var to:Number;
		protected var _rate:Number;
		protected var _loop:Enum;
		
		// temp
		protected const coordination:Coordination = new Coordination();
		
		// externally set
		protected var _character:Character;
		protected var _indexParentVector:int = -1; // index of this Action in containing Vector
		
		public function Action(character:Character, actionData:ActionInfo)
		{
			_character = character;
			data = actionData;
			from = actionData.from;
			to = actionData.to;
			_loop = actionData.mode;
			
			_rate = data.rate;
			if (!_rate) _rate = 30; // default = 30 frames per second
		}
		
		/**
		 * Abstract: take full control of your character and do whatever you like with it
		 */
		public function seizeCharacter():void {
		}
		
		/**
		 * Abstract: release control of your character and restore it to default state! NOW!
		 * @param endOfAction True if new Character Action is <b>AFTER</b> this one
		 */
		public function surrenderCharacter(endOfAction:Boolean = false):void {
		}
		
		/**
		 * @param time <b>Local</b> Action time (starts at 0)
		 */
		public function setCoordination(time:Number):void {
			getCoordination(time);
			
			const orientationPivot:Pivot3D = _character.charPivot;
			var vec:Vector3D = coordination.position;
			orientationPivot.setPosition(vec.x, vec.y, vec.z, 1, false);
			
			// NOTE : below line should probably go inside 'getCoordination'!
			coordination.direction.y = 0; // characters always stand up-right..?
			orientationPivot.setOrientation(coordination.direction);
			
			// set animated pivots' frame
			for each (var pivot:Pivot3D in _character.animatedPivots) {
				pivot.gotoAndStop(coordination.frame, 0, false);
			}
			
			// set animated meshes' frame
			const secondsToBlend:Number = 0.15; // TODO : move to ActionInfo!!!
			const lerp:Number = time / secondsToBlend;
			if (lerp < 1 && indexParentVector > 0) {
				_character.setAdvancedMeshesFrame(getPreviousActionFinalFrame(), coordination.frame, lerp);
			} else {
				_character.setMeshesFrame(coordination.frame);
			}
		}
		
		/**
		 * Remove Node from this Action. Removes Action reference in Node, too. 
		 * @param node
		 * @return The index of the Node at the time of removal.
		 */
		internal function removeNode(node:Node):int {
			const nodeIndex:int = nodes.indexOf(node);
			nodes.splice(nodeIndex, 1); // remove Node from Action
			node.actions.remove(this); // remove Action from Node
			
			return nodeIndex;
		}
		
		/**
		 * Abstract 
		 * @param node
		 */
		public function nodeChanged(node:Node):void {
		}
		
		/**
		 * 
		 * @param time Node local time! [0...]
		 * @return Coordination object contains position, orientation, frame number.
		 */
		public function getCoordination(time:Number):Coordination {
			coordination.position = getPosition(time);
			coordination.direction = getDirection(time);
			coordination.frame = getFrame(time);
			return coordination;
		}
		
		public function getFrame(time:Number):Number {
			return CalcLinearFrame(time, from, to, _loop, _rate);
		}
		
		public function getFinalFrame():Number {
			return CalcLinearFrame(_duration, from, to, _loop, _rate);
		}
		public function getPreviousActionFinalFrame():Number {
			var previousActionLastFrame:Number;
			if (_indexParentVector > 0) {
				previousActionLastFrame = _character.getAction(_indexParentVector - 1).getFinalFrame();
			} else {
				previousActionLastFrame = NaN;
			}
			return previousActionLastFrame;
		}
		
		/**
		 * Clean-up while being deleted from ActionManager. NOTE : must only be called by ActionManager !
		 */
		public function _dispose():void {
		}
		
		/**
		 * 
		 * Function is abstract!
		 * @param time Local Action time, must be >= 0
		 * @return World coordinates
		 */
		public function getPosition(time:Number):Vector3D {
			return null; // override!
		}
		
		/**
		 * Function is abstract!
		 * @param time Local Action time, must be >= 0
		 * @return Direction as set by previous Actions
		 */
		public function getDirection(time:Number):Vector3D {
			return null; // override!
		}
		
		// TODO : cache and mark dirty for following Actions if 'nodeChanged', etc..!
		public function getTimeOffset():Number {
			const prevAction:Action = _character.getAction(indexParentVector-1);
			if (prevAction) {
				return (prevAction.duration + prevAction.getTimeOffset());
			}
			return 0;
		}
		
		/**
		 * If Node doesn't belong to this Action, NaN is returned 
		 * @param node
		 * @return Time offset
		 */
		public function getNodeTimeOffset(node:Node):Number {
			var index:int = nodes.indexOf(node);
			if (index >= 0) return getNodeIndexTimeOffset(index);
			return NaN;
		}
		
		public function getNodeIndexTimeOffset(index:int):Number {
			return 0;
		}
		
		/**
		 * 
		 * @param time Local Action time, must be >= 0
		 * @return Frame number (decimal)
		 */
		static public function CalcLinearFrame(time:Number, from:Number, to:Number, _loop:Enum, _rate:Number):Number {
			const numFrames:Number = to - from + 1;
			var frame:Number;
			if (_loop === LOOP) {
				frame = from + (time * _rate) % numFrames;
			} else if (_loop === STOP) {
				frame = from + time * _rate;
				if (frame > (to + 1)) frame = to + 1;
			} else if (_loop === PING_PONG) {
				// TODO : implement
			}
			return frame;
		}
		
		public function getLastNode():Node {
			return nodes[nodes.length-1];
		}
		public function getFirstNode():Node {
			return nodes[0];
		}
		public function getNodeByIndex(i:int):Node {
			return nodes[i];
		}
		public function getNodeByReverseIndex(i:int):Node {
			return nodes[nodes.length-1-i];
		}
		public function get nodesNum():uint {
			return nodes.length;
		}
		public function getIndexParentVector():int { 
			return indexParentVector;
		}
		
		public function get id():String { return data.id }
		public function get propInfo():PropInfo { return data.prop }
//		public function get loopType():Enum { return _loop }
		
		public function get duration():Number
		{
			return _duration;
		}
		
		protected function getNodes():Vector.<Node> {
			return nodes;
		}
		
		// IParam
		public function get params():Vector.<Param> {
			return Params;
		}
		public function get paramsTitle():String {
			return	"<grey>Action:</grey> " + data.id +
					"\n<grey><sm>"+getQualifiedClassName(this)+"</sm></grey>";
		}
		
		// save
		public function serialize(dat:* = undefined):Object {
			const charNodes:Array = dat;
			
			const obj:Object = {};
			obj.t = getQualifiedClassName(this);
			obj.d = id;
			
			// nodes
			const nodesIndices:Array = [];
			for (var i:int = 0; i < nodes.length; ++i) {
				const node:Node = nodes[i];
				nodesIndices.push(charNodes.indexOf(node));
			}
			obj.n = nodesIndices;
			
			return obj;
		}
		public function deserialize(obj:Object):void {
			// deserialized by Factory
		}

		public function get indexParentVector():int { return _indexParentVector; }
		public function set indexParentVector(value:int):void {
			_indexParentVector = value;
		}

		public function get character():Character
		{
			return _character;
		}


	}
}