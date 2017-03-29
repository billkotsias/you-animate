package upload.server
{
	import fanlib.utils.Utils;

	public class EditModeVars
	{
		static public function Get(flashvars:Object):EditModeVars
		{
			const vars:EditModeVars = new EditModeVars();
			for each (var n:String in Utils.GetWritableVars(vars)) {
				vars[n] = flashvars[n];
				if (!vars[n]) return null; // no variable must be null to be in "Edit Mode"
			}
			
			return vars;
		}
		
		//
		
		public var character:String;
		public var model:String;
//		public var modelURL:String; // yet to be impemented!
		
		public function EditModeVars()
		{
		}
	}
}