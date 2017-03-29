package fanlib.utils
{
	import flash.utils.Dictionary;

	/**
	 * Also known as Enabled or Enablable 
	 * @author Bill
	 */
	public class Pausable implements IPausable
	{
		private const pauses:Dictionary = new Dictionary(false);
		
		public function Pausable() {
		}
		
		public function get paused():Boolean { return !Utils.IsEmpty(pauses) }
		
		public function pause(pauser:*):void {
			pauses[pauser] = 1;
		}
		
		/**
		 * @param Previously set pauser
		 * @return if still paused
		 */
		public function unpause(pauser:*):Boolean {
			delete pauses[pauser];
			return paused;
		}
	}
}