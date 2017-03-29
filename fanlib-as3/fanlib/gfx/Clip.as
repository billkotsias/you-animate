package fanlib.gfx {
	
	import fanlib.event.ObjEvent;
	import fanlib.utils.Debug;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class Clip extends TSprite {

		public static var FULLY_INIT:String = "ClipStarted";
		public static var REACHED_END:String = "ReachedEnd";
		
		public var loop:Boolean;
		
		private var video:Video;
		private var nc:NetConnection;
		private var ns:NetStream;
		
		private var started:Boolean;
		private var metadataRead:Boolean;
		private var fullyInit:Boolean;
		
		public function Clip(filepath:String = null, startPaused:Boolean = true):void {
			
			// default
			loop = true;
			started = false;
			metadataRead = false;
			fullyInit = false;
			
			nc = new NetConnection();
			nc.connect(null);
			
			ns = new NetStream(nc);
			//ns.inBufferSeek = true;
			ns.client = {onMetaData:this.onMetaData, onCuePoint:this.onCuePoint};
			ns.addEventListener(NetStatusEvent.NET_STATUS, onStatus);
			ns.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAError);
            nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onStatus);
			
			video = new Video();
			video.smoothing = true;
			video.attachNetStream(ns);
			addChild(video);
			if (filepath) play(filepath, startPaused);
		}

		private function onIOError(e:IOErrorEvent):void {
			Debug.field.appendText("\nio "+e);
			Debug.field.appendText("\n"+e.errorID+e.text+e.type);
		}
		private function onAError(e:AsyncErrorEvent):void {
			Debug.field.appendText("\nasync "+e);
			Debug.field.appendText("\n"+e.errorID+e.text+e.type);
		}
		
		// initialize and start playing a new clip; if 'startPaused' == true, clip will only be initialized
		public function play(filepath:String, startPaused:Boolean = true):void {
			close();
			
			ns.play(filepath);
			Debug.field.appendText("\nfuck it "+filepath);
			if (startPaused) pause();
		}
		
		// for 'XMLParser' - erm, in the future
		public function set media(filepath:String):void {
			play(filepath, false); // start immediately
		}
		
		public function close():void {
			ns.close();
			
			started = false;
			metadataRead = false;
			fullyInit = false;
		}
		
		public function pause():void {
			ns.pause();
		}
		
		public function resume():void {
			ns.resume();
		}
		
		public function rewindAndPause():void {
			ns.seek(0);
			ns.pause();
		}
		
		public function onMetaData(item:Object):void {

			// Resize video instance.
			video.width = item.width;
			video.height = item.height;
			metadataRead = true;
			checkFullyInit();
		}
		 
		public function onCuePoint(item:Object):void {
			//trace(item.name + "\t" + item.time);
		}
		
		public function onStatus(item:Object):void {
			//trace(item, item.info.code);
			
			if (item.info.code == "NetStream.Play.Stop") {
				
				if (loop) {
					ns.seek(0);
					ns.resume();
				}
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
				childChanged(this);
			}
		}
		
		public function getVideo():Video {
			return video;
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