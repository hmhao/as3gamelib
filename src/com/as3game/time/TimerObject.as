package com.as3game.time
{
	
	/**
	 * 游戏中计时器对象TimerObject，所有的TimerObject由GameTimer统一管理
	 * @author Tylerzhu
	 */
	public class TimerObject
	{
		
		public function TimerObject(name:String, interval:Number, repeatCount:int, callback:Function)
		{
			m_name = name;
			m_interval = interval;
			m_repeatCount = repeatCount;
			m_callback = callback;
		}
		
		public function handler():void
		{
			if (m_callBack != null)
			{
				m_callBack(m_currCount);
			}
		}
		
		private var m_name:String; //唯一标识一个计时器对象
		private var m_interval:Number;
		private var m_repeatCount:int; //重复执行次数
		private var m_currCount:int; //当前执行次数
		private var m_callback:Function;
	}

}