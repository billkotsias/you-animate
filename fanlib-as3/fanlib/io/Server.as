package fanlib.io
{
	public class Server
	{
		static public var UncacheScripts:Boolean = false;
		
		static public function UncacheURL(url:String, force:Boolean = false):String {
			if (!(UncacheScripts || force)) return url;
			if (url.indexOf("?") < 0) {
				url += "?";
			} else {
				url += "&";
			}
			url += "uncache=" + int(Math.random() * 1000000);
			return url;
		}
	}
}