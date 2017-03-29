package fanlib.utils
{
	public interface ILexicon
	{
		function autoUpdateRefs(auto:ILexiRef, ... refs):void;
		function getCurrentRef(ref:String):*;
	}
}