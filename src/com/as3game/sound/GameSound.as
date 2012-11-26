package com.as3game.sound
{
	import com.as3game.asset.AssetManager;
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
		public static function getInstance():GameSound
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
		 * @param	offset	:	Number 应开始回放的初始位置（以毫秒为单位）
		 * @param	loops	:	int 定义在声道停止回放之前，声音循环回 startTime 值的次数
		 * @param	transform	:	SoundTransform 分配给该声道的初始 SoundTransform 对象
		 * @param	applicationDomain
		 * @return
		 */
		public function playSound(name:String, offset:Number = 0, loops:int = 0, //
			transform:SoundTransform = null, applicationDomain:ApplicationDomain = null):SoundChannel
		{
			if (!m_soundDic[name])
			{
				//声音不存在，创建声音对象SoundObject
				var sound:Sound;
				var soundCls:Class;
				try
				{
					soundCls = (applicationDomain != null) ? applicationDomain.getDefinition(name) as Class : getDefinitionByName(name) as Class;
				}
				catch (err:ReferenceError)
				{
					trace("找不到" + name + "指定的声音对象，尝试加载外部文件。");
				}
				
				if (soundCls)
				{
					sound = new soundCls() as Sound;
					m_soundDic[name] = sound;
					
					var channel:SoundChannel = m_soundDic[name].play(offset, loops, transform);
					if (channel == null)
					{
						return null;
					}
					return channel;
				}
				else
				{
					AssetManager.getInstance().getAsset(name, function():SoundChannel
						{
							sound = AssetManager.getInstance().bulkLoader.getSound(name);
							m_soundDic[name] = sound;
							
							var channel:SoundChannel = m_soundDic[name].play(offset, loops, transform);
							if (channel == null)
							{
								return null;
							}
							return channel;
						});
					return null;
				}
			}
			else
			{
				return null;
			}
		}
		
		/**
		 *
		 * @param	name
		 */
		public function stopSound(name:String = null):void
		{
			if (name)
			{
				if (m_soundDic[name])
				{
					m_soundDic[name].stop();
				}
				else
				{
					trace("sound " + name + "不存在");
				}
			}
			else
			{
				for each (var item:SoundObject in m_soundDic)
				{
					item.stop();
				}
			}
		}
		
		/**
		 *
		 * @param	value
		 * @param	name
		 */
		public function setVolume(value:Number, name:String = null):void
		{
			if (name)
			{
				if (m_soundDic[name])
				{
					m_soundDic[name].volume = Math.max(0, Math.min(1, value));
				}
				else
				{
					trace("sound " + name + "不存在");
				}
			}
			else
			{
				for each (var item:SoundObject in m_soundDic)
				{
					item.volume = Math.max(0, Math.min(1, value));
				}
			}
		}
		
		public function getVolume(name:String):Number
		{
			if (m_soundDic[name])
			{
				return m_soundDic[name].volume;
			}
			else
			{
				throw new Error("Sound " + name + " 不存在");
			}
			return 0;
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