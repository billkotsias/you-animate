package test   
{
	import flare.basic.*;
	import flare.core.*;
	import flare.system.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.getTimer;
	
	/**
	 * @author Ariel Nehmad
	 */
	[SWF(width='1280',height='800',backgroundColor='#cccccc',frameRate='60')]
	public class Zoom extends Sprite 
	{
		private var _scene:Scene3D;
		private var main:Vector.<Number>;
		private var zoom:Vector.<Number>;
		private var proj:Matrix3D;
		
		public function Zoom() 
		{
//			trace("asdf");
//			const mat:Matrix3D = new Matrix3D();
//			const dat:Vector.<Number> = mat.rawData;
//			const j:int = 10000000;
//			var time:int = getTimer();
//			for (var i:int = j; i >= 0; --i) {
//				mat.rawData = dat;
//			}
//			trace(getTimer()-time);
//			time = getTimer();
//			for (var i:int = j; i >= 0; --i) {
//				mat.copyRawDataFrom(dat);
//			}
//			trace(getTimer()-time);
			_scene = new Viewer3D(this);
			_scene.addChildFromFile("D:/Projects/Flash/Walk3D/bin-debug/data/props/scooter.zf3d");
			_scene.autoResize = false;
			_scene.setViewport(320,200,640,400,2);
			_scene.addEventListener(Scene3D.COMPLETE_EVENT, completeEvent);
			trace("aspectRatio",_scene.camera.aspectRatio);
		}
		
		private function completeEvent(e:Event):void 
		{
			Input3D.rightClickEnabled = true;
			_scene.camera.setPosition(100,100,100);
			_scene.camera.lookAt(0,0,0);
			var cam:Camera3D = _scene.camera;
			trace("aspectRatio",cam.aspectRatio);
			trace(cam.projection.rawData[0], 1/Math.tan(cam.fieldOfView*Math.PI/360));
			trace(cam.projection.rawData[5], _scene.viewPort.width/_scene.viewPort.height * 1/Math.tan(cam.fieldOfView*Math.PI/180/2));
			trace(cam.projection.rawData[10], (cam.far)/(cam.far-cam.near));
			trace(cam.projection.rawData[14], (-cam.near*cam.far)/(cam.far-cam.near));
			
			// unfortunately, we need to disable culling, otherwise, since projection planes are not longer valid.
			_scene.forEach(function(m:Mesh3D):void { m.bounds = null }, Mesh3D);
			
			_scene.addEventListener(Scene3D.RENDER_EVENT, renderEvent);
			
			main = cam.projection.rawData;
			zoom = cam.projection.rawData;
			proj = cam.projection = cam.projection;
			trace(proj.rawData);
			cam.fovMode = 2;
			trace(proj.rawData);
			trace("fieldOfView",cam.fieldOfView);
			cam.zoom *= 4;
			trace("fieldOfView",cam.fieldOfView);
			trace(proj.rawData);
		}
		
		private function renderEvent(e:Event):void 
		{
			var viewWidth:Number = _scene.viewPort.width;
			var viewHeight:Number = _scene.viewPort.height;
			
			// our zoom rectangle
			var rw:Number = 160;
			var rh:Number = rw * (viewHeight/viewWidth); // if we don't use the same aspect ratio, the image will be stretched.
			var rx:Number = _scene.viewPort.x + viewWidth * 0.5 - stage.mouseX;
			var ry:Number = _scene.viewPort.y + viewHeight * 0.5 - stage.mouseY;
			
			graphics.clear();
			
			if (Input3D.rightMouseDown) {
				
				var scaleX:Number = viewWidth / rw;
				var scaleY:Number = viewHeight / rh;
				var transX:Number = 2*rx/rw;
				var transY:Number = 2*ry/rh;
				
				zoom[0] = main[0] * scaleX;
				zoom[5] = main[5] * scaleY;
				zoom[8] = transX;
				zoom[9] = -transY;
				
				proj.rawData = zoom;
				
			} else {
				
				proj.rawData = main;
				
				graphics.lineStyle(1, 0xff0000);
				graphics.drawRect( stage.mouseX - rw/2, stage.mouseY - rh/2, rw, rh );
			}
		}
	}
}