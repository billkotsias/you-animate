package fanlib.utils {
	
	public interface ICompare {
		
		// Must be compared with the same type obviously

		// Interface methods:
		function lessThan(obj:ICompare):Boolean;
		function equal(obj:ICompare):Boolean;
	}
	
}
