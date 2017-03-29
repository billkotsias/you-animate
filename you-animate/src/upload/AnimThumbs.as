package upload
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Gfx;
	import fanlib.text.FTextField;
	import fanlib.ui.TouchMenu;
	
	import ui.LabelThumb;
	
	public class AnimThumbs extends TouchMenu
	{
		static public const BMP:String = "bmp";
		static public const TEXT:String = "txt";
		
		public var spaceY:Number = 96;
		public var animInfoThumb:LabelThumb;
		
		public function AnimThumbs()
		{
			super();
			mouseWheel = 10;
		}
		
		public function update(anims:Array, thumbs:Array):void {
			removeChildren();
			
			for (var i:int = 0; i < anims.length; ++i) {
				const cont:FSprite = FSprite.FromTemplate("ANIM_THUMB");
				const id:String = anims[i].id;
				(cont.getChildByName(BMP) as FBitmap).bitmapData = thumbs[i] || animInfoThumb.getDefaultCheckersData();
				(cont.getChildByName(TEXT) as FTextField).htmlText = id;
				cont.name = id;
				addChild(cont);
			}
			
			Gfx.SortChildrenByName(container);
			for (i = 0; i < numChildren; ++i) {
				getChildAt(i).y = spaceY * i;
			}
		}
	}
}