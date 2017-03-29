package fanlib.containers
{
	import fanlib.utils.FArray;
	
	import flash.utils.Dictionary;

	// First-in first-served array
	// Elements must be unique
	// Incoming elements are serially stacked, but randomly removed from
	// Smart 'for each' implentation
	public class List
	{
		private const array:Array = [];
		private var registrations:Dictionary = new Dictionary(true); // quickly find if object is already in
		private const iterating:Array = [];
		
		public function List()
		{
		}
		
		/**
		 * @param obj
		 * @param iterateNow
		 * @return True if obj is new, false if already in
		 */
		public function push(obj:*, iterateNow:Boolean = false):Boolean {
			if (registrations[obj]) return false; // already in
			
			registrations[obj] = true;
			array.push(obj);
			if (iterateNow) {
				for each (var arr:Array in iterating) {
					arr.unshift(obj);
				}
			}
			return true;
		}
		
		public function pushList(other:List, iterateNow:Boolean = false):void {
			const otherArray:Array = other.array;
			for (var i:int = 0; i < otherArray.length; ++i) {
				push(otherArray[i], iterateNow);
			}
		}
		
		/**
		 * @param obj
		 * @return true if obj is found
		 */
		public function remove(obj:*):Boolean {
			if (!registrations[obj]) return false; // already out
			
			delete registrations[obj];
			FArray.Remove(array, obj, true);
			for each (var arr:Array in iterating) {
				FArray.Remove(arr, obj, true);
			}
			return true;
		}
		
		public function pop():* {
			const lasty:* = last;
			remove(lasty);
			return lasty;
		}
		
		public function isIn(obj:*):Boolean {
			return registrations[obj];
		}
		
		public function forEach(func:Function):void {
			const arr:Array = array.concat().reverse(); // reverse doesn't make a copy! Fuck Adobe docs!!!
			iterating.push(arr);
			while (arr.length) {
				func(arr.pop());
			}
			iterating.pop();
		}
		
		/**
		 * Function will be applied till it returns "truable"
		 * @param func
		 */
		public function forEachBreakable(func:Function):* {
			var value:*;
			const arr:Array = array.concat().reverse(); // reverse doesn't make a copy! Fuck Adobe docs!!!
			iterating.push(arr);
			
			while (!value && arr.length) {
				value = func(arr.pop());
			}
			
			iterating.pop();
			
			return value;
		}
		
		public function clear(stopIteration:Boolean):void {
			if (stopIteration) {
				for each (var arr:Array in iterating) {
					arr.length = 0;
				}
			}
			array.length = 0;
			registrations = new Dictionary(true);
		}
		
		public function getByIndex(i:int):* { return array[i]; }
		public function get length():uint { return array.length; }
		public function isEmpty():Boolean { return array.length === 0; }
		public function get last():* { return array[array.length-1]; }
		public function getByValue(key:String, value:*):* { return FArray.FindByValue(array, key, value) }
			
		public function toArray():Array { return array.concat(); }
		
		static public function FromArray(arr:Array):List {
			const list:List = new List();
			for each (var obj:* in arr) {
				list.push(obj, false);
			}
			return list;
		}
	}
}