package fanlib.gfx {
	
	import fanlib.utils.Enum;
	
	public class Align {
		
		static public const LEFT:Enum = new Enum();
		static public const RIGHT:Enum = new Enum();
		static public const CENTER:Enum = new Enum();
		static public const TOP:Enum = new Enum();
		static public const BOTTOM:Enum = new Enum();
		static public const NONE:Enum = new Enum();

		static public function WRONG_ENUM():void { throw "Wrong Align Enum"; }

		static public const ALIGN_LEFT:String = "left";
		static public const ALIGN_RIGHT:String = "right";
		static public const ALIGN_TOP:String = "top";
		static public const ALIGN_BOTTOM:String = "bottom";
		static public const ALIGN_CENTER:String = "center";
	}
	
}
