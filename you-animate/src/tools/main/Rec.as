package tools.main
{
	import com.rainbowcreatures.swf.FWVideoEncoder;
	
	import fanlib.event.Unlistener;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.TSprite;
	import fanlib.gfx.vector.FShape;
	import fanlib.gfx.vector.TopLayer;
	import fanlib.text.FTextField;
	import fanlib.ui.FButton2;
	CONFIG::debug { import fanlib.utils.Debug; }
	
	import flare.basic.Scene3D;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.globalization.DateTimeFormatter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	import scene.Scene;
	
	import ui.ContextWindow;
	import ui.LabelInput;
	import ui.play.Timeline;
	import fanlib.utils.IChange;
	import scene.camera.ZoomWindow;
	import flash.display3D.Context3D;
	import flare.system.Device3D;
	
	public class Rec extends ContextWindow
	{
		static public const END_INFO:String = "End of recording - <red>Click to save</red>"
			
		private var myEncoder:FWVideoEncoder;
		private var encoderReady:Boolean;
		
		private var vWidth:uint;
		private var vHeight:uint;
		private var vFps:Number;
		private var vBitrate:Number;
		private var vFramesTotal:uint;
		
		private var recording:Boolean;
		private var currentFrame:int;
		
		private var fileReference:FileReference;
		private const unlistener:Unlistener = new Unlistener();
		
		public var timeline:Timeline;
		public var viewport:FShape;
		
		public var tWidth:LabelInput;
		public var tHeight:LabelInput;
		public var tFps:LabelInput;
		public var tBitrate:LabelInput;
		public var startRec:FButton2;
		
		public var zoomWindow:ZoomWindow;
		
		// debug
		private var timeTotal:int;
		
		public function Rec()
		{
			super();
			
			myEncoder = FWVideoEncoder.getInstance(this);
			myEncoder.addEventListener(StatusEvent.STATUS, onStatus);
//			myEncoder.load(Walk3D.APP_DIR + "rec_ogv/");
			myEncoder.load(Walk3D.APP_DIR + "rec_mp4/");
			CONFIG::debug {
				Debug.appendLine(this+"myEncoder.load");
			}
		}
		
//		override public function childChanged(obj:IChange):void {
//			trace(this,trackChanges,obj,new Error().getStackTrace());
//			super.childChanged(obj);
//			for (var i:int = 0; i < numChildren; ++i) {
//				trace(this,getChildAt(i),getChildAt(i).name,getChildAt(i).getRect(Stg.Get()));
//			}
//		}
		
		override protected function contextSelected(e:Event):void {
			CONFIG::debug { Debug.appendLine(this+"contextSelected"+e.toString()); }
			super.contextSelected(e);
			unlistener.addListener(startRec, FButton2.CLICKED, startRecord);
		}
		
		override protected function contextDeselected(e:Event):void {
			CONFIG::debug { Debug.appendLine(this+"contextDeselected"+e.toString()); }
			super.contextDeselected(e);
			unlistener.removeAll();
			stopRecord();
		}
		
		public function startRecord(e:* = undefined):void {
			CONFIG::debug { Debug.appendLine(this+"encoderReady"+encoderReady); }
			recording = true;
			startRec.enabled = false;
			if (!encoderReady) return; // wait for actual encoder code to load!
			
			vWidth = tWidth.result;
			vHeight = tHeight.result;
//			vWidth = viewport.width;
//			vHeight = viewport.height;
//			const scale:Number = Math.min(uint(tWidth.input) / viewport.width, uint(tHeight.input) / viewport.height);

			vFps = Number(tFps.input);
			vBitrate = Number(tBitrate.input) * 1000;
			vFramesTotal = timeline.durationTotal * vFps;
			
			currentFrame = 0;
			timeline.value = 0;
			timeTotal = getTimer();
			Scene.INSTANCE.camera3D.zoom2DEnabled = zoomWindow.enableZoom2DBut.state;
			
			myEncoder.forcePTSMode(FWVideoEncoder.PTS_MONO);
			myEncoder.forceFramedropMode(FWVideoEncoder.FRAMEDROP_OFF);
			myEncoder.start(vFps, FWVideoEncoder.AUDIO_OFF, false, vWidth, vHeight, vBitrate, 44100, 64000, 0, null);
		}
		
		private function captureFrame(e:Event):void {
			const timeSinceLast:int = getTimer() - timeTotal;
			timeTotal += timeSinceLast;
//			trace(this,"timeSinceLast",timeSinceLast);
//			Stg.Get().addEventListener(Event.ENTER_FRAME, function(e:Event):void {
//				Stg.Get().removeEventListener(Event.ENTER_FRAME, arguments.callee);
//			});
			const scene3D:Scene3D = Scene.INSTANCE.iScene3D as Scene3D;
			const context3D:Context3D = scene3D.context;
			context3D.clear(0,0,0,0);
			Walk3D.starlingBack.nextFrame();
			scene3D.render();
			myEncoder.capture(context3D);
//			context3D.present();
			
			timeline.value = (++currentFrame) / vFramesTotal; // no time error accumulated this way!
			if (currentFrame >= vFramesTotal) {
				stopRecord();
			}
		}
		
		private function stopRecord():void {
			if (!recording) return;
			recording = false;
			myEncoder.finish();
			Scene.INSTANCE.camera3D.zoom2DEnabled = false;
			Stg.Get().removeEventListener(Event.ENTER_FRAME, captureFrame);
//			unlistener.removeListener(Scene.INSTANCE.iScene3D as Scene3D, Scene3D.POSTRENDER_EVENT, captureFrame);
		}
		
		private function onStatus(e:StatusEvent):void {
			CONFIG::debug { Debug.appendLine(this+e.toString()); }
			if (e.code === "ready") {
				
				encoderReady = true;
				if (recording) startRecord();
				
			} else if (e.code === "started") {

				Stg.Get().addEventListener(Event.ENTER_FRAME, captureFrame);
//				unlistener.addListener(Scene.INSTANCE.iScene3D as Scene3D, Scene3D.POSTRENDER_EVENT, captureFrame);
				
			} else if (e.code === "encoded") {
				
				const video:ByteArray = myEncoder.getVideo(); // as soon as “encoded” is dispatched, you can getVideo()
				const dtf:DateTimeFormatter = new DateTimeFormatter("en-US");
				dtf.setDateTimePattern("yyyy-MM-dd 'at' HH-mm-ss");
				const recordingDate:String = dtf.format(new Date());
				
				const topLayer:TopLayer = FSprite.FromTemplate("endOfRec") as TopLayer;
				(topLayer.findChild("info") as FTextField).htmlText = END_INFO +
					"<small>\n<grey>Frames: </grey>" + currentFrame + "   <grey>Size: </grey>" + (video.length >>> 10) + "KBs</small>";
				topLayer.addEventListener(
					MouseEvent.MOUSE_DOWN,
					function(e:MouseEvent):void {
						topLayer.removeEventListener(MouseEvent.MOUSE_DOWN, arguments.callee);
						topLayer.fadeAway();
						
						fileReference = new FileReference();
						fileReference.addEventListener(Event.COMPLETE, fileRefComplete);
						fileReference.addEventListener(IOErrorEvent.IO_ERROR, fileRefError);
						fileReference.save(video, "Recording " + recordingDate + ".mp4");
					}
				);
				
				startRec.enabled = true;
			}
		}
		
		private function fileRefComplete(e:Event):void {
			fileReference = null;
		}
		private function fileRefError(e:IOErrorEvent):void {
			fileReference = null;
		}
	}
}