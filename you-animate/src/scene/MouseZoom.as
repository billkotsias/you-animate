package scene
{
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.utils.IPausable;
	import fanlib.utils.Pausable;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	
	public class MouseZoom extends FSprite implements IPausable /*extends SelectCharContext*/
	{
		public var zoomFactor:Number = 0.05;
		
		private const unlistener:Unlistener = new Unlistener();
		
		public var dobj:InteractiveObject;
		
		private var xx:Number = 0;
		private var yy:Number = 0;
		private var scale:Number = 1;
		
		private var stgX:Number;
		private var stgY:Number;
		private var relevanceX:Number;
		private var relevanceY:Number;
		
		private const pauser:Pausable = new Pausable();
		
		public function MouseZoom()
		{
			addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent):void { reset() });
		}
		
		public function get paused():Boolean { return pauser.paused }
		public function pause(pauser:*):void {
			this.pauser.pause(pauser);
			disable();
		}
		public function unpause(pauser:*):Boolean {
			const _paused:Boolean = this.pauser.unpause(pauser);
			if (!_paused) {
				enable();
				return false;
			}
			return true;
		}
		
		private function enable():void {
			unlistener.addListener(dobj, MouseEvent.MOUSE_WHEEL, mWheel);
			unlistener.addListener(dobj, MouseEvent.RIGHT_MOUSE_DOWN, mDown);
			unlistener.addListener(dobj, MouseEvent.RIGHT_MOUSE_UP, mUp);
			unlistener.addListener(dobj, MouseEvent.ROLL_OUT, mUp);
			Scene.INSTANCE.camera3D.zoom2DEnabled = true;
			update();
		}
		
		private function disable():void {
			unlistener.removeAll();
			Scene.INSTANCE.camera3D.zoom2DEnabled = false;
			visible = false;
		}

		//
		
		public function reset():void {
			xx = yy = 0;
			scale = 1;
			if (!paused) update();
		}
		
		private function mWheel(e:MouseEvent):void {
//			trace(xx,yy,scale);
			const factor:Number = e.delta / 1; // NOTE : was 3
			scale *= Math.pow( 1 - zoomFactor * (factor > 0 ? -1 : 1), Math.abs(factor) );
			update();
		}
		private function mDown(e:MouseEvent):void {
			stgX = e.stageX;
			stgY = e.stageY;
			// get pixel-relevance to viewport size
			const vRect:Rectangle = Scene.INSTANCE.viewport.getRect(Stg.Get());
			relevanceX = 1 / vRect.width;
			relevanceY = 1 / vRect.height;
			
			unlistener.addListener(dobj, MouseEvent.MOUSE_MOVE, mMove);
		}
		private function mMove(e:MouseEvent):void {
			xx += (stgX - (stgX = e.stageX)) / scale * relevanceX;
			yy += (stgY - (stgY = e.stageY)) / scale * relevanceY;
			update();
		}
		private function mUp(e:MouseEvent):void {
			unlistener.removeListener(dobj, MouseEvent.MOUSE_MOVE, mMove);
		}
		
		/**
		 * Check if paused BEFORE calling this
		 */
		private function update():void {
			Scene.INSTANCE.camera3D.setZoom2D2(xx, yy, scale);
			if (xx === yy && xx === 0 && scale === 1)
				visible = false;
			else
				visible = true;
		}
	}
}