package skinning
{
	import flare.basic.*;
	import flare.core.*;
	import flare.materials.*;
	import flare.modifiers.*;
	import flare.system.*;
	import flare.utils.*;
	
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	/**
	 * This event occurs after the bones has been animated, so it is possible to change their transformation before render.
	 * @eventType flash.events.Event
	 */
	[Event(name = "change", type = "flash.events.Event")]
	
	/**
	 * Contains all the information needed to perform skinning deformations.
	 */
	public class SkinModifierNew extends Modifier implements IEventDispatcher
	{
		static private const _changeEvent:Event = new Event( Event.CHANGE );
		
		static public function CloneToNew(_skin:Modifier):Modifier {
			const skin:SkinModifier = _skin as SkinModifier;
			if (!skin) return _skin;
			
			// SkinModifier already exists for this skeleton, so what gives?
			var custom:SkinModifierNew = new SkinModifierNew();
			
			// essentials
			custom.root = skin.root;
			custom.skinData = skin.skinData;
			custom.invBoneMatrix = skin.invBoneMatrix;
			custom.bones = skin.bones;
			
			// useless?
			//custom.mesh = skin.mesh;
			custom.bindTransform = skin.bindTransform;
			
			custom.buildTransformList();
			
			return custom;
		}
		
		/**
		 * A reference to the skinned mesh
		 */
		//public var mesh:Mesh3D;
		/**
		 * Source transform from where the inverse bones transforms are calculated.
		 */
		public var bindTransform:Matrix3D = new Matrix3D();
		/**
		 * List of all bones.
		 */
		public var bones:Vector.<Pivot3D>;
		/**
		 * Contains the bone indices for each surface.
		 */
		public var skinData:Vector.<Vector.<int>>;
		/**
		 * Initial transform for each bone.
		 */
		public var invBoneMatrix:Vector.<Matrix3D> = new Vector.<Matrix3D>();
		/**
		 * The main bone node.
		 */
		public var root:Pivot3D = new Pivot3D("Root");
		
		protected var _totalFrames:int;
		protected var _transformList:Vector.<Pivot3D>;
		protected var _blending:Dictionary = new Dictionary(true);
		private var _events:EventDispatcher;
		
		public function SkinModifierNew()
		{
			_events = new EventDispatcher( this );
		}
		
		override public function clone():Modifier
		{
			// there is no needs to clone because all share the same information.
			return this;
		}
		
		/**
		 * Adds a new bone so that vertices can be then bound to it.
		 * @param	pivot Pivot3D object that is to perform the bone function.
		 * @return The added bone index.
		 */
		public function addBone( pivot:Pivot3D ):int
		{
			if ( !bones )
				bones = new Vector.<Pivot3D>();
			
			if ( pivot.frames && pivot.frames.length > _totalFrames )
				_totalFrames = pivot.frames.length;
			
			return bones.push( pivot ) - 1;
		}
		
		public function buildTransformList():void
		{
			// makes the sorted bone list.
			if ( !_transformList )
			{
				_totalFrames = 0;
				_transformList = new Vector.<Pivot3D>();
				root.lock = true;
				
				for each ( var p:Pivot3D in root.children ) {
					addBoneToList( p );
				}
				
				// make sure all bones have equal number of frames (the last frame is repeated to reach '_totalFrames' length)
				var frames:Vector.<Frame3D>;
				for each ( p in _transformList ) {
					if ( (frames = p.frames) ) {
						const lastFrame:Frame3D = frames[ frames.length - 1 ];
						for ( var i:int = _totalFrames - frames.length; i > 0; --i )
							frames.push( lastFrame );
					}
				}
			}
		}
		private function addBoneToList( pivot:Pivot3D ):void
		{
			pivot.lock = true;
			
			for each ( var p:Pivot3D in pivot.children )
				addBoneToList( p );
			
			if ( pivot.frames && pivot.frames.length > _totalFrames )
				_totalFrames = pivot.frames.length;
			
			_transformList.push( pivot );
		}
		
		//
		
		public function setFrame( mesh:Mesh3D ):void
		{
			var i:int;
			var p:Pivot3D;
			var length:int = _transformList.length;
			var currFrame:int = mesh.currentFrame;
			var smooth:int = mesh.animationSmoothMode;
			
//			trace(this,"setFrame-old-style",currFrame,mesh.name,smooth);
			
			// old-style frame setting
			if ( smooth === Pivot3D.ANIMATION_SMOOTH_NONE ) {
				
				for ( i = 0; i < length; i++ ) {
					p = _transformList[ i ];
					if ( p.frames )
						p.transform.copyFrom( p.frames[ currFrame ] );
					p.dirty = true;
				}
				
			} else {
				
				var label:Label3D = mesh.currentLabel;
				var from:int
				var to:int;
				
				if ( !label ) {
					from = 0;
					to = _totalFrames;
				} else {
					from = label.from;
					to = label.to;
				}
				
				var labelLength:int = to - from;
				var toFrame:int = currFrame + 1 - from;
				var percent:Number = mesh.currentFrame - currFrame;
				
				if ( mesh.animationMode == Pivot3D.ANIMATION_LOOP_MODE )
					toFrame %= labelLength;
				else if ( mesh.animationMode == Pivot3D.ANIMATION_STOP_MODE ) 
					if ( toFrame > labelLength ) toFrame = labelLength;
				
				for ( i = 0; i < length; i++ ) {
					p = _transformList[ i ]; 
					if ( p.frames ) {
						p.transform.copyFrom( p.frames[currFrame] );
						if ( smooth === Pivot3D.ANIMATION_SMOOTH_NORMAL )
							p.transform.interpolateTo( p.frames[toFrame + from], percent ); // buggy as sh*t
						else
							Matrix3DUtils.interpolateTo( p.transform, p.frames[toFrame + from], percent );
					}
					p.dirty = true;
				}
			}
		}
		
		override public function draw( mesh:Mesh3D, material:Material3D = null ):void
		{
			if ( !_transformList ) return;
			setFrame( mesh );
			
			var i:int;
			var p:Pivot3D;
			var length:int = _transformList.length;
			var currFrame:int = mesh.currentFrame;
			var smooth:int = mesh.animationSmoothMode;
//			trace(this,"draw",mesh.name,currFrame);
			
			// perform old-style blending if needed
			if ( mesh.blendValue !== 1 ) {
				trace(this,"old style blending performed");
				var blend:Dictionary = _blending[mesh];
				for ( i = 0; i < length; i++ ) {
					p = _transformList[ i ];
					if ( p.frames ) 
						if ( smooth == Pivot3D.ANIMATION_SMOOTH_NORMAL )
							p.transform.interpolateTo( Matrix3D( blend[p] ), 1 - mesh.blendValue );
						else
							Matrix3DUtils.interpolateTo( p.transform, Matrix3D( blend[p] ), 1 - mesh.blendValue );
					p.dirty = true;
				}
			}
			
			// note: this is slow, but allows to render bones children for special cases when enabled
			if ( root.visible ) {
				trace(this, "skeleton root is visible");
				root.dirty = true;
				root.transform.copyFrom(mesh.world);
				root.draw();
				root.transform.identity();
				root.updateTransforms(true);
			}
			
			// anyone needs to alter my guts JUST (!) before the rendering?
			if ( _events.hasEventListener( Event.CHANGE ) )
				dispatchEvent( _changeEvent );
			
			// actual pre-render calls!
			Device3D.global.copyFrom( mesh.world );
			Device3D.worldViewProj.copyFrom( Device3D.global );
			Device3D.worldViewProj.append( Device3D.viewProj );
			Device3D.objectsDrawn++;
			
			var len:int = mesh.surfaces.length;
			for ( var index:int = 0; index < len; index++ )
			{
				var data:Vector.<int> = skinData[index];
				var surf:Surface3D = mesh.surfaces[index];
				
				if ( !surf.visible )
					continue;
				
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
		
		public function get totalFrames():int { return _totalFrames }
		public function set totalFrames( value:int ):void { _totalFrames = value }
		
		/**
		 * This is trigered when calling gotoAndPlay or gotoAndStop on a Pivot3D to save the last frame state.
		 */
		public function setBlendingState( mesh:Mesh3D ):void
		{
			setFrame( mesh );
			
			// to perfrom the blending, we need to cache previous position per mesh first.
			var length:int = _transformList.length;
			var blend:Dictionary = _blending[mesh] || new Dictionary( true );
			_blending[mesh] = blend;
			for ( var i:int = 0; i < length; i++ ) {
				var p:Pivot3D = _transformList[ i ];
				var m:Matrix3D = blend[p] || new Matrix3D;
				m.copyFrom( p.transform );
				blend[p] = m;
			}
		}
		
		/* INTERFACE flash.events.IEventDispatcher */
		
		public function addEventListener( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false ):void
		{
			_events.addEventListener( type, listener, useCapture, priority, useWeakReference );
		}
		
		public function removeEventListener( type:String, listener:Function, useCapture:Boolean = false ):void
		{
			_events.removeEventListener( type, listener, useCapture );
		}
		
		public function dispatchEvent( event:Event ):Boolean
		{
			return _events.dispatchEvent( event );
		}
		
		public function hasEventListener( type:String ):Boolean
		{
			return _events.hasEventListener( type );
		}
		
		public function willTrigger( type:String ):Boolean
		{
			return _events.willTrigger( type );
		}
	}
}
