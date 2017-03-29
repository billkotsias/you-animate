package fanlib.box2d {
	
	import fanlib.gfx.Stg;
	
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class StageCage extends Cage {

		static public var MIN_WIDTH:Number = -1;		// <0 means "disabled"
		static public var MIN_HEIGHT:Number = -1;	// same here
		
		public function StageCage(rect:Rectangle = null) {
			super(rect);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		
		protected function addedToStage(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			Stg.Get().addEventListener(Event.RESIZE, resize, false, 0, true);
			resize();
		}
		
		public function resize(e:Event = null):void {
			var pos:Point = new Point();
			var size:Point = new Point(Stg.Get().stageWidth, Stg.Get().stageHeight);
			
			if (MIN_WIDTH >= 0) {
				if (Stg.Get().stageWidth < MIN_WIDTH) {
					size.x = MIN_WIDTH;
					pos.x = (Stg.Get().stageWidth - MIN_WIDTH) / 2;
				}
			}
			if (MIN_HEIGHT >= 0) {
				if (Stg.Get().stageHeight < MIN_HEIGHT) {
					size.y = MIN_HEIGHT;
					pos.y = (Stg.Get().stageHeight - MIN_HEIGHT) / 2;
				}
			}
			setRect(new Rectangle(pos.x + Stg.Get().x, pos.y + Stg.Get().y,
								  size.x, size.y));
		}

	}
	
}
