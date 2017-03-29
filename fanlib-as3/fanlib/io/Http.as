package fanlib.io
{
	import com.adobe.net.URI;
	
	import fanlib.utils.Debug;
	import fanlib.utils.Pair;
	
	import flash.utils.ByteArray;
	
	import org.httpclient.HttpClient;
	import org.httpclient.HttpRequest;
	import org.httpclient.events.HttpDataEvent;
	import org.httpclient.events.HttpDataListener;
	import org.httpclient.events.HttpResponseEvent;
	import org.httpclient.http.Post;
	import org.httpclient.http.multipart.Multipart;
	import org.httpclient.http.multipart.Part;

	/**
	 * Socket based!!! Only suitable for Adobe AIR!!! 
	 * @author BillWork
	 * 
	 */
	public class Http
	{
		public function Http()
		{
		}
		
		public function post(uri:URI, body:*, contentType:String, listener:HttpDataListener, customHeaders:Array = null):void {
			const http:HttpClient = newClient(listener);
			
//			http.post(uri, body, contentType); // ...was; ...
			const request:Post = new Post();
			request.body = body;
			request.contentType = contentType;
			addHeaders(request, customHeaders);
			http.request(uri, request);			
		}
		
		public function postFormData(uri:URI, data:Object, listener:HttpDataListener, customHeaders:Array = null):void {
			const http:HttpClient = newClient(listener);
			const variables:Array = [];
			for (var name:String in data) {
				variables.push({name:name, value:data[name]});
			}
			
//			http.postFormData(uri, variables); // ...was; didn't allow custom headers!
			const request:Post = new Post(variables);
			addHeaders(request, customHeaders);
			Debug.appendLineMulti("\n","Sending 'postFormData' (header + body):",request.header.content,request.body);
			try {
				http.request(uri, request);
			} catch (err:Error) { Debug.appendLineMulti("\n",err.errorID,err.message) };
		}
		
		public function postMultipart(uri:URI, parts:Array, listener:HttpDataListener, customHeaders:Array = null):void {
			const http:HttpClient = newClient(listener);
			
//			http.postMultipart(uri, new Multipart(parts)); // ...was; ...
			const request:Post = new Post();
			request.setMultipart(new Multipart(parts));
			addHeaders(request, customHeaders);
			Debug.appendLineMulti("\n","Sending 'postMultipart' (header + body)",request.header.content,request.body);
			http.request(uri, request);
		}
		
		//
		
		private function addHeaders(req:HttpRequest, headers:Array):void {
			for each (var pair:Pair in headers) {
//				trace(this,"adding header",pair.key, pair.value,"to",req.body);
				req.addHeader(pair.key, pair.value);
			}
		}
		
		//
		
		private function newClient(listener:HttpDataListener):HttpClient {
			const _onDataComplete:Function = listener.onDataComplete;
			const _data:ByteArray = new ByteArray();
			
			const http:HttpClient = new HttpClient();
			
			// user functions
			http.listener.onStatus = listener.onStatus;
			http.listener.onError = listener.onError;
			
			// local functions
			http.listener.onData = function(e:HttpDataEvent):void {
				var pos:uint = e.bytes.position;
				Debug.appendLineMulti("\n","Server response data:", e.bytes.readUTFBytes(e.bytes.length));
				e.bytes.position = pos;
				_data.writeBytes(e.bytes);
			}
			
			http.listener.onComplete = function(e:HttpResponseEvent):void {
				Debug.appendLineMulti("\n","Server response COMPLETE:", e.response);
				_data.position = 0; // I am nice
				if (_onDataComplete !== null) _onDataComplete(e, _data);
			}
			
			return http;
		}
	}
}