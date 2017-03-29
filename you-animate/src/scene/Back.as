package scene
{
	import fanlib.containers.Array2D;
	import fanlib.gfx.Align;
	import fanlib.gfx.Gfx;
	import fanlib.gfx.Stg;
	import fanlib.starling.FBitmap;
	import fanlib.starling.FSprite;
	import fanlib.ui.BrowseLocal;
	import fanlib.utils.Pausable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.sampler.startSampling;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import scene.camera.Camera;
	import scene.camera.Zoom2DProps;
	import scene.layers.LayerUI;
	import scene.serialize.ISerialize;
	
	import starling.display.Quad;

	public class Back extends FSprite implements ISerialize
	{
		private var _bytes:ByteArray;
		private var _fileName:String;
		private var loader:Loader;
		private var _bitmapData:BitmapData; // original, unsplit
		private const pauseVisible:Pausable = new Pausable();
		
		private const tempPoint:Point = new Point();
		
		public function Back()
		{
			super();
			align(Align.CENTER, Align.CENTER);
		}
		
		public function browseForTexture():void {
			checkInitState();
			new BrowseLocal(new FileFilter("JPEG, PNG, GIF files", "*.jpg;*.jpeg;*.gif;*.png"), setBytes, setFileNameRef);
		}
		private function setFileNameRef(fileRef:FileReference):void {
			_fileName = fileRef.name;
		}
		
		public function getBytes():ByteArray { return _bytes; }
		public function setBytes(bytes:ByteArray, addHistoryState:Boolean = true):void {
			if (addHistoryState) checkInitState();
			
			_bytes = bytes;
			if (_bytes) {
				if (loader) loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesLoaded);
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, bytesLoaded, false, 0, true);
				loader.loadBytes(bytes);
			} else {
				_fileName = null;
				bitmapData = null;
				Scene.INSTANCE.camera3D.removeEventListener(Camera.ZOOM_2D_CHANGED, zoom2D);
			}
			
			if (addHistoryState) Scene.INSTANCE.history.addState(this, getHistoryState());
		}
		protected function bytesLoaded(e:Event):void {
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, bytesLoaded);
			bitmapData = ((loader.getChildAt(0) as Bitmap).bitmapData); // get yer bitmapData
			loader = null;
			
			Scene.INSTANCE.camera3D.addEventListener(Camera.ZOOM_2D_CHANGED, zoom2D);
		}
		public function get bitmapData():BitmapData { return _bitmapData }
		public function set bitmapData(b:BitmapData):void {
			removeChildren(0,-1,true);
			_bitmapData = b;
			
			// by-pass stencil-buffer bug conflict with Flare3D
			var bmpBug:FBitmap = new FBitmap(null);
			addChild(bmpBug);
			
			if (b) {
				const split:Array = Utils3D.SplitOversizedToStarling(b).table;
//				for (var i:int = 0; i <= table.length - 1; ++i) {
				for (var i:int = split.length - 1; i >= 0; --i) { // NOTE : ESSENTIAL order
					const bmp:FBitmap = split[i];
					addChild(bmp);
				}
			}
			
			zoom2D();
			Scene.INSTANCE.dispatchEvent(new Event(Scene.BACKGROUND_CHANGE));
		}
		
		private function centerViewport():void {
			x = stage.stageWidth / 2;
			y = stage.stageHeight / 2;
			Gfx.SetMaxSize(this, stage.stageWidth, stage.stageHeight, true);
			align(Align.CENTER, Align.CENTER);
		}
		
		private function zoom2D(o:Event = null):void {
			centerViewport();
			
			if (Scene.INSTANCE.camera3D.zoom2DEnabled) {
				const zoom2Dprops:Zoom2DProps = Scene.INSTANCE.camera3D.zoom2DProps;
				const scale:Number = zoom2Dprops.scale;
				x += (x - zoom2Dprops.viewportPos.x) * scale;
				y += (y - zoom2Dprops.viewportPos.y) * scale;
				scaleX *= scale;
				scaleY *= scale;
				align(Align.CENTER, Align.CENTER);
			}
		}
		
		// visibility
		public function setInvisible(setter:*):void {
			pauseVisible.pause(setter);
			visible = false;
		}
		public function unsetInvisible(setter:*):void {
			if (!pauseVisible.unpause(setter)) visible = true;
		}
		
		public function set fileName(f:String):void { _fileName = f }
		public function get fileName():String { return _fileName }
		
		// undo
		
		private function getHistoryState():HistoryState {
			const fname:String = _fileName;
			const bytes:ByteArray = _bytes;
			return new HistoryState(
				function():void {
					_fileName = fname;
					setBytes(bytes, false);
				});
		}
		
		private function checkInitState():void {
			if ( !Scene.INSTANCE.history.hasStateList(this) )
				Scene.INSTANCE.history.newStateList(this, getHistoryState());
		}
		
		// save
		
		public function serialize(dat:* = undefined):Object {
			const obj:Object = {};
			obj.t = getQualifiedClassName(this);
			obj.f = _fileName;
			obj.b = _bytes;
			return obj;
		}
		public function deserialize(obj:Object):void {
			Scene.INSTANCE.background = this;
			_fileName = obj.f;
			setBytes(obj.b, false);
			Scene.INSTANCE.dispatchEvent(new Event(Scene.BACKGROUND_CHANGE));
		}

	}
}