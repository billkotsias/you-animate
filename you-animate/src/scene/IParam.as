package scene
{
	import tools.param.Param;

	public interface IParam
	{
		function get params():Vector.<Param>;
		function get paramsTitle():String;
	}
}