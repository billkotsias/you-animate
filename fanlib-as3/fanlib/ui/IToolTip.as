package fanlib.ui
{
	public interface IToolTip
	{
		function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean =false):void;
		function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void;
		function get tip():String;
	}
}