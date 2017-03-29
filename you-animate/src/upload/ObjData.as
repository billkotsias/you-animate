package upload
{
	import fanlib.utils.Utils;
	
	/**
	 * Shit based on Andreas-san logic
	 * @author BillWork
	 */
	public class ObjData
	{
		public var id:String = "";
		public var name:String = "";
		public var url:String = "";
		public var data:Object = {};
		
		public function ObjData(data:Object)
		{
			Utils.CopyDynamicProperties(this, data, false, true, true);
		}
	}
}