package fanlib.gfx {
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.display.StageQuality;
	//import fanlib.utils.Debug;
	
	public class Quality {

		static private var _stage:Stage;
		static private var time:int;
		static private var _currentQuality:int;
		static private var frameCount:int;
		
		static private const NUM_TO_QUALITY:Array = new Array(StageQuality.LOW, StageQuality.MEDIUM,
															  StageQuality.HIGH, StageQuality.BEST);
		
		// desired minimum quality and fps - NOTE : minimum quality is always respected
		static private var DESIRED_QUALITY:int;	// min desired quality (0 = LOW, 1 = MEDIUM, 2 = HIGH, 3 = BEST)
		static private var DESIRED_FPS:int;		// min desired FPS
		static private var MAX:int;				// max quality allowed
		static private var FPS_MAX:int;			// maximum fps allowed
		static private var CALIBRATE_EVERY:int;	// in mecs
		
		static public function get currentQuality():int { return _currentQuality; }
		
		static public function start(stage:Stage, q:int = 1, f:int = 30, m:int = 3, fm:int = 120, ca:int = 1000):void {
			stop();
			
			_stage = stage;
			DESIRED_QUALITY = q;
			DESIRED_FPS = f;
			MAX = m;
			FPS_MAX = fm;
			CALIBRATE_EVERY = ca;
			
			_currentQuality = MAX;
			frameCount = 0;
			time = getTimer();
			_stage.addEventListener(Event.ENTER_FRAME, enterFrame);
			_stage.frameRate = FPS_MAX;
		}
		
		static public function stop():void {
			if (_stage) _stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		static private function enterFrame(e:Event):void {
			++frameCount;
			
			var currentTime:int = getTimer();
			var timeDiff:int = currentTime - time;
			if (timeDiff < CALIBRATE_EVERY) return; // not yet
			
			var currentFPS:Number = frameCount * 1000 / timeDiff;
			time = currentTime;
			frameCount = 0;
			
			if (currentFPS < DESIRED_FPS) {
				if (_currentQuality > DESIRED_QUALITY) {
					--_currentQuality;
					applyCurrent();
				}
			} else if ( Math.ceil(currentFPS) >= Math.min(FPS_MAX, DESIRED_FPS * 2) ) { // debatable!
				if (_currentQuality < MAX) {
					++_currentQuality;
					applyCurrent();
				}
			}
			//Debug.field.text = ( timeDiff.toString() + "\nfps=" + currentFPS.toString() + "\nqua=" + _currentQuality.toString() + "\n" );
			//Debug.field.appendText( timeDiff.toString() + " " + currentFPS.toString() + " " + _currentQuality.toString() + "\n" );
		}
		
		static public function applyCurrent():void {
			_stage.quality = NUM_TO_QUALITY[ int(Math.floor(_currentQuality)) ];
		}

	}
	
}
