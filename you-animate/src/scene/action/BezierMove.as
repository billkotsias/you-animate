package scene.action
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.math.BezierCubic3D;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import scene.Character;
	import scene.IScene3D;
	import scene.Scene;
	
	public class BezierMove extends AbstractMoveAction
	{
		protected const beziers:Vector.<BezierCubic3D> = new Vector.<BezierCubic3D>;
		
		protected var cachedTime:Number; // check against this to see if co-ordination values are cached
		protected var cachedBezier:BezierCubic3D;
		protected var cachedFactor:Number;
		protected var cachedFactorNormalized:Number;
		
		private const col:uint = Math.random() * 0xffffff;
		
		public function BezierMove(character:Character, data:ActionInfo, node0:BNode, node1:BNode, referencePivot:Pivot3D, parent2D:FSprite)
		{
			super(character, data, node0, node1, referencePivot, parent2D);
//			BNode.AlignControls(node1, node0, true, true);
		}
		
		override public function insertNode(node:Node, nodeIndex:int):void {
			const bezier:BezierCubic3D = new BezierCubic3D(); // NOTE : one more than needed
			beziers.splice(nodeIndex, 0, bezier);
			super.insertNode(node, nodeIndex);
		}
		
		override internal function removeNode(node:Node):int {
			const nodeIndex:int = nodes.indexOf(node);
			beziers.splice(nodeIndex, 1); // must come before 'super.removeNode'
			return super.removeNode(node);
		}
		
		override public function cacheProperties():void {
			// - durations
			durations.length = 0;
			_duration = 0;
			if (!nodes.length) return;
			
			var startNode:BNode = nodes[0] as BNode;
			for (var i:int = 1; i < nodes.length; ++i) {
				var nextNode:BNode = nodes[i] as BNode;
				
				var bezier:BezierCubic3D = beziers[i-1];
				startNode.getPosition(bezier.anchor1);
				startNode.control1.getPosition(bezier.control1);
				nextNode.getPosition(bezier.anchor2);
				nextNode.control0.getPosition(bezier.control2);
				bezier.recalc();
//				trace(this,i,"\n",bezier.anchor1,"\n",bezier.anchor2,"\n",bezier.control1,"\n",bezier.control2);
				
				var dur:Number = bezier.length / (referencePivot.getScale(false).x * _speed);
				durations.push(dur);
				_duration += dur;
				startNode = nextNode;
			}
			cachedTime = NaN;
			
			if (character) character.dispatchEvent(new ObjEvent(this, ActionManager.CHANGE));
		}
		
		override public function getDirection(time:Number):Vector3D {
			cacheSegmentProperties(time);
			const dir:Vector3D = cachedBezier.getDirectionAt(cachedFactorNormalized).clone();
			if ((dir.x === 0) && (dir.y === 0) && (dir.z === 0)) {
				dir.z = -1;
			} else {
				dir.negate();
			}
			return dir;
		}
		
		/**
		 * @param time Local time
		 * @return World coordinates
		 */
		override public function getPosition(time:Number):Vector3D {
			cacheSegmentProperties(time);
			const pos:Vector3D = cachedBezier.getPointAt(cachedFactorNormalized).clone();
			return pos;
		}
		
		/**
		 * @param time Local Action time
		 */
		protected function cacheSegmentProperties(time:Number):void {
			if (time >= _duration) time = _duration * 0.99999; // rounding errors
			if (cachedTime === time && cachedBezier) return;
			cachedTime = time; // link this time to current cache
			
			for (var i:int = 0; i < durations.length; ++i) {
				var dur:Number = durations[i];
				if (time <= dur) { // time inside this "duration"
					cachedBezier = beziers[i];
					if (dur) {
						cachedFactor = time / dur;
						cachedFactorNormalized = cachedBezier.normalizeT(cachedFactor);
					} else {
						cachedFactor = 0;
						cachedFactorNormalized = 0;
					}
					break;
				} else {
					time -= dur;
				}
			}
		}
		
		override public function drawPath(start:int, end:int):void {
			if (nodes.length < 2) return;
			if (start < 0) start = 0;
			if (end >= nodes.length) end = nodes.length - 1;
			
			const scene3D:IScene3D = Scene.INSTANCE.iScene3D;
			const pos3D:Vector3D = nodes[start].getPosition();
			var pos2D:Point = scene3D.getPointScreenCoordsRelative(pos3D, path2D, pos3D);
			for (var i:int = start; i < end; ++i) {
				var gfx:Graphics = (path2D.getChildAt(i) as SpriteAction).newGraphics(col);
				gfx.moveTo(pos2D.x, pos2D.y);
				
				const bezier:BezierCubic3D = beziers[i];
				const timeStep:Number = 2 / bezier.length;
				var t:Number = 0;
				// TODO : make step dynamic, relative to 2D distance between "points"
				do {
					t += timeStep;
					if (t > 1) t = 1;
					pos2D = scene3D.getPointScreenCoordsRelative(bezier.getPointAt(t), path2D, pos3D);
					gfx.lineTo(pos2D.x, pos2D.y);
//					gfx.drawCircle(pos2D.x, pos2D.y, 4);
				} while (t < 1);
			}
		}
		
		//
	}
}