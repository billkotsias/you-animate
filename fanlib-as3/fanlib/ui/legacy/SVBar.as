package fanlib.ui.legacy {
	
	import fanlib.gfx.TSprite;
	import fanlib.io.MLoader;
	import flash.events.MouseEvent;
	import fanlib.event.ObjEvent;
	import flash.geom.Point;
	import fanlib.math.Maths;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.Align;
	
	public class SVBar extends TSprite {

		public static const SVBAR_UPDATED:String = "SVBAR_UPDATED";
		
		private var back:FBitmap = null;
		private var vbar:TSprite = null;
		
		private var _barHeight:Number = 40; // a default
		private var _vpos:Number = 0; // percentage [0...1]
		
		private var clickedPos:Point;
		private var clickedY:Number;
		
		public function SVBar() {
			vbar = new TSprite();
			vbar.buttonMode = true;
			vbar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			this.addChild(vbar);
		}
		
		private function mouseDown(e:MouseEvent):void {
			clickedPos = new Point(e.stageX, e.stageY);
			clickedY = vbar.y;
			
			vbar.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
			vbar.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
			vbar.stage.addEventListener(MouseEvent.ROLL_OUT, mouseUp, false, 0, true);
		}
		
		private function mouseUp(e:MouseEvent):void {
			vbar.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			vbar.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			vbar.stage.removeEventListener(MouseEvent.ROLL_OUT, mouseUp);
		}
		
		private function mouseMove(e:MouseEvent):void {
			var newPos:Point = new Point(e.stageX, e.stageY);
			var diffY:Number = this.globalToLocal(newPos).y - this.globalToLocal(clickedPos).y;
			if (vbar.height > _barHeight) {
				vpos = 0;
			} else {
				vpos = (clickedY + diffY) / (_barHeight - vbar.height);
			}
		}
		
		public function set vpos(v:Number):void {
			_vpos = Maths.bound2(v,0,1);
			
			update();
			
			dispatchEvent(new ObjEvent(this, SVBAR_UPDATED));
		}
		public function get vpos():Number { return _vpos;}
		
		public function set barHeight(h:Number):void {
			_barHeight = h;
			
			if (back != null) {
				back.height = _barHeight;
			}
			
			update();
		}
		public function get barHeight():Number { return _barHeight;}
		
		public function update():void {
			
			// bar vertical position
			if (vbar.height > _barHeight) {
				vbar.y = 0;
			} else {
				vbar.y = _vpos * (_barHeight - vbar.height);
			}
			childChanged(this);
		}
		
		// gfx loading may be handled in-class
		public function set backFile(path:String):void {
			new MLoader(new Array(path), backLoaded);
		}
		public function set vbarFile(path:String):void {
			new MLoader(new Array(path), vbarLoaded);
		}
		
		private function backLoaded(loader:MLoader):void {
			try { backBmp = new FBitmap(loader.files[0].bitmapData, Align.CENTER); } catch(e:Error) {}
		}		
		private function vbarLoaded(loader:MLoader):void {
			try { vbarBmp = new FBitmap(loader.files[0].bitmapData, Align.CENTER); } catch(e:Error) {}
		}
		
		public function set backBmp(bmp:FBitmap):void {
			if (back != null) {
				this.removeChild(back);
				bmp.y = back.y;
			}
			
			back = bmp;
			bmp.height = _barHeight;
			this.addChildAt(back, 0);
			
			update();
		}
		
		public function set vbarBmp(bmp:FBitmap):void {
			if (vbar.numChildren > 0) vbar.removeChildAt(0);
			vbar.addChild(bmp);
			
			update();
		}
		
		public function get backBmp():FBitmap { return back;}
		public function get vbarBmp():FBitmap {
			if (vbar.numChildren > 0) return vbar.getChildAt(0) as FBitmap;
			return null;
		}
	}
	
}
