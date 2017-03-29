package skinning 
{
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	import flare.materials.Material3D;
	import flare.modifiers.Modifier;
	import flare.modifiers.SkinModifier;
	import flare.system.Device3D;
	import flare.utils.Matrix3DUtils;
	
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	
	public class CustomModifier2 extends SkinModifierNew
	{
		static private const RootToSkin:Dictionary = new Dictionary(true);
		
		static public function CloneToCustom(_skin:Modifier):Modifier {
			const skin:SkinModifier = _skin as SkinModifier;
			if (!skin) return _skin;
			
			const custom:CustomModifier2 = new CustomModifier2();
			
			// essentials
			custom.root = skin.root;
			custom.skinData = skin.skinData;
			custom.invBoneMatrix = skin.invBoneMatrix;
			custom.bones = skin.bones;
			
			// useless?
			//custom.mesh = skin.mesh;
			custom.bindTransform = skin.bindTransform;
			
			// optimization
			const sameSkeletonSkin:CustomModifier2 = RootToSkin[skin.root];
			if (sameSkeletonSkin) {
				custom._transformList = sameSkeletonSkin._transformList;
				custom._totalFrames = sameSkeletonSkin._totalFrames;
				custom.sharedSkinData = sameSkeletonSkin.sharedSkinData;
			} else {
				custom.buildTransformList();
				custom.sharedSkinData = new SharedSkinData();
				RootToSkin[skin.root] = custom;
			}
			//trace("skin.skinData",skin.skinData.length,"skin.invBoneMatrix",skin.invBoneMatrix.length,"skin.bones",skin.bones.length,"skin._transformList",custom._transformList.length);
			
			return custom;
		}
		
		//
		
		// advanced blending
		/**
		 * starting frame number; set to <b>non-Infinity</b> to use advanced blending
		 */
		public var startFrame:Number = Infinity;
		/**
		 * 0 to 1 inclusive (but should be exclusive in practice!)
		 */
		public var lerpFactor:Number = Infinity;
		
		private const tempMat:Matrix3D = new Matrix3D();
		private var sharedSkinData:SharedSkinData;
		
		public function CustomModifier2()
		{
			super();
		}
		
		override public function setFrame( mesh:Mesh3D ):void {
			const endFrame:Number = mesh.currentFrame;
			
			// check if setFrame is needed at all
			if (
				endFrame === sharedSkinData.endFrame &&
				startFrame === sharedSkinData.startFrame &&
				(
				 startFrame === Infinity ||
				 lerpFactor === sharedSkinData.lerpFactor
				)
			   )
				return; // _transformList already set
			
			// it is needed
//			trace(this,"setFrame", mesh.name, startFrame, endFrame, lerpFactor);
			sharedSkinData.startFrame = startFrame;
			sharedSkinData.endFrame = endFrame;
			sharedSkinData.lerpFactor = lerpFactor;
			
			if (startFrame === Infinity) {
				super.setFrame(mesh); // old-style transform
				return;
			}
			
			// new-style transform
			const startFrame1:int = startFrame % _totalFrames;
			const startFrame2:int = (startFrame1 + 1) % _totalFrames;
			const startLerpFactor:Number = startFrame - int(startFrame);
			
			const endFrame1:int = mesh.currentFrame % _totalFrames;
			const endFrame2:int = (endFrame1 + 1) % _totalFrames;
			const endLerpFactor:Number = mesh.currentFrame - int(mesh.currentFrame);
			
			var bone:Pivot3D;
			var i:int;
			
//			trace(startFrame1,startFrame2,startLerpFactor,endFrame1,endFrame2,endLerpFactor);
			for (i = _transformList.length - 1; i >= 0; --i) {
				bone = _transformList[i];
				if (bone.frames) {
					const bTrans:Matrix3D = bone.transform;
					// startFrame
					bTrans.copyFrom( bone.frames[ startFrame1 ] );
					Matrix3DUtils.interpolateTo( bTrans, bone.frames[ startFrame2 ], startLerpFactor );
//					bone.transform.interpolateTo( bone.frames[ startFrame2 ], startLerpFactor );
					// endFrame
					tempMat.copyFrom( bone.frames[ endFrame1 ] );
//					Matrix3DUtils.interpolateTo(tempMat, bone.frames[ endFrame2 ], endLerpFactor );
					tempMat.interpolateTo( bone.frames[ endFrame2 ], endLerpFactor ); // can get away with this
//					// result
//					bTrans.interpolateTo( tempMat, lerpFactor );
					Matrix3DUtils.interpolateTo( bTrans, tempMat, lerpFactor );
				}
				bone.dirty = true; // NOTE : mark dirty anyway!
			}
		}
	}
}

class SharedSkinData {
	
	public var startFrame:Number;
	public var endFrame:Number;
	public var lerpFactor:Number;
}