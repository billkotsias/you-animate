package upload
{
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Gfx;
	import fanlib.gfx.Stg;
	import fanlib.text.FTextField;
	import fanlib.ui.BrowseLocal;
	import fanlib.ui.FButton2;
	import fanlib.ui.RadioButton;
	import fanlib.utils.IInit;
	import fanlib.utils.Utils;
	
	import flare.basic.Scene3D;
	import flare.core.Camera3D;
	import flare.core.Pivot3D;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import ui.BasicWindow;
	import ui.ButtonText;
	import ui.LabelRadio;
	import ui.LabeledUI;
	import ui.report.Reporter;
	
	import upload.server.ServerObjectFile;
	
	public class PropWindow extends BasicWindow implements IInit
	{
		static public const CLOSE:String = "PropWindowClose";
		
		private var title:FTextField;
		private var defaultTitle:String;
		private var typeRadio:RadioButton;
		
		public var objectList:ObjectList;
		public var newObjectBut:ButtonText;
		public var updateObjectBut:ButtonText;
		public var complexData:FSprite;
		
		public var charEdit:CharEdit;
		
		private const elements:Object = {};
		private var browseLocal:BrowseLocal;
		
		private var object3D:FlareLoader;
//		private var objScene3D:Scene3D;
		private var objScene3D:ModelViewer;
		
		public function PropWindow()
		{
			super();
			
			objScene3D = new ModelViewer(this);
//			objScene3D = new Scene3D(this);
			objScene3D.antialias = 2;
			objScene3D.addEventListener(Event.CONTEXT3D_CREATE, context3DCreated, false, 0, true);
		}
		private function context3DCreated(e:Event):void {
			objScene3D.camera = new Camera3D();
			objScene3D.addChild(objScene3D.camera); // must be added in the scene to be rendered!
			resetCamera();
		}
		
		public function resetCamera():void {
			objScene3D.camera.setPosition( 0, 2.2, -35 );
			objScene3D.camera.lookAt( 0, 0, 0 );
		}
		
		public function initLast():void {
			(findChild("ok") as FButton2).addEventListener(FButton2.CLICKED, okClicked);
			(findChild("cancel") as FButton2).addEventListener(FButton2.CLICKED, cancelClicked);
			
			typeRadio = (findChild("type") as LabelRadio).radio;
			typeRadio.addEventListener(RadioButton.CHANGE, checkObjectType);
			
			title = findChild("_title");
			defaultTitle = title.text;
			
			newObjectBut.addEventListener(FButton2.CLICKED, function (e:MouseEvent):void {
				objectList.selected = null;
				browseForObject();
			});
			updateObjectBut.addEventListener(FButton2.CLICKED, browseForObject);
			
			objectList.addEventListener(ObjectList.SELECTED_CHANGED, update);
			
			// scene3D
			objScene3D.viewportDO = findChild("objViewport");
			objScene3D.viewportInteractive = findChild("objViewportHitArea");
			objScene3D.renderTarget = findChild("objRender");
			objScene3D.hide();
			
			// register entries (fields)
			elements["id"] = findChild("id");
			elements["type"] = findChild("type");
			UItoObject.GetAllIUI(elements, findChild("mainData"));
			UItoObject.GetAllIUI(elements, complexData, 1);
			
			// listen to changes
			for each (var element:LabeledUI in elements) {
				element.addEventListener(LabeledUI.CHANGE, uiChange);
			}
		}
		
		private function uiChange(e:Event):void {
			// copy data from UI to selected ObjData
			const objData:ObjData = objectList.selected;
			objData.name = (elements["name"] as IUItoObject).result;
			const data:Object = objData.data || {}; // just in case
			objData.data = data;
			for (var elementName:String in elements) {
				data[elementName] = (elements[elementName] as IUItoObject).result;
			}
			
			objectList.redrawList();
			new ServerObjectFile().send(null, objectList.selected);
		}
		
		public function open(objectID:String):void {
			visible = true;
			setSingleTask();
			title.htmlText = defaultTitle + " <red>" + charEdit.currentAnimation.id + "</red>";
			objectList.selectByID(objectID); // event dispatched
		}
		
		private function update(e:* = undefined):void {
			var element:IUItoObject;
			
			const objData:ObjData = objectList.selected;
			
			(findChild("fields") as FSprite).visible = Boolean(objData);
			if (!objData) {
				updateObjectBut.enabled = false;
				newObject3D(null);
				return;
			}
			
			updateObjectBut.enabled = true;
			newObject3D(objData.url);
			
			// clear all fields 1st
			for each (element in elements) {
				element.result = "";
			}
			// copy any data to fields
			(elements["id"] as IUItoObject).result = objData.id;
			(elements["name"] as IUItoObject).result = objData.name;
			const data:Object = objData.data || {}; // just in case
			for (var elementName:String in elements) {
				var dataValue:* = data[elementName];
				if (dataValue !== undefined) (elements[elementName] as IUItoObject).result = dataValue;
			}
			
			checkObjectType();
		}
		
		private function checkObjectType(e:* = undefined):void {
			if (typeRadio && typeRadio.selected) Gfx.OneChildVisibleByName( complexData, typeRadio.selected.parent.name );
		}
		
		//
		
		private function browseForObject(e:* = undefined):void {
			if (browseLocal) return;
			
			var fileRef:FileReference;
			
			browseLocal = new BrowseLocal(
				new FileFilter("Flare3D files", "*.f3d;*.zf3d"),
				function bytesLoaded(data:ByteArray):void {
					browseLocal = null;
					new ServerObjectFile().sendFile(objectList.update, fileRef, objectList.selected);
					newObject3D(data);
				},
				function fileSelected(ref:FileReference):void {
					fileRef = ref;
					if (objectList.selected) {
						Reporter.AddInfo(this, "Update object " + objectList.selected.name + " (" + ref.name + ")");
					} else {
						Reporter.AddInfo(this, "New Flare3D object " + ref.name);
					}
				},
				function cancel():void {
					browseLocal = null;
				}
			);
		}
		
		private function newObject3D(request:*):void {
			if (object3D) object3D.parent = null;
			objScene3D.updateRenderTarget();
			if (!request) return;
			
			object3D = new FlareLoader(request, null, objScene3D, true);
			objScene3D.addChild(object3D);
			const _object3D:Pivot3D = object3D;
			object3D.whenComplete(function():void {
				if (object3D !== _object3D) return;
				resetCamera();
				object3D.gotoAndStop(0);
				objScene3D.updateRenderTarget();
			});
		}
		
		//
		
		public function close():void {
			visible = false;
			unsetSingleTask();
		}
		
		private function okClicked(e:Event):void {
			close();
			dispatchEvent(new ObjEvent(objectList.selected, CLOSE));
		}
		
		private function cancelClicked(e:Event):void {
			close();
			dispatchEvent(new ObjEvent(undefined, CLOSE));
		}
	}
}