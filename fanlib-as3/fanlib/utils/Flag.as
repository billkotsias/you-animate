package fanlib.utils {
	
	public class Flag {
		
		public function Flag() {} // shut the fuck up

		static public function OUT_OF_BITS():void { throw "Flag : maximum bits reached"; }
		
		static private const DEFAULT:Flag = new Flag();
		static public function Reset():uint { return DEFAULT.reset(); }
		static public function Neo():uint { return DEFAULT.neo(); }
		
		private var flag:uint = 1;
		
		public function reset():uint {
			flag = 1;
			return flag;
		}
		
		public function neo():uint {
			flag = flag << 1;
			if (flag == 0) OUT_OF_BITS(); // 32 max!
			return flag;
		}
	}
	
}
