package fanlib.physix {
	
	import fanlib.utils.ICompare;
	
	public class CollisionParams implements ICompare {

		public function CollisionParams() {
			// constructor code
		}
		
		public function lessThan(obj:ICompare):Boolean { return false; }
		public function equal(obj:ICompare):Boolean { return false; }
		public function lessThanOrEqual(obj:ICompare):Boolean { return false; }

	}
	
}
