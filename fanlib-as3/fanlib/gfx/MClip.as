package fanlib.gfx {
	
	import fanlib.event.ObjEvent;
	import fanlib.utils.FArray;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class MClip extends EventDispatcher {

		public static var FULLY_INIT:String = "ClipStarted";
		public static var REACHED_END:String = "ReachedEnd";
		
		public var loop:Number;
		public var transparent:Boolean = true;
		
		private var videoCont:TSprite = new TSprite();
		private var video:Video;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var bmps:Array = new Array();
		private var previousTime:Number;
		private var bitmapData:BitmapData;
		
		private var width:Number = NaN;
		private var height:Number = NaN;
		
		private var started:Boolean;
		private var metadataRead:Boolean;
		private var fullyInit:Boolean;
		
		public function MClip(filepath:String = null, startPaused:Boolean = true):void {
			
			// default
			loop = 0; // loop, and return at start
			started = false;
			metadataRead = false;
			fullyInit = false;
			
			nc = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
			ns.client = {onMetaData:this.onMetaData, onCuePoint:this.onCuePoint};
			ns.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
            nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onStatus);
			
			video = new Video();
			video.smoothing = true;
			video.attachNetStream(ns);
			videoCont.addChild(video);
			
			if (filepath) play(filepath, startPaused);
		}
			
		public function attachBitmap(bmp:Bitmap):void {
			if (bmps.indexOf(bmp) < 0) {
				bmp.bitmapData = bitmapData; // immediate effect
				bmps.push(bmp);
			}
		}
		public function detachBitmap(bmp:Bitmap):void {
			var i:int = bmps.find(bmp);
			if (i >= 0) {
				bmps.removeFast(i);
			}
		}
		
		// initialize and start playing a new clip; if 'startPaused' == true, clip will only be initialized
		public function play(filepath:String, startPaused:Boolean = true):void {
			close();
			
			ns.play(filepath);
			if (startPaused) {
				pause();
			} else {
				resume();
			}
		}
		
		public function stopAndDetachAllBitmaps():void {
			rewindAndPause();
			bitmapData.fillRect(bitmapData.rect, 0);
			bmps.length = 0;
		}
		
		public function close():void {
			ns.close();
			
			started = false;
			metadataRead = false;
			fullyInit = false;
			
			previousTime = NaN;
			Stg.Get().removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function rewindAndPause():void {
			ns.seek(0);
			pause();
		}
		
		public function pause():void {
			ns.pause();
			Stg.Get().removeEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function resume():void {
			ns.resume();
			Stg.Get().addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
		}
		
		private function enterFrame(e:Event):void {
			if (ns.time == previousTime) return;
			previousTime = ns.time;
			if (bmps.length) {
				if (transparent) bitmapData.fillRect(bitmapData.rect, 0); 
				bitmapData.draw(videoCont, null, null, null, null, true);
				for (var i:int = 0; i < bmps.length; ++i) {
					(bmps[i] as Bitmap).bitmapData = bitmapData;
				}
			}
		}
		
		public function onMetaData(item:Object):void {
			if (metadataRead) return;
			
			video.width = item.width;
			video.height = item.height;
			videoCont.width = video.width;
			videoCont.height = video.height;
			
			bitmapData = new BitmapData(video.width, video.height, transparent, 0);
			metadataRead = true;
			checkFullyInit();
		}
		 
		public function onCuePoint(item:Object):void {
			//trace(item.name + "\t" + item.time);
		}
		
		public function onStatus(item:Object):void {
			//trace(item, item.info.code);
			
			if (item.info.code == "NetStream.Play.Stop") {
				
				if (!isNaN(loop)) ns.seek(loop);
				dispatchEvent(new ObjEvent(this, REACHED_END));
				
			} else if (item.info.code == "NetStream.Play.Start") {
				
				started = true;
				
			}
		}
		
		public function checkFullyInit():void {
			if (fullyInit) return;
			
			if (started && metadataRead) {
				fullyInit = true;
				dispatchEvent(new ObjEvent(this, FULLY_INIT));
			}
		}
		
		public function getSoundTransform():SoundTransform {
			return ns.soundTransform;
		}
		public function setSoundTransform(snd:SoundTransform):void {
			ns.soundTransform = snd;
		}
		
		public function getStarted():Boolean {
			return started;
		}
	}
}