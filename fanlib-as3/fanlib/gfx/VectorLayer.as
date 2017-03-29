package fanlib.gfx {
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class VectorLayer extends AutoSizedSprite {

		private var _color:uint = 0;
		private var _valpha:Number = 0;
		private var extVisible:Boolean = true;
		
		public function VectorLayer() {
			addEventListener(Event.ADDED_TO_STAGE, update, false, 0, true);
		}
		
		public function update(e:* = undefined):void {
			graphics.clear();
			graphics.beginFill(_color, _valpha);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();
			stageResized();
		}
		
		override public function set visible(b:Boolean):void {
			extVisible = b;
			checkVisible();
		}
		
		override public function set alpha(a:Number):void {
			super.alpha = a;
			checkVisible();
		}
		
		public function set vAlpha(a:Number):void {
			_valpha = a;
			checkVisible();
			update();
		}
		
		public function set color(c:uint):void {
			_color = c;
			update();
		}
		
		private function checkVisible():void {
			// forced
			if (!extVisible) {
				super.visible = false;
				return;
			}
			// optimization
			if (alpha * _valpha == 0) {
				super.visible = false;
			} else {
				super.visible = true;
			}
		}
	}
	
}
