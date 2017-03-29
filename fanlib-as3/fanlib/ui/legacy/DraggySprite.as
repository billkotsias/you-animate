package fanlib.ui.legacy {
	
	import fanlib.event.ObjEvent;
	import fanlib.gfx.Stg;
	import fanlib.ui.legacy.SpeedySprite;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class DraggySprite extends SpeedySprite {
		
		static public const START_DRAGGING:String = "StartDragging";
		static public const STOP_DRAGGING:String = "StopDragging";
		static public const CLICKING_NOT_DRAGGING:String = "ClickingNotDragging";
		
		static public var DRAG_THRESHOLD:Number = 8;// pixels

		protected var dragSpeed:Point = new Point();	// dragging speed - accumulated between frames!
		private var origPos:Point = new Point();	// original position before dragging
		private var previousPos:Point = new Point();

		private var dragging:Boolean = false;
		private var clicking:Boolean = false;
		
		public function DraggySprite() {
			// constructor code
		}

		override public function start():void {
			super.start();
			addEventListener(MouseEvent.MOUSE_DOWN, _startDrag);
			addEventListener(MouseEvent.CLICK, clicked);
		}
		
		override public function stop():void {
			super.stop();
			removeEventListener(MouseEvent.MOUSE_DOWN, _startDrag);
			removeEventListener(MouseEvent.CLICK, clicked);
		}
		
		protected function clicked(e:MouseEvent):void {
			if (clicking) dispatchEvent(new ObjEvent(e, CLICKING_NOT_DRAGGING));
		}
		
		protected function _startDrag(e:MouseEvent):void {
			if (dragging) return;
			
			clicking = true; // may go into 'false' state
			dragging = true;
			
			previousPos.x = e.stageX; // global
			previousPos.y = e.stageY;
			previousPos = this.parent.globalToLocal(previousPos); // local
			origPos.x = previousPos.x;
			origPos.y = previousPos.y;
			Stg.Get().addEventListener(MouseEvent.MOUSE_MOVE, calcDragSpeed);
			Stg.Get().addEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			this.addEventListener(MouseEvent.ROLL_OUT, _stopDrag);
			
			dispatchEvent(new ObjEvent(this, START_DRAGGING));
		}

		public function _stopDrag(e:MouseEvent):void {
			if (!dragging) return;
			
			dragging = false;
			
			Stg.Get().removeEventListener(MouseEvent.MOUSE_MOVE, calcDragSpeed);
			Stg.Get().removeEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			this.removeEventListener(MouseEvent.ROLL_OUT, _stopDrag);
			
			dispatchEvent(new ObjEvent(this, STOP_DRAGGING));
		}

		public function calcDragSpeed(e:MouseEvent):void {
			if (!dragging) return; // shouldn't be here anyway
			
			var newPos:Point = new Point(e.stageX, e.stageY); // global
			newPos = this.parent.globalToLocal(newPos); // local
			dragSpeed.x += (newPos.x - previousPos.x);
			dragSpeed.y += (newPos.y - previousPos.y);
			previousPos.x = newPos.x;
			previousPos.y = newPos.y;
			
			if (clicking) {
				if (Math.abs(newPos.x - origPos.x) > DRAG_THRESHOLD || Math.abs(newPos.y - origPos.y) > DRAG_THRESHOLD) {
					clicking = false;
				}
			}
		}
		
		override protected function addSpeed():void {
			
			if (dragSpeed.x != 0 || dragSpeed.y != 0) {
				speed.x = dragSpeed.x;
				speed.y = dragSpeed.y;
				dragSpeed.x = 0;
				dragSpeed.y = 0;
			}
		
			super.addSpeed();
		}
	}
	
}
