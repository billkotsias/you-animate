package ui.addChar
{
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.TSprite;
	import fanlib.text.FTextField;
	
	import scene.CharacterInfo;
	
	public class GridItem extends TSprite
	{
		public var thumb:FBitmap;
		public var itemName:FTextField;
		public var anims:FTextField;
		
		private var _info:CharacterInfo;
		
		public function GridItem()
		{
			super();
		}
		
		public function getInfo():CharacterInfo { return _info }
		public function setInfo(i:CharacterInfo, htmlText:String = "", htmlText2:String = ""):void {
			_info = i;
			if (i.thumb) thumb.lazyBitmapData = Walk3D.AppendToPathIfRelative(Walk3D.CHARS_DIR, i.thumb);
			itemName.htmlText = htmlText;
			anims.htmlText = htmlText2;
		}
	}
}