package upload.server
{
	public class CharInfo
	{
		// returned from server
		public var character:String;
		public var model:String;
		
		// user-defined
		public var title:String = "A new challenger"; // name
		public var scale:Number = 1;
		public var hide:Boolean = true;

		// misc
		public var description:String;
		public var tags:String;
		public var polygons:uint;
		public var geometry:String;
		public var body_rigged:Boolean;
		public var facial_rigged:Boolean;
		public var textures:String;
		public var materials:Boolean;
		public var uv_mapped:Boolean;
		public var uv_unwrapped:Boolean;
		public var units:Boolean;
		
		public function CharInfo() {
		}
	}
}