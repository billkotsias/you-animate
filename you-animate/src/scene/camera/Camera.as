package scene.camera
{
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.system.Device3D;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import scene.Scene;
	import scene.serialize.ISerialize;
	import scene.serialize.Serialize;
	
	public class Camera extends Camera3D implements ISerialize
	{
		static public const ZOOM_CHANGED:String = "ZOOM_CHANGED";
		static public const ZOOM_2D_CHANGED:String = "ZOOM_2D_CHANGED";
		static public const PI_DIV_360:Number = Math.PI / 360;
		
		static public var DefaultSettings:Object;
		
		CONFIG::oldFlare { private const origMeshBounds:Dictionary = new Dictionary(true); }
		
		private var _zoom2DEnabled:Boolean;
		private var projectionRaw:Vector.<Number> = new Vector.<Number>(16,true);
		private var alterProjectionRaw:Vector.<Number> = new Vector.<Number>(16,true);
		public const zoom2DProps:Zoom2DProps = new Zoom2DProps();
		
		
		public function Camera(name:String="", fieldOfView:Number=75, near:Number=1, far:Number=5000)
		{
			super(name, fieldOfView, near, far);
			projection = projection; // NOTE : Override Flare3D internal wisdom
			projectionRaw = projection.rawData;
			alterProjectionRaw = projectionRaw.concat();
		}
		
		public function getPixelScaleAt(distanceFromCamera:Number, viewportWidth:Number):Number {
			return 2 * distanceFromCamera * Math.tan(fieldOfView * PI_DIV_360) / viewportWidth;
		}
		
		public function recalcProjectionFOV():void {
			projectionRaw[0] = 1 / Math.tan(fieldOfView * PI_DIV_360);
			alterProjectionRaw[0] = projectionRaw[0] * zoom2DProps.scale;
			
			projectionRaw[5] = projectionRaw[0] * aspectRatio;
			alterProjectionRaw[5] = alterProjectionRaw[0] * aspectRatio;
			
			setRawData();
		}
		public function recalcProjectionClipping():void {
			const invFrustumDepth:Number = 1 / (far - near);
			alterProjectionRaw[10] = projectionRaw[10] = far * invFrustumDepth;
			alterProjectionRaw[14] = projectionRaw[14] = - near * far * invFrustumDepth;
			
			setRawData();
		}
		
		override public function set fieldOfView(value:Number):void {
			super.fieldOfView = value;
			recalcProjectionFOV();
			dispatchEvent(new Event(ZOOM_CHANGED));
		}
		override public function set zoom(value:Number):void {
			super.zoom = value;
			recalcProjectionFOV();
			dispatchEvent(new Event(ZOOM_CHANGED));
		}
		
		override public function set far(value:Number):void {
			super.far = value;
			recalcProjectionClipping();
		}
		override public function set near(value:Number):void {
			super.near = value;
			recalcProjectionClipping();
		}
		
		public function get zoom2DEnabled():Boolean { return _zoom2DEnabled }
		public function set zoom2DEnabled(e:Boolean):void {
			if (_zoom2DEnabled === e) return; // back off
			_zoom2DEnabled = e;
			
			if (e) {
				CONFIG::newFlare { Device3D.ignoreCameraCulling = true; }
				CONFIG::oldFlare { (this.scene).forEach(function (m:Mesh3D):void { origMeshBounds[m] = m.bounds; m.bounds = null; }, Mesh3D); }
			} else {
				CONFIG::newFlare { Device3D.ignoreCameraCulling = false; }
				CONFIG::oldFlare { for (var m:* in origMeshBounds) m.bounds = origMeshBounds[m]; }
			}
			
			setRawData();
			dispatchEvent(new Event(ZOOM_2D_CHANGED)); // = "zoom 2D unset"
		}
		
		/**
		 * Zoom view into a 2D rectangle. Rectangle height calculated from viewport's aspect ratio.
		 * @param stageX Rectangle x-center (stage coordinate)
		 * @param stageY Rectangle y-center (stage coordinate)
		 * @param rw Rectangle width
		 */
		public function setZoom2D(stageX:Number, stageY:Number, rw:Number):void {
			const rh:Number = rw / aspectRatio; // was: * (viewHeight/viewWidth) - if we don't use the same aspect ratio, the image will be stretched
			
			const viewPort:Rectangle = (this.scene).viewPort;
			const viewWidth:Number = viewPort.width;
			const scale:Number = viewWidth / rw; // NOTE : if same aspect ratio, viewWidth/rw === viewHeight/rh
			
			alterProjectionRaw[0] = projectionRaw[0] * scale;
			alterProjectionRaw[5] = projectionRaw[5] * scale;
			
			// make rectangle position relative to viewport's center
			const rx:Number = viewPort.x + viewWidth * 0.5 - stageX;
			const ry:Number = viewPort.y + viewPort.height * 0.5 - stageY;
			
			alterProjectionRaw[8] = 2*rx/rw;
			alterProjectionRaw[9] = -2*ry/rh;
			
			if (_zoom2DEnabled) projection.rawData = alterProjectionRaw; // set quickly
			
			zoom2DProps.scale = scale;
			zoom2DProps.viewportPos.copyFrom( Scene.INSTANCE.viewport.globalToLocal(new Point(stageX, stageY)) );
			
			dispatchEvent(new Event(ZOOM_2D_CHANGED));
		}
		
		public function setZoom2D2(xRelative:Number, yRelative:Number, scale:Number):void {
			alterProjectionRaw[0] = projectionRaw[0] * scale;
			alterProjectionRaw[5] = projectionRaw[5] * scale;
			alterProjectionRaw[8] = -2 * xRelative * scale;
			alterProjectionRaw[9] = 2 * yRelative * scale;
			
			if (_zoom2DEnabled) projection.rawData = alterProjectionRaw;
			
			zoom2DProps.scale = scale;
			const viewport:DisplayObject = Scene.INSTANCE.viewport;
			const vRect:Rectangle = viewport.getRect(viewport);
			zoom2DProps.viewportPos.x = (0.5 + xRelative) * vRect.width;
			zoom2DProps.viewportPos.y = (0.5 + yRelative) * vRect.height;
			
			dispatchEvent(new Event(ZOOM_2D_CHANGED));
		}
		
		private function setRawData():void {
			projection.rawData = _zoom2DEnabled ? alterProjectionRaw : projectionRaw;
		}
		
		// save
		
		public function serialize(dat:* = undefined):Object {
			var obj:Object = {};
			obj.t = getQualifiedClassName(this);
			obj.p = Serialize.Pivot3D_(this); // position, rotation, scaling
			obj.fov = fieldOfView;
//			obj.z = zoom;
			obj.n = near;
			obj.f = far;
			return obj;
		}
		public function deserialize(obj:Object):void {
			const sceneCamera:Camera3D = Scene.INSTANCE.camera3D; // override Flare3D's bug
			Serialize._Pivot3D(obj.p, sceneCamera);
			if (obj.fov) {
				sceneCamera.fieldOfView = obj.fov;
			} else {
				sceneCamera.zoom = obj.z;
			}
			sceneCamera.near = obj.n;
			sceneCamera.far = obj.f;
		}

	}
}