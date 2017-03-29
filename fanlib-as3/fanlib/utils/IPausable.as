package fanlib.utils
{
	public interface IPausable
	{
		function get paused():Boolean;
		function pause(pauser:*):void;
		/**
		 * @param Previously set pauser
		 * @return if still paused
		 */
		function unpause(pauser:*):Boolean;
		
	}
}