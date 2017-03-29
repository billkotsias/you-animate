package upload
{
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	
	import flash.events.Event;
	
	import tools.CheckButtonTool;
	import tools.ITool;
	import tools.Tool;
	import tools.ToolButton;
	
	public class AnimPlay extends CheckButtonTool
	{
		private var list:TList;
		private var _timeline:Animline;
		public var playLoop:CheckButtonTool;
		
		public function AnimPlay()
		{
			super();
		}

		override public function set selected(select:Boolean):void
		{
			super.selected = select;
			
			// if playing, stop
			if (list) {
				list.removeEventListener(TList.TLIST_COMPLETE, listComplete);
				TPlayer.DEFAULT.removePlaylist(list, false);
			}
			// if wasn't playing, play
			if (state) {
				if (_timeline.value === 1) _timeline.value = 0; // if at end, start all over
				list = TPlayer.DEFAULT.addTween(
					new TLinear(new TVector1(1),
						_timeline.getValue, _timeline.setValue,
						_timeline.durationTotal * (1 - _timeline.value)),
					true);
				list.addEventListener(TList.TLIST_COMPLETE, listComplete, false, 0, true);
			}
		}
		private function listComplete(e:Event):void {
			if (playLoop.state) {
				selected = true;
			} else {
				selected = false;
			}
		}

		public function set timeline(value:Animline):void
		{
			_timeline = value;
			_timeline.animPlay = this;
		}

	}
}