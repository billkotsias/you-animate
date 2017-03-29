package tools.lights
{
	import flash.utils.getQualifiedClassName;
	
	import scene.Scene;
	import scene.serialize.ISerialize;
	
	public class LightsOptions implements ISerialize
	{
		public var ambienceColor:uint;
		public var elevation:Number;
		public var direction:Number;
		public var shadows:Boolean;
		
		public function LightsOptions()
		{
		}
		
		public function serialize(dat:* = undefined):Object
		{
			const obj:Object = {};
			obj.t = getQualifiedClassName(this);
			obj.am = ambienceColor;
			obj.el = elevation;
			obj.di = direction;
			obj.sh = shadows;
			return obj;
		}
		
		// TODO : remove Scene.INSTACE from all deserialize SHITTTTT!
		public function deserialize(obj:Object):void
		{
			ambienceColor = obj.am;
			elevation = obj.el;
			direction = obj.di;
			shadows = obj.sh;
			Scene.INSTANCE.lights.options = this;
		}
	}
}