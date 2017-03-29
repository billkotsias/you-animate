package
{
	import fanlib.utils.Debug;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	import flare.loaders.Flare3DLoader;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	public class FlareLoader extends Flare3DLoader
	{
		private var _complete:Boolean; // true = clonable
		
		public function FlareLoader(request:*, parent:Pivot3D=null, sceneContext:Scene3D=null, loadNow:Boolean = false)
		{
			super(request, parent, sceneContext);
			addEventListener(Event.COMPLETE, loaderComplete);
//			addEventListener(ProgressEvent.PROGRESS, loaderProgress);
			if (loadNow) load(); // REMEMER THIS!
		}
		
		public function whenComplete(func:Function):void {
			if (_complete) {
				func();
			} else {
				addEventListener(Event.COMPLETE, function loaderComplete2(e:Event):void {
					removeEventListener(Event.COMPLETE, loaderComplete2);
					func();
				});
			}
		}
		
		private function loaderProgress(e:ProgressEvent):void {
			Debug.field.text = (e.toString() + "\n");
		}
		
		private function loaderComplete(e:Event):void {
			removeEventListener(Event.COMPLETE, loaderComplete);
			removeEventListener(ProgressEvent.PROGRESS, loaderProgress);
			_complete = true;
		}

		public function get complete():Boolean
		{
			return _complete;
		}

	}
}