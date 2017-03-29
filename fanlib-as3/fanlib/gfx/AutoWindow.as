package fanlib.gfx {
	
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import fanlib.tween.TVector2;
	import fanlib.tween.ITweenedData;
	import fanlib.utils.IChange;
	
	public class AutoWindow extends TSprite {
		
		public var onlyOnOver:Boolean = false; // scroll only when mouse is over 'this'
		
		public var invertX:Boolean = false;
		public var invertY:Boolean = false;
		public var negativeMovement:Boolean = true;
		
		public var marginX:Number = 0; // pixels
		public var marginY:Number = 0;
		
		public var allowXScroll:Boolean = true;
		public var allowYScroll:Boolean = true;
		
		private var winOffset:TVector2 = new TVector2();
		public function setOffset(o:ITweenedData):void { winOffset = o.copy() as TVector2; }
		public function getOffset():ITweenedData { return winOffset.copy(); }
		
		private var cont:DisplayObjectContainer;
		public function get container():DisplayObjectContainer { return cont; }
		public function set container(o:DisplayObjectContainer):void {
			if (cont) super.removeChild(cont);
			cont = o;
			if (cont) {
				super.addChild(cont);
				scrollRect = scrollRect;
			}
		}

		public function AutoWindow() {
			// constructor code
		}
		
		override public function addChild(c:DisplayObject):DisplayObject {
			// pretty DFXML-compatible hack!
			if (cont) {
				c = cont.addChild(c);
			} else {
				container = c as DisplayObjectContainer;
			}
			childChanged(this);
			return c;
		}
		override public function addChildAt(c:DisplayObject, i:int):DisplayObject {
			c = cont.addChildAt(c, i);
			childChanged(this);
			return c;
		}
		override public function removeChild(c:DisplayObject):DisplayObject {
			c = cont.removeChild(c);
			childChanged(this);
			return c;
		}
		override public function removeChildAt(i:int):DisplayObject {
			var c:DisplayObject = cont.removeChildAt(i);
			childChanged(this);
			return c;
		}
		override public function getChildAt(i:int):DisplayObject {
			var c:DisplayObject = cont.getChildAt(i);
			childChanged(this);
			return c;
		}
		override public function get numChildren():int {
			return cont.numChildren;
		}
		override public function getChildIndex(c:DisplayObject):int {
			var index:int;
			try {
				index = cont.getChildIndex(c);
			} catch (e:Error) {
				index = super.getChildIndex(c);
			}
			return index;
		}
		
		override public function set scrollRect(r:Rectangle):void {
			super.scrollRect = r;
			
			if (r && cont) {
				Stg.Get().addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
				adjustRect(true);
			} else {
				Stg.Get().removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			}
		}
		
		override public function childChanged(obj:IChange):void {
			adjustRect(true);
			super.childChanged(obj);
		}
		
		private function mouseMove(e:MouseEvent):void {
			adjustRect(false);
		}
		private function adjustRect(force:Boolean):void {
			var onOver:Boolean = onlyOnOver && !force;
			if (!(cont && scrollRect)) return;
			var p:Point = this.globalToLocal(new Point(Stg.Get().mouseX, Stg.Get().mouseY));
			var r:Rectangle = scrollRect;
			p.x -= r.x;
			p.y -= r.y;
			
			// check if inside
			if (p.x < 0) {
				if (onOver) return;
				p.x = 0;
			} else if (p.x > r.width) {
				if (onOver) return;
				p.x = r.width;
			}
			if (p.y < 0) {
				if (onOver) return;
				p.y = 0;
			} else if (p.y > r.height) {
				if (onOver) return;
				p.y = r.height;
			}
			
			var contRect:Rectangle = cont.getRect(this);
			if (contRect.width === 0 && contRect.height === 0) { // override yet another long-standing Flash bug!
				contRect.x = 0;
				contRect.y = 0;
			}
			
			var factor:Number;
			
			if (allowXScroll) {
				factor = p.x / r.width;
				if (invertX) factor = 1 - factor;
				p.x = - marginX + contRect.x + (contRect.width + marginX * 2 - r.width) * factor;
			} else {
				p.x = super.scrollRect.x;
			}
			
			if (allowYScroll) {
				factor = p.y / r.height;
				if (invertY) factor = 1 - factor;
				p.y = - marginY + contRect.y + (contRect.height + marginY * 2 - r.height) * factor;
			} else {
				p.y = super.scrollRect.y;
			}
			
			if (!negativeMovement) {
				if (p.x < -marginX/2) p.x = -marginX/2;
				if (p.y < -marginY/2) p.y = -marginY/2;
			} else {
				//p.x += contRect.x;
				//p.y += contRect.y;
			}
			//if (this.name == "treeWindow") trace(p, contRect.x, contRect.width, r.width);
			
			super.scrollRect = new Rectangle(p.x + winOffset.x, p.y + winOffset.y, r.width, r.height);
		}
	}
	
}
