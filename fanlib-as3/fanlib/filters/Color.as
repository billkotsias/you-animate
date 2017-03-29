package fanlib.filters {
	
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	
	public class Color {

		static private const Sepia:ColorMatrixFilter = CreateSepia();
		static private function CreateSepia():ColorMatrixFilter {
			var sepia:ColorMatrixFilter = new ColorMatrixFilter();
			sepia.matrix = [0.3930000066757202, 0.7689999938011169, 0.1889999955892563, 0, 0,
							0.3490000069141388, 0.6859999895095825, 0.1679999977350235, 0, 0, 
							0.2720000147819519, 0.5339999794960022, 0.1309999972581863, 0, 0,
							0, 0, 0, 1, 0];
			return sepia;
		}
		
		// end of internal functions
		
		static public function MultiplyHEX(hex:uint):ColorTransform {
			return new ColorTransform(
				((hex & 0x00FF0000) >>> 16)/255,
				((hex & 0x0000FF00) >>> 8)/255,
				(hex & 0x000000FF)/255,
				((hex & 0xFF000000) >>> 24)/255
			);
		}
		
		static public function TintRGBMatrix(r:Number, g:Number, b:Number, a:Number):ColorMatrixFilter {
			var matrix:Array = new Array();
			matrix = matrix.concat([r, 0, 0, 0, 0]); // red
			matrix = matrix.concat([0, g, 0, 0, 0]); // green
			matrix = matrix.concat([0, 0, b, 0, 0]); // blue
			matrix = matrix.concat([0, 0, 0, a, 0]); // alpha
			return new ColorMatrixFilter(matrix);
		}

		static public function TintHEXMatrix(hex:uint):ColorMatrixFilter {
			var matrix:Array = new Array();
			matrix = matrix.concat([((hex & 0x00FF0000) >>> 16)/255, 0, 0, 0, 0]); // red
			matrix = matrix.concat([0, ((hex & 0x0000FF00) >>> 8)/255, 0, 0, 0]); // green
			matrix = matrix.concat([0, 0, (hex & 0x000000FF)/255, 0, 0]); // blue
			matrix = matrix.concat([0, 0, 0, ((hex & 0xFF000000) >>> 24)/255, 0]); // alpha
			return new ColorMatrixFilter(matrix);
		}

		static public function CombineRGBA(r:uint, g:uint, b:uint, a:uint):uint {
			return uint( (a << 24) | (r << 16) | (g << 8) | b);
		}
		
		static public function HEXtoVector3D(hex:uint):Vector3D {
			return new Vector3D(
				((hex & 0x00FF0000) >>> 16)/255,
				((hex & 0x0000FF00) >>> 8)/255,
				(hex & 0x000000FF)/255,
				((hex & 0xFF000000) >>> 24)/255
			);
		}
		
		static public function SepiaFilter(br:Number = 1):ColorMatrixFilter {
			var sepia:ColorMatrixFilter = Sepia.clone() as ColorMatrixFilter;
			var matrix:Array = sepia.matrix;
			for (var i:int = 0; i < 15; ++i) {
				matrix[i] = matrix[i] * br;
			}
			sepia.matrix = matrix;
			return sepia;
		}
		
		// Turn an image (gradually) into a grayscale
		// t is a Number ranging from 0 == 100% saturation, full colors
		// to 1 == fully grayscale (is default)
		static public function DesaturationFilter(t:Number = 1):ColorMatrixFilter {
			// luminance coefficients as by Charles A. Poynton, 1997
			// see point C-9 of http://www.faqs.org/faqs/graphics/colorspace-faq/
			// alternative coefficients by Paul Haeberly :http://www.sgi.com/misc/grafica/matrix/
			var r:Number = 0.212671;
			var g:Number = 0.715160;
			var b:Number = 0.072169;
			return new ColorMatrixFilter(
					[t*r+1-t, t*g, t*b, 0, 0,
					t*r, t*g+1-t, t*b, 0, 0,
					t*r, t*g, t*b+1-t, 0, 0,
					0, 0, 0, 1, 0]);
		}
	}
}
