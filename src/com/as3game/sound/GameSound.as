package com.as3game.sound
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	/**
	 * 游戏声音管理类：管理游戏中的背景音乐、按钮等点击声效
	 * 声音的播放，即将Sound.play()方法赋值给SoundChannel实例就可以开始播放歌曲了。
	 * 如果使用Sound和SoundChannel装载和播放另一个mp3时，这个声音也会开始播放，因为没有对实例做任何限制，因此两个实例都可以正常播放。
	 * 因此必须检测是否对SoundChannel实例赋值了，如果它是null，脚本继续执行并播放选择的文件；如果它不是null，先停止当前正在播放的文件
	 * 后再装载和播放另一个mp3文件。这样就可以保证某一时刻只播放一个文件了。
	 *
	 * 游戏中声音有2两种：
	 *         1. 背景音乐：循环播放一直存在
	 *         2. 按钮音效等：点击才触发，这种声音任何时候只播放一个，如果两个瞬间点击多个按钮，只播放最后一个声音
	 * @author Tylerzhu
	 */
	public class GameSound
	{
		public function getInstance():GameSound
		{
			if (!m_instance)
			{
				m_instance = new GameSound(new PrivateClass());
			}
			return m_instance;
		}
		
		/**
		 *
		 * @param	name	:	String 
		 * @param	startTime	:	Number 应开始回放的初始位置（以毫秒为单位）
		 * @param	loops	:	int 定义在声道停止回放之前，声音循环回 startTime 值的次数
		 * @param	transform	:	SoundTransform 分配给该声道的初始 SoundTransform 对象
		 * @param	applicationDomain
		 * @return
		 */
		public function playSound(name:String, offset:Number = 0, startTime:int = 0, //
			transform:SoundTransform = null, applicationDomain:ApplicationDomain = null):SoundChannel
		{
			if (!m_soundDic[name]) 
			{
				//声音不存在，创建声音对象SoundObject
				var sound:Sound;
				var soundCls:Class;
				try 
				{
					soundCls = (applicationDomain != null)?applicationDomain.getDefinition(name) as Class:getDefinitionByName(name) as Class;
				}
				catch (err:ReferenceError)
				{
					
				}
			}
		}
		
		public function stopSound(name:String = null):void
		{
		
		}
		
		public function GameSound(pvt:PrivateClass)
		{
			if (m_instance)
			{
				throw new Error("GameSound is a Singleton class. Use getInstance() to retrieve the existing instance.");
			}
			
			m_soundDic = new Dictionary(true);
		}
		
		private static var m_instance:GameSound; //实例对象
		
		private var m_soundDic:Dictionary;
	}

}

class PrivateClass
{
	public function PrivateClass()
	{
		trace("包外类，用于实现单例");
	}
}