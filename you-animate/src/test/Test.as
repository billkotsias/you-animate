package test 
{ 
	import com.apdevblog.utils.Draw;
	
	import fanlib.containers.Array2D;
	import fanlib.event.ObjEvent;
	import fanlib.gfx.FBitmap;
	import fanlib.gfx.FSprite;
	import fanlib.gfx.Stg;
	import fanlib.gfx.vector.DashedLine;
	import fanlib.gfx.vector.FShape;
	import fanlib.math.BezierCubic3D;
	import fanlib.text.FTextField;
	import fanlib.ui.ProgressBar;
	import fanlib.utils.DFXML2;
	import fanlib.utils.Debug;
	import fanlib.utils.FANApp;
	import fanlib.utils.FArray;
	import fanlib.utils.FStr;
	import fanlib.utils.Utils;
	
	import flare.basic.*;
	import flare.collisions.*;
	import flare.core.*;
	import flare.events.*;
	import flare.loaders.ColladaLoader;
	import flare.loaders.Flare3DLoader1;
	import flare.modifiers.*;
	import flare.primitives.*;
	import flare.system.Input3D;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.events.*;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	import flash.geom.Vector3D;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import scene.serialize.Serialize;
	
	import skinning.CustomModifier;
	import skinning.CustomModifier2;
	import skinning.SkinModifierNew;
	
	import tools.CheckButtonTool;
	import tools.ToolButton;
	import tools.lights.LightsWindow;
	import tools.misc.ColorPicker;
	
	import ui.report.RepIcon;
	import ui.report.Reporter;
	
	[SWF(width='1280',height='800',backgroundColor='#cccccc',frameRate='60')]
	public class Test extends FANApp
	{
		Flare3DLoader1; CustomModifier; ColladaLoader; FShape;
		
		private var _scene:Scene3D;
		private var props:Pivot3D;
		private var spyros:Pivot3D;
		private var vasilis:Pivot3D;
		private var spyrosRoot:Pivot3D;
		private var spyrosSkin:SkinModifierNew;
		
		private var f:Number = 0;
		
		//
		
		public function Test() {
//			const types:Array = [ "r", "g", "b", "c", "m", "y", "w", "k" ];
			const types:Array = [ "r", "g", "b", "k" ];
			var indent:String = "\t\t";
			var textb:String = "";
			textb = indent + "balls [\n";
			indent += "\t";
			const size:int = 4;
			const offZ:int = 12;
			const offY:int = size + 1;
			const offX:int = 0;
			for (var x:int = -size; x < size; ++x) {
				for (var y:int = -size; y < size; ++y) {
					for (var z:int = -size; z < size-1; ++z) {
						textb += indent + "[ " + (x+offX) + " " + (y+offY) + " " + (z+offZ) +
							" c::" + FArray.GetRandom(types) + " ]\n";
					}
				}
			}
			indent = indent.slice(0,-1);
			textb += indent + "]\n";
			trace(textb);
			
			super();
			return;
			
			const vec:Vector.<Boolean> = new Vector.<Boolean>;
//			vec.push(new Vector3D(1,2,3));
//			vec.push(new Vector3D(4,5,6));
//			vec.push(new Vector3D(7,8,9));
			vec.push(true);
			vec.push(false);
			const obja:Object = Serialize.ObjectToArray( Serialize.FromByteArray( Serialize.ToByteArray(vec) ) );
			trace(Utils.PrettyString(obja));
			trace(obja is Array, obja[1] === false, obja[0] is Boolean, obja[1] is Boolean);
			return;
			
			const sh:Shit = new Shit();
			const func1:Function = sh.afunc();
			trace(func1());
			sh.id = "kariolis";
			trace(func1());
			trace(sh.afunc()());
			return;
			
			const spr:Shape = Draw.gradientRect(4500,4500,45,0xff0000,0x00ffff,1,1);
			const rect:Rectangle = spr.getBounds(spr);
			const bmpData:BitmapData = new BitmapData(rect.width,rect.height,true,0);
			bmpData.draw(spr);
			const bmp:FBitmap = new FBitmap(bmpData);
			addChild(bmp);
			bmp.scaleX = bmp.scaleY = 1/6;
			
			const spr2:FSprite = new FSprite();
			const gr:Graphics = spr2.graphics;
			addChild(spr2);
			gr.lineStyle(1);
			gr.drawRect(0,0,stage.stageWidth-1,stage.stageHeight-1);
			
			const par:FSprite = new FSprite();
			addChild(par);
			const arr:Array2D = Utils3D.SplitOversizedBmpData(bmpData);
			var posY:Number = 0;
			var text:FTextField = new FTextField();
			text.defaultTextFormat = new TextFormat(null,128,0,true,true,true);
			text.autoSize = "left";
			for (var j:int = 0; j < arr.height; ++j) {
				var posX:Number = 0;
				for (var i:int = 0; i < arr.width; ++i) {
					text.htmlText = "ass = " + i.toString() + "*" + j.toString();
					const data:BitmapData = arr.get(i,j);
					data.draw(text);
					const bmp2:FBitmap = new FBitmap(data);
					bmp2.filters = [new GlowFilter()];
					trace(i,j,posX,posY);
					par.addChild(bmp2);
					bmp2.x = posX;
					bmp2.y = posY;
					posX += bmp2.width+10;
				}
				posY += bmp2.height+10;
			}
			par.scaleX = par.scaleY = bmp.scaleX;
			return;
			
			//
			LightsWindow; DashedLine; ColorPicker; CheckButtonTool;
			ToolButton.IconsFolder = "data/ui/";
			new DFXML2("test/lights.xml", this, lightsLoaded, null, "data/ui/");
		}
		
		private function lightsLoaded(o:ObjEvent):void {
		}
		
		override protected function stageInitialized():void {
			return;
			
			_scene = new Viewer3D(this);
			_scene.autoResize = true;
			_scene.camera = new Camera3D();
			_scene.camera.setPosition( 50, 75, -75 );
			_scene.camera.lookAt( 0, 40, 0 );
			_scene.addEventListener( Scene3D.COMPLETE_EVENT, completeEvent );
			
			_scene.addEventListener(Scene3D.PROGRESS_EVENT, progress);
			props = _scene.addChildFromFile("test/ArmyPilot.dae", props);
//			props = _scene.addChildFromFile("test/Spyros_test01.zf3d", props);
//			props = _scene.addChildFromFile("test/coffee_cup.zf3d", props);
			return;
			_scene.addChildFromFile("test/cellphoneOpt.zf3d");
			_scene.addChildFromFile("test/cigarette.zf3d", props);
//			spyros = _scene.addChildFromFile("test/vasilis.DAE");
//			spyros = _scene.addChildFromFile("test/Maria_walk_02.zf3d");
			spyros = _scene.addChildFromFile("test/Vasilis_all_anim_22-6.zf3d");
//			vasilis = _scene.addChildFromFile("test/Vasilis_all_anim_22-6.zf3d");
			vasilis = new Pivot3D();
			Debug.field.scaleX = Debug.field.scaleY = 2;
		}
		private function progress(p:ProgressEvent):void {
			Debug.field.text = (100 * p.bytesLoaded / p.bytesTotal).toFixed(2) + "% loaded";
		}
		
		private function completeEvent(e:Event):void 
		{
			stage.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				trace("===========");
				const meshes:Vector.<Pivot3D> = props.getChildrenByClass(Mesh3D);
				var tris:uint = 0;
				var surfaces:uint = 0;
				var meshNum:uint = 0;
				for each (var mesh:Mesh3D in meshes) {
					++meshNum;
					for each (var surface:Surface3D in mesh.surfaces) {
						++surfaces;
						tris += surface.indexVector.length / 3;
					}
				}
				trace("tris=",tris,"surfaces=",surfaces,"meshNum",meshNum);
				trace("===========");
			});
			return;
			
			Debug.field.text = "Processing, please wait";
			
			const IDENTITY:Matrix3D = new Matrix3D();
			const propsArr:Array = [
				"OBJ_Cellphone01",
				"OBJ_Cigarette01",
				"OBJ_Cookie02","OBJ_CoffePlate01","OBJ_Cookie01","OBJ_CoffeCup01"];
			propsArr.length = 0; // NO PROPERTIES
			for each (var propStr:String in propsArr) {
				var prop:Pivot3D = props.getChildByName(propStr);
				prop.transform.copyFrom(IDENTITY);
				spyros.getChildByName(propStr).addChild(prop.clone());
				vasilis.getChildByName(propStr).addChild(prop);
			}
			
//			spyrosSkin = (spyros.getChildrenByClass(Mesh3D)[0] as Mesh3D).modifier as SkinModifier;
			spyrosSkin = CustomModifier2.CloneToCustom((spyros.getChildrenByClass(Mesh3D)[0] as Mesh3D).modifier) as CustomModifier2;
			(spyros.getChildrenByClass(Mesh3D)[0] as Mesh3D).modifier = spyrosSkin;
			
//			const vasSkin:SkinModifier = (vasilis.getChildrenByClass(Mesh3D)[0] as Mesh3D).modifier as SkinModifier;
//			trace("spyros frames:", spyrosSkin.totalFrames, "vasilis frames:", vasSkin.totalFrames);
//			var t:Frame3D = new Frame3D(spyros.transform.rawData, Frame3D.TYPE_NULL);
//			spyros.frames = new Vector.<Frame3D>; // spyros.frames is null!
//			for ( var i:int = 0; i < vasSkin.totalFrames; ++i ) spyros.frames[i] = t;
//			spyros.transform = t;
//			spyrosSkin.totalFrames = vasSkin.totalFrames;
//			trace("spyros frames:", spyrosSkin.totalFrames, "vasilis frames:", vasSkin.totalFrames);
			
			spyrosRoot = spyrosSkin.root;
			try {
//				vasSkin.root.forEach(copyFrames);
				
				vasilis.z = 20;
				vasilis.frameSpeed /= 3;
				spyros.frameSpeed = vasilis.frameSpeed;
				trace("spyros.frameSpeed",spyros.frameSpeed);
				trace("spyros.gotoAndPlay(0);");
				spyros.gotoAndPlay(0);
				spyros.gotoAndStop(0);
				trace("spyros.gotoAndPlay(0);");
				_scene.addEventListener(Scene3D.RENDER_EVENT, event);
			} catch (e:Error) {
				Debug.field.text = e.toString();
			}
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, rightDown);
		}
		
		private function rightDown(e:MouseEvent):void {
			stage.addEventListener(Event.ENTER_FRAME, enterFrame);
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP,
				function rightUp(e:MouseEvent):void {
					stage.removeEventListener(MouseEvent.RIGHT_MOUSE_UP, rightUp);
					stage.removeEventListener(Event.ENTER_FRAME, enterFrame);
				});
		}
		private function enterFrame(e:Event):void {
			_scene.camera.translateY(Input3D.mouseYSpeed);
			trace(_scene.camera.getPosition().length);
//			_scene.camera.translateY(Input3D.mouseYSpeed * _scene.camera.getPosition().length / 300);
//			const pos:Vector3D = _scene.camera.getPosition();
//			_scene.camera.setPosition(pos.x, pos.y + Input3D.mouseYSpeed, pos.z);
		}
		
		private function keyDown(e:KeyboardEvent):void {
			f = 0;
//			vasilis.gotoAndPlay(new Label3D("", 0, 200)); 
//			spyros.gotoAndPlay(new Label3D("", 0, 200)); 
//			vasilis.gotoAndPlay(f);
//			spyros.gotoAndPlay(f);
		}
		
		private function copyFrames(p:Pivot3D):void {
			const sPiv:Pivot3D = spyrosRoot.getChildByName(p.name);
			if (sPiv) {
				sPiv.frames = p.frames;
			} else {
				trace(p.name);
			}
		}
		
		private function event(e:Event):void {
			(spyrosSkin as CustomModifier2).startFrame = f;
			(spyrosSkin as CustomModifier2).lerpFactor = 0;
			f+= spyros.frameSpeed;
			spyros.gotoAndStop(f);
		}
	} 
}

class Shit {
	
	public function Shit() {
		id = "poustis";
	}
	
	public function afunc():Function {
		var skata:String = id;
		return function():String {
			trace("in fucking function",skata,id);
			return skata;
		}
	}
		
	public var id:String = "malakas";
}