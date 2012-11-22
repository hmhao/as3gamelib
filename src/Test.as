package 
{
	import com.as3game.asset.AssetManager;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Tylerzhu
	 */
	public class Test extends Sprite 
	{
		
		public function Test():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			AssetManager.getInstance().getAsset("res/loading.swf", test1);
			AssetManager.getInstance().getGroupAssets("group1", ["res/loading.swf", "res/testsound.swf", "res/game.swf"], test2);
		}
		
		private function test1(content:*):void 
		{
			var i:int = 1;
			trace("test1");
		} 
		
		private function test2():void 
		{
			var j:int = 1;
			trace("test2")
			var game:* = AssetManager.getInstance().bulkLoader.getContent("res/game.swf");
			addChild(game);
			game.startGame();
			
			var timer:Timer = new Timer(1000, 5);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
			timer.start();
			
		}
		
		private function onComplete(e:TimerEvent):void 
		{
			AssetManager.getInstance().getAsset("res/sizetest1.mp3", test1);
		}
	}
	
}