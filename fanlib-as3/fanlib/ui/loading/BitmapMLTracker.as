package fanlib.ui.loading
{
	import fanlib.filters.Color;
	import fanlib.gfx.Align;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.StagedSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.io.MLoader;
	import fanlib.text.TTextField;
	import fanlib.tween.TLinear;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TVector1;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BitmapMLTracker extends MLTracker
	{
		// static
		static public const GREY_BACK:FBitmap = new FBitmap();
		
		static private const TEXT:TTextField = new TTextField();
		static private const BMP_CONT:TSprite = new TSprite();
		static public const INSTANCE:BitmapMLTracker = new BitmapMLTracker();
		
		static public function Start(bmpFile:String, bytesToLoad:uint = 1000000):void {
			INSTANCE.removeChildren();
			
			INSTANCE.addChild(BMP_CONT);
			
			// text
			TEXT.autoSize = TextFieldAutoSize.CENTER;
			TEXT.align(Align.CENTER);
			INSTANCE.addChild(TEXT);
			
			INSTANCE.bytesToLoad = bytesToLoad;
			new MLoader(bmpFile, INSTANCE.bmpLoaded);
		}
		
		static public function SetTextFormat(f:TextFormat):void {
			TEXT.defaultTextFormat = f;
			TEXT.setTextFormat(f);
		}
		
		static public function get GetText():TTextField { return TEXT; }
		
		static public function Restart(bytesToLoad:uint = 1000000, resetBytesLoaded:Boolean = true):void {
			INSTANCE.bytesToLoad = bytesToLoad;
			
			Stg.Get().addChild(INSTANCE);
			INSTANCE.stageAlignX = Align.ALIGN_CENTER;
			INSTANCE.stageAlignY = Align.ALIGN_CENTER;
			INSTANCE.fadein(0.66);
			if (resetBytesLoaded) {
				MLoader.bytesLoaded = 0;
				MLoader.bytesTotal = 0;
				INSTANCE.setProgress(new TVector1(0));
			}
			INSTANCE.trackProgress();
			INSTANCE.stageResized();
		}
		
		static public function Stop(fadeTime:Number = 0.66):void {
			INSTANCE.fadeout(fadeTime).addEventListener(TList.TLIST_COMPLETE, Stopped, false, 0, true); // super-optimize
			INSTANCE.stopTracking();
		}
		static private function Stopped(e:Event):void {
			Stg.Get().removeChild(INSTANCE);
		}
		
		// static
		
		private var currentProgress:TVector1 = new TVector1(0);
		private var tlist:TList;
		private var bytesToLoad:uint;
		
		public function BitmapMLTracker() {
			super(false);
			GREY_BACK.filters = [ Color.SepiaFilter(0.20) ];
			BMP_CONT.addChild(GREY_BACK);
		}
		
		private function bmpLoaded(l:MLoader):void {
			var data:BitmapData = l.files[0].bitmapData;
			
			// greyed-out back
			GREY_BACK.bitmapData = data;
			// full-color front
			BMP_CONT.addChild(new FBitmap(data));
			BMP_CONT.align(Align.CENTER, Align.CENTER);
			
			TEXT.y += data.height / 2 + TEXT.height;
			
			Restart(INSTANCE.bytesToLoad, false);
		}
		
		override public function progress(e:Event):void {
			var loadedRatio:Number = MLoader.bytesLoaded / bytesToLoad;
			// fuck this for good!
//			TPlayer.DEFAULT.removePlaylist(tlist, false);
//			tlist = TPlayer.DEFAULT.addTween(new TLinear(new TVector1(loadedRatio),
//													  getProgress, setProgress, 0.3));
//			setProgress(currentProgress);
			setProgress(new TVector1(loadedRatio));
		}
		
		public function getProgress():TVector1 { return currentProgress; }
		public function setProgress(p:TVector1):void  {
			currentProgress.x = p.x;
			if (currentProgress.x > 1) currentProgress.x = 1;
			var bmp:FBitmap = (getChildAt(0) as DisplayObjectContainer).getChildAt(1) as FBitmap;
			bmp.scrollRect = new Rectangle(0,0,bmp.bitmapData.width,bmp.bitmapData.height * currentProgress.x);
		}
		
		override public function stopTracking(dummy:* = undefined):void {
			if (bytesToLoad != MLoader.bytesTotal) trace(this, "bytesToLoad =", bytesToLoad, "loaded =",MLoader.bytesLoaded, MLoader.bytesTotal);
			super.stopTracking(dummy);
			TPlayer.DEFAULT.removePlaylist(tlist, false);
		}
	}
}