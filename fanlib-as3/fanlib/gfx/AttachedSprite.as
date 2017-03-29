package fanlib.gfx {
	
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import fanlib.utils.IChange;
	
	public class AttachedSprite extends TSprite {

		protected var attachedx:DisplayObject;
		protected var attachedy:DisplayObject;
		private var pAttx:Number = 0;
		private var pAtty:Number = 0;
		
		public function AttachedSprite() {
			// constructor code
		}
		
		public function attachBothTo(obj:DisplayObject):void {
			attachAxisTo("x", obj);
			attachAxisTo("y", obj);
		}
		
		// DFXML-friendly function
		// => ax = "x" or "y" axis
		public function attachXTo(obj:DisplayObject):void {
			attachAxisTo("x", obj);
		}
		public function attachYTo(obj:DisplayObject):void {
			attachAxisTo("y", obj);
		}
		private function attachAxisTo(ax:String, obj:DisplayObject):void {
			var update:Function = this["update"+ax];
			var previous:DisplayObject = this["attached"+ax];
			if (previous) previous.removeEventListener(Event.CHANGE, update);
			
			this["attached"+ax] = obj;
			obj.addEventListener(Event.CHANGE, update, false, 0, true);
			update();
		}
		
		public function set attachBothToRelative(name:String):void {
			var obj:DisplayObject = FSprite.FindChild(parent, name);
			attachBothTo(obj);
		}
		public function set attachXToRelative(name:String):void {
			var obj:DisplayObject = FSprite.FindChild(parent, name);
			attachAxisTo("x", obj);
		}
		public function set attachYToRelative(name:String):void {
			var obj:DisplayObject = FSprite.FindChild(parent, name);
			attachAxisTo("y", obj);
		}
		
		// each of the 'Align' values
		public function set pointAttachedX(align:String):void {
			pointAttached("x", align);
		}
		public function set pointAttachedY(align:String):void {
			pointAttached("y", align);
		}
		public function pointAttached(ax:String, align:String):void {
			switch(align) {
				case Align.ALIGN_LEFT:
				case Align.ALIGN_TOP:
					this["pAtt"+ax] = 0;
					break;
				case Align.ALIGN_CENTER:
					this["pAtt"+ax] = 0.5;
					break;
				case Align.ALIGN_RIGHT:
				case Align.ALIGN_BOTTOM:
					this["pAtt"+ax] = 1;
					break;
			}
			var update:Function = this["update"+ax];
			update();
		}
		
		public function updatex(e:Event = null):void {
			if (attachedx == null) return;
			var rect:Rectangle = attachedx.getBounds(this.parent);
			x = rect.x;
			if (attachedx.scrollRect) {
				x += attachedx.scrollRect.x + pAttx * attachedx.scrollRect.width;
			} else {
				x += pAttx * rect.width;
			}
			super.childChanged(this);
		}
		
		public function updatey(e:Event = null):void {
			if (attachedy == null) return;
			var rect:Rectangle = attachedy.getBounds(this.parent);
			y = rect.y;
			if (attachedy.scrollRect) {
				y += attachedy.scrollRect.y + pAtty * attachedy.scrollRect.height;
			} else {
				y += pAtty * rect.height;
			}
			super.childChanged(this);
		}
		
		public function updateAll():void {
			updatex();
			updatey();
		}
		
		override public function childChanged(obj:IChange):void {
			var temp:Boolean = trackChanges;
			trackChanges = false;
			updateAll();
			trackChanges = temp;
			super.childChanged(obj);
		}

	}
	
}
