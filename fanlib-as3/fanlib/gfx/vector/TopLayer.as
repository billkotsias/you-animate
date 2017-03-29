package fanlib.gfx.vector {
	
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.tween.TList;
	
	import flash.events.Event;
	
	public class TopLayer extends TSprite {
		
		private var _color:uint = 0x0;
		private var _vAlpha:Number = 1;
		
		public function TopLayer(updateImmediately:Boolean = false) {
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
			
			Stg.Get().addChild(this); // I am the chosen one
			if (updateImmediately) update();
			stage.addEventListener(Event.RESIZE, update, false, 0, true);
		}
		
		public function set color32(c:uint):void {
			_color = c & 0xffffff;
			_vAlpha = (c >>> 24)/255;
			update();
		}
		
		public function set vAlpha(c:Number):void {
			_vAlpha = c;
			update();
		}
		
		public function set color(c:uint):void {
			_color = c & 0xffffff; // prevent assholity
			update();
		}
		
		public function update(e:Event = null):void {
			graphics.clear();
			graphics.beginFill(_color, _vAlpha);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();
		}

		public function fadeAway(time:Number = 0.3):void {
			fadeout(time, 0, TSprite.FADE_REMOVE);
		}
		
		override public function copy(baseClass:Class = null):* {
			const obj:TopLayer = super.copy(baseClass);
			obj.color32 = ((_vAlpha * 255) << 24) | _color;
			return obj;
		}
		
		private function removedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			stage.removeEventListener(Event.RESIZE, update);
		}
	}
	
}