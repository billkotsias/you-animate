package ui.play
{
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	
	import flash.events.Event;
	
	import tools.ToolButton;
	import tools.CheckButtonTool;
	import tools.ITool;
	import tools.Tool;
	
	public class PlayPause extends CheckButtonTool
	{
		private var list:TList;
		public var timeline:Timeline;
		
		public function PlayPause()
		{
			super();
		}

		override public function set selected(select:Boolean):void
		{
			super.selected = select;
			
			if (list) {
				list.removeEventListener(TList.TLIST_COMPLETE, listComplete);
				TPlayer.DEFAULT.removePlaylist(list, false);
			}
			if (state) {
				if (timeline.value === 1) timeline.value = 0; // if at end, start all over
				list = TPlayer.DEFAULT.addTween(
					new TLinear(new TVector1(1),
						timeline.getValue, timeline.setValue,
						timeline.durationTotal * (1 - timeline.value)),
					true);
				list.addEventListener(TList.TLIST_COMPLETE, listComplete, false, 0, true);
			}
		}
		private function listComplete(e:Event):void {
			selected = false;
		}
	}
}