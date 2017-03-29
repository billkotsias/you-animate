package fanlib.gfx
{
	import fanlib.tween.TList;
	
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;

	public class StageFade
	{
		private var bmp:TBitmap;
		
		public function StageFade() {
		}
		
		public function cloneStage(transparent:Boolean = false, color:uint = 0):StageFade {
			var stage:Stage = Stg.Get();
			if (!bmp) bmp = new TBitmap();
			bmp.bitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, transparent, color);
			bmp.bitmapData.draw(stage);
			bmp.alpha = 1;
			stage.addChild(bmp); // theoritically on top of all
			return this;
		}
		
		public function fade(time:Number = 0.5, delay:Number = 0):void {
			if (!bmp || !bmp.bitmapData) cloneStage();
			var list:TList = bmp.fadeout(time, delay, TBitmap.OPTIMIZE_REMOVE);
			list.data = bmp;
			list.addEventListener(TList.TLIST_COMPLETE, fadeComplete, false, 0, true);
			bmp = null;
		}
		
		private function fadeComplete(e:Event):void {
			var list:TList = e.currentTarget as TList;
			list.removeEventListener(TList.TLIST_COMPLETE, fadeComplete);
			var _bmp:TBitmap = list.data;
			_bmp.bitmapData.dispose();
			_bmp.bitmapData = null;
		}
	}
}