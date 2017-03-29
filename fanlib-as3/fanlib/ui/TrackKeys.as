package fanlib.ui
{
	import fanlib.gfx.Stg;
	
	import flash.events.KeyboardEvent;

	public class TrackKeys
	{
		private const strokes:Array = [];
		
		public const stringToFunc:Object = {}; // check for these strings
		public var length:uint = 100; // default
		
		public function TrackKeys(len:uint = 100)
		{
			length = len;
		}
		
		public function start():void {
			Stg.Get().addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		public function stop():void {
			Stg.Get().removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function keyDown(e:KeyboardEvent):void {
			strokes.push(String.fromCharCode(e.keyCode));
			while (strokes.length > length) strokes.shift();
			var current:String = strokes.join("");
			for (var str:String in stringToFunc) {
				if (str == current.slice(current.length - str.length)) stringToFunc[str](); // call respective function
			}
		}
	}
}