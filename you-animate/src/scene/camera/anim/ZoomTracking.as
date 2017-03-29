package scene.camera.anim
{
	import scene.Character;

	public class ZoomTracking extends AbstractZoomKey
	{
		public var char:Character;
		
		public function ZoomTracking()
		{
			super();
		}
		
		override public function serialize(dat:* = undefined):Object {
			const obj:Object = super.serialize(dat);
//			obj.c = charIndex?
			return obj;
		}
		
		override public function deserialize(obj:Object):void {
			super.deserialize(obj);
//			char = fromIndex?
		}
	}
}