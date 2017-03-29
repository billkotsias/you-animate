package fanlib.ui {
	
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	public class Pointer extends TSprite {

		private var _parent:DisplayObjectContainer;
		
		public function Pointer(par:DisplayObjectContainer = null) {
			setParent(par);
		}
		
		public function setParent(par:DisplayObjectContainer):void {
			_parent = par;
			move();
		}

		public function start():void {
			_parent.addChild(this);
			Stg.Get().addEventListener(MouseEvent.MOUSE_MOVE, move);
			Mouse.hide();
		}

		public function stop():void {
			Mouse.show();
			Stg.Get().removeEventListener(MouseEvent.MOUSE_MOVE, move);
			parent.removeChild(this);
		}
		
		protected function move(e:MouseEvent = null):void {
			if (parent == null) return;
			
			x = parent.mouseX;
			y = parent.mouseY;
		}
	}
	
}
