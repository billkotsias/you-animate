package fanlib.utils {
	
	import fanlib.math.Maths;
	
	import flash.geom.Point;
	
	public class FArray {
	
		static public function AddPrefix(arr:Array, pre:String):Array {
			for (var i:int = arr.length - 1; i >= 0; --i) {
				arr[i] = pre + arr[i];
			}
			return arr;
		}
		
		static public function AddPostfix(arr:Array, post:String):Array {
			for (var i:int = arr.length - 1; i >= 0; --i) {
				arr[i] += post;
			}
			return arr;
		}
		
		static public function RotateLeft(arr:Array):* {
			const value:* = arr.shift();
			arr.push(value);
			return value;
		}
		
		static public function RotateRight(arr:Array):* {
			const value:* = arr.pop();
			arr.unshift(value);
			return value;
		}
		
		// no error checking, no sorting. Fast but lethal!
		static public function RemoveFast(arr:Array, i:int):void {
			arr[i] = arr[arr.length - 1];
			--arr.length;
		}
		
		static public function GetAndRemoveFast(arr:Array, i:int):* {
			var obj:* = arr[i];
			arr[i] = arr[arr.length - 1];
			--arr.length;
			return obj;
		}
		
		static public function GetByValueAndRemoveFast(arr:*, key:String, value:*):* {
			for (var i:int = arr.length - 1; i >= 0; --i) {
				var obj:* = arr[i];
				if (obj[key] === value) {
					arr[i] = arr[arr.length - 1];
					--arr.length;
					return obj;
				}
			}
			return null;
		}
		
		static public function Remove(arr:Object, obj:*, thereCanBeOnlyOne:Boolean = false):void {
			var index:int;
			while ((index = arr.indexOf(obj, index)) >= 0) {
				arr.splice(index, 1);
				if (thereCanBeOnlyOne) break;
			}
		}
		
		// get an object's index (or indices) & remove
		static public function FindIndicesAndRemove(arr:Array, obj:*, thereCanBeOnlyOne:Boolean = false):Array {
			var indices:Array = [];
			var index:int;
			while ((index = arr.indexOf(obj, index)) >= 0) {
				arr.splice(index, 1);
				indices.push(index);
				if (thereCanBeOnlyOne) break;
			}
			return indices;
		}
		
		// <= true = object is unique, inserted
		static public function PushUnique(arr:Array, obj:ICompare):Boolean {
			var i:int = FindEqual(arr, obj);
			if (i >= 0) return false;
			arr.push(obj);
			return true;
		}
		
		static public function ConcatUnique(arr1:Array, arr2:Array):Array {
			var arr:Array = arr1.concat();
			for each (var obj:ICompare in arr2) {
				PushUnique(arr, obj);
			}
			return arr;
		}

		static public function FindEqual(arr:Array, obj:ICompare):int {
			for (var i:int = arr.length - 1; i >= 0; --i) {
				if (obj.equal(arr[i] as ICompare)) return i;
			}
			return -1;
		}
		
		static public function RemoveEqual(arr:Array, obj:ICompare):* {
			var i:int = FindEqual(arr, obj);
			if (i >= 0) return arr.splice(i, 1)[0]; // remove elements from original Array and return removed items (splice does)
			return null;
		}
		
		static public function FindByValue(container:*, key:String, value:*):* {
			for each (var obj:* in container) {
				try {
					if (obj[key] === value) return obj;
				} catch(e:Error) { trace("FindByValue error:",e) }
			}
			return undefined;
		}
		
		static public function Shuffle(arr:Array, iterations:uint):void {
			for (; iterations > 0; --iterations) {
				var i1:uint = Maths.randomUInt(arr.length);
				var i2:uint = Maths.randomUInt(arr.length);
				var temp:* = arr[i1];
				arr[i1] = arr[i2];
				arr[i2] = temp;
			}
		}
		
		static public function GetRandom(arr:Array):* {
			return arr[Maths.randomUInt(arr.length)];
		}
		
		static public function GetRandomAndRemoveFast(arr:Array):* {
			return GetAndRemoveFast(arr, Maths.randomUInt(arr.length));
		}
		
		static public function Compare(arr1:Array, arr2:Array):Boolean {
			if (arr1.length != arr2.length) return false;
			for (var i:int = arr1.length - 1; i >= 0; --i) {
				if (arr1[i] != arr2[i]) break;
			}
			if (i < 0) return true;
			return false;
		}
		
		static public function ToString(arr:Array, str:String = ""):String {
			for (var v:* in arr) {
				var val:* = arr[v];
				if (val == undefined) continue;
				str += v + "=" + arr[v] + ",";
			}
			return str.slice(0,-1);
		}
	}
	
}