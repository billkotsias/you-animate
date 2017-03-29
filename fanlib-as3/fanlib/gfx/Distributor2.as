package fanlib.gfx
{
	import fanlib.gfx.FSprite;
	import fanlib.utils.IChange;
	import fanlib.utils.IInit;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	public class Distributor2 extends FSprite implements IInit
	{
		public var columns:uint = 1;
		/**
		 * Set as NaN to disable x setting 
		 */
		public var spaceX:Number = 5;
		/**
		 * Set as NaN to disable y setting 
		 */
		public var spaceY:Number = 5;
		
		public function Distributor2()
		{
			super();
			trackChanges = false;
		}
		
		public function initLast():void {
			trackChanges = true;
			rearrange();
			align(alignX, alignY);
			super.childChanged(this);
		}
		
		public function rearrange():void {
//			trace(this.name,spaceX);
			var j:int = 0; // child index
			var yy:Number = 0;
			while (j < numChildren) {
				var i:int = 0; // column index
				var xx:Number = 0;
				do {
					const obj:DisplayObject = getChildAt(j);
					const rect:Rectangle = obj.getRect(obj);
					if (spaceX === spaceX) {
						obj.x = xx - rect.x * obj.scaleX;
						xx += spaceX - (rect.x - rect.width) * obj.scaleX;
					}
					if (spaceY === spaceY) {
						obj.y = yy - (rect.y * obj.scaleY);
					}
					if (++j >= numChildren) break;
				} while (++i < columns);
				if (spaceY === spaceY) yy += spaceY - (rect.y - rect.height) * obj.scaleY;
			}
		}
		
		override public function childChanged(obj:IChange):void {
			if (!trackChanges) return;
			rearrange();
			super.childChanged(obj);
		}
		
		override public function copy(baseClass:Class=null):* {
			const dist:Distributor2 = super.copy(baseClass);
			dist.spaceX = this.spaceX;
			dist.spaceY = this.spaceY;
			dist.columns = this.columns;
			return dist;
		}
	}
}