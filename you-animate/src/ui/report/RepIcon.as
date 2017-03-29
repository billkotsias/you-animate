package ui.report
{
	import fanlib.gfx.FSprite;
	
	import flash.events.Event;
	
	public class RepIcon extends FSprite
	{
		[Embed(source="../embedded/logError.png")]
		public static const LogError:Class;
		[Embed(source="../embedded/logWarning.png")]
		public static const LogWarning:Class;
		[Embed(source="../embedded/logInfo.png")]
		public static const LogInfo:Class;
		
		static public const ID_ERROR:String = "errr";
		static public const ID_WARNING:String = "warn";
		static public const ID_INFO:String = "info";
		
		static public var DefaultWidth:Number = 5; // NOTE : good (although a lie) for Courier, 11 for Times New
		static public var DefaultHeight:Number = 11;
		
		public function RepIcon()
		{
			super();
			graphics.drawRect(0,0,DefaultWidth, DefaultHeight);
			addEventListener(Event.FRAME_CONSTRUCTED, nameSet);
		}
		
		private function nameSet(e:Event):void {
			removeEventListener(e.type, nameSet);
			graphics.clear();
			
			switch(name) {
				case ID_ERROR:
					addChild(new LogError());
					break;
				case ID_INFO:
					addChild(new LogInfo());
					break;
				case ID_WARNING:
				default:
					addChild(new LogWarning());
					break;
			}
		}
	}
}