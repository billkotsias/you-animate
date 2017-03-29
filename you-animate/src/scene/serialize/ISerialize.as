package scene.serialize
{
	public interface ISerialize
	{
		/**
		 * @param dat Optional, external data may be required by serializing Object
		 * @return Serialized Object (ByteArray-able)
		 */
		function serialize(dat:* = undefined):Object;
		function deserialize(obj:Object):void;
	}
}