package fanlib.security
{
	import fanlib.utils.QuickLoad;
	
	import flash.net.URLLoaderDataFormat;

	public class Dated
	{
		public const dates:Array = [];
		public var changeEveryDays:int; // valid from 7 (min) to 15 (max) days!
		
		private var callBack:Function;
		private var randomSeed:Number;
		
		/* Use following file on server:
		<?php
		echo date('z Y H:i:s');
		?>
		*/
		/**
		 * IDEAS to make it harder to realize how stupidly it works:
		 * - REVERSE THE NUMBER
		 * - CONVERT THE NUMBERS TO CHARS
		 * - MIX SHIT DEPENDING ON LAST DIGIT (BEFORE FRIGGING REVERSE) 
		 * @param callBack Function must accept a 'Dated' object as parameter
		 * @param randomSeed A number between [0...1]
		 * @param serverAdr
		 * @param changeEveryDays
		 */
		public function Dated(callBack:Function, randomSeed:Number, serverAdr:String = "serverTime.php", changeEveryDays:int = 7)
		{
			this.changeEveryDays = changeEveryDays;
			this.callBack = callBack;
			this.randomSeed = randomSeed;
			
//			new QuickLoad(serverAdr+"?"+Math.random(), dateLoaded));
			new QuickLoad(serverAdr, dateLoaded, URLLoaderDataFormat.TEXT, false);
		}
		
		private function dateLoaded(data:*):void {
			var nums:Array = String(data).split(" ");
			var day:int = nums[0];
			var year:int = nums[1];
			for (var i:int = -1; i <= 1; ++i) {
				dates.push(calcDate(day, year, i)); // 3 accepted dates
			}
			callBack(this);
		}
		
		public function calcDate(day:int, year:int, next:int):int {
			year = (year % 100) + 100;
			day = int((day + changeEveryDays * next) / changeEveryDays);
			return Math.pow((day + 101), (1 + randomSeed)) * (year + day);
		}
	}
}