package fanlib.text {
	import fl.core.UIComponent;
	import fanlib.utils.FArray;
	
	public class FocusMan {

		static private const Mans:Array = [];
		
		static public function AddFocusable(manName:String, comp:UIComponent):FocusMan {
			var man:FocusMan = Mans[manName];
			if (!man) {
				man = new FocusMan();
				Mans[manName] = man;
			}
			man.addFocusable(comp);
			return man;
		}
		
		static public function GetGroup(manName:String):Array {
			return (Mans[manName] as FocusMan).comps;
		}
		
		private const comps:Array = [];
		
		public function FocusMan() {
			// constructor code
		}
		
		public function addFocusable(comp:UIComponent):void {
			comps.push(comp);
		}
		
		public function setNextFocus(comp:UIComponent):void {
			if (!comps.length) return;
			var i:int = comps.indexOf(comp) + 1;
			if (i == comps.length) i = 0;
			(comps[i] as UIComponent).setFocus();
		}

	}
	
}
