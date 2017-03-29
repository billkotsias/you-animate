package skinning 
{
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.materials.Material3D;
	import flare.modifiers.Modifier;
	import flare.modifiers.SkinModifier;
	import flare.system.Device3D;
	
	import flash.geom.Matrix3D;
	
	public class CustomModifier extends SkinModifier
	{
		static public function CloneToCustom(_skin:Modifier):Modifier {
			const skin:SkinModifier = _skin as SkinModifier;
			if (!skin) return _skin;
			
			const custom:CustomModifier = new CustomModifier(null);
			custom.bindTransform = skin.bindTransform;
			custom.bones = skin.bones;
			custom.invBoneMatrix = skin.invBoneMatrix;
			custom.mesh = skin.mesh;
			custom.root = skin.root;
			custom.skinData = skin.skinData;
			custom.totalFrames = skin.totalFrames;
			
			custom.root.forEach(custom.initBones);
			return custom;
		}
		
		private const transformList:Array = [];
		
		// advanced blending
		public var startFrame:Number;	// starting frame number
		public var lerpFactor:Number;	// 0 to 1 inclusive (but should be exclusive really!)
		private const tempMat:Matrix3D = new Matrix3D();
		
		public function CustomModifier(_skin:Modifier)
		{
//			super();
//			const skin:SkinModifier = _skin as SkinModifier;
//			mesh = skin.mesh;
//			root = skin.root;
//			skinData = skin.skinData;
//			bindTransform = skin.bindTransform; // useless?
//			invBoneMatrix = skin.invBoneMatrix;
//			
//			skin.bones.forEach( function(...params):void {
//				const bone:Pivot3D = params[0];
//				addBone(bone);
//				initBones(bone);
//			});
//			update(); // !!!
			super();
			
			// TO DELETE:
			if (!_skin) return;
			const skin:SkinModifier = _skin as SkinModifier;
			bindTransform = skin.bindTransform;
			bones = skin.bones;
			invBoneMatrix = skin.invBoneMatrix;
			mesh = skin.mesh;
			root = skin.root;
			skinData = skin.skinData;
			totalFrames = skin.totalFrames;
			
			root.forEach(initBones);
			// :TO DELETE
		}
		
		private function initBones(bone:Pivot3D):void {
			transformList.push(bone);
		}
		
		override public function setFrame(mesh:Mesh3D):void {
			trace("setFrame",mesh.currentFrame);
		}
		
		override public function draw( mesh:Mesh3D, material:Material3D = null ):void
		{
			trace("draw",mesh.currentFrame, mesh === this.mesh);
			//			trace(this,totalFrames,mesh.currentFrame);
			const endFrame1:int = mesh.currentFrame % totalFrames;
			const endFrame2:int = (endFrame1 + 1) % totalFrames;
			const endLerpFactor:Number = mesh.currentFrame - int(mesh.currentFrame);
			
			const startFrame1:int = startFrame % totalFrames;
			const startFrame2:int = (startFrame1 + 1) % totalFrames;
			const startLerpFactor:Number = startFrame - int(startFrame);
			
			var bone:Pivot3D;
			var i:int;
			
			if (startFrame >= 0) {
				// advanced blending
				for (i = transformList.length - 1; i >= 0; --i) {
					bone = transformList[i];
					if (bone.frames) {
						const bTrans:Matrix3D = bone.transform;
						// startFrame
						bTrans.copyFrom( bone.frames[ startFrame1 ] );
						bTrans.interpolateTo( bone.frames[ startFrame2 ], startLerpFactor );
						// endFrame
						tempMat.copyFrom( bone.frames[ endFrame1 ] );
						tempMat.interpolateTo( bone.frames[ endFrame2 ], endLerpFactor );
						// result
						bTrans.interpolateTo( tempMat, lerpFactor );
					}
					bone.dirty = true; // NOTE : mark dirty anyway!
				}
				
			} else {
				// simple sequential-frames blending
				for (i = transformList.length - 1; i >= 0; --i) {
					bone = transformList[i];
					if (bone.frames) {
						bone.transform.copyFrom( bone.frames[ endFrame1 ] );
						bone.transform.interpolateTo( bone.frames[ endFrame2 ], mesh.currentFrame - int(mesh.currentFrame) );
					}
					bone.dirty = true; // NOTE : mark dirty anyway!
				}
			}
			// blending
			
			Device3D.global.copyFrom( mesh.world );
			Device3D.worldViewProj.copyFrom( Device3D.global );
			Device3D.worldViewProj.append( Device3D.viewProj );
			Device3D.objectsDrawn++;
			
			var index:int;
			for each ( var surf:Surface3D in mesh.surfaces )
			{
				var data:Vector.<int> = skinData[ index++ ];		
				var boneCount:int = data.length;
				for ( var b:int = 0; b < boneCount; b++ )
				{
					var boneIndex:int = data[ b ];
					Device3D.temporal0.copyFrom( invBoneMatrix[ boneIndex ] );
					Device3D.temporal0.append( bones[ boneIndex ].world );
					Device3D.temporal0.copyRawDataTo( Device3D.bones, b * 12, true );
				}
				Material3D( material || surf.material ).draw( mesh, surf, surf.firstIndex, surf.numTriangles );
			}
		}
	}
}