package
{
	import flare.basic.Scene3D;
	
	import flash.display.BitmapData;

	public class Snapshot3D
	{
		static public function Get(scene3D:Scene3D, bmpData:BitmapData = null):BitmapData {
			// draw to BitmapData
			if (!bmpData) bmpData = new BitmapData(scene3D.viewPort.width, scene3D.viewPort.height, true, 0);
			scene3D.context.clear(0,0,0,0);
			scene3D.render();
			scene3D.context.drawToBitmapData(bmpData);
			return bmpData;
		}
	}
}