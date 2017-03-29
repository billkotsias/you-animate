package scene.action
{
	import fanlib.event.ObjEvent;
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.utils.Utils;
	
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import scene.Character;
	
	import tools.param.Param;

	public class AbstractMoveAction extends Action
	{
		static private function BuildParams():Vector.<Param> {
			const bparams:Vector.<Param> = Action.Params.concat();
			bparams.push(
				new Param("speed", "defSpeed")
			);
			return bparams;
		}
		static public const Params:Vector.<Param> = BuildParams();
		
		protected var referencePivot:Pivot3D; // A reference pivot (like Character's loaderPivot), used to calculate local distances
		protected const path2D:FSprite = new FSprite();
		
		// cached properties
		protected const durations:Vector.<Number> = new Vector.<Number>;
		
		protected const unlistener:Unlistener = new Unlistener();
		
		// parameters
		protected var _speed:Number;
		
		/**
		 * @param character Character this Action belongs to
		 * @param data CharacterInfo's Move data object
		 * @param node0 Initial point.
		 * @param node1 Second point. A MoveAction must have at least 2 Nodes to exist.
		 * @param referencePivot A reference pivot (like Character's loaderPivot), used to calculate local distances
		 * @param parent2D A container for 2D graphics.
		 * 
		 */
		public function AbstractMoveAction(character:Character, data:ActionInfo, node0:Node, node1:Node, referencePivot:Pivot3D, parent2D:FSprite)
		{
			super(character, data);
			_speed = this.data.speed;
			this.referencePivot = referencePivot;
			parent2D.addChild(path2D);
			insertNode(node0, 0);
			insertNode(node1, 1);
			
			unlistener.addListener(character, Character.SCALE_CHANGED, charScaleChanged, false, 0, true);
		}
		
		protected function charScaleChanged(e:Event = null):void {
			cacheProperties();
		}
		override public function _dispose():void {
			super._dispose();
			unlistener.removeAll();
		}

		override internal function removeNode(node:Node):int {
			const nodeIndex:int = super.removeNode(node);
			cacheProperties();
			
			// path
			var fixedIndex1:int = nodeIndex-1;
			var fixedIndex2:int = nodeIndex;
			if (fixedIndex1 < 0) {
				fixedIndex1 = 0;
				fixedIndex2 = 1;
			}
			path2D.removeChildAt(fixedIndex1); // TODO? : there will be one more Sprite than needed...!
			drawPath(fixedIndex1, fixedIndex2);
			
			return nodeIndex;
		}
		
		public function pushNode(node:Node):void {
			insertNode(node, nodes.length);
		}
		public function unshiftNode(node:Node):void {
			insertNode(node, 0);
		}
		public function insertNode(node:Node, nodeIndex:int):void {
			nodes.splice(nodeIndex, 0, node);
			node.actions.push(this);
			cacheProperties();
			
			// path
			path2D.addChildAt(new SpriteAction(), nodeIndex); // TODO? : there will be one more Sprite than needed...!
			drawPath(nodeIndex-1, nodeIndex+1);
		}
		
		/**
		 * Cachable properties are updated 
		 * @param node The Node that changed (the world)
		 */
		override public function nodeChanged(node:Node):void {
			cacheProperties(); // TODO : could be optimized
			const nodeIndex:int = nodes.indexOf(node);
			drawPath(nodeIndex-1,nodeIndex+1);
		}
		
		override public function getNodeIndexTimeOffset(index:int):Number {
			const debug:int = index;
			var offset:Number = 0;
			while (index > 0) { offset += durations[--index]; }
			return offset;
		}
		
		//
		
		/**
		 * Function is abstract!
		 */
		public function cacheProperties():void {
		}
		
		/**
		 * Function is abstract!
		 * @param start Inclusive
		 * @param end "Exclusive"
		 */
		public function drawPath(start:int, end:int):void {
		}
		
		// split
		
		public function splitAtNode(node:Node):Array {
			return splitAtIndex(nodes.indexOf(node));
		}
		public function splitAtIndex(index:int):Array {
			if (index < 1 || index >= nodes.length - 1) return null; // can't split at that index
			
			const classDef:Class = Utils.GetClass(this);
			const move1:AbstractMoveAction = clone(0, index, classDef);
			const move2:AbstractMoveAction = clone(index, nodes.length-1, classDef);
			return [move1, move2];
		}
		
		/**
		 * Clone Move Action. May be "mutated" by setting a different 'classDef'.
		 * @param nodeIndStart Inclusive
		 * @param nodeIndEnd Inclusive
		 * @param classDef
		 * @return Cloned (may be mutated)
		 */
		public function clone(nodeIndStart:int, nodeIndEnd:int, classDef:Class = null):AbstractMoveAction {
			if (!classDef) classDef = Utils.GetClass(this);
			const move:AbstractMoveAction = new classDef(character, data, nodes[nodeIndStart], nodes[nodeIndStart+1], referencePivot, path2D.parent);
			for (var i:int = nodeIndStart + 2; i <= nodeIndEnd; ++i) {
				move.pushNode(nodes[i]);
			}
			return move;
		}
		
		// IParams
		override public function get params():Vector.<Param> {
			return Params;
		}
		
		public function get defSpeed():Number { return data.speed }
		public function get speed():Number { return _speed }
		public function set speed(sp:Number):void {
			if (_speed === sp) return; // avoid computational overhead
			_speed = sp;
			_rate = data.rate * _speed / data.speed; // NOTE : _rate is analogous to _speed!
			cacheProperties();
		}
		
		// save
		override public function serialize(dat:* = undefined):Object {
			const obj:Object = super.serialize(dat);
			obj.sp = speed;
			return obj;
		}
		
		override public function deserialize(obj:Object):void {
			super.deserialize(obj);
			speed = obj.sp;
		}
	}
}