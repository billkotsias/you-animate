package fanlib.fx.emitters
{
	import fanlib.math.Maths;
	import fanlib.tween.TPlayer;
	import fanlib.tween.TSin;
	import fanlib.tween.TVector2;

	public class ECircle extends EBasic
	{	
		public var radius:Number = 100;
		
		public function ECircle()
		{
			super();
		}
		
		override protected function initPosition(data:ParticleData):TVector2 {
			return new TVector2(particleTemplate.x, particleTemplate.y);
		}
		
		override protected function finalPosition(data:ParticleData):TVector2 {
			var angle:Number = data.index * 2 * Math.PI;
			return new TVector2(
				radius * Math.cos(angle),
				radius * Math.sin(angle));
		}
		
		// to emit emitters
		override public function copy(baseClass:Class = null):* {
			var obj:ECircle = super.copy(baseClass);
			obj.radius = this.radius;
			return obj;
		}
	}
}