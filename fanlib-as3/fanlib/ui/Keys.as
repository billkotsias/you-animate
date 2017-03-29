package fanlib.ui
{
	import fanlib.gfx.Stg;
	import fanlib.utils.Pair;
	import fanlib.utils.Utils;
	
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import flash.utils.describeType;

	public class Keys
	{
		private const listeners:Object = {};
		private const groups:Dictionary = new Dictionary(true);
		
		public function Keys()
		{
		}
		
		public function set enable(v:Boolean):void {
			if (v)
				Stg.Get().addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			else
				Stg.Get().removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		public function listen(keyCode:uint, func:Function, group:* = undefined/*, type:String = KeyboardEvent.KEY_DOWN*/):void {
			const prevListener:Function = listeners[keyCode];
			if (prevListener !== null && prevListener !== func) trace( this + " : multiple listeners for keycode : " + keyCode.toString() + "\n" + new Error().getStackTrace() );
			listeners[keyCode] = func;
			if (group !== undefined) (Utils.GetGuaranteed(groups, group, Array) as Array).push( new Pair(keyCode, func) ); 
		}
		
		public function unlisten(keyCode:uint, func:Function):void {
			if (listeners[keyCode] === func) {
				delete listeners[keyCode];
			} else if (listeners[keyCode]) {
				trace( this + " : trying to unlisten key with a different function :\n" + new Error().getStackTrace() );
				throw new Error();
			}
		}
		
		public function unlistenGroup(group:*):void {
			for each (var pair:Pair in Utils.GetGuaranteed(groups, group, Array)) {
				unlisten(pair.key, pair.value);
			}
		}
		
		private function keyDown(e:KeyboardEvent):void {
//			trace(this,e.keyCode,e.charCode,e.keyLocation,e.ctrlKey,e.altKey,e.shiftKey);
			const func:Function = listeners[e.keyCode];
			if (func !== null) func(e);
		}
	}
}