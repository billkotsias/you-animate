package fanlib.tween {
	
	public interface ITweenedData {

		// misc
		function copy():ITweenedData;
		
		// math
		// NOTE : use only with same classes!
		function add(d:ITweenedData):ITweenedData;
		function sub(d:ITweenedData):ITweenedData;
		function mul(d:ITweenedData):ITweenedData;
		function div(d:ITweenedData):ITweenedData;
		function addN(n:Number):ITweenedData;
		function subN(n:Number):ITweenedData;
		function mulN(n:Number):ITweenedData;
		function divN(n:Number):ITweenedData;
		function idivN(n:Number):ITweenedData;
	}
	
}
