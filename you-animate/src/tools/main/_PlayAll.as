package tools.main
{
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import scene.Character;
	import scene.Scene;
	
	import tools.Tool;

	/**
	 * REDUNDANT 
	 * @author See 'PlayPause'
	 */
	public class _PlayAll extends Tool
	{
		private const lists:Dictionary = new Dictionary(true);
		
		public function _PlayAll()
		{
			super();
		}
		
		override public function set selected(select:Boolean):void {
			super.selected = select;
			if (select) {
				playAll();
				addEventListener(MouseEvent.MOUSE_DOWN, myMouseDown, false, 0, true);
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, myMouseDown);
				stopAll();
			}
		}
		private function myMouseDown(e:MouseEvent):void {
			if (selected) playAll();
		}
		
		public function playAll():void {
			Scene.INSTANCE.characters.forEach(playChar);
		}
		
		public function stopAll():void {
			for (var char:* in lists) {
				var list:TList = lists[char];
				TPlayer.DEFAULT.removePlaylist(list, false);
				delete lists[char];
			}
		}
		
		public function playChar(char:Character):void {
			TPlayer.DEFAULT.removePlaylist(lists[char], false);
			char.setTime(0);
			var duration:Number = char.getDuration();
			lists[char] = TPlayer.DEFAULT.addTween( new TLinear(new TVector1(duration), char.getTimeAnim, char.setTimeAnim, duration/1.) );
		}
	}
}