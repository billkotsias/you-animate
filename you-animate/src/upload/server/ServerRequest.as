package upload.server
{
	import fanlib.utils.Debug;
	import fanlib.utils.FStr;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.utils.ByteArray;
	
	import upload.CharEdit;

	public class ServerRequest
	{
		QueueReport;
		
		static protected var APIRoot:String= ""; // default
		static protected var Domain:String= "http://beta.you-animate.com"; // default
//		static protected var APIRoot:String= "/api/platform"; // default
//		static protected var Domain:String= "http://stg.you-animate.com"; // default
		static public var DebugMode:String = "&debug";
		
		static public var SessionID:String;
		
		static public function SetDomainPaths(loaderInfo:LoaderInfo):void {
			const splitAtDoubleSlash:Array = loaderInfo.url.split("//");
			const dom:String = (splitAtDoubleSlash[1] as String).split("/")[0]; // keep "root" domain only
			if (dom) Domain = splitAtDoubleSlash[0] + "//" + dom;
			
			APIRoot = loaderInfo.parameters["APIRoot"] || APIRoot;
			trace("[ServerRequest]",Domain,APIRoot);
		}
		static public function GetDomain():String { return Domain }
		static public function GetAPIRoot():String { return APIRoot }
		
		// Server request URLs
		static public function URLUpload():String {
			return Domain + APIRoot + "/upload?json" + DebugMode;
		}
		
		static public function URLCharDetails(charEdit:CharEdit):String {
			return Domain + APIRoot + "/character/"+charEdit.charInfo.character+"?json" + DebugMode;
		}
		
		static public function URLAllCharacters():String {
			return Domain + APIRoot + "/store?json&detailed";
		}
		
		static public function URLMyObjects():String {
			return Domain + APIRoot + "/my-objects?json";
		}
		
		static public function URLAllObjects():String {
			return Domain + APIRoot + "/objects?json";
		}
		
		static public function URLObjectUpload():String {
			return Domain + APIRoot + "/upload-object?json";
		}
		// Server request URLs
		
		static private var Sending:Boolean;
		static private const Outgoing:Vector.<QueuedServerRequest> = new Vector.<QueuedServerRequest>;
		
		// Reporting
		
		static public var Report:QueueReport;
		
		public function ServerRequest() {
		}
		
		static protected function QueueMessage(queuedMessage:QueuedServerRequest):void {
			Outgoing.push(queuedMessage);
			if (Report) {
				Report.setQueue(Outgoing);
			}
			if (!Sending) SendQueue();
		}
		
		static private function SendQueue():void {
//			trace("[ServerRequest.SendQueue]", (dummy is String) ? "string="+dummy : "bytes="+FStr.BytesToString(dummy) );
			const qm:QueuedServerRequest = (Outgoing.length) ? Outgoing[0] : null;
			if (qm !== null) {
				Sending = true;
				qm.execute(
					function (serverResponse:* = undefined):void {
						Outgoing.shift();
						Report.setQueue(Outgoing);
						SendQueue();
					},
					ReportProgress
				);
			} else {
				Sending = false;
			}
		}
		
		static private function ReportProgress(e:ProgressEvent):void {
			if (!Report) return;
			
			var total:Number;
			if ((total = e.bytesTotal)) {
				Report.setProgress(e.bytesLoaded / total);
			} else {
				Report.setProgress(0.5); // fuck you
			}
		}
	}
}