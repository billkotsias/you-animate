package fanlib.ui {
	
	import fanlib.gfx.BmpSlicer;
	import fanlib.gfx.TBitmap;
	import fanlib.gfx.TSprite;
	import fanlib.io.MLoader;
	import fanlib.sound.Note;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	
	public class AudioMute extends TSprite {
		
		static public var SHARED_OBJECT_VAR:String = "fanlib.ui.AudioMute";
		
		private const data:Array = new Array();
		private const bmp:TBitmap = new TBitmap();
		
		private var mSelection:uint = 0;
		private var sharedObject:String;
		
		// "num" must be >= 2
		public function AudioMute(gfx:String, defVol:uint = 1, _width:int = 40, _height:int = 40, num:int = 4, useSharedObject:String = null) {
			addChild(bmp);
			
			mSelection = defVol;
			sharedObject = useSharedObject;
			if (sharedObject) {
				var so:SharedObject = SharedObject.getLocal(sharedObject);
				mSelection = so.data[SHARED_OBJECT_VAR];
			}
			
			Note.MasterVolume = mSelection / (num - 1);
			new MLoader(gfx, gfxLoaded, {width:_width, height:_height, num:num});
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
		}
		
		private function gfxLoaded(l:MLoader):void {
			var src:BitmapData = l.files[0].bitmapData;
			var rect:Rectangle = new Rectangle(0, 0, l.data["width"], l.data["height"]);
			
			for (var i:int = 0; i < l.data["num"]; ++i) {
				rect.x = i * rect.width;
				data[i] = new BitmapData(rect.width, rect.height, true, 0);
				BmpSlicer.copyRect(data[i], src, rect);
			}
			
			volume = mSelection;
		}
		
		public function set volume(v:uint):void {
			mSelection = v;
			if (mSelection >= data.length) return;
			bmp.bitmapData = data[mSelection];
			Note.MasterVolume = mSelection / (data.length - 1);
		}
		
		public function increaseVolume():void {
			if (++mSelection >= data.length) mSelection = 0;
			volume = mSelection;
		}
		
		private function mouseDown(e:MouseEvent):void {
			increaseVolume();
			if (sharedObject) {
				var so:SharedObject = SharedObject.getLocal(sharedObject);
				so.data[SHARED_OBJECT_VAR] = mSelection;
				so.flush();
			}
		}
	}
	
}
