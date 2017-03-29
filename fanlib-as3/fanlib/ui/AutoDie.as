package fanlib.ui
{
	import fanlib.gfx.FSprite;
	
	import flash.events.Event;
	
	public class AutoDie extends FSprite
	{
		public function AutoDie()
		{
			addEventListener(Event.ADDED, die, false, 0, true);
		}
		
		private function die(e:Event):void {
			if (parent) parent.removeChild(this);
			removeEventListener(Event.ADDED, die);
		}
		
	}
}