package fanlib.ui.legacy {
	
	import fanlib.gfx.TSprite;
	import fanlib.io.MLoader;
	import flash.events.MouseEvent;
	import fanlib.event.ObjEvent;
	import flash.geom.Point;
	import fanlib.math.Maths;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.Align;
	
	public class SHBar extends TSprite {

		public static const SHBAR_UPDATED:String = "SHBAR_UPDATED";
		
		private var back:FBitmap = null;
		private var hbar:TSprite = null;
		
		private var _barWidth:Number = 40; // a default
		private var _hpos:Number = 0; // percentage [0...1]
		
		private var clickedPos:Point;
		private var clickedX:Number;
		
		public function SHBar() {
			hbar = new TSprite();
			hbar.buttonMode = true;
			hbar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
			this.addChild(hbar);
		}
		
		private function mouseDown(e:MouseEvent):void {
			clickedPos = new Point(e.stageX, e.stageY);
			clickedX = hbar.x;
			
			hbar.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
			hbar.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp, false, 0, true);
			hbar.stage.addEventListener(MouseEvent.ROLL_OUT, mouseUp, false, 0, true);
		}
		
		private function mouseUp(e:MouseEvent):void {
			hbar.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			hbar.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			hbar.stage.removeEventListener(MouseEvent.ROLL_OUT, mouseUp);
		}
		
		private function mouseMove(e:MouseEvent):void {
			var newPos:Point = new Point(e.stageX, e.stageY);
			var diffX:Number = this.globalToLocal(newPos).x - this.globalToLocal(clickedPos).x;
			if (hbar.width > _barWidth) {
				hpos = 0;
			} else {
				hpos = (clickedX + diffX) / (_barWidth - hbar.width);
			}
		}
		
		public function set hpos(v:Number):void {
			_hpos = Maths.bound2(v,0,1);
			
			update();
			
			dispatchEvent(new ObjEvent(this, SHBAR_UPDATED));
		}
		public function get hpos():Number { return _hpos;}
		
		public function set barWidth(h:Number):void {
			_barWidth = h;
			
			if (back != null) {
				back.width = _barWidth;
			}
			
			update();
		}
		public function get barWidth():Number { return _barWidth;}
		
		public function update():void {
			
			// bar vertical position
			if (hbar.width > _barWidth) {
				hbar.x = 0;
			} else {
				hbar.x = _hpos * (_barWidth - hbar.width);
			}
		}
		
		// gfx loading may be handled in-class
		public function set backFile(path:String):void {
			new MLoader(new Array(path), backLoaded);
		}
		public function set hbarFile(path:String):void {
			new MLoader(new Array(path), hbarLoaded);
		}
		
		private function backLoaded(loader:MLoader):void {
			try { backBmp = new FBitmap(loader.files[0].bitmapData, null, Align.CENTER); } catch(e:Error) {}
		}		
		private function hbarLoaded(loader:MLoader):void {
			try { hbarBmp = new FBitmap(loader.files[0].bitmapData, null, Align.CENTER); } catch(e:Error) {}
		}
		
		public function set backBmp(bmp:FBitmap):void {
			if (back != null) {
				this.removeChild(back);
				bmp.x = back.x;
			}
			
			back = bmp;
			back.width = _barWidth;
			this.addChildAt(back, 0);
			
			update();
		}
		
		public function set hbarBmp(bmp:FBitmap):void {
			if (hbar.numChildren > 0) hbar.removeChildAt(0);
			hbar.addChild(bmp);
			
			update();
		}
		
		public function get backBmp():FBitmap { return back;}
		public function get hbarBmp():FBitmap {
			if (hbar.numChildren > 0) return hbar.getChildAt(0) as FBitmap;
			return null;
		}
	}
	
}
