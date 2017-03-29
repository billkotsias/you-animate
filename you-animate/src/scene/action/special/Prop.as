package scene.action.special
{
	import fanlib.math.Maths;
	
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.describeType;
	
	public class Prop extends EventDispatcher
	{
		static public const INITIALIZED:String = "INITIALIZED";
		
		public const pivot3D:Pivot3D = new Pivot3D();
		
		protected var _initialized:Boolean;
		
		public function Prop(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public function destroy():void {
			pivot3D.parent = null;
		}
		
		internal function whenInitialized(func:Function):void {
			if (_initialized) {
				func();
			} else {
				addEventListener(INITIALIZED, function(e:Event):void {
					removeEventListener(INITIALIZED, arguments.callee); // without 'this', 'removeEventListener' works FINE!!!
					func();
				});
			}
		}
		
		/**
		 * Abstract 
		 * @param loader
		 */
		internal function loaded(loader:FlareLoader):void {
			pivot3D.addChild(loader.clone());
			pivot3D.gotoAndPlay(0); // } Bypass Flare3D bug!!!
			pivot3D.gotoAndStop(0); // }
		}

		public function get initialized():Boolean
		{
			return _initialized;
		}

	}
}