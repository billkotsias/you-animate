package fanlib.box2d {
	
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	
	import fanlib.event.ObjEvent;
	import fanlib.gfx.Stg;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class DragWorldSprite extends WorldSprite {

		// UI stuff
		static public const START_DRAGGING:String = "StartDragging";
		static public const STOP_DRAGGING:String = "StopDragging";
		static public const CLICKING_NOT_DRAGGING:String = "ClickingNotDragging";
		static public var DRAG_THRESHOLD:Number = 8;	// pixels
		
		private var dragging:Boolean = false;
		private var clicking:Boolean = false;
		private var origPos:Point = new Point();	// original position before dragging
		
		public var mouseJoint:b2MouseJoint;

		public function DragWorldSprite() {
			addEventListener(MouseEvent.MOUSE_DOWN, _startDrag, false, 0, true);
			addEventListener(MouseEvent.CLICK, clicked, false, 0, true);
		}
		private function clicked(e:MouseEvent):void {
			if (clicking) {
				dispatchEvent(new ObjEvent(e, CLICKING_NOT_DRAGGING));
			}
		}
		
		protected function _startDrag(e:MouseEvent):void {
			if (dragging) return;
			
			clicking = true; // may go into 'false' state
			dragging = true;
			
			origPos.x = e.stageX; // global
			origPos.y = e.stageY;
			Stg.Get().addEventListener(MouseEvent.MOUSE_MOVE, moving);
			Stg.Get().addEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			
			newMouseJoint(origPos);
		}

		public function moving(e:MouseEvent):void {
			if (!dragging) return; // shouldn't be here anyway
			
			var newPos:Point = new Point(e.stageX, e.stageY); // global
			
			if (clicking) {
				if (Math.abs(newPos.x - origPos.x) > DRAG_THRESHOLD || Math.abs(newPos.y - origPos.y) > DRAG_THRESHOLD) {
					clicking = false;
					dispatchEvent(new ObjEvent(this, START_DRAGGING));
				}
			}
			
			setMJTarget(newPos);
		}

		public function _stopDrag(e:MouseEvent = null):void {
			if (!dragging) return;
			
			dragging = false;
			
			Stg.Get().removeEventListener(MouseEvent.MOUSE_MOVE, moving);
			Stg.Get().removeEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			
			if (!clicking) dispatchEvent(new ObjEvent(this, STOP_DRAGGING));
			
			destroyMouseJoint();
		}

		public function newMouseJoint(p:Point):void {
			destroyMouseJoint();
			
			var md:b2MouseJointDef = new b2MouseJointDef();
			md.bodyA = worldDoc.world.GetGroundBody();
			md.bodyB = _body;
			var targ:Point = worldDoc.globalToLocalWorld(p);
			md.target.Set(targ.x, targ.y);
			md.collideConnected = true;
			mouseJoint = worldDoc.world.CreateJoint(md) as b2MouseJoint;
			mouseJoint.SetMaxForce(Infinity);
			_body.SetAwake(true);
		}
		
		// => set mouse joint target in Stage co-ordinates
		public function setMJTarget(p:Point):void {
			p = worldDoc.globalToLocal(p);
			p.x *= worldDoc.worldScale;
			p.y *= worldDoc.worldScale;
			mouseJoint.SetTarget(new b2Vec2(p.x, p.y));
		}
		
		public function destroyMouseJoint():void {
			if (mouseJoint) {
				worldDoc.world.DestroyJoint(mouseJoint);
				mouseJoint = null;
			}
		}

	}
	
}
