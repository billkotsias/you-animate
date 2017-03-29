package fanlib.gfx {
	
	import fanlib.event.StgEvent;
	
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	public class Stg extends Stage {
		
		static private var StgWidth:Number;
		static private var StgHeight:Number;
		static private var _PixelWidth:Number;
		static private var _PixelHeight:Number;
		static private var _PixelRatio:Number;

		static private var stg:Stage;
		static public function Set(_stg:Stage):void {
			if (!_stg) return;
			stg = _stg;
			
			LockPixelDims(); // get current Stage values in case ACTIVATE never fires (browser case!)
			// TODO : line below should only run for mobile devices!!!
			//stg.addEventListener(Event.ACTIVATE, LockPixelDims);
		}
		static public function Get():Stage { return stg; }
		
		// returns true 'stage' size in pixels; works with both Windows and Android!!!
		// must not be issued immediately when stage has initialized!!!
		static public function LockPixelDims(dummy:* = undefined):void {
			stg.removeEventListener(Event.ACTIVATE, LockPixelDims);
			var mode:String = stg.scaleMode;
			stg.scaleMode = StageScaleMode.NO_SCALE;
			_PixelWidth = stg.stageWidth;
			_PixelHeight = stg.stageHeight;
			_PixelRatio = _PixelWidth / _PixelHeight;
			stg.scaleMode = mode;
			//trace(mode,DisplayWidth,DisplayHeight);
		}
		
		static public function LockStageDims():void {
			StgWidth = stg.stageWidth;
			StgHeight = stg.stageHeight;
		}
		static public function UnlockStageDims():void {
			StgWidth = NaN;
			StgHeight = NaN;
		}
		
		static public function Width():Number { return (StgWidth != StgWidth) ? stg.stageWidth : StgWidth; }
		static public function Height():Number { return (StgHeight != StgHeight) ? stg.stageHeight : StgHeight; }
		
		static public function PixelWidth():Number { return _PixelWidth; }
		static public function PixelHeight():Number { return _PixelHeight; }
		static public function PixelRatio():Number { return _PixelRatio; }
		
		//
		
		static public var time:uint;
		static public var timeSinceLast:uint;
		
		static private const EVENTS:EventDispatcher = new EventDispatcher(new EventDispatcher()); // keep 'EVENTS' totally secret!
		
		static public function addEventListener(type:String, func:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			
			switch (type) {
				case Event.ENTER_FRAME:
					if (!EVENTS.hasEventListener(Event.ENTER_FRAME)) {
						time = getTimer();
						stg.addEventListener(Event.ENTER_FRAME, enterFrame);
					}
					EVENTS.addEventListener(type, func, useCapture, priority, useWeakReference);
					break;
				
				default:
					throw "[Stg] unhandled event: " + type;
					break;
			}
		}
		static public function removeEventListener(type:String, func:Function, useCapture:Boolean = false):void {
			
			switch (type) {
				case Event.ENTER_FRAME:
					EVENTS.removeEventListener(type, func, useCapture);
					if (!EVENTS.hasEventListener(Event.ENTER_FRAME)) {
						stg.removeEventListener(Event.ENTER_FRAME, enterFrame);
					}
					break;
				
				default:
					throw "[Stg] unhandled event: " + type;
					break;
			}
		}
		
		static private function enterFrame(e:Event):void {
			timeSinceLast = -time + (time = getTimer());
			EVENTS.dispatchEvent( new StgEvent(time, timeSinceLast, Event.ENTER_FRAME) );
		}
	}
}
