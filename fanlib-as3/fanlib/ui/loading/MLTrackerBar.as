package fanlib.ui.loading {
	
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Shape;
	import fanlib.io.MLoader;
	import fanlib.tween.TVector2;
	import fanlib.tween.TList;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TSin;
	import fanlib.tween.TVector1;
	import flash.events.Event;
	import fanlib.utils.Debug;
	import fanlib.tween.TLinear;
	import fanlib.gfx.TSprite;
	
	public class MLTrackerBar extends MLTracker {

		public const barCont:TSprite = new TSprite();
		public const bar:Shape = new Shape();
		private var currentProgress:TVector1 = new TVector1(0);
		private var tlist:TList;
		
		public var bytesToPixelsRatio:Number = 0.001; // default = 1KB/pixel
		public var lineWidth:Number = 3;
		
		public function MLTrackerBar() {
			
			addChild(barCont);
			
			barCont.addChild(bar);
			bar.scaleX = 0.99;
			bar.scaleY = 0.7;
			
			setProgress(currentProgress);
		}
		
		public function resetProgress():void {
			MLoader.bytesLoaded = 0;
			MLoader.bytesTotal = 0;
			currentProgress.x = 0;
			setProgress(currentProgress);
		}
		
		override public function progress(e:Event):void {
			// will have to look into this, why it works like "blaf"
//			var loadedRatio:Number = MLoader.bytesLoaded / MLoader.bytesTotal;
//			if (loadedRatio < bytesToPixelsRatio * 10) return;
//			
//			TPlayer.DEFAULT.removePlaylist(tlist, false);
//			tlist = TPlayer.DEFAULT.addTween(new TLinear(new TVector1(loadedRatio),
//													  getProgress, setProgress, 0.3));
			currentProgress.x = (MLoader.bytesLoaded >= MLoader.bytesTotal) ? 1 : (MLoader.bytesLoaded / MLoader.bytesTotal);
			setProgress(currentProgress);
		}
		
		public function getProgress():TVector1 { return currentProgress; }
		public function setProgress(p:TVector1):void  {
			
			currentProgress.x = p.x;
			
			// bar container
			var w:Number = MLoader.bytesTotal * bytesToPixelsRatio;
			barCont.graphics.clear();
			barCont.graphics.lineStyle(lineWidth, 0, 0.5, true, LineScaleMode.NONE, CapsStyle.ROUND, JointStyle.ROUND);
			barCont.graphics.drawRect(-w/2, -50, w, 100);
			
			// bar
			bar.graphics.clear();
			if (!MLoader.bytesTotal) return;
			
			bar.graphics.lineStyle(0, 0x008888, 0.5, true, LineScaleMode.NONE, CapsStyle.ROUND, JointStyle.ROUND);
			bar.graphics.beginFill(0x008888, 0.5);
			bar.graphics.drawRect(0,0,
								  currentProgress.x * w, 100);
			bar.graphics.endFill();
			bar.x = - bar.width / 2;
			bar.y = - bar.height / 2;
		}

		override public function stopTracking(dummy:* = undefined):void {
			super.stopTracking(dummy);
			TPlayer.DEFAULT.removePlaylist(tlist, false);
		}

	}
	
}
