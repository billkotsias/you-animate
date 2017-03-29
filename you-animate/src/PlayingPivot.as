package
{
	import fanlib.utils.Enum;
	import fanlib.utils.Utils;
	
	import flare.core.Pivot3D;
	
	public class PlayingPivot {
		
		static public const STOP:Enum = new Enum;
		static public const LOOP:Enum = new Enum;
		static public const PING_PONG:Enum = new Enum;
		
		public var from:Number;
		public var to:Number;
		/** frames advanced every 1/30 secs */
		public var speed:Number;
		public var loop:Enum;
		public var currentFrame:Number; // works as "start frame" too
		
		public var lerpTime:Number;
		public var currentLerpTime:Number; // works as "start lerp time" too, but that would be stupid
		
		/**
		 * @param _from
		 * @param _to If not provided, it will be assigned the maximum frame number of the 1st pivot to be played with this
		 * @param _speed
		 * @param _loop
		 * @param _currentFrame
		 */
		public function PlayingPivot(_from:Number = NaN, _to:Number = NaN, _speed:Number = NaN, _loop:Enum = null, _currentFrame:Number = NaN) {
			from = _from;
			if (from !== from) from = 0;
			
			to = _to; // to be checked later
			
			speed = _speed;
			if (speed !== speed) speed = 1;
			
			loop = _loop;
			if (!loop) loop = LOOP;
			
			currentFrame = _currentFrame;
			if (currentFrame !== currentFrame) currentFrame = from;
		}
	}
}