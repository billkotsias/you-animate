package scene.action.special
{
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class PropVehicle extends Prop
	{
		public function PropVehicle() {
			super();
		}
		
		override internal function loaded(loader:FlareLoader):void {
//			const propClone:Pivot3D = loader.clone();
//			trace(this,propClone.name,propClone.getPosition(),propClone.getRotation(),propClone.getScale());
			// DEBUG
//			propClone.setPosition(0,0,-0*0.07); // -56*0.07
//			trace(this,propClone.name,propClone.getScale());
//			propClone.setScale(0.07,0.07,0.07);
			// DEBUG
//			pivot3D.addChild(propClone);
			super.loaded(loader);
			
			_initialized = true;
			dispatchEvent(new Event(INITIALIZED));
		}
	}
}