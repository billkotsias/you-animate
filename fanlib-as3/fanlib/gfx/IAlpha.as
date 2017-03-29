package fanlib.gfx {
	
	import flash.geom.Point;
	
	public interface IAlpha {

		// Interface methods:
		// => global or local point
		//	  if alpha at that point is less than or equal to 'minMask', return -1
		// <= alpha value or '-1' if "irrelevant"
		function getAlphaGlobal(p:Point, minMask:int = 0):int;
		function getAlphaLocal(p:Point, minMask:int = 0):int;
	}
	
}
