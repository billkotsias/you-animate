package scene.action
{
	import fanlib.event.ObjEvent;
	import fanlib.math.FVector3D;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	import scene.Character;
	
	import tools.param.Param;

	public class FixedAction extends Action
	{
		static private function BuildParams():Vector.<Param> {
			const bparams:Vector.<Param> = Action.Params.concat();
			bparams.push(
				new Param("rate", "defRate"),
				new Param("loops"),
				new Param("duration")
			);
			return bparams;
		}
		static public const Params:Vector.<Param> = BuildParams();
		
		private var _direction:Vector3D = null; // cached (same all along)
		
		// parameters
		protected var _loops:Number = 1;
		
		public function FixedAction(character:Character, data:ActionInfo, node:Node)
		{
			super(character, data);
			nodes.push(node);
			node.actions.push(this);
			
			calcDuration();
		}
		
		override internal function removeNode(node:Node):int {
			nodes.length = 0; // remove Node from Action
			node.actions.remove(this); // remove Action from Node
			return 0;
		}
		
		override public function nodeChanged(node:Node):void {
			_direction = null;
		}
		
		override public function getDirection(time:Number):Vector3D {
			if (_direction === null) {
				// re-cache
				// Solution 1: check if on BNode
				const node:BNode = nodes[0] as BNode;
				if (node) {
					_direction = node.control0.mesh3D.getPosition(true);
//					_direction.normalize(); // unnecessary
				}
				if (_direction === null || _direction.lengthSquared === 0) {
					// Solution 2: get from previous Action
					const prevAction:Action = character.getAction(indexParentVector-1);
					if (prevAction) {
						_direction = prevAction.getDirection(prevAction.duration);
					} else {
						// Solution 3: default value
						_direction = FVector3D.Z_Axis();
					}
				}
			}
			return _direction;
		}
		
		/**
		 * @param time Local Action time, must be >= 0
		 * @return World coordinates
		 */
		override public function getPosition(time:Number):Vector3D {
			return nodes[0].getPosition();
		}
		
		// IParams
		override public function get params():Vector.<Param> {
			return Params;
		}
		
		public function get defRate():Number { return data.rate }
		public function get rate():Number { return _rate }
		public function set rate(r:Number):void {
			_rate = r;
			calcDuration();
		}
		
		public function get loops():Number { return _loops }
		public function set loops(l:Number):void {
			_loops = l;
			calcDuration();
		}
		
		protected function calcDuration():void {
			_duration = (to - from + 1) * _loops / _rate;
			character.dispatchEvent(new ObjEvent(this, ActionManager.CHANGE));
		}
		
		public function set duration(d:Number):void {
			_duration = d; // I am a good man
			_rate = (to - from + 1) * _loops / _duration; // inverse calc
			character.dispatchEvent(new ObjEvent(this, ActionManager.CHANGE));
		}
		
		// save
		override public function serialize(dat:* = undefined):Object {
			const obj:Object = super.serialize(dat);
			obj.dur = _duration;
			obj.ra = _rate;
			obj.lo = _loops;
			return obj;
		}
		
		override public function deserialize(obj:Object):void {
			super.deserialize(obj);
			_duration = obj.dur;
			_rate = obj.ra;
			_loops = obj.lo;
		}
	}
}