package ui.thumbs
{
	import tools.selectChar.AddBezierMove;

	public class ThumbsMove extends ThumbsAnim
	{
		public var addBezierMove:AddBezierMove;
		public var addBezierMoveHead:AddBezierMove;
		
		public function ThumbsMove()
		{
			super();
			animGroup = "moves";
		}
		
		override protected function dragNDrop(animName:String, index:int):void {
			var tool:AddBezierMove;
			if (selectedChar.getActionNum() == 0 || index) {
				tool = addBezierMove;
			} else {
				tool = addBezierMoveHead;
			}
			tool.addMove( animName );
		}
	}
}