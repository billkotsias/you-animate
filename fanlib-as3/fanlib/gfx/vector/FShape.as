package fanlib.gfx.vector
{
	import com.apdevblog.utils.Draw;
	
	import fanlib.gfx.TSprite;
	import fanlib.math.Maths;

	public class FShape extends TSprite
	{
		public var color:uint = Maths.random(0, 0xffffff);
		public var vAlpha:Number = 0.5;
		private var _lineStyle:Array;
		
		public function FShape()
		{
			super();
		}
		
		// => left,top,width,height
		public function set rect(arr:Array):void {
			graphics.beginFill(color, vAlpha);
			graphics.drawRect(arr[0], arr[1], arr[2], arr[3]);
		}
		
		// => center x,y,radius
		public function set circle(arr:Array):void {
			graphics.beginFill(color, vAlpha);
			graphics.drawCircle(arr[0], arr[1], arr[2]);
		}
		
		// => width, height, ellipse width, ellipse height, rotation, color2, alpha2
		public function set gradRoundRect(a:Array):void {
			Draw.gradientRoundRect(this, a[0], a[1], a[2], a[3], a[4], color, a[5], vAlpha, a[6]);
		}
		
		// => x,y,radius
		public function set semicircle(arr:Array):void {
			graphics.beginFill(color, vAlpha);
			const diam:Number = arr[2] * 2;
			const xx:Number = arr[0] - diam/2;
			const yy:Number = arr[1];
			const hei:Number = -diam*Math.SQRT2/2.15; // approx.
			graphics.moveTo(xx,yy);
			graphics.cubicCurveTo(xx,yy+hei,xx+diam,yy+hei,xx+diam,yy);
		}
		
		// in case copied graphics are unwanted!
		public function set clear(dummy:*):void {
			graphics.clear();
		}

		public function set lineStyle(value:*):void
		{
			if (!(value is Array)) value = [value];
			_lineStyle = value;
			graphics.lineStyle.apply(graphics, _lineStyle);
		}

	}
}