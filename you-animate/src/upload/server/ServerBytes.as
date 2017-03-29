package upload.server
{
	import fanlib.gfx.Stg;
	import fanlib.io.MPart;
	import fanlib.utils.Debug;
	import fanlib.utils.Utils;
	
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	
	import upload.CharEdit;

	public class ServerBytes extends ServerRequest
	{
		public function ServerBytes() {
		}
		
		public function send(
			title:String, charEdit:CharEdit, callback:Function, propName:String, filename:String, sourceBytes:ByteArray,
			extraData:Object = null):ServerBytes {
			
			// clone bytes now!
			const clone:ByteArray = new ByteArray();
			if (sourceBytes) {
				sourceBytes.position = 0;
				sourceBytes.readBytes(clone);
				clone.position = 0;
				sourceBytes.position = 0;
			}
			CONFIG::debug {Debug.appendLine(String(this)+" send bytes:"+clone.length); }
			
			QueueMessage( new QueuedURLLoader(title, function():URLLoader {
				
				const charInfo:CharInfo = charEdit.charInfo;
				const contentType:String = "application/octet-stream";
				clone.position = 0;
				
				const data:Object = Utils.Clone(extraData) || {};
				data["UploadCharacterForm[character]"] = charInfo.character;
				data["UploadCharacterForm[model]"] = charInfo.model;
				
				const mpart:MPart = new MPart( URLUpload() );
				mpart.addFields(data);
				mpart.addFile(propName, clone, contentType, filename);
				
				const urlloader:URLLoader = mpart.loadRequest(callback, null); // custom headers not required
				
				return urlloader;
			}) );
			
			return this;
		}
	}
}