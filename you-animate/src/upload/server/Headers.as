package upload.server
{
	import fanlib.utils.Pair;
	
	import flash.net.URLRequestHeader;

	public class Headers
	{
		static private const HEADERS:Vector.<URLRequestHeader> = new Vector.<URLRequestHeader>;
		static public function AddHeader(name:String, value:String):void {
			if (value !== null) HEADERS.push(new URLRequestHeader(name, value));
		}
		
		static public function Get():Vector.<URLRequestHeader> { return HEADERS.concat() }
	}
}