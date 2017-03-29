package upload.server
{
	import fanlib.io.MPart;
	import fanlib.math.Maths;
	import fanlib.utils.Debug;
	import fanlib.utils.FStr;
	import fanlib.utils.Utils;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import mx.utils.Base64Encoder;
	
	import org.httpclient.http.multipart.Part;
	
	import upload.CharEdit;

	public class ServerF3DFile extends ServerRequest
	{
		public function ServerF3DFile() {
		}
		
		public function send(charEdit:CharEdit, callback:Function, fileRef:FileReference):ServerF3DFile
		{
//			const userAgent:String = ExternalInterface.call("window.navigator.userAgent.toString");
//			if ((userAgent.indexOf("Chrome") >= 0 || userAgent.indexOf("MSIE") >= 0)) {
			if (true) {
			
				QueueMessage( new QueuedFileReference("FL Upload Flare3D file " + fileRef.name, function():FileReference {
					
					const charInfo:CharInfo = charEdit.charInfo;
					
					const data:URLVariables = new URLVariables();
					data["UploadCharacterForm[character]"] = charInfo.character;
					data["UploadCharacterForm[model]"] = charInfo.model;
					data["UploadCharacterForm[type]"] = "2";
					if (SessionID) data["_sess_token"] = SessionID;
					
					const urlRequest:URLRequest = new URLRequest( URLUpload() );
					urlRequest.data = data;
					urlRequest.method = URLRequestMethod.POST;
					// don't bother, Flash doesn't accept headers with FileReference
//					for each (var header:URLRequestHeader in Headers.Get()) {
//						urlRequest.requestHeaders.push(header);
//					}
					
					fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(e:DataEvent):void {
							fileRef.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, arguments.callee);
							callback( FStr.StringToBytes(e.data) ); // ugh, for compatibility...
						}, false, 0, true);
					fileRef.upload(urlRequest, "file", false);
					
					return fileRef;
				}) );
				
			} else {
				
				// Firefox et al
				const base64:Base64Encoder = new Base64Encoder();
				var files:Array;
				if (fileRef.data) {
					base64.encodeBytes(fileRef.data);
					fileRef.data.position = 0;
					files = [{name:"file", type:"application/octet-stream", data:base64.toString()}];
				}
				
				QueueMessage( new QueuedXMLHttpResponse("JS Upload Flare3D file " + fileRef.name, function():Object {
							
					const charInfo:CharInfo = charEdit.charInfo;
					const data:Object = {};
					data["character"] = charInfo.character;
					data["model"] = charInfo.model;
					data["type"] = "2";
					
					const processID:String = ExternalInterface.call(
						"window.you_animate.uploadFromFlash",
						ServerRequest.URLUpload(),
						files,
						data
					);
					
					return processID;
				}) );
			}
			
			return this;
		}
	}
}