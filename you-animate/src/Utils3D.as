package
{
	import fanlib.containers.Array2D;
	import fanlib.starling.FBitmap;
	import fanlib.utils.Pair;
	
	import flare.basic.Scene3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.utils.Pivot3DUtils;
	
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;
	
	import starling.display.Quad;

	public class Utils3D
	{
		static public function CountTriangles(pivot:Pivot3D):uint {
			const meshes:Vector.<Pivot3D> = pivot.getChildrenByClass(Mesh3D);
			var tris:uint = 0;
			var surfaces:uint = 0;
			var meshNum:uint = 0;
			for each (var mesh:Mesh3D in meshes) {
				for each (var surface:Surface3D in mesh.surfaces) {
					tris += surface.indexVector.length / 3;
				}
			}
			return tris;
		}
		
		static public function SetWorkaroundBugScale(pivot:Pivot3D, apply:Boolean = false):Number {
			var workAroundGodDamnSillyScalingBug:Number = Pivot3DUtils.getBounds(pivot).radius;
			for (var i:int = 0; i < 35; ++i) {
				pivot.gotoAndStop(0.35);
			}
			workAroundGodDamnSillyScalingBug /= Pivot3DUtils.getBounds(pivot).radius;
			if (apply) pivot.setScale(workAroundGodDamnSillyScalingBug,workAroundGodDamnSillyScalingBug,workAroundGodDamnSillyScalingBug);
			// your pivot is now !@#%$ ready to conquer the #%!#%@ world
			return workAroundGodDamnSillyScalingBug;
		}
		
		static public function GetScene3DSnapshot(scene3D:Scene3D, width:Number, height:Number):BitmapData {
			const bmpData:BitmapData = new BitmapData(scene3D.viewPort.width, scene3D.viewPort.height, true, 0);
			scene3D.context.clear(0,0,0,0);
			scene3D.render();
			scene3D.context.drawToBitmapData(bmpData);
			const aspect:Number = bmpData.width / bmpData.height;
			
			// crop to same aspect ratio
			var cropWidth:Number = bmpData.width;
			var cropHeight:Number = bmpData.height;
			const newAspect:Number = width / height;
			if (newAspect > aspect) {
				cropHeight = cropWidth * newAspect; // less new height
			} else {
				cropWidth = cropHeight * newAspect; // less new width
			}
			
			// resize
			const newScale:Number = width / cropWidth;
			const newX:Number = (cropWidth - bmpData.width) / 2;	// <= 0
			const newY:Number = (cropHeight - bmpData.height) / 2;	// <= 0
			const mat:Matrix = new Matrix(1,0,0,1,newX,newY);
			mat.scale(newScale, newScale);
			
			// draw
			const newBmpData:BitmapData = new BitmapData(width, height, true, 0);
			newBmpData.draw(bmpData, mat, null,null,null, true);
			return newBmpData;
		}
		
		static public function GetScene3DSnapshotPNGBase64(scene3D:Scene3D, width:Number, height:Number):String {
			const data:BitmapData = GetScene3DSnapshot(scene3D, width, height);
			const pngBytes:ByteArray = data.encode(data.rect, new PNGEncoderOptions(false));
			const base64:Base64Encoder = new Base64Encoder();
			base64.encodeBytes(pngBytes);
			return base64.toString();
		}
		
		/**
		 * @param num
		 * @param min MUST be power of 2
		 * @return calculated
		 */
		static public function CalcNearestPowerOfTwo(num:Number, min:Number = 4):Number {
			var i:int = min;
			while (i < num) {
				i <<= 1;
			}
			return i;
		}
		
		static public function SplitOversizedBmpData(oldBmp:BitmapData, powerOfTwo:Boolean = false, widthMax:Number = 2048, heightMax:Number = 2048):Array2D {
			if (!powerOfTwo && oldBmp.width <= widthMax && oldBmp.height <= heightMax) return new Array2D(1,1,[ new Pair(oldBmp) ]);
			
//			const rows:uint = 1 + ( (oldBmp.height-1) / heightMax);
//			const columns:uint = 1 + ( (oldBmp.width-1) / widthMax);
//			const newTable:Array2D = new Array2D(columns, rows);
			var columns:uint;
			var rows:uint = 0;
			const newArray:Array = [];
			const zeroPoint:Point = new Point();
			const rectSrc:Rectangle = new Rectangle();
			
			var uv:Point = new Point(1,1);
			var temp:Number;
			var remainHeight:int = oldBmp.height;
			
			while (remainHeight > 2 || rows === 0) {
//			for (var j:int = 0; j < rows; ++j) {
				
				++rows;
				
				var height:uint = (remainHeight > heightMax) ? heightMax : remainHeight;
				if (powerOfTwo) {
					temp = CalcNearestPowerOfTwo(height);
					uv.y = (height-1) / temp; // was 1
					height = temp;
				}
				
				rectSrc.height = height;
				
				var remainWidth:int = oldBmp.width;
				columns = 0;

				while (remainWidth > 2 || columns === 0) {
//				for (var i:int = 0; i < columns; ++i) {
					
					++columns;
					
					var width:uint = (remainWidth > widthMax) ? widthMax : remainWidth;
					if (powerOfTwo) {
						temp = CalcNearestPowerOfTwo(width);
						uv.x = (width-1) / temp; // was 1
						width = temp;
					}
					rectSrc.width = width;
					
					const newBmp:BitmapData = new BitmapData(width, height, oldBmp.transparent, 0);
					newBmp.copyPixels(oldBmp, rectSrc, zeroPoint);
					newArray.push( new Pair(newBmp, uv.clone()) );
//					newTable.set( new Pair(newBmp, uv.clone()), i, j );
					
					rectSrc.x += (width-2);
					remainWidth -= (width-2);
				}
				
				rectSrc.x = 0;
				rectSrc.y += (height-2);
				remainHeight -= (height-2);
			}
			
			return new Array2D(columns, rows, newArray);
		}
		
		static public function SplitOversizedToStarling(oldBmp:BitmapData, widthMax:Number = 2048, heightMax:Number = 2048):Array2D {
			const table:Array2D = SplitOversizedBmpData(oldBmp, false, widthMax, heightMax);
			
			var posY:Number = 0;
			for (var j:int = 0; j < table.height; ++j) {
				
				var posX:Number = 0;
				for (var i:int = 0; i < table.width; ++i) {
					const bmp:FBitmap = new FBitmap( (table.get(i,j) as Pair).key );
					bmp.mask = new Quad(bmp.width-1,bmp.height-1);
					table.set(bmp, i, j); // replace data with FBitmap
					bmp.x = posX;
					bmp.y = posY;
					posX += bmp.width - 2;
				}
				posY += bmp.height - 2;
			}
			
			return table;
		}
	}
}