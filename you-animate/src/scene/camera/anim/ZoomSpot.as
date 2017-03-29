package scene.camera.anim
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import scene.serialize.Serialize;

	public class ZoomSpot extends AbstractZoomKey
	{
		public var x:Number;
		public var y:Number;
		
		public function ZoomSpot() {
			super();
		}

		override public function serialize(dat:* = undefined):Object {
			const obj:Object = super.serialize(dat);
			obj.x = x;
			obj.y = y;
			return obj;
		}
		
		override public function deserialize(obj:Object):void {
			x = obj.x;
			y = obj.y;
			super.deserialize(obj); // called last because creation event is dispatched here... anyway
		}
	}
}