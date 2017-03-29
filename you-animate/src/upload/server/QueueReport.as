package upload.server
{
	import fanlib.text.FTextField;
	import fanlib.ui.ProgressBar;
	import fanlib.utils.IInit;
	
	import flash.utils.getQualifiedClassName;

	public class QueueReport extends FTextField implements IInit
	{
		static public const EMPTY_QUEUE:String = "No jobs in process queue";
		static public function JOBS_TO_DO(num:uint):String {
			return num.toString() + " job" + (num !== 1 ? "s" : "") + " in progress...\n"
		}
		
		private var progressBar:ProgressBar;
		
		public function QueueReport()
		{
		}
		
		public function initLast():void {
			ProgressBar.Default_Width = width - 10;
			ProgressBar.Default_Height = defaultTextFormat.size + 2;
		}
		
		public function setQueue(queue:Vector.<QueuedServerRequest>):void {
			var length:uint;
			if (!(length = queue.length)) {
				htmlText = EMPTY_QUEUE;
				progressBar = null;
				return;
			}
			
			var newTxt:String = queue[0].title + "\n<img src='" + getQualifiedClassName(ProgressBar) + "' hspace='0' vspace='0'/>\n<li>";
			
			for (var i:int = 1; i < queue.length; ++i) {
				newTxt += queue[i].title + "\n";
			}
			htmlText = JOBS_TO_DO(length) + newTxt + "</li>";
			
			var previousProgress:Number = progressBar ? progressBar.progress : 0;
			progressBar = ProgressBar.Last_Instance; // set in 'htmlText=' above
			setProgress(previousProgress);
		}
		
		public function setProgress(num:Number):void {
			if (progressBar) progressBar.progress = num;
			trace(this,num);
		}
	}
}