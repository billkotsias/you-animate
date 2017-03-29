package scene.action
{
	import fanlib.gfx.FSprite;
	
	import flash.display.Graphics;
	
	public class SpriteAction extends FSprite
	{
		static public const PATH_WIDTH:Number = 6;
		static public const COLOR:uint = 0x0000ff;
		static public const ALPHA:Number = 0.5;
		
		//private var _actionRef:Action;
		
		public function SpriteAction(/*action:Action*/)
		{
			super();
//			_actionRef = action;
		}

		public function newGraphics(col:uint):Graphics {
			graphics.clear();
			graphics.lineStyle(PATH_WIDTH, col, ALPHA);
			return graphics;
		}
		
//		public function get actionRef():Action
//		{
//			return _actionRef;
//		}

	}
}