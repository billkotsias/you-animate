package upload
{
	import fanlib.gfx.Stg;
	
	import flare.system.Input3D;
	import flare.utils.Vector3DUtils;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	public class ModelViewer extends AutoResizeScene3D
	{
		// NOTE : Must change whole logic (have a target point, always look at it, rotate around THAT, change distance to it)
		private const out:Vector3D = new Vector3D(); // temp data holder
		
		public var renderTarget:Bitmap;
		
		public function ModelViewer(container:DisplayObjectContainer, file:String="")
		{
			super(container, file);
//			Input3D.rightClickEnabled = true;
		}
		
		public function set viewportInteractive(dobj:DisplayObject):void {
			dobj.addEventListener(MouseEvent.MOUSE_DOWN, viewportDown);
			dobj.addEventListener(MouseEvent.MOUSE_WHEEL, viewportWheel);
			dobj.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, viewportRight);
		}
		
		//
		
		private function viewportRight(e:MouseEvent):void {
			Stg.Get().addEventListener(MouseEvent.MOUSE_MOVE, rightMove);
			Stg.Get().addEventListener(MouseEvent.RIGHT_MOUSE_UP, rightStop);
			Stg.Get().addEventListener(Event.MOUSE_LEAVE, rightStop);
		}
		private function rightStop(e:Event):void {
			Stg.Get().removeEventListener(MouseEvent.MOUSE_MOVE, rightMove);
			Stg.Get().removeEventListener(MouseEvent.RIGHT_MOUSE_UP, mMoveStop);
			Stg.Get().removeEventListener(Event.MOUSE_LEAVE, mMoveStop);
		}
		
		private function viewportDown(e:MouseEvent):void {
			Stg.Get().addEventListener(MouseEvent.MOUSE_MOVE, mMove);
			Stg.Get().addEventListener(MouseEvent.MOUSE_UP, mMoveStop);
			Stg.Get().addEventListener(MouseEvent.RELEASE_OUTSIDE, mMoveStop);
		}
		private function mMoveStop(e:Event):void {
			Stg.Get().removeEventListener(MouseEvent.MOUSE_MOVE, mMove);
			Stg.Get().removeEventListener(MouseEvent.MOUSE_UP, mMoveStop);
			Stg.Get().removeEventListener(MouseEvent.RELEASE_OUTSIDE, mMoveStop);
		}
		
		//
		
		private function rightMove(e:MouseEvent):void {
			camera.translateX( -Input3D.mouseXSpeed * camera.getPosition().length / 300 );
			camera.translateY( Input3D.mouseYSpeed * camera.getPosition().length / 300 );
			updateRenderTarget();
		}
		
		private function mMove(e:MouseEvent):void {
			camera.rotateY( Input3D.mouseXSpeed, false, Vector3DUtils.ZERO );
			camera.rotateX( Input3D.mouseYSpeed, true, Vector3DUtils.ZERO );
			updateRenderTarget();
		}
		
		private function viewportWheel(e:MouseEvent):void {
			if ( e.delta != 0 ) camera.translateZ( camera.getPosition( false, out ).length * e.delta / 20 );
			updateRenderTarget();
		}
		
		public function updateRenderTarget():void {
			if (!renderTarget) return;
			renderTarget.bitmapData = Snapshot3D.Get(this, renderTarget.bitmapData);
		}
	}
}