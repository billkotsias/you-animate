package fanlib.math
{
	import fanlib.tween.TVector2;

	public class Vector2D
	{
		private var _length:Number = 0;
		private var _direction:TVector2 = new TVector2(0,0);
		private var _components:TVector2 = new TVector2();
		// TODO : _angle derived from direction
		
		public function Vector2D()
		{
		}
		
		public function accelerate(d:Number):Number {
			return (length = _length + d);
		}
		public function decelerate(d:Number):Number {
			if ((_length -= d) < 0) _length = 0;
			return (length = _length);
		}
		
		public function get length():Number { return _length; }
		public function set length(value:Number):void
		{
			_length = value;
			_components = _direction.mulN(length) as TVector2;
		}

		public function get components():TVector2 { return _components.copy() as TVector2; }
		public function set components(value:TVector2):void
		{
			_components = value.copy() as TVector2;
			_length = Math.sqrt(_components.x * _components.x + _components.y * _components.y);
			if (_length) {
				_direction = _components.divN(length) as TVector2;
			} else {
				_direction.x = 0;
				_direction.y = 0;
			}
		}

		public function get direction():TVector2 { return _direction; }
		/**
		 * 
		 * @param value MUST BE NORMALIZED!
		 * 
		 */
		public function set direction(value:TVector2):void
		{
			_direction = value;
			_components = _direction.mulN(length) as TVector2;
		}


	}
}