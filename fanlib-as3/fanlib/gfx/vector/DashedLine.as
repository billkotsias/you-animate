package fanlib.gfx.vector {
	
	import fanlib.math.Maths;
	import fanlib.math.Vector2D;
	
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.geom.Point;
	
	public class DashedLine extends Shape {
		
		private const position:Point = new Point();
		private var _dash:Number;
		private var _gap:Number;
		
		public function DashedLine(dash:Number = 3, gap:Number = 3) {
			super();
			_dash = dash;
			_gap = gap;
		}
		
		// DFXML
		public function set style(arr:Array):void { lineStyle(arr[0], arr[1], arr[2]) }
		public function set line(arr:Array):void {
			moveTo(arr.shift(), arr.shift());
			while (arr.length) {
				lineTo(arr.shift(), arr.shift());
			}
		}
		// DFXML

		public function clear():void {
			graphics.clear();
			position.setTo(0,0);
		}
		
		public function lineStyle(thickness:Number, color:uint, alpha:Number):void {
			graphics.lineStyle(thickness, color, alpha, false, LineScaleMode.NONE);
		}
		
		public function moveTo(x:Number, y:Number):void {
			position.x = x;
			position.y = y;
			graphics.moveTo(x, y);
		}
		
		public function lineTo(x:Number, y:Number):void {
			const p1:Point = position;
			const p2:Point = new Point(x, y);
			const dist:Number = Point.distance(p1, p2);
			const angle:Number = Maths.AngleBetweenPoints(p1, p2);
			const dashStepX:Number = Math.cos(angle) * _dash;
			const dashStepY:Number = Math.sin(angle) * _dash;
			const gapStepX:Number = Math.cos(angle) * _gap;
			const gapStepY:Number = Math.sin(angle) * _gap;
			
			var xx:Number = position.x;
			var yy:Number = position.y;
			const len:uint = int(dist / (_dash + _gap));
			for (var i:int = 0; i < len; i++) {
				xx += dashStepX;
				yy += dashStepY;
				graphics.lineTo(xx, yy);
				xx += gapStepX;
				yy += gapStepY;
				graphics.moveTo(xx, yy);
			}
			if (len !== dist) {
				graphics.lineTo(p2.x, p2.y);
			}
			position.setTo(p2.x, p2.y);
		}
		
		public function drawRect(x:Number, y:Number, width:Number, height:Number):void {
			moveTo(x, y);
			lineTo(x + width, y);
			lineTo(x + width, y + height);
			lineTo(x, y + height);
			lineTo(x, y);
		}
		
	}
}