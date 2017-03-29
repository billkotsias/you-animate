package fanlib.box2d {
	
	import flash.geom.Rectangle;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Common.Math.b2Vec2;
	
	public class Cage extends WorldSprite {

		public var edgeWidth:Number = 10;
		public var edgeHeight:Number = 10;
		
		override public function set body(b:b2Body):void { throw toString() + ": manual body not allowed"; }
		
		public function Cage(rect:Rectangle = null) {
			if (rect) setRect(rect);
		}
		
		// => screen co-ordinates
		public function setRect(rect:Rectangle):void {
			if (!worldDoc) return;
			var sc:Number = worldDoc.worldScale;
			var wRect:Rectangle = new Rectangle(rect.x * sc, rect.y * sc, rect.width * sc, rect.height * sc);
			setRectWorld(wRect);
		}
		
		// => world co-ordinates
		public function setRectWorld(rect:Rectangle):void {
			if (!worldDoc) return;
			
			// reset _body
			if (_body) worldDoc.world.DestroyBody(_body);
			_body = worldDoc.world.CreateBody(new b2BodyDef());
			_body.SetPosition(new b2Vec2(rect.x + rect.width / 2, rect.y + rect.height / 2));
			
			var shape:b2PolygonShape;
			// bottom
			shape = new b2PolygonShape();
			shape.SetAsOrientedBox(rect.width / 2, edgeHeight / 2, new b2Vec2(0, (rect.height + edgeHeight) / 2));
			_body.CreateFixture2(shape);
			// top
			shape = new b2PolygonShape();
			shape.SetAsOrientedBox(rect.width / 2, edgeHeight / 2, new b2Vec2(0, - (rect.height + edgeHeight) / 2));
			_body.CreateFixture2(shape);
			// left
			shape = new b2PolygonShape();
			shape.SetAsOrientedBox(edgeWidth / 2, rect.height / 2, new b2Vec2(- (rect.width + edgeWidth) / 2, 0));
			_body.CreateFixture2(shape);
			// right
			shape = new b2PolygonShape();
			shape.SetAsOrientedBox(edgeWidth / 2, rect.height / 2, new b2Vec2((rect.width + edgeWidth) / 2, 0));
			_body.CreateFixture2(shape);
			
		}

	}
	
}
