package scene.camera.anim
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import scene.Scene;
	import scene.serialize.ISerialize;

	public class AbstractZoomKey extends EventDispatcher implements ISerialize {
		
		public var zoom:Number; // = viewport.width / rectangle.width
		private var _time:Number; // position in timeline
		public var ui:AbstractZoomKeyUI;
		
		public function AbstractZoomKey()
		{
		}
		
		public function get time():Number { return _time }
		public function set time(value:Number):void
		{
			if (value < 0) value = 0;
			_time = value;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		//
		
		public function serialize(dat:* = undefined):Object {
			const obj:Object = {};
			obj.t = getQualifiedClassName(this);
			obj.z = zoom;
			obj.ti = _time;
			return obj;
		}
		
		public function deserialize(obj:Object):void {
			zoom = obj.z;
			time = obj.ti;
			Scene.INSTANCE.zoomMan.addKey(this);
		}
	}
}