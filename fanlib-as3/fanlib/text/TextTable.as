package fanlib.text {
	
	import fanlib.gfx.FSprite;
	import fanlib.gfx.TSprite;
	import fanlib.text.FTextField;
	
	import flash.display.Graphics;
	
	public class TextTable extends TSprite
	{
		private var _template:FTextField;
		
		public function TextTable()
		{
		}
		
		public function set textFieldTemplate(value:FTextField):void
		{
			_template = value;
		}
		public function get textFieldTemplate():FTextField { return _template; }
		
		/** template must be set first!
		 * @param cellsX number of horizontal cells
		 * @param cellsY number of vertical cells
		 * @param w widths of columns
		 * @param h height of rows
		 */
		public function reset(cellsX:int, cellsY:int, w:Array, h:Number):void
		{
			removeChildren();
			
			var mod:int = w.length - 0;
			for (var j:int = 0; j < cellsY; ++j) {
				
				var row:TSprite = new TSprite(); // group fields in rows!
				addChild(row);
				var xx:Number = 0;
				
				for (var i:int = 0; i < cellsX; ++i) {
					var fWidth:Number = w[i % mod];
					var fieldCont:TSprite = new TSprite();
					fieldCont.x = xx;
					xx += fWidth;
					fieldCont.y = j * h;
					
					var field:FTextField = _template.copy();
					field.width = fWidth;
					field.height = h;
					
					fieldCont.addChild(field);
					row.addChild(fieldCont);
				}
			}
		}
		// => cellsX, cellsY, h, w (array)
		public function set init(arr:Array):void {
			var widths:Array = arr.slice(3);
			reset(arr[0], arr[1], widths, arr[2]);
		}
		
		public function getRow(yy:int):TSprite {
			return getChildAt(yy) as TSprite;
		}
		
		public function getRowIndex(row:TSprite):int {
			var i:int;
			try { i = getChildIndex(row); } catch(e:Error) { return -1; }
			return i;
		}
		
		public function setRowText(yy:int, txt:Array):void {
			for (var i:int = Math.min(columns, txt.length) - 1; i >= 0; --i) {
				var field:FTextField = getField(i, yy);
				field.htmlText = txt[i];
			}
		}
		
		public function setRowBackgroundGraphics(yy:int, src:Graphics):void {
			for (var i:int = 0; i < columns; ++i) {
				var fieldCont:TSprite = getFieldCont(i, yy);
				var gfx:Graphics = fieldCont.graphics; 
				gfx.clear();
				gfx.copyFrom(src);
				gfx.drawRect(0, 0, fieldCont.width, fieldCont.height);
			}
		}
		
		public function getFieldCont(xx:int, yy:int):TSprite
		{
			return ((getChildAt(yy) as TSprite).getChildAt(xx) as TSprite);
		}
		
		public function getField(xx:int, yy:int):FTextField
		{
			return getFieldCont(xx, yy).getChildAt(0) as FTextField;
		}

		public function get columns():int
		{
			return (getChildAt(0) as TSprite).numChildren;
		}

		public function get rows():int
		{
			return numChildren;
		}


	}
}