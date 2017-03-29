package
{
	import fanlib.security.Dated;
	import fanlib.utils.Debug;
	import fanlib.utils.FANApp;
	import fanlib.utils.Utils;
	
	import flash.text.TextFormat;
	
	public class ShowDatedCodes extends FANApp
	{
		static public const RANDOM_SEED:Number = 0.63246126;
		static public const CHANGE_EVERY_DAYS:int = 2;
		static public const ADDRESS:String = "http://www.kyballgame.com/walk3d/serverTime.php";
		
		public function ShowDatedCodes()
		{
			super();
		}
		
		override protected function stageInitialized():void {
			Debug.field.defaultTextFormat = new TextFormat(null, 32, 0x0);
			Debug.field.text = "Loading data from server";
			
			new Dated(
				function(d:Dated):void {
					const dates:Array = d.dates;
					Debug.field.text = "Sort time code : "+dates[1]+
									   "\nLonger time code : "+dates[2];
				}, RANDOM_SEED, ADDRESS, CHANGE_EVERY_DAYS);
			
		}
	}
}