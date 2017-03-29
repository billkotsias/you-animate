package scene.action
{
	import fanlib.gfx.FSprite;
	
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Point;
	
	public class SpriteCtrlNode extends SpriteNode
	{
		static private const Zero:Point = new Point();
		
		static public const COLOR:uint = 0xff00ff;
		static public const ALPHA:Number = 0.3;
		static public const RADIUS_2D:Number = 10;
		
//		private var _nodeRef:Node;
		
		private const link:Shape = new Shape();
		
		public function SpriteCtrlNode()
		{
			super(COLOR, ALPHA, RADIUS_2D);
			addChild(link);
		}
		
		public function linkToParent(par:FSprite):void {
			const g:Graphics = link.graphics;
			var pos:Point;
			g.clear();
			g.lineStyle(3, COLOR, ALPHA);
			pos = link.globalToLocal(main.localToGlobal(Zero));
			g.moveTo(pos.x, pos.y);
			pos = link.globalToLocal(par.localToGlobal(Zero));
			g.lineTo(pos.x, pos.y);
		}
	}
}