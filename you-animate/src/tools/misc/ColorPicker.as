package tools.misc
{
	import fanlib.filters.Color;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.vector.FShape;
	import fanlib.text.FTextField;
	import fanlib.utils.FStr;
	import fanlib.utils.IInit;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import tools.MouseActions;
	
	public class ColorPicker extends FSprite implements IInit
	{
		static public const PICKED:String = "PICKED";
		static public const PICKED_END:String = "PICKED_END";
		
		private const point:Point = new Point();
		
		public var colorPickerBmp:Bitmap;
		public var colorSelected:FShape;
		public var colorHex:FTextField;
		
		private var _color:uint;
		
		public function ColorPicker()
		{
			super();
		}
		
		public function initLast():void {
			MouseActions.ListenToTouchDrag(findChild("colorPicker"), colorTouched, colorTouchedEnd);
			colorHex.addEventListener(FTextField.FINALIZED, setFromHexText);
		}
		
		private function setFromHexText(e:Event):void {
			color = uint("0x"+colorHex.text);
			
			dispatchEvent(new Event(PICKED));
		}
		
		private function colorTouched(e:MouseEvent):void {
			point.x = e.stageX;
			point.y = e.stageY;
			const bmpCoords:Point = colorPickerBmp.globalToLocal(point);
			if (bmpCoords.x >= colorPickerBmp.width || bmpCoords.y >= colorPickerBmp.height) return;
			
			color = colorPickerBmp.bitmapData.getPixel(bmpCoords.x, bmpCoords.y);
			dispatchEvent(new Event(PICKED));
		}
		
		private function colorTouchedEnd(e:MouseEvent):void {
			dispatchEvent(new Event(PICKED_END));
		}
		
		public function set color(c:uint):void {
			_color = c;
			colorHex.htmlText = FStr.AddLeadingChars(c.toString(16), "0".charCodeAt(0), 6);
			colorSelected.transform.colorTransform = Color.MultiplyHEX(c | 0xff000000);
		}
		public function get color():uint {
			return _color;
		}
	}
}