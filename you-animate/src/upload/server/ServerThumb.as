package upload.server
{
	import fanlib.math.Maths;
	
	import flash.utils.ByteArray;
	
	import upload.CharEdit;

	public class ServerThumb extends ServerBytes
	{
		public function ServerThumb() {
		}
		
		public function sendThumbData(propName:String, charEdit:CharEdit, callback:Function, bytes:ByteArray):ServerThumb {
			return send(
				"Upload thumbnail",
				charEdit, callback, propName, "thumb"+Maths.randomUInt(10000).toString()+".img",
				bytes,
				null) as ServerThumb;
		}
	}
}