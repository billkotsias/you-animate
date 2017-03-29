package fanlib.ui.legacy {
	
	import flash.geom.Point;
	
	public class BoundDSprite extends DraggySprite {

		public var X_MIN:Number = -100;
		public var Y_MIN:Number = -100;
		public var X_MAX:Number = 0;
		public var Y_MAX:Number = 0;
		
		public function BoundDSprite() {
			// constructor code
		}
		
		override protected function addSpeed():void {
			
			super.addSpeed();
			applyBounds();
		}
		
		public function applyBounds():void {
			if (x < X_MIN) {
				x = X_MIN;
				speed.x = 0;
			} else if (x > X_MAX) {
				x = X_MAX;
				speed.x = 0;
			}
			if (y < Y_MIN) {
				y = Y_MIN;
				speed.y = 0;
			} else if (y > Y_MAX) {
				y = Y_MAX;
				speed.y = 0;
			}
		}

	}
	
}
