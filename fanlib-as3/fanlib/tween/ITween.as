package fanlib.tween
{
	import flash.events.IEventDispatcher;

	public interface ITween extends IEventDispatcher
	{
		function run(time:Number):Number;
		function start():void;
	}
}