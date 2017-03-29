package filters
{
	import fanlib.gfx.Stg;
	import fanlib.utils.FArray;
	import fanlib.utils.Utils;
	
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.materials.Shader3D;
	import flare.materials.filters.ColorFilter;
	
	import flash.display.BlendMode;
	import flash.events.Event;
	
	public class Color
	{
		private const materials:Array = [];
		private var filter:ColorFilter;
		
		public function Color(pivot:Pivot3D, color:uint = 0xffffff, blend:String = BlendMode.MULTIPLY, alpha:Number = 1)
		{
			// get materials
			for each ( var shader:Shader3D in pivot.getMaterials() ) {
				if (!shader) continue;
				materials.push( shader );
			}
			
			filter = new ColorFilter(color, alpha, blend);
			
			for each (shader in materials) {
				shader.filters.push( filter );
				shader.rebuild();
			}
			
		}
		
		public function setParams(color:uint, blendMode:String, alpha:Number = 1):void {
			filter.color = color;
			filter.blendMode = blendMode;
			filter.a = alpha;
		}
		
		public function setSeeThrough():void {
			setParams(0xffffff, BlendMode.MULTIPLY, 1);
		}
		
		public function destroy():void {
			for each (var shader:Shader3D in materials) {
				FArray.Remove( shader.filters, filter, true );
				shader.rebuild();
			}
			filter = null;
			materials.length = 0;
		}
	}
}