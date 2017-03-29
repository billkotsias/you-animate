package fanlib.ui.legacy {
	
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.tween.ITweenedData;
	import fanlib.tween.TVector2;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	public class SpeedySprite extends TSprite {
		
		public var deceleration:Number = 0.01;			// deceleration applied to speed
		public var minSpeedThres:Number = 1;
		
		protected var speed:Point = new Point();		// speed added every frame
		private var runtime:int;
		
		public function SpeedySprite() {
			// constructor code
		}

		public function start():void {
			Stg.Get().addEventListener(Event.ENTER_FRAME, enterFrame);
			runtime = getTimer();
		}
		
		public function stop():void {
			Stg.Get().removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		protected function enterFrame(e:Event):void {
			addSpeed();
		}
		
		protected function addSpeed():void {
			
			var timeSinceLast:int = getTimer() - runtime;
			runtime += timeSinceLast;
			
			// optimization
			if (speed.x == 0 && speed.y == 0) return;
			// optimization
			
			moveBy(speed.x,
				   speed.y);
			
			// decelerate
			//var spl:Number = Math.sqrt(speed.x * speed.x + speed.y * speed.y);
			
			var _newSpeed:Number = speed.x - deceleration * timeSinceLast * speed.x;
			if (_newSpeed * speed.x <= 0) {
				speed.x = 0;
			} else {
				speed.x = _newSpeed;
			}
			
			_newSpeed = speed.y - deceleration * timeSinceLast * speed.y;
			if (_newSpeed * speed.y <= 0) {
				speed.y = 0;
			} else {
				speed.y = _newSpeed;
			}
			
			if ((speed.x * speed.x + speed.y * speed.y) < minSpeedThres) {
				speed.x = 0;
				speed.y = 0;
			}
		}
		
		public function getSpeed():ITweenedData {
			return new TVector2(speed.x, speed.y);
		}
		
		public function setSpeed(__speed:ITweenedData):void {
			var _speed:TVector2 = (__speed as TVector2);
			speed.x = _speed.x;
			speed.y = _speed.y;
		}
	}
}
