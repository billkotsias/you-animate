package scene.serialize
{
	import fanlib.utils.FStr;
	
	import flare.core.Pivot3D;
	
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import scene.camera.anim.ZoomSpot;

	public class Serialize
	{
		public function Serialize()
		{
		}
		
		static public function Pivot3D_(pivot:Pivot3D):Object {
			const obj:Object = {};
			obj.n = FStr.StringToBytes(pivot.name);
			obj.p = ToByteArray( pivot.getPosition(false) );
			obj.r = ToByteArray( pivot.getRotation(true) ); // local!
			obj.s = ToByteArray( pivot.getScale(true) ); // local!
			return obj;
		}
		static public function _Pivot3D(obj:Object, pivot:Pivot3D):void {
			pivot.name = FStr.BytesToString(obj.n);
			
			var vec:Object;
			vec = FromByteArray(obj.p);
			pivot.setPosition(vec.x, vec.y, vec.z, 1, false);
			
			vec = FromByteArray(obj.r);
			pivot.setRotation(vec.x, vec.y, vec.z); // local!
			
			vec = FromByteArray(obj.s);
			pivot.setScale(vec.x, vec.y, vec.z); // local!
		}
		
		static public function ToByteArray(obj:Object):ByteArray {
			const bytes:ByteArray = new ByteArray();
			bytes.writeObject(obj);
			return bytes;
		}
		static public function FromByteArray(bytes:ByteArray):Object {
			bytes.position = 0;
			return bytes.readObject();
		}
		
		static public function ObjectToArray(obj:Object):Array {
			const arr:Array = [];
			for (var valName:* in obj) {
				const index:Number = Number(valName);
				if (index >= 0) arr[index] = obj[valName]; else arr[valName] = obj[valName];
			}
			return arr;
		}
		
		// Class aliases
		static private const Aliases:Object = {};
		static private function RegisterClassAlias(cl:Class):void {
			const alias:String = getQualifiedClassName(cl).split("::").pop(); // for future compatibility, just keep last part
			if (Aliases[alias]) throw "[Serialize.RegisterClassAlias]: " + alias + " already defined";
			Aliases[alias] = true;
			registerClassAlias(alias, cl);
		}
		
		static private const DEFAULT_REGISTRATIONS:* = function():void {
			const reg:Array = [
//				ZoomSpot
			];
			
			for each (var cl:Class in reg) RegisterClassAlias(cl);
		}();
	}
}