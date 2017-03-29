package fanlib.utils
{
	public class ReadOnly
	{
		private var _data:Object;
		
		/**
		 * Don't keep copy of data Object for best results 
		 * @param data Object to provide read-only access to
		 * @param makeCopy For best security set to true, for speed leave as false
		 */
		public function ReadOnly(data:Object, makeCopy:Boolean = false)
		{
			if (makeCopy) {
				_data = Utils.Clone(data);
			} else {
				_data = data;
			}
		}
		
		public function getValue(name:String):* {
			return _data[name];
		}
	}
}