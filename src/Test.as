package 
{
	import com.as3game.asset.AssetManager;
	import com.as3game.sound.GameSound;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.setInterval;
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
			
			GameSound.getInstance().playSound("res/sizetest.mp3");
			//AssetManager.getInstance().getAsset("res/sizetest.mp3", test1);
			AssetManager.getInstance().getGroupAssets("group1", ["res/loading.swf", "res/testsound.swf", "res/game.swf"], test2);
		}
		
		private function test1(content:*):void 
		{
			//var i:int = 1;
			//trace("test1");
			//var test:Sound = AssetManager.getInstance().bulkLoader.getSound("res/sizetest.mp3");
			//test.play();
		} 
		
		private function test2():void 
		{
			var j:int = 1;
			trace("test2")
			var game:* = AssetManager.getInstance().bulkLoader.getContent("res/game.swf");
			addChild(game);
			game.startGame();
			
			//setInterval();
		}
		
		
	}
	
}