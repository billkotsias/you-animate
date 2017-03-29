package upload.server
{
	import fanlib.io.MPart;
	import fanlib.utils.FStr;
	import fanlib.utils.Utils;
	
	import flash.events.DataEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import upload.ObjData;

	public class ServerObjectFile extends ServerRequest
	{
		public function ServerObjectFile()
		{
			super();
		}
		
		public function sendFile(callback:Function, fileRef:FileReference, objData:ObjData):ServerObjectFile
		{
			QueueMessage( new QueuedFileReference("FL Upload Flare3D object " + fileRef.name, function():FileReference {
				const data:URLVariables = new URLVariables();
				if (objData) {
					data["UploadObjectForm[object]"] = objData.id;
					data["UploadObjectForm[name]"] = objData.name;
					data["UploadObjectForm[data]"] = JSON.stringify(objData.data);
				} else {
					data["UploadObjectForm[name]"] = "New Object";
					data["UploadObjectForm[data]"] = {};
				}
				if (SessionID) data["_sess_token"] = SessionID;
				
				const urlRequest:URLRequest = new URLRequest( URLObjectUpload() );
				urlRequest.data = data;
				urlRequest.method = URLRequestMethod.POST;
				
				fileRef.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,
					function completeEvent(e:DataEvent):void {
						fileRef.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, completeEvent);
						if (callback !== null) callback( FStr.StringToBytes(e.data) ); // ugh, for compatibility...
					}, false, 0, true);
				fileRef.upload(urlRequest, "file", false);
				
				return fileRef;
			}) );
			
			return this;
		}
		
		public function send(callback:Function, objData:ObjData):ServerObjectFile
		{
			if (!objData) return null;
			
			QueueMessage( new QueuedURLLoader("Upload object info " + objData.name, function():URLLoader {
				const data:URLVariables = new URLVariables();
				data["UploadObjectForm[object]"] = objData.id;
				data["UploadObjectForm[name]"] = objData.name;
				data["UploadObjectForm[data]"] = JSON.stringify(objData.data);
				if (SessionID) data["_sess_token"] = SessionID;
				
//				trace(this,"GAGA\n",Utils.PrettyString(data),"\nGAGA");
//				if (callback === null) callback = debugShit;
				
				const mpart:MPart = new MPart( URLObjectUpload() );
				mpart.addFields(data);
				const urlloader:URLLoader = mpart.loadRequest(callback, null);
				return urlloader;
			}) );
			
			return this;
		}
		
//		static private function debugShit(_data:ByteArray):void {
//			trace("static private function debugShit GOUGOU");
//			trace( Utils.PrettyString(JSON.parse( FStr.BytesToString(_data) ) ) );
//		}
	}
}