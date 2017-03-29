package webViewer
{
	import com.quasimondo.geom.ColorMatrix;
	
	import fanlib.io.MLoader;
	
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	import flare.primitives.SkyBox;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	
	public class DSkybox extends Pivot3D
	{
		public var context:Scene3D;
		
		private const colorMatrix:ColorMatrix = new ColorMatrix();
		private var skybox:SkyBox;
		private var mloader:MLoader;
		private const finalBmps:Array = [];
		
		public function DSkybox(name:String="")
		{
			super(name);
		}
		
		public function setTextures(arr:Array):void {
			new MLoader(arr, function(l:MLoader):void {
				mloader = l;
				updateSkybox();
			});
		}
		
		public function setHSBC(hue:Number, sat:Number, bright:Number, contr:Number):void {
			colorMatrix.reset();
			colorMatrix.adjustBrightness(bright*100);
			colorMatrix.adjustHue(hue*180);
			colorMatrix.adjustSaturation(sat+1);
			colorMatrix.adjustContrast(contr);
			updateSkybox();
		}
		
		public function randomHSBC():void {
			colorMatrix.reset();
			colorMatrix.randomize(1);
			updateSkybox();
		}
		
		private function updateSkybox():void {
			if (!mloader) return;
			
			var bmp:Bitmap, data:BitmapData, i:int;
			
			// create new Bitmaps
			if (!finalBmps.length) {
				for (i = 0; i < mloader.files.length; ++i) {
					data = (mloader.files[i] as Bitmap).bitmapData;
					finalBmps.push( new BitmapData( data.width, data.height, data.transparent, 0xffffffff ) );
				}
			}
			
			// update BitmapData's
			const cmfilterArray:Array = [colorMatrix.filter];
			for (i = 0; i < finalBmps.length; ++i) {
				bmp = mloader.files[i];
				bmp.filters = cmfilterArray;
				(finalBmps[i] as BitmapData).draw( bmp );
			}
			
			if (skybox) {
				skybox.parent = null;
				skybox.dispose();
			}
			CONFIG::newFlare { skybox = new SkyBox(finalBmps, context, 0.75); }
			CONFIG::oldFlare { skybox = new SkyBox(finalBmps, null, context, 0.75); }
			addChild(skybox);
		}
	}
}