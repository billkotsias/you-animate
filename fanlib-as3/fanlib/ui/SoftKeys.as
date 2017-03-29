package fanlib.ui
{
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.gfx.vector.FShape;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class SoftKeys extends TSprite
	{
		private var _enable:Boolean;
		public var string:String = ""; // don't set to null, asshole
		public var numerical:Boolean = true;
		
		private var keysCont:FSprite = new FSprite();
		
		public function SoftKeys()
		{
			super();
			
			addChild(keysCont);
			hitArea = keysCont;
			enable = true;
		}
		
		// => columns widths, rows heights, key chars (left to right -> top to bottom)
		public function setGrid(columns:Array, rows:Array, keys:Array, x0:Number = 0, y0:Number = 0):void {
			keysCont.removeChildren();
			
			var key:int = 0;
			var yy:Number = y0;
			for (var j:int = 0; j < rows.length; ++j) {
				var xx:Number = x0;
				var hh:Number = rows[j];
				for (var i:int = 0; i < columns.length; ++i) {
					var shCont:FSprite = new FSprite();
					shCont.name = keys[key++];
					var sh:FShape = new FShape();
					shCont.addChild(sh);
					shCont.hitArea = sh;
					sh.visible = false; // optimize (no rendering)
					sh.name = shCont.name;
					var ww:Number = columns[i];
					sh.rect = [xx, yy, ww, hh];
					xx += ww;
					keysCont.addChild(shCont);
				}
				yy += hh;
			}
		}

		private function mDown(e:MouseEvent):void {
			var newChar:String = e.target.name;
			if (numerical) {
				if (newChar == ".") {
					if (string.indexOf(".") >= 0) return;
					if (string == "") string = "0";
				} else if (string == "0") {
					if (newChar == "0") return; else if (newChar != ".") string = "";
				}
			}
			if (newChar == "\b") {
				string = string.slice(0, -1);
				if (numerical && string == "") string = "0";
			} else {
				string += newChar;
			}
			dispatchEvent(new Event(Event.CHANGE));
			trace(this, string);
		}
		
		public function get enable():Boolean
		{
			return _enable;
		}
		public function set enable(value:Boolean):void
		{
			_enable = value;
			if (_enable)
				addEventListener(MouseEvent.MOUSE_DOWN, mDown, false, 0, true);
			else
				removeEventListener(MouseEvent.MOUSE_DOWN, mDown);
		}

	}
}