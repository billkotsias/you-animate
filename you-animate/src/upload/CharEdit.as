package upload
{
	import com.hurlant.util.asn1.parser.extract;
	
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.io.MLoader;
	import fanlib.text.FTextField;
	import fanlib.ui.FButton2;
	import fanlib.ui.TouchMenu;
	import fanlib.utils.Debug;
	import fanlib.utils.DelayedCall;
	import fanlib.utils.FArray;
	import fanlib.utils.FStr;
	import fanlib.utils.Utils;
	
	import flare.basic.Scene3D;
	import flare.core.Label3D;
	import flare.core.Mesh3D;
	import flare.core.Pivot3D;
	import flare.core.Surface3D;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.utils.UIDUtil;
	
	import org.httpclient.events.HttpResponseEvent;
	
	import ui.ButtonText;
	import ui.LabelCheck;
	import ui.LabelInput;
	import ui.LabelRadio;
	import ui.LabelThumb;
	import ui.LabeledUI;
	import ui.report.Reporter;
	
	import upload.buttons.UploadModel;
	import upload.server.AnimInfo;
	import upload.server.CharInfo;
	import upload.server.EditModeVars;
	import upload.server.ServerCharDetails;
	import upload.server.ServerF3DFile;
	import upload.server.ServerProperties;
	import upload.server.ServerRequest;
	import upload.server.ServerThumb;
	
	public class CharEdit extends Pivot3D
	{
		static public const CURRENT_ANIMATION_CHANGED:String = "CURRENT_ANIMATION_CHANGED";
		static public const MODEL_CHANGED:String = "MODEL_CHANGED";
		static public const MODEL_LOADED:String = "MODEL_LOADED";
		
		private var loader:FlareLoader;
		private var progressFunction:Function;
		
		public const charInfo:CharInfo = new CharInfo();
		public const animations:Array = [];
		
		private var curAnimation:AnimInfo;
		private const thumbs:Array = [];
		private var defaultAnimInfo:AnimInfo = new AnimInfo();
		
		private var propMan:PropMan;
		
		// assigned
		private var mainInfo:FSprite;
		private var animInfo:FSprite;
		private var miscParams:FSprite;
		private var preview:LabelThumb;
		private var animInfoThumb:LabelThumb;
		private var newAnimation:ButtonText;
		private var deleteAnimation:ButtonText;
		private var animationEdit:FSprite;
		private var animWindow:AnimThumbs;
		private var newModel:UploadModel;
		private var timeline:Animline; // TODO : affect timeline according to anim selected curAnimation
		
		private var animMaxID:uint;
		private var animIDRadix:uint = 36;
		
		public function CharEdit(_request:*, sceneContext:Scene3D, nameToObject:Object, progressFunction:Function = null)
		{
			super();
			
			// keep init order
			sceneContext.addChild(this);
			propMan = new PropMan(this, sceneContext);
			linkToUI(nameToObject);
			this.progressFunction = progressFunction;
			
			// load
			newLoader(_request);
		}
		
		public function newLoader(_request:*):void {
			if (loader) loader.parent = null;
			
			if (_request is FileReference) {
				
				const fileRef:FileReference = _request;
				const modelBytes:ByteArray = fileRef.data;
				if (!(charInfo.character && charInfo.model)) {
					sendProperties(); // get character & model ids if file is new
				}
				sendF3DFile(fileRef);	// send new model based on ids above
				
				loader = new FlareLoader(modelBytes, null, parent as Scene3D);
				loader.whenComplete(modelBytesLoaded);
				loader.load();
				
			} else if (_request is EditModeVars) {
				
				// NOTE : this can only occur once on start-up!
				const emv:EditModeVars = _request;
				charInfo.character = emv.character;
				charInfo.model = emv.model;
				loader = null;
				
				new ServerProperties().request(this, function(serverData:ByteArray):void {
					try {
						const json:Object = JSON.parse(FStr.BytesToString(serverData));
					} catch (e:Error) {
						Reporter.AddError(this,"Can't load character data", e.message, FStr.BytesToString(serverData));
						return; // stop errors here
					}
					
					// character thumbnail
					const charDetails:ServerCharDetails = new ServerCharDetails( json );
					preview.setLazyBitmapData(charDetails.getModelThumbnail(emv.model), false);
					
					// model
					loader = new FlareLoader(charDetails.getModelURL(emv.model), null, parent as Scene3D);
					if (progressFunction !== null) {
						loader.addEventListener(ProgressEvent.PROGRESS, progressFunction);
						whenModelLoaded(function():void {
							loader.removeEventListener(ProgressEvent.PROGRESS, progressFunction);
						});
					}
					loader.whenComplete(modelDownloaded);
					loader.load();
					
					// main info
					charDetails.copyToCharInfo(charInfo); // 1st, read into 'charInfo'
					copyPropertiesToUI(charInfo, mainInfo);
					copyPropertiesToUI(charInfo, miscParams);
					mainInfoChanged();
					
					// animations
					const animThumbs:Array = charDetails.getAnimThumbs(emv.model);
					for each (var anim:Object in charDetails.getAnimations(emv.model)) {
						const _animInfo:AnimInfo = new AnimInfo();
						Utils.CopyDynamicProperties(_animInfo, anim, false, true, true);
						animations.push(_animInfo);
						thumbs.push(null);
						
						// - load thumbnail
						const animThumbObj:Object = FArray.FindByValue(animThumbs, "i", _animInfo.i);
						const thumb:String = (animThumbObj) ? animThumbObj["url"] : null;
						if (thumb) {
							new MLoader(thumb, function(l:MLoader):void {
								// _animInfo must be PASSED-IN, or else it will be a CONSTANT
								const _animInfo:AnimInfo = l.data;
								const index:int = animations.indexOf(_animInfo);
								if (index >= 0) {
									const bmpData:BitmapData = l.files[0].bitmapData;
									if (curAnimation === _animInfo) animInfoThumb.setBitmapData(bmpData, false);
									thumbs[index] = bmpData;
									animsChanged();
								}
							}, _animInfo);
						}
						
						// - calc max anim ID
						const animID:uint = parseInt(_animInfo.i, animIDRadix);
						if (animID > animMaxID) animMaxID = animID;
					}
					animsChanged();
				});
				
			} else {
				
				Reporter.AddError(this,"Unknown newLoader request",String(_request));
			}
			
		}
		
		public function whenModelLoaded(func:Function):void {
			if (loader && loader.complete) {
				func();
			} else {
				addEventListener(MODEL_LOADED, function _modelLoaded(e:Event):void {
					removeEventListener(MODEL_LOADED, _modelLoaded);
					func();
				});
			}
		}
		
		//
		
		private function modelDownloaded():void {
			addChild(loader);
			this.gotoAndPlay(0);
			this.gotoAndStop(0);
			dispatchEvent(new Event(MODEL_LOADED));
			
			if (!charInfo.polygons) {
				charInfo.polygons = Utils3D.CountTriangles(this);
				copyPropertiesToUI(charInfo, miscParams);
			}
			
			// - hack : pre-load props
			for each (var _animInfo:AnimInfo in animations) {
				if (_animInfo.prop) propMan.propChanged(_animInfo.prop, _animInfo);
			}
		}
		
		private function modelBytesLoaded():void {
			modelDownloaded();
			
			// extract (new) Animation Labels!
//			const thumbDims:Array = animInfoThumb.maxDims;
//			const defaultThumb:BitmapData = LabelThumb.GetCheckersData(thumbDims[2], thumbDims[3]);
			
			const meshes:Vector.<Pivot3D> = loader.getChildrenByClass(Mesh3D);
			for each (var mesh:Mesh3D in meshes) {
//				trace(mesh.name,"\n"+Utils.PrettyString(mesh.labels));
				for each (var label:Label3D in mesh.labels) {
					var anim:AnimInfo = FArray.FindByValue(animations, "id", label.name);
					if (!anim) {
						anim = new AnimInfo();
						anim.i = getNextAnimID();
						anim.id = label.name;
						anim.from = label.from;
						anim.to = label.to;
						anim.rate = label.frameSpeed * 30;
						animations.push(anim);
						thumbs.push(null);
					}
				}
			}
			animsChanged();
			dispatchEvent(new Event(MODEL_CHANGED));
		}
		
		private function linkToUI(nameToObject:Object):void {
			const refNames:Array = [
				"newAnimation", "newModel", "deleteAnimation", "mainInfo", "preview",
				"animInfo", "animInfoThumb", "animationEdit", "animWindow", "miscParams"];
			for each (var n:String in refNames) {
				this[n] = nameToObject[n];
			}
			newModel.charEdit = this;
			newAnimation.addEventListener(FButton2.CLICKED, newAnimClicked);
			deleteAnimation.addEventListener(FButton2.CLICKED, deleteAnimClicked);
			animWindow.addEventListener(TouchMenu.CHILD_SELECTED, animSelected);
			animsChanged();
			
			listenToInputs(mainInfo);
			listenToInputs(animInfo);
			listenToInputs(miscParams);
			(animInfo.findChild("prop") as PropInput).propMan = propMan;
			
			Utils.CopyDynamicProperties(defaultAnimInfo, UItoObject.ExtractData(animInfo), false, true, true);
			
			mainInfoChanged();
//			trace("defaultAnimInfo\n"+Utils.PrettyString(defaultAnimInfo));
		}
		
		private function listenToInputs(cont:DisplayObjectContainer):void {
			for (var i:int = cont.numChildren - 1; i >= 0; --i) {
				var child:LabeledUI = cont.getChildAt(i) as LabeledUI;
				if (child) child.addEventListener(LabeledUI.CHANGE, userInput);
			}
		}
		
		// get data
		
		private function userInput(e:Event):void {
			const lui:LabeledUI = e.currentTarget as LabeledUI;
			if (lui is LabelThumb)
				thumbChanged(lui as LabelThumb);
			else
				collectInputData(lui);
		}
		
		private function collectInputData(lui:LabeledUI):void {
			
			const cont:DisplayObjectContainer = lui.parent;
			if (cont === mainInfo) {
				
				mainInfoChanged();
				
			} else if (cont === animInfo) {
				
				// animation info changed
				UItoObject.CopyPropertiesFromUI(curAnimation, cont);
				if (lui.name === "id") animsChanged(); // re-sort animation thumbnails (must double-click to select! Gotcha!)
				dispatchEvent(new Event(CURRENT_ANIMATION_CHANGED)); // animation preview is also affected
				
			} else if (cont === miscParams) {
				
				UItoObject.CopyPropertiesFromUI(charInfo, cont);
			}
			
			sendProperties();
		}
		
		
		private function mainInfoChanged():void {
			UItoObject.CopyPropertiesFromUI(charInfo, mainInfo);
			const newScale:Number = charInfo.scale;
			setScale(newScale,newScale,newScale);
			dispatchEvent(new Event(CURRENT_ANIMATION_CHANGED)); // animation preview is also affected
		}
		
		private function sendProperties():void {
			new ServerProperties().send(this, serverCharDataResponse);
		}
		
		private function sendF3DFile(fileRef:FileReference):void {
			new ServerF3DFile().send(this, serverCharDataResponse, fileRef);
		}
		
		private function serverCharDataResponse(data:ByteArray):void {
//			trace(this,"serverCharDataResponse",FStr.BytesToString(data));
			try {
				const json:Object = JSON.parse(FStr.BytesToString(data));
//				trace(this,"serverCharDataResponse",Utils.PrettyString(json));
				for (var propName:String in json) {
					try {
						// usually only 'character' and 'model' values are returned
						charInfo[propName] = json[propName];
					} catch (er1:Error) {
						if (propName !== "debug") {
							if (propName === "error") {
								Reporter.AddError(this,"Server error",FStr.BytesToString(data));
							} else {
								Reporter.AddWarning(this,"Unknown data",er1.message);
							}
							
						}
					}
				}
			} catch(er2:Error) { Reporter.AddError(this,"Can't parse character data",er2.message,FStr.BytesToString(data)) }
		}
		
		//
		
		private function thumbChanged(thumb:LabelThumb):void {
			const cont:DisplayObjectContainer = thumb.parent;
			if (cont === mainInfo) {
				
				new ServerThumb().sendThumbData("thumb", this, thumbSent, thumb.thumbnailBytes);
				
			} else if (cont === animInfo) {
				
				const animIndex:int = animations.indexOf(curAnimation);
				thumbs[animIndex] = thumb.thumbnailData;
				animsChanged(); // re-sort animation thumbnails (must double-click to select! Gotcha!)
				new ServerThumb().sendThumbData("animation_"+curAnimation.i, this, thumbSent, thumb.thumbnailBytes);
			}
		}
		
		private function thumbSent(data:ByteArray):void {
			CONFIG::debug { Debug.appendLineMulti(",",this,"thumbSent !!",FStr.BytesToString(data)); }
		}
			
		// Animation creation & selection
		
		private function newAnimClicked(e:MouseEvent):void {
			// init new animation
			changeCurrentAnimation( Utils.Clone(defaultAnimInfo) );
			curAnimation.i = getNextAnimID();
			curAnimation.id = guaranteeUniqueAnimName(defaultAnimInfo.id);
			animations.push(curAnimation); // register new animation
			
			// setup UI
			animationEdit.visible = true;
			copyPropertiesToUI(curAnimation, animInfo);
			animInfoThumb.setBitmapData(null); // nullify animation thumb -> shows checkers
			thumbs.push(null);
			animsChanged();
		}
		
		private function deleteAnimClicked(e:MouseEvent):void {
			new ServerThumb().sendThumbData("animation_"+curAnimation.i, this, thumbSent, null);
			
			animationEdit.visible = false;
			const animIndex:int = FArray.FindIndicesAndRemove(animations, curAnimation, true)[0];
			changeCurrentAnimation( null );
			thumbs.splice(animIndex, 1);
			animsChanged();
			
			dispatchEvent(new Event(CURRENT_ANIMATION_CHANGED)); // current animation wholy changed
			
			sendProperties();
		}
		
		private function animSelected(e:ObjEvent):void {
			changeCurrentAnimation( getAnimByID(e.getObj().name) );
			
			animationEdit.visible = true;
			copyPropertiesToUI(curAnimation, animInfo);
			const animIndex:int = animations.indexOf(curAnimation);
			animInfoThumb.setBitmapData(thumbs[animIndex], false);
		}
		
		// helpers
		private function copyPropertiesToUI(source:Object, cont:DisplayObjectContainer):void {
			UItoObject.CopyPropertiesToUI(source, cont);
			dispatchEvent(new Event(CURRENT_ANIMATION_CHANGED));
		}
		
		private function animsChanged():void {
			if (animWindow) animWindow.update(animations, thumbs);
		}
		
		private function getAnimByID(id:String):AnimInfo {
			return FArray.FindByValue(animations, "id", id);
		}
		
		private function guaranteeUniqueAnimName(animName:String):String {
			const origName:String = animName;
			var nameNum:uint = 2;
			while (getAnimByID(animName)) {
				animName = origName + " " + (nameNum++).toString();
			}
			return animName;
		}
		
		//
		
		private function getNextAnimID():String {
			return (++animMaxID).toString(animIDRadix);
		}
		
		private function changeCurrentAnimation(newAnim:AnimInfo):void {
			propMan.changeProps(curAnimation, newAnim);
			curAnimation = newAnim;
		}
		
		// getters
		
		public function get currentAnimation():AnimInfo { return curAnimation }
	}
}