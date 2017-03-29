package ui.thumbs
{
	import scene.Scene;
	import scene.action.Node;

	public class ThumbsFixed extends ThumbsAnim
	{
		public function ThumbsFixed()
		{
			super();
			animGroup = "fixed";
		}
		
		override protected function dragNDrop(animName:String, index:int):void {
			selectedChar.addFixedAction(animName, index);
			Scene.INSTANCE.history.addState( selectedChar.id, selectedChar.getHistoryState() );
		}
		
		override protected function dragNDropNode(animName:String, node:Node):void {
			selectedChar.addFixedActionAtNode(animName, node);
			Scene.INSTANCE.history.addState( selectedChar.id, selectedChar.getHistoryState() );
		}

	}
}