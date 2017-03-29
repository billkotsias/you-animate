package fanlib.event {
	import fanlib.utils.FArray;
	
	public class Unlistener {

		private var arr:Array = new Array();
		
		public function Unlistener() {
			// constructor code
		}

		public function addListener(o:Object, t:String, l:Function, u:Boolean = false, p:int = 0, w:Boolean = false):void {
			o.addEventListener(t, l, u, p, w);
			arr.push( new ListenParams(o,t,l,u) );
		}
		
		public function removeListener(o:Object, t:String, l:Function, u:Boolean = false):void {
			o.removeEventListener(t, l, u);
			FArray.RemoveEqual(arr, new ListenParams(o,t,l,u));
		}
		
		public function removeAll():void {
			for each (var dat:ListenParams in arr) {
				dat.o.removeEventListener(dat.t, dat.l, dat.u);
			}
			arr.length = 0;
		}
		
		public function get numListeners():int {
			return arr.length;
		}
		
		public function getDispatcher(i:int):* {
			return arr[i].o;
		}
	}
	
}
import fanlib.utils.ICompare;

class ListenParams implements ICompare {
	public var o:Object;
	public var t:String;
	public var l:Function;
	public var u:Boolean;
	
	public function ListenParams(o:Object, t:String, l:Function, u:Boolean) {
		this.o = o;
		this.t = t;
		this.l = l;
		this.u = u;
	}
	
	public function lessThan(obj:ICompare):Boolean {
		return t < (obj as ListenParams).t; // TODO : impement something better?
	}
	public function equal(obj:ICompare):Boolean {
		var x:ListenParams = obj as ListenParams;
		if (o === x.o &&
			t === x.t &&
			l === x.l &&
			u === x.u) return true;
		return false;
	}
}