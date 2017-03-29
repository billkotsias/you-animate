package fanlib.gfx
{
	import fanlib.utils.Enum;

	public interface ICacheToBmp
	{
		function get cacheToBitmap():Enum;
		function set cacheToBitmap(type:Enum):void;
	}
}