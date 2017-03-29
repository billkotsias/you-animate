package fanlib.box2d {
	
	import fanlib.gfx.TSprite;
	import Box2D.Dynamics.b2Body;
	import fanlib.tween.ITweenedData;
	import Box2D.Common.Math.b2Vec2;
	import fanlib.tween.TVector2;
	import fanlib.tween.TVector1;
	import flash.geom.Point;
	
	public class WorldSprite extends TSprite {

		// body stuff
		protected var _body:b2Body;
		public function get body():b2Body { return _body; }
		public function set body(b:b2Body):void { _body = b; }
		
		internal var _worldDoc:WorldDoc; // set by 'WorldDoc' itself
		public function get worldDoc():WorldDoc { return _worldDoc; }
		
		public function WorldSprite() {
		}
		
		// update pos/rot from body
		public function updateFromBody():void {
			if (!_body || parent) return;
			var bodyPos:b2Vec2 = _body.GetPosition();
//			var pos:Point = parent.globalToLocal(new Point(bodyPos.x * worldDoc.screenScale,
//														   bodyPos.y * worldDoc.screenScale));
//			super.x = pos.x;
//			super.y = pos.y;
			super.x = bodyPos.x;
			super.y = bodyPos.y;
			super.rotation = _body.GetAngle() * (180./Math.PI);
		}
		
		// update body
		override public function setRot(_r:ITweenedData):void {
			super.setRot(_r);
			
			if (!_body || !worldDoc) return;
			var r:TVector1 = _r as TVector1;
			_body.SetAngle(r.x * (Math.PI / 180.));
		}
		
		override public function setPos(_pos:ITweenedData):void {
			super.setPos(_pos);
			updateBodyPos();
		}
		override public function set x(_x:Number):void {
			super.x = _x;
			updateBodyPos();
		}
		override public function set y(_y:Number):void {
			super.y = _y;
			updateBodyPos();
		}

		public function updateBodyPos():void {
			if (_body && worldDoc) {
			//if (_body && worldDoc && parent) {
				//var pos:Point = parent.localToGlobal(new Point(x,y));
				//_body.SetPosition(new b2Vec2(pos.x * worldDoc.worldScale, pos.y * worldDoc.worldScale));
				_body.SetPosition(new b2Vec2(x * worldDoc.worldScale, y * worldDoc.worldScale));
			}
		}
		
		
	}
	
}
