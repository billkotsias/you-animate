package fanlib.io
{
	import fanlib.utils.Enum;
	
	import flash.net.SharedObject;
	import flash.utils.Dictionary;

	public class SharedData
	{
		private var so:SharedObject;
		
		public function SharedData(name:String, localPath:String = null, secure:Boolean = false)
		{
			// TODO : pass-in at construction time pairs of [String,default values]
			so = SharedObject.getLocal(name, localPath, secure);
		}
		
		public function getData(name:String, defaultValue:* = undefined, writeDefault:Boolean = false):* {
			var value:* = so.data[name];
			if (value === undefined) {
				value = defaultValue;
				if (writeDefault) so.data[name] = defaultValue;
			}
			return value;
		}
		
		public function setData(name:String, data:*):* {
			so.data[name] = data;
			return data;
		}
		
		public function get sharedObject():SharedObject { return so; }
	}
}