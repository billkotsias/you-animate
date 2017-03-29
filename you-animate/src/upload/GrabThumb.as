package upload
{
	import fanlib.ui.FButton2;
	import fanlib.ui.IToolTip;
	import fanlib.utils.IInit;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Matrix;
	
	import tools.ToolButton;
	
	import ui.LabelThumb;
	
	public class GrabThumb extends ToolButton
	{
		public var labelThumb:LabelThumb;
		
		public var scene3D:Scene3D;
		public const hideStuff:Array = [];
		
		public function GrabThumb()
		{
			super();
			addEventListener(FButton2.CLICKED, click);
		}
		
		private function click(e:Event):void {
			
			var toHide:Pivot3D;
			for each (toHide in hideStuff) toHide.hide(); // hide stuff
			
			// draw to BitmapData
			const bmpData:BitmapData = Snapshot3D.Get(scene3D);
			
			for each (toHide in hideStuff) toHide.show(); // show stuff
			
			// crop to same aspect ratio
			const aspect:Number = bmpData.width / bmpData.height;
			var newWidth:Number = bmpData.width;
			var newHeight:Number = bmpData.height;
			const dims:Array = labelThumb.maxDims;
			const newAspect:Number = dims[0] / dims[1];
			if (newAspect > aspect) {
				newHeight = newWidth * newAspect; // less new height
			} else {
				newWidth = newHeight * newAspect; // less...
			}
			var newX:Number = (newWidth - bmpData.width) / 2;	// <= 0
			var newY:Number = (newHeight - bmpData.height) / 2;	// <= 0
			
			const newBmpData:BitmapData = new BitmapData(newWidth, newHeight, true, 0);
			const mat:Matrix = new Matrix(1,0,0,1,newX,newY);
			newBmpData.draw(bmpData, mat, null,null,null, true);
			
			// set
			labelThumb.setBitmapData(newBmpData);
		}
	}
}