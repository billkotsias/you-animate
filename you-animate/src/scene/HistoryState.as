package scene
{
	public class HistoryState
	{
		private var _buildFunc:Function;
		
		public function HistoryState(buildFunc:Function) {
			_buildFunc = buildFunc;
		}
		
		public function build():void {
			_buildFunc();
		}
		
//		public function get buildFunc():Function { return _buildFunc }
	}
}