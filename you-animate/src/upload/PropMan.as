package upload
{
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	
	import flash.geom.Matrix3D;
	import flash.utils.Dictionary;
	
	import scene.CharManager;
	import scene.action.special.DriveAction;
	import scene.action.special.PropAttached;
	import scene.action.special.PropInfo;
	
	import ui.report.Reporter;
	
	import upload.server.AnimInfo;

	public class PropMan
	{
		static private const IDENTITY:Matrix3D = new Matrix3D();
		
		private var props:Dictionary = new Dictionary(false); // AnimInfo -> Array of 'Pivots' (attached to same-named 'Pivots' in 'CharEdit')
		
		private var charEdit:CharEdit;
		private var sceneContext:Scene3D;
		
		public function PropMan(charEdit:CharEdit, sceneContext:Scene3D)
		{
			this.charEdit = charEdit;
			this.sceneContext = sceneContext;
		}
		
		public function changeProps(oldAnim:AnimInfo, newAnim:AnimInfo):void {
			var pivot:Pivot3D;
			
			const charScale:Number = charEdit.charInfo.scale;
			charEdit.setScale(charScale,charScale,charScale);
			sceneContext.addChild(charEdit); // do this anyway
			
			// old
			for each (pivot in props[oldAnim]) {
				pivot.hide();
			}
			
			// new
			for each (pivot in props[newAnim]) {
				pivot.show();
			}
			if (newAnim) {
				const propInfo:PropInfo = CharManager.INSTANCE.getPropInfoByID(newAnim.prop);
				if (propInfo && propInfo.data.type === "vehicleData") {
					const driverSeat:Pivot3D = pivot.getChildByName(DriveAction.DRIVER_PIVOT_NAME);
					if (!driverSeat) {
						Reporter.AddError("Control point CTRL_driver_seat not found in vehicle " + propInfo.name);
						return;
					}
					driverSeat.addChild(charEdit);
					charEdit.setScale(1,1,1);
				}	
			}
		}
		
		/**
		 * Prop changed for a particular animation! 
		 * @param newPropID
		 * @param anim
		 */
		internal function propChanged(newPropID:String, anim:AnimInfo = null):void {
//			trace("for fun", newPropID, anim.prop, newPropID == anim.prop);
			anim ||= charEdit.currentAnimation; // if null, default = current
			
			// destroy old
			for each (var pivot:Pivot3D in props[anim]) {
				pivot.gotoAndStop(0);
				pivot.parent = null;
			}
			delete props[anim]; // NOTE : Used to check if still valid !!!
			
			if (!newPropID) return; // end of the line
				
			// create new
			CharManager.INSTANCE.defaultSanAndreasList(function():void {
				
				const propInfo:PropInfo = CharManager.INSTANCE.getPropInfoByID(newPropID);
				if (propInfo) {
					const newPivots:Array = [];
					props[anim] = newPivots;
					
					const loader:FlareLoader = new FlareLoader(propInfo.getFullFilePath(), null, sceneContext, true);
					loader.whenComplete(function():void {
						
						if (props[anim] !== newPivots) return; // NOTE : outdated !!!
						
						if (propInfo.data.type === "vehicleData") {
							
							const driverSeat:Pivot3D = loader.getChildByName(DriveAction.DRIVER_PIVOT_NAME);
							if (!driverSeat) {
								Reporter.AddError("Control point CTRL_driver_seat not found in vehicle " + propInfo.name);
							}
							const vScale:Number = (propInfo.scale || 0.07);
							loader.setScale(vScale,vScale,vScale);
							sceneContext.addChild(loader);
							loader.gotoAndPlay(0);
							loader.gotoAndStop(0);
							newPivots.push( loader );
							
						} else {
							
							// get parents by name: all 1st-level children of loader (cloned inside Pivot3D)
							const children:Vector.<Pivot3D> = loader.children;
							for (var i:int = children.length - 1; i >= 0; --i) {
								
								pivot = children[i];
								
								const pivotParent:Pivot3D = charEdit.getChildByName(pivot.name);
								if (!pivotParent) {
									Reporter.AddError("Control point " + pivot.name + " of animation " + anim.id + " not found in character model");
									continue;
								}
								
								pivot.transform.copyFrom(IDENTITY); // NOTE : like 'PropAttached.attachToAnimatedParent'
								pivotParent.addChild(pivot);
								pivotParent.gotoAndPlay(0);
								pivotParent.gotoAndStop(0);
								
								newPivots.push( pivot );
							}
						}
						
						// show now or not?
						for each (pivot in newPivots) {
							if (charEdit.currentAnimation === anim) pivot.show(); else pivot.hide();
						}
					});
					
				} else {
					Reporter.AddError("Object " + newPropID + " of animation " + anim.id + " not found");
				}
			});
		}
	}
}