package com.as3game.time
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Tylerzhu
	 */
	public class GameTimer
	{
		
		static function getInstance():GameTimer
		{
			if (m_instance == null)
			{
				m_instance = new GameTimer(new PrivateClass());
			}
			return m_instance;
		}
		
		function register(name:String, interval:Number, repeatCount:int, callback:Function):void
		{
			if (m_timerDic[name] == null)
			{
				m_timerDic[name] = new TimerObject(name, interval, repeatCount, callback);
				//如果字典中只有一个TimerObject对象
				if (timerNum == 1) 
				{
					
				}
			}
			else
			{
				trace("定时器：" + name + " 已经存在，无需重复注册");
			}
		}
		
		function unregister(name:String):void
		{
		
		}
		
		public function GameTimer()
		{
			if (m_instance != null)
			{
				throw new Error("GameTimer is a Singleton class. Use getInstance() to retrieve the existing instance.");
			}
			
			m_timerDic = new Dictionary(true);
		}
		
		private function get timerNum():uint
		{
			var num:uint = 0;
			for each (var timer:TimerObject in m_timerDic)
			{
				num++;
			}
			return num;
		}
		
		static private var m_instance:GameTimer;
		private var m_timerDic:Dictionary;
	}

}

class PrivateClass
{
	public function PrivateClass()
	{
		//trace("包外类，用于实现单例");
	}
}