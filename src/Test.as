package
{
	import com.as3game.asset.AssetManager;
	import com.as3game.sound.GameSound;
	import com.as3game.time.GameTimer;
	import com.as3game.utils.BitUtil;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
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
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			//stage.addEventListener(MouseEvent.CLICK, backGroundMusic);
			
			//GameSound.getInstance().playSound("res/music/background1.mp3");
			AssetManager.getInstance().getAsset("res/MainView.swf", function ():void 
			{
			var mc:MovieClip = AssetManager.getInstance().getMovieClipByName("MainView.ToolsBar");
			mc && addChild(mc);
			});
			
			//GameTimer.getInstance().register("test1", 100, 5, testTimer1);
			//GameTimer.getInstance().register("test2", 200, 0, testTimer2);
			
			//trace(AssetManager.getInstance().registerNewType(".dat", AssetManager.TYPE_ZIP, AssetManager.CLASS_BINARY));
			//AssetManager.getInstance().getAsset('config.dat', testDat);
			
			var arr:Array = BitUtil.getBits(18);
			for each (var item:uint in arr)
			{
				trace(item);
			}
			
			trace(BitUtil.getBitValue(5, 18));
			trace(BitUtil.getBitValue(8, 18));
			trace(BitUtil.getBitValue(1, 18));
			trace(BitUtil.getBitValue(2, 18));
		}
		
		private function testDat(content:*):void
		{
			var i:int = 1;
		}
		
		private function testTimer1(currentCount:int):void
		{
			trace("[定时器]test1。。。。。。。。" + currentCount);
		}
		
		private function testTimer2(currentCount:int):void
		{
			trace("[定时器]test2。。。。。。。。" + currentCount);
			if (currentCount == 100)
			{
				GameTimer.getInstance().unregister("test2");
			}
			else if (currentCount == 2)
			{
				GameTimer.getInstance().interval = 50;
			}
		}
		
		private function backGroundMusic(e:MouseEvent):void
		{
			var flag:Boolean = GameSound.getInstance().isPlaying("res/music/background1.mp3");
			trace("background music flag ", flag);
			if (flag)
			{
				GameSound.getInstance().pauseSound("res/music/background1.mp3");
			}
			else
			{
				GameSound.getInstance().pauseSound("res/music/background1.mp3");
			}
		}
		
		private function test1(content:*):void
		{
			//var i:int = 1;
			//trace("test1");
			//var test:Sound = AssetManager.getInstance().bulkLoader.getSound("res/music/background1.mp3");
			//test.play();
		}
		
		private function test2():void
		{
			trace("test2")
			var game:* = AssetManager.getInstance().bulkLoader.getContent("res/game.swf");
			addChild(game);
			game.startGame();
		
			//setInterval();
		}
	
	}

}