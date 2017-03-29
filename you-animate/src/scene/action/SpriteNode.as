package scene.action
{
	import fanlib.gfx.FSprite;
	import fanlib.gfx.vector.DashedLine;
	
	public class SpriteNode extends FSprite
	{
		static public const COLOR:uint = 0x0000ff;
		static public const OFFSET_COLOR:uint = 0x0077ff;
		static public const ALPHA:Number = 0.5;
		static public const RADIUS_2D:Number = 15;
		
		public const main:FSprite = new FSprite();
		public const offset:FSprite = new FSprite();
		public const dashed:DashedLine = new DashedLine(7,6);
		
		public function SpriteNode(col:uint = COLOR, alfa:Number = ALPHA, radius:Number = RADIUS_2D)
		{
			super();
			
			main.graphics.beginFill(col, alfa);
			main.graphics.drawCircle(0, 0, radius);
			addChild(main);
			
			offset.graphics.beginFill(OFFSET_COLOR, ALPHA);
			offset.graphics.drawCircle(0, 0, RADIUS_2D);
			addChild(offset);
			addChild(dashed);
		}
		
		public function unsetOffset():void {
			offset.visible = false;
			dashed.visible = false;
		}
		
		public function setOffsetPos(xx:Number, yy:Number):void {
			offset.visible = true;
			dashed.visible = true;
			offset.x = xx;
			offset.y = yy;
			dashed.clear();
			dashed.lineStyle(3, OFFSET_COLOR, ALPHA);
			dashed.moveTo(main.x, main.y);
			dashed.lineTo(xx, yy);
		}
	}
}