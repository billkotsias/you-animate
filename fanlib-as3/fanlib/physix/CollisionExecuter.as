package fanlib.physix {
	
	public class CollisionExecuter {

		public function CollisionExecuter() {
			// constructor code
		}


		// High level functions : collision detection
	
		/// Sphere VS Sphere
		static public function checkCollision(sphere1:Sphere, sphere2:Sphere):CollisionParams {
	
			/// WATCH IT : CollisionExecuter expects passed objects to be <Ready> !
	
			/// convert collision to line VS sphere
			/// - calc new sphere radius, position = (0,0,0)
			// use |abs| in case of <negative> ("inner") radius
			//var sphereRadius:Number = Math.abs(sphere1.getWorldRadius() + sphere2.getWorldRadius());
			/// - calc new velocity
			//Ogre::Vector3 start = sphere1->getWorldPosition() - sphere2->getWorldPosition();
			//Ogre::Vector3 velocity = sphere1->getWorldVelocity() - sphere2->getWorldVelocity();
	
			//double time;
			//Ogre::Vector3 normal;
			//sphereVSline(start, velocity, sphereRadius, !(sphere1->checkFutureCollision || sphere2->checkFutureCollision), time, normal);
	
			//return new CollisionParams(sphere1, sphere2, time, normal);
			return new CollisionParams();
		}

	}
	
}
