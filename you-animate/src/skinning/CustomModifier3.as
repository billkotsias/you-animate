package skinning
{
	import fanlib.utils.FArray;
	import fanlib.utils.Utils;
	
	import flare.core.Frame3D;
	import flare.core.Label3D;
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
	
	// MUST be 'SkinModifier' for shadows to frigging work
	public class CustomModifier3 extends SkinModifier
	{
		// static...
		static private const RootToSkin:Dictionary = new Dictionary(true);
		
		static public function CloneToCustom(_skin:Modifier, _subrootNames:Array = null):Modifier {
			const skin:SkinModifier = _skin as SkinModifier;
			if (!skin) return _skin;
			
			const custom:CustomModifier3 = new CustomModifier3();
			
			// essentials
			custom.root = skin.root;
			custom.skinData = skin.skinData;
			custom.invBoneMatrix = skin.invBoneMatrix;
			custom.bones = skin.bones;
			
			// useless? (found in ColladaLoader)
			//custom.bindTransform = skin.bindTransform;
			
			// optimization : stuff shared between same-skeleton SkinModifiers!
			const sameSkeletonSkin:CustomModifier3 = RootToSkin[skin.root];
			if (sameSkeletonSkin) {
				custom.boneSets = sameSkeletonSkin.boneSets;
				custom.subrootNamesCopy = sameSkeletonSkin.subrootNamesCopy; // useful to clone declaring order! Gege?
				custom._totalFrames = sameSkeletonSkin._totalFrames;
			} else {
				custom.buildBoneSets(_subrootNames);
				RootToSkin[skin.root] = custom;
			}
			
			return custom;
		}
		
		static protected const MeshToFrames:Dictionary = new Dictionary(true);
		static public function SetMeshFrames(mesh:Mesh3D, framesArray:Vector.<Frame>):void {
			const frames:Dictionary = MeshToFrames[mesh] = new Dictionary(true);
			for each (var frame:Frame in framesArray) {
				frames[ frame.rootBoneName /*may be null, thus Dictionary and not Object*/ ] = frame;
			}
		}
		
		/**
		 * Get new frames for every skeleton found, and assign those frames to meshes using each skeleton
		 * @param pivot Get from this pivot children meshes and their skeleton(s)
		 * @return Frames with names according to _subrootNames passed when building the skeletons (=modifiers)
		 */
		static public function GetFramesPerSkeleton(pivot:Pivot3D):Vector.<Frame> {
			const skeletonToMeshes:Dictionary = new Dictionary(true);
			pivot.forEach(function(mesh:Mesh3D):void {
				const modifier:CustomModifier3 = mesh.modifier as CustomModifier3;
				if (!modifier) return;
				const meshesArray:Array = Utils.GetGuaranteed(skeletonToMeshes, modifier.root, Array);
				meshesArray.push(mesh);
			}, Mesh3D);
			
			// super size me
			var arr:Vector.<Frame> = new Vector.<Frame>;
			for each (var meshesArray:Array in skeletonToMeshes) {
				const modifier:CustomModifier3 = (meshesArray[0] as Mesh3D).modifier as CustomModifier3;
				const frames:Vector.<Frame> = modifier.getSkeletonFrames();
				arr = arr.concat( frames );
				for each (var mesh:Mesh3D in meshesArray) {
					CustomModifier3.SetMeshFrames(mesh, frames);
				}
			}
			return arr;
		}
		// ...static
		
		// SkinModifier stuff
//		protected var bones:Vector.<Pivot3D>;
//		protected var skinData:Vector.<Vector.<int>>;
//		protected var invBoneMatrix:Vector.<Matrix3D>;
//		protected var root:Pivot3D;
//		protected var bindTransform:Matrix3D = new Matrix3D();
		protected var _totalFrames:int;
		
		// the 1st one is considered the "default" one
		private var subrootNamesCopy:Array;
		protected var boneSets:Vector.<BoneSet>;
		protected const boneNameToSet:Object = {};
		
		private const tempMat:Matrix3D = new Matrix3D();
		
		public function CustomModifier3()
		{
			super();
		}
		
		override public function draw( mesh:Mesh3D, material:Material3D = null ):void
		{
			if ( !boneSets ) return;
			
			var i:int;
			var bone:Pivot3D;
			var boneList:Vector.<Pivot3D>;
			var boneSet:BoneSet;
			
			const frames:Dictionary = MeshToFrames[mesh] || new Dictionary(true);
			var defaultFrame:Frame = frames[ null ];
			if (!defaultFrame) {
				defaultFrame = new Frame(); // dummy
				defaultFrame.endFrame = mesh.currentFrame; // follow mesh 'gotoAndPlay' frame
			}
			
			var allSetsFramesEqual:Boolean = true;
			for each (boneSet in boneSets) {
				
				boneList = boneSet.boneList;
				var frame:Frame = frames[ boneSet.rootBoneName ] || defaultFrame; // default if specific doesn't exist
				
				// check if boneSet has already been set to 'frame'
//				trace("is equal?");
				if (boneSet.isEqualTo(frame)) continue;
				allSetsFramesEqual = false; // now we need to mark the whole skeleton as dirty!
				
//				trace("is not equal",mesh.currentFrame,mesh.name);
				boneSet.copy(frame);
				
				const endFrame:Number = boneSet.endFrame;
				const endFrame1:int = endFrame % _totalFrames;
				const endLerpFactor:Number = endFrame - int(endFrame);
				
				if (boneSet.advancedBlending)
				{
					// new-style transform
					const startFrame:Number = boneSet.startFrame;
					const startFrame1:int = startFrame % _totalFrames;
					const startFrame2:int = (startFrame1 + 1) % _totalFrames;
					const startLerpFactor:Number = startFrame - int(startFrame);
					
					const endFrame2:int = (endFrame1 + 1) % _totalFrames;
					
					const lerpFactor:Number = boneSet.lerpFactor;
					
					for (i = boneList.length - 1; i >= 0; --i) {
						bone = boneList[i];
						if (bone.frames) {
							const bTrans:Matrix3D = bone.transform;
							// startFrame
							bTrans.copyFrom( bone.frames[ startFrame1 ] );
							Matrix3DUtils.interpolateTo( bTrans, bone.frames[ startFrame2 ], startLerpFactor );
							// endFrame
							tempMat.copyFrom( bone.frames[ endFrame1 ] );
							tempMat.interpolateTo( bone.frames[ endFrame2 ], endLerpFactor ); // can get away with this one
							// result
							Matrix3DUtils.interpolateTo( bTrans, tempMat, lerpFactor );
						}
					}
					
				} else {
					
					const smooth:int = mesh.animationSmoothMode;
					if ( smooth === Pivot3D.ANIMATION_SMOOTH_NONE ) {
						
						for ( i = boneList.length - 1; i >= 0; --i ) {
							bone = boneList[ i ];
							if ( bone.frames )
								bone.transform.copyFrom( bone.frames[ endFrame1 ] );
						}
						
					} else {
						
						// default Flare3D stuff
						var label:Label3D, from:int, to:int;
						if ((label = mesh.currentLabel)) { from = label.from; to = label.to } else { from = 0; to = _totalFrames } 
						
						var labelLength:int = to - from;
						var toFrame:int = endFrame1 + 1 - from;
						
						if ( mesh.animationMode === Pivot3D.ANIMATION_LOOP_MODE )
							toFrame %= labelLength;
						else if ( mesh.animationMode === Pivot3D.ANIMATION_STOP_MODE ) 
							if ( toFrame > labelLength ) toFrame = labelLength;
						
						for ( i = boneList.length - 1; i >= 0; --i ) {
							bone = boneList[ i ]; 
							if ( bone.frames ) {
								bone.transform.copyFrom( bone.frames[endFrame1] );
								Matrix3DUtils.interpolateTo( bone.transform, bone.frames[toFrame + from], endLerpFactor );
							}
						}
					}
				}
			}
			
			if (!allSetsFramesEqual) {
				for each (boneSet in boneSets) {
					boneList = boneSet.boneList;
					for (i = boneList.length - 1; i >= 0; --i) boneList[i].dirty = true; // NOTE : mark dirty anyway!!!
				}
			}
			
			// note: this is slow, but allows to render bones children for special cases when enabled
			if ( root.visible ) {
				trace(this, mesh.name, "skeleton root is visible");
				root.dirty = true;
				root.transform.copyFrom(mesh.world);
				root.draw();
				root.transform.identity();
				root.updateTransforms(true);
			}
			
			// actual pre-render calls!
			Device3D.global.copyFrom( mesh.world );
			Device3D.worldViewProj.copyFrom( Device3D.global );
			Device3D.worldViewProj.append( Device3D.viewProj );
			Device3D.objectsDrawn++;
			
			var len:int = mesh.surfaces.length;
			for ( var index:int = 0; index < len; index++ )
			{
				const surf:Surface3D = mesh.surfaces[index];
				if ( !surf.visible ) continue;
				
				const data:Vector.<int> = skinData[index];
				const boneCount:int = data.length;
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
		
		//
		
		public function buildBoneSets(_subrootNames:Array):void
		{
			_totalFrames = 0;
			boneSets = new Vector.<BoneSet>;
			_subrootNames ||= [];
			
			subrootNamesCopy = [""].concat(_subrootNames);
			root.name = ""; // default root name = empty
			buildBoneSet( root, _subrootNames.concat() );
			
			// make sure all bones have equal number of frames (the last frame is repeated to reach '_totalFrames' length)
			var frames:Vector.<Frame3D>;
			for each (var boneSet:BoneSet in boneSets) {
				for each (var bone:Pivot3D in boneSet.boneList) {
					if ( (frames = bone.frames) ) {
						const lastFrame:Frame3D = frames[ frames.length - 1 ];
						for ( var i:int = _totalFrames - frames.length; i > 0; --i )
							frames.push( lastFrame );
					}
				}
			}
		}
		private function buildBoneSet(rootBone:Pivot3D, _subrootNames:Array):BoneSet
		{
			const boneSet:BoneSet = new BoneSet();
			boneSets.push(boneSet);
			boneNameToSet[ (boneSet.rootBoneName = rootBone.name) ] = boneSet;
			const boneList:Vector.<Pivot3D> = boneSet.boneList;
			
			const serialized:Vector.<Pivot3D> = new Vector.<Pivot3D>;
			serialized.push(rootBone);
			do {
				const currentBone:Pivot3D = serialized.pop();
				const nameIndex:int = _subrootNames.indexOf( currentBone.name );
				if (nameIndex >= 0) {
					// this bone is a new sub-root
					_subrootNames.splice(nameIndex, 1); // no longer need to check for it
					buildBoneSet( currentBone, _subrootNames );
				} else {
					// add to current set
					boneList.push( currentBone );
					currentBone.lock = true;
					if ( currentBone.frames && currentBone.frames.length > _totalFrames )
						_totalFrames = currentBone.frames.length;
					
					for each ( var childBone:Pivot3D in currentBone.children )
						serialized.push(childBone);
				}
			} while (serialized.length);
			
			return boneSet;
		}
		
		/**
		 * @return A vector of 'Frame's corresponding to 'BoneSet's defined by '_subrootNames'. Gheghe?
		 */
		public function getSkeletonFrames():Vector.<Frame> {
			const arr:Vector.<Frame> = new Vector.<Frame>;
			for (var i:int = 0; i < subrootNamesCopy.length; ++i) {
				const rootBoneName:String = subrootNamesCopy[i];
				if ( boneNameToSet[rootBoneName] ) {
					const frame:Frame = new Frame();
					frame.rootBoneName = rootBoneName;
					arr.push( frame );
				} else {
					arr.push( null ); // null passed as "warning" since no bone "after this name" was found
				}
			}
			return arr;
		}
		
		override public function clone():Modifier { return this } // there is no need to clone because all share the same information
	}
}