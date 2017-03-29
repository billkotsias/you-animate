package upload.server
{
	import fanlib.utils.Debug;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.Utils;
	
	import flash.events.ProgressEvent;
	import flash.external.ExternalInterface;
	
	import ui.report.Reporter;

	public class QueuedXMLHttpResponse extends QueuedServerRequest
	{
		public function QueuedXMLHttpResponse(title:String, messageFunction:Function)
		{
			super(title, messageFunction);
		}
		
		override protected function _execute():void {
			CONFIG::debug_upload { Debug.appendLine(this+"======================================="); }
			const processID:String = messageFunction();
			CONFIG::debug_upload { Debug.appendLine(this+"processID"+processID); }
			
			const trackProcess:DelayedCall = new DelayedCall(
				function():void {
					const progress:Object = ExternalInterface.call("window.you_animate.trackProcessID", processID);
					if (progress) {
						CONFIG::debug_upload { Debug.appendLine("progress="+Utils.PrettyString(progress)); }
						
						const progressEvent:Object = progress.progressEvent;
						if (progressEvent) {
							if (progressCallback !== null)
								progressCallback(new ProgressEvent("", false, false,
									progressEvent.loaded || progressEvent.position,
									progressEvent.totalSize || progressEvent.total)); // browser inconsistencies, how cute
						}
						
						if (progress.successEvent) {
							trackProcess.dismiss();
							completeCallback( progress.successEvent );
							cleanup();
						}
						
						if (progress.errorEvent) {
							trackProcess.dismiss();
							Reporter.AddError(this, title, progress.errorEvent.status, progress.errorEvent.statusText);
							completeCallback( progress.errorEvent );
							cleanup();
						}
					}
				},
				1/3 /* 3 times / sec */,
				null,
				0 /* forever */
			);
		}
	}
}