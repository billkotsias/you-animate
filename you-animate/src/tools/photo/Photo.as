package tools.photo
{
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Gfx;
	import fanlib.text.FTextField;
	import fanlib.ui.CheckButton;
	import fanlib.ui.FButton2;
	import fanlib.utils.IInit;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	
	import scene.Scene;
	import scene.layers.LayerUI;
	
	import tools.CheckButtonTool;
	import tools.IContext;
	import tools.Tool;

	public class Photo extends FSprite implements IContext, IInit
	{
		private const imgSizeOrig:Array = [];
		private var _thumb:FBitmap;
		public var file:FTextField;
		
		public function Photo()
		{
			super();
//			addEventListener(FButton2.MOUSE_DOWN, mDown, false, 0, true);
			Scene.INSTANCE.addEventListener(Scene.BACKGROUND_CHANGE, backChanged, false, 0, true);
		}
		
		public function initLast():void {
			(findChild("thumbName") as FSprite).addEventListener(MouseEvent.MOUSE_DOWN, mDown, false, 0, true);
			(findChild("backVisible") as CheckButtonTool).addEventListener(CheckButton.CHANGE, backVisChange, false, 0, true);
		}
		
		private function backVisChange(e:Event):void {
			if ( (e.currentTarget as CheckButtonTool).state ) {
				Scene.INSTANCE.background.unsetInvisible( this );
			} else {
				Scene.INSTANCE.background.setInvisible( this );
			}
		}
		
		public function contextSelected(context:Tool):void {
//			enabled = true;
			if (!Scene.INSTANCE.background.getBytes()) mDown();
		}
		public function contextDeselected():void {
//			enabled = false;
		}
		
		private function backChanged(e:Event):void {
			// thumbnail
			_thumb.bitmapData = Scene.INSTANCE.background.bitmapData;
			Gfx.SetMaxSize(_thumb, imgSizeOrig[0], imgSizeOrig[1], true);
			_thumb.childChanged(_thumb);
			// filename
			const filename:String = Scene.INSTANCE.background.fileName;
			file.htmlText = filename || LayerUI.NAME_DEFAULT;
		}
		
		protected function mDown(e:MouseEvent = null):void {
			Scene.INSTANCE.background.browseForTexture();
		}

		public function set thumb(value:FBitmap):void {
			_thumb = value;
			imgSizeOrig.push(_thumb.width,_thumb.height);
		}

	}
}