package tools.param
{
	public class Param
	{
		public var getSetName:String;
		public var defaultGetName:String;
		
		public function Param(getSetName:String = null, defaultGetName:String = null) {
			this.getSetName = getSetName;
			this.defaultGetName = defaultGetName;
		}
		
		public function toString():String {
			return "[Param] " + getSetName + " " + defaultGetName;
		}
	}
}