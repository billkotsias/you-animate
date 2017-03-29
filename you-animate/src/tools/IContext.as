package tools
{
	public interface IContext
	{
		function contextSelected(tool:Tool):void;
		function contextDeselected():void;
	}
}