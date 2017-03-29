package skinning
{
	import fanlib.utils.FStr;
	import fanlib.utils.Utils;
	
	import flare.core.Mesh3D;
	
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	public class Frame
	{
		public var rootBoneName:String = ""; // default = empty string. NOTE : don't nullify!
		public var advancedBlending:Boolean;
		public var startFrame:Number;
		public var endFrame:Number;
		public var lerpFactor:Number;
		
		public function setNormal(end:Number):void {
			advancedBlending = false;
			startFrame = lerpFactor = NaN;
			endFrame = end;
		}
		
		public function setAdvanced(start:Number, end:Number, lerp:Number):void {
			advancedBlending = true;
			startFrame = start;
			endFrame = end;
			lerpFactor = lerp;
		}
		
		public function isEqualTo(other:Frame):Boolean {
			if (other.advancedBlending !== advancedBlending ||
				other.endFrame !== endFrame ||
				(
					advancedBlending &&
					(other.startFrame!== startFrame ||
						other.lerpFactor !== lerpFactor)
				)
			) return false;
			return true;
		}
		
		public function copy(other:Frame):void {
			advancedBlending = other.advancedBlending;
			startFrame = other.startFrame;
			endFrame = other.endFrame;
			lerpFactor = other.lerpFactor;
		}
		
		public function toString():String {
			return FStr.Concat(" ","name{"+rootBoneName+"}",getQualifiedClassName(this),advancedBlending,startFrame,endFrame,lerpFactor);
		}
	}
}