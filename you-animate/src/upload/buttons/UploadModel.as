package upload.buttons
{
	import fanlib.ui.BrowseLocal;
	import fanlib.ui.FButton2;
	
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import ui.ButtonText;
	import ui.report.Reporter;
	import upload.CharEdit;
	
	public class UploadModel extends ButtonText
	{
		public var charEdit:CharEdit;
		
		private var browseLocal:BrowseLocal;
		
		public function UploadModel()
		{
			super();
			addEventListener(FButton2.CLICKED, clicked);
		}
		
		private function clicked(e:MouseEvent):void {
			if (browseLocal) return;
			
			var fileRef:FileReference;
			
			browseLocal = new BrowseLocal(
				new FileFilter("Flare3D files (.f3d, .zf3d)", "*.f3d;*.zf3d;"),
				function bytesLoaded(data:ByteArray):void {
					browseLocal = null;
					charEdit.newLoader(fileRef);
				},
				function fileSelected(ref:FileReference):void {
					fileRef = ref;
					Reporter.AddInfo(this, "New Flare3D file " + ref.name + " selected");
				},
				function cancel():void {
					browseLocal = null;
				}
			);
		}
	}
}