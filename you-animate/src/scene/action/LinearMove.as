package scene.action
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.math.FVector3D;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import scene.Character;
	import scene.IScene3D;
	import scene.Scene;
	
	public class LinearMove extends AbstractMoveAction
	{
		static private const ZERO:Vector3D = FVector3D.Zero(); // don't touch, assholes
		
		// a bit of optimization
		private var cachedTime:Number; // check against this to see if co-ordination values are cached
		private const cachedStartPos:Vector3D = new Vector3D();
		private var cachedDir:Vector3D;
		private var cachedMove:Vector3D;
		private var cachedFactor:Number;
		private const cachedDirections:Vector.<Vector3D> = new Vector.<Vector3D>;
		private const cachedMoveVectors:Vector.<Vector3D> = new Vector.<Vector3D>;
		
		private const col:uint = Math.random() * 0xffffff;
		
		/**
		 * @param data CharacterInfo
		 * @param node0 Initial point.
		 * @param node1 Second point. A MoveAction must have at least 2 Nodes to exist.
		 * @param referencePivot A reference pivot (like Character's loaderPivot), used to calculate local distances
		 * @param parent2D A container for 2D graphics.
		 * 
		 */
		public function LinearMove(character:Character, data:ActionInfo, node0:Node, node1:Node, referencePivot:Pivot3D, parent2D:FSprite)
		{
			super(character, data, node0, node1, referencePivot, parent2D);
		}

		override public function cacheProperties():void {
			cachedTime = NaN; // cache needs refresh
			
			// reinit
			durations.length = 0;
			_duration = 0;
			cachedMoveVectors.length = 0;
			cachedDirections.length = 0;
			
			if (nodes.length == 0) return;
			const startPos:Vector3D = nodes[0].getPosition();
			const nextPos:Vector3D = new Vector3D();
			for (var i:int = 1; i < nodes.length; ++i) {
				
				// move vectors
				nodes[i].getPosition(nextPos);
				const moveVector:Vector3D = nextPos.subtract(startPos);
				cachedMoveVectors.push(moveVector.clone());
				
				// durations
				var dur:Number = moveVector.length / (referencePivot.getScale(false).x * _speed); // / ((guy.scaleX/MODEL_SCALE)*9.75);
				durations.push(dur);
				_duration += dur;
				
				// directions
				if (moveVector.equals(ZERO)) {
					FVector3D.Z_Axis(moveVector);
				} else {
					moveVector.negate();
					moveVector.normalize(); // check for extreme case
				}
				cachedDirections.push(moveVector);
				
				startPos.copyFrom(nextPos);
			}
			
			if (character) character.dispatchEvent(new ObjEvent(this, ActionManager.CHANGE));
		}
		
		override public function getDirection(time:Number):Vector3D {
			cacheSegmentProperties(time);
			return cachedDir;
		}
		
		/**
		 * @param time
		 * @return World coordinates
		 */
		override public function getPosition(time:Number):Vector3D {
			cacheSegmentProperties(time);
			
			// was : pos.x = cachedStartPos.x + (cachedPivot1.x - cachedStartPos.x) * cachedFactor;
			var pos:Vector3D = cachedMove.clone();
			pos.scaleBy(cachedFactor);
			pos.incrementBy(cachedStartPos);
			
			// TODO : additional y calc
			
			return pos;
		}
		
		/**
		 * @param time Local Action time
		 */
		private function cacheSegmentProperties(time:Number):void {
			if (time >= _duration) time = _duration * 0.99999; // rounding errors
			if (cachedTime === time) return;
			cachedTime = time; // link this time to current cache
			
			for (var i:int = 0; i < durations.length; ++i) {
				var dur:Number = durations[i];
				if (time <= dur) { // time inside this "duration"
					nodes[i].getPosition(cachedStartPos);
					cachedDir = cachedDirections[i];
					cachedMove = cachedMoveVectors[i];
					if (!dur) cachedFactor = 0; else cachedFactor = time / dur;
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
				nodes[i+1].getPosition(pos3D);
				pos2D = scene3D.getPointScreenCoordsRelative(pos3D, path2D, pos3D);
				gfx.lineTo(pos2D.x, pos2D.y);
			}
		}
	}
}