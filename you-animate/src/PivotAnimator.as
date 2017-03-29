package
{
	import fanlib.event.StgEvent;
	import fanlib.gfx.Stg;
	import fanlib.utils.Enum;
	import fanlib.utils.FArray;
	import fanlib.utils.Pausable;
	import fanlib.utils.Utils;
	
	import flare.core.Label3D;
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class PivotAnimator extends Pausable
	{
		static public const INSTANCE:PivotAnimator = new PivotAnimator();
		public var defaultFPS:Number = 30;
		
		private const pivots:Dictionary = new Dictionary(true);
		
		public function PivotAnimator()
		{
			unpause(undefined);
		}
		
		override public function pause(pauser:*):void {
			super.pause(pauser);
			Stg.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}

		override public function unpause(pauser:*):Boolean {
			if (super.unpause(pauser)) return true;
			
			Stg.addEventListener(Event.ENTER_FRAME, enterFrame);
			return false;
		}
		
		public function addAnimation(pivot:Pivot3D, pp:PlayingPivot):void {
			const anims:Array = Utils.GetGuaranteed(pivots, pivot, Array);
			anims.push( pp );
			if (anims.length === 1) {
				// TODO : lerp from pivot's currentFrame to pp's animation
				pivot.currentFrame = pp.currentFrame;
			}
		}
		
		public function removeAnimation(pivot:Pivot3D, pp:PlayingPivot):void {
			const anims:Array = Utils.GetGuaranteed(pivots, pivot, Array);
			FArray.Remove(anims, pp, true);
		}
		
		private function enterFrame(e:StgEvent):void {
			const speedFactor:Number = e.timeSinceLast * defaultFPS * 0.001; // 1000 msecs => 30 * speed
			
			for (var _pivot:Object in pivots) {
				
				var pivot:Pivot3D = _pivot as Pivot3D;
				const anims:Array = pivots[pivot];
				const pp:PlayingPivot = anims[0];
				const from:Number = pp.from;
				var frame:Number = pp.currentFrame + speedFactor * pp.speed;
				// TODO : lerp etc...
				
				switch (pp.loop) {
					case PlayingPivot.LOOP:
						frame = from + (frame - from) % (pp.to - from);
						pp.currentFrame = frame;
						pivot.gotoAndStop(frame);
						// animation can only "break" manually, by removing it
						break;
					
					case PlayingPivot.STOP:
						// TODO:
						// - test if animation has finished
						// - calc time available for NEXT animation
						// - again test if new anim has finished (!)...
						// - take lerp into account
						break;
					
					case PlayingPivot.PING_PONG:
						// TODO
						break;
				}
			}
		}
	}
}