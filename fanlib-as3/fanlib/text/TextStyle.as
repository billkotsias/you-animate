package fanlib.text {
	
	import fanlib.text.FTextField;
	
	import flash.events.Event;
	import flash.text.TextFormat;
	
	public class TextStyle extends FTextField {

		static private const Styles:Object = {};
		
		public function TextStyle() {
			visible = false;
			addEventListener(Event.ADDED, added, false, 0, true);
		}
		private function added(e:Event):void {
			if (parent) parent.removeChild(this); // I'm just a style holder
		}
		
		override public function set name(n:String):void {
			super.name = n;
			Styles[n] = this;
		}
		
		static public function GetFormat(name:String):TextFormat {
			return (Styles[name] as FTextField).defaultTextFormat;
		}

	}
	
}
