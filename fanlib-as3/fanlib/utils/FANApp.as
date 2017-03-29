package fanlib.utils
{
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.tween.TPlayer;
	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	public class FANApp extends TSprite
	{
		public function FANApp()
		{
			super();
			
			if (stage) {
				initStage();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, initStage);
			}
		}
		
		// after adding on stage
		private function initStage(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, initStage);
			
			Stg.Set(stage);
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			TPlayer.DEFAULT.start(); // start default tweener
			
			stageInitialized();
		}
		
		// override
		protected function stageInitialized():void {
		}
		
		protected function autoShowAll(enable:Boolean):void {
			if (enable) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				stage.addEventListener(Event.RESIZE, stageResize, false, int.MAX_VALUE);
			} else {
				stage.removeEventListener(Event.RESIZE, stageResize);
			}
		}
		
		private function stageResize(e:Event = null):void {
			var stageW:int = stage.stageWidth;
			var stageH:int = stage.stageHeight;
			
			// root readjusting
			this.scaleX = stageW / Stg.PixelWidth(); // PixelWidth really is "ORIGINAL Stage Width"
			this.scaleY = stageH / Stg.PixelHeight(); // Same shit here
			if (this.scaleX > this.scaleY) {
				this.scaleX = this.scaleY;
			} else {
				this.scaleY = this.scaleX;
			}
			this.x = (stageW - this.scaleX * Stg.PixelWidth()) / 2;
			this.y = (stageH - this.scaleY * Stg.PixelHeight()) / 2;
			
			// viewport readjusting
//			var newViewport:Rectangle = viewport.getRect(stage);
//			scene3D.setViewport(newViewport.x, newViewport.y, newViewport.width, newViewport.height, scene3D.antialias);
//			_Starling.viewPort = newViewport; // don't touch this, follows Scene3D's viewport
		}
	}
}