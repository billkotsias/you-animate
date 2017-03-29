package fanlib.gfx {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import fanlib.event.ObjEvent;
	import fanlib.utils.Parser;
	import fanlib.tween.TList;
	
	public class Transitions extends EventDispatcher {

		private var obj:Object;
		private var params:Array;
		private var func:Function;
		
		public function Transitions(o:Object, p:Array) {
			obj = o;
			func = this[ p.shift() ]; // 1st param = function name
			params = p;
		}
		
		public function start():void {
			func();
		}
		
		// fade
		// supported by : TSprite, TBitmap, TTextField
		// params : time to fade, delay, optimize
		private function fadein():void {
			Parser.applyDefaultParams(params, new Array(0.5,0,false), true);
			obj.fadein(params[0], params[1], params[2]).addEventListener(TList.TLIST_COMPLETE, complete, false, 0, true);
		}
		private function fadeout():void {
			Parser.applyDefaultParams(params, new Array(0.5,0,false), true);
			obj.fadeout(params[0], params[1], params[2]).addEventListener(TList.TLIST_COMPLETE, complete, false, 0, true);
		}

		// complete
		private function complete(e:Event = null):void {
			dispatchEvent(new ObjEvent(this, Event.COMPLETE));
		}
	}
	
}
