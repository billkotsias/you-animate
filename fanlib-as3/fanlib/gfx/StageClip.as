package fanlib.gfx {
	
	import fanlib.event.ObjEvent;
	import fanlib.utils.Debug;
	import fanlib.utils.Utils;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class StageClip extends TSprite {

		public static var FULLY_INIT:String = "ClipStarted";
		public static var REACHED_END:String = "ReachedEnd";
		
		public var loop:int;
		
		private var video:StageVideo;
		private var nc:NetConnection;
		private var ns:NetStream;
		private var file:String;
		
		private var started:Boolean;
		private var metadataRead:Boolean;
		private var fullyInit:Boolean;
		
		public function StageClip(filepath:String = null):void {
			
			// default
			loop = 0;
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
			
			file = filepath;
			// FUCK FLASH
			Stg.Get().addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
		}
		
		private function onIOError(e:IOErrorEvent):void {
			Debug.field.appendText("\nio "+e);
			Debug.field.appendText("\n"+e.errorID+e.text+e.type);
		}
		private function onAError(e:AsyncErrorEvent):void {
			Debug.field.appendText("\nasync "+e);
			Debug.field.appendText("\n"+e.errorID+e.text+e.type);
		}
		
		private function onStageVideoState(event:StageVideoAvailabilityEvent):void {
			Stg.Get().removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoState);
			Debug.field.appendText("\n"+event.availability+(event.availability==StageVideoAvailability.AVAILABLE));
			if (event.availability != StageVideoAvailability.AVAILABLE) return;
			
			Debug.field.appendText("\nfuck me do"+Stg.Get().stageVideos);
			video = Stg.Get().stageVideos[0];			
			Debug.field.appendText("\nfuck me do2");
			video.attachNetStream(ns);
			Debug.field.appendText("\nfuck me do3"+" "+video.toString());
			if (file) play(file, false);
		}
		
		// initialize and start playing a new clip; if 'startPaused' == true, clip will only be initialized
		public function play(filepath:String, startPaused:Boolean = true):void {
			close();
			
			Debug.field.appendText("\nfuck yeah"+filepath);
			ns.play(filepath);
			Debug.field.appendText("\nfuck yeah"+filepath);
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
			Debug.field.appendText("\n"+this+Utils.PrettyString(item)+"\n"+video);

			// Resize video instance.
			if (video) video.viewPort = new Rectangle(0,0,item.width,item.height);
			metadataRead = true;
			checkFullyInit();
		}
		 
		public function onCuePoint(item:Object):void {
			//trace(item.name + "\t" + item.time);
		}
		
		public function onStatus(item:Object):void {
			Debug.field.appendText("\n"+this+Utils.PrettyString(item)+"\n"+video);
			Debug.field.appendText("\n"+item.info.code);
			
			if (item.info.code == "NetStream.Play.Stop") {
				
				if (loop && --loop) {
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
		
		public function getVideo():StageVideo {
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