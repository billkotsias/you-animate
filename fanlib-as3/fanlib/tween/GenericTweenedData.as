package fanlib.tween {

	// tweenable class containing only Number variables
	dynamic public class GenericTweenedData implements ITweenedData {

		public function GenericTweenedData() {
		}
		
		// misc
		public function copy():ITweenedData {
			var copied:GenericTweenedData = new GenericTweenedData();
			for (var variable:String in this) {
				copied[variable] = this[variable];
			}
			return copied;
		}
		
		// math
		// NOTE : use only with same classes!
		public function add(d:ITweenedData):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] += d[variable];
			}
			return copied;
		};
		public function sub(d:ITweenedData):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] -= d[variable];
			}
			return copied;
		};
		public function mul(d:ITweenedData):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in this) {
				copied[variable] *= d[variable];
			}
			return copied;
		};
		public function div(d:ITweenedData):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] /= d[variable];
			}
			return copied;
		};
		public function addN(n:Number):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] += n;
			}
			return copied;
		};
		public function subN(n:Number):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] -= n;
			}
			return copied;
		};
		public function mulN(n:Number):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] *= n;
			}
			return copied;
		};
		public function divN(n:Number):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] /= n;
			}
			return copied;
		};
		public function idivN(n:Number):ITweenedData {
			var copied:GenericTweenedData = this.copy() as GenericTweenedData;
			for (var variable:String in copied) {
				copied[variable] = n / copied[variable];
			}
			return copied;
		};

	}
	
}
