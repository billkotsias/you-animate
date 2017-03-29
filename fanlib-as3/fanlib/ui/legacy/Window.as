package fanlib.ui.legacy {
	
	import fanlib.math.Maths;
	import flash.geom.Rectangle;
	import fanlib.event.ObjEvent;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.events.Event;
	import fanlib.utils.IChange;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.TSprite;
	
	public class Window extends TSprite {

		public var marginX:Number = 0.00; // } percentages of full window width and height
		public var marginY:Number = 0.00; // }
		
		private var _hpos:Number = 0; // horizontal and...
		private var _vpos:Number = 0; // vertical position (%)
		
		private var vbar:SVBar = null;
		
		public function Window() {
		}

		// scrolling by percentage
		public function set vpos(v:Number):void {
			_vpos = Maths.bound2(v,0,1);
			update();
		}
		public function set hpos(h:Number):void {
			_hpos = Maths.bound2(h,0,1);
			update();
		}
		public function get vpos():Number { return _vpos; }
		public function get hpos():Number { return _hpos; }
		
		// listen to a scroll bar
		public function set vbarSibling(n:String):void {
			if (this.parent == null) return;
			
			if (vbar != null) vbar.removeEventListener(SVBar.SVBAR_UPDATED, vbared);
			//vbar = this.parent.getChildByName(n) as SVBar;
			var candidates:Array = FSprite.FindChildren(parent, n);
			for (var i:int = 0; i < candidates.length; ++i) {
				var candidate:SVBar = candidates[i] as SVBar;
				if (candidate) {
					vbar = candidate;
					break;
				}
			}
			if (vbar != null) vbar.addEventListener(SVBar.SVBAR_UPDATED, vbared);
		}
		
		private function vbared(e:ObjEvent):void {
			var vbar:Object = e.getObj();
			this.vpos = vbar.vpos;
		}
		
		// overrides
		override public function set scrollRect(value:Rectangle):void {
			super.scrollRect = value;
			update();
		}
		
		// additional to 'scrollRect'
		public function set windowWidth(v:Number):void {
			var rect:Rectangle = scrollRect;
			if (rect == null) rect = new Rectangle();
			rect.width = v;
			this.scrollRect = rect;
		}
		public function set windowHeight(v:Number):void {
			var rect:Rectangle = scrollRect;
			if (rect == null) rect = new Rectangle();
			rect.height = v;
			this.scrollRect = rect;
		}
		
		// update
		public function update(e:Event = null):void {
			if (this.scrollRect == null) return;
			
			var newRect:Rectangle = this.scrollRect;
			var fullRect:Rectangle = FSprite.getFullBounds(this);
			
			if (newRect.width < fullRect.width) {
				newRect.x = (_hpos * (1 + 2 * marginX) - marginX) * (fullRect.width - newRect.width);
			}
			
			if (newRect.height < fullRect.height) {
				newRect.y = (_vpos * (1 + 2 * marginY) - marginY) * (fullRect.height - newRect.height);
				//newRect.y = _vpos * (fullRect.height - newRect.height);
			}
			
			super.scrollRect = newRect;
			// Flash bug - fixed in FSprite..!
			//var bmpData:BitmapData = new BitmapData(1, 1);
			//bmpData.draw(this);
		}
		
		// track children changes
		override public function childChanged(obj:IChange):void {
			update();
			super.childChanged(obj);
		}
	}
	
}
