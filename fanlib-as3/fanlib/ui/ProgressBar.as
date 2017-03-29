package fanlib.ui
{
	import fanlib.gfx.TSprite;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	
	public class ProgressBar extends TSprite
	{
		static public var Last_Instance:ProgressBar;
		
		static public var Default_Width:Number = 100;
		static public var Default_Height:Number = 12;
		static public var Default_Margins:Number = 2;
		static public var Default_Color:uint = 0x00EB08;
		
		private const pump:Shape = new Shape();
		
		public function ProgressBar()
		{
			super();
			addChild(pump);
			params = [Default_Width, Default_Height, Default_Margins, Default_Color];
			progress = 1; // this is the progress variable: 2-in-1
			Last_Instance = this;
		}
		
		public function set params(dims:Array):void {
			const width:Number = dims[0];
			const height:Number = dims[1];
			var margin:Number = dims[2];
			
			var gfx:Graphics = graphics;
			gfx.clear();
			gfx.lineStyle(1, 0x0);
			gfx.drawRect(0,0,width,height);
			
			pump.x = pump.y = margin;
			gfx = pump.graphics;
			gfx.clear();
			gfx.beginFill(dims[3], 1);
			gfx.drawRect(0, 0, width - margin * 2 + 1, height - margin * 2 + 1);
		}

		public function get progress():Number
		{
			return pump.scaleX;
		}

		public function set progress(value:Number):void
		{
			pump.scaleX = value;
		}

	}
}