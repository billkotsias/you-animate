package fanlib.gfx
{
	import fanlib.utils.IChange;

	public class Grid extends TSprite
	{
		public var columns:int;
		public var sizeX:Number;
		public var rowHeight:Number;
		
		/**
		 * Semi-redundant; check <b>Distributor2</b> instead 
		 * 
		 */
		public function Grid()
		{
			super();
		}
		
		public function update():void {
			var step:Number = sizeX / columns;
			
			var column:Number = 0;
			var yy:Number = rowHeight / 2;
			for (var i:int = 0; i < numChildren; ++i) {
				
				var obj:FSprite = getChildAt(i) as FSprite;
				if (!obj) continue;
				obj.align(Align.CENTER, Align.CENTER);
				obj.x = step * (column + 0.5);
				obj.y = yy;
				
				if (++column >= columns) {
					column = 0;
					yy += rowHeight;
				}
			}
			
			super.childChanged(this);
		}
		
		override public function childChanged(obj:IChange):void {
			if (trackChanges) update();
		}
		
		override public function copy(baseClass:Class=null):* {
			const grid:Grid = super.copy(baseClass);
			grid.columns = columns;
			grid.sizeX = sizeX;
			grid.rowHeight = rowHeight;
			return grid;
		}
	}
}