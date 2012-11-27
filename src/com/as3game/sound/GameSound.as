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
			var channel:SoundChannel = null;
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
					m_soundDic[name] = new SoundObject(name, sound);
					channel = m_soundDic[name].play(offset, loops, transform);
				}
				else
				{
					AssetManager.getInstance().getAsset(name, function():void
						{
							sound = AssetManager.getInstance().bulkLoader.getSound(name);
							m_soundDic[name] = new SoundObject(name, sound);
							channel = m_soundDic[name].play(offset, loops, transform);
						});
				}
			}
			else
			{
				channel = m_soundDic[name].play(offset, loops, transform);
			}
			
			return channel;
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
		
		public function getChannel(name:String):SoundChannel
		{
			if (m_soundDic[name])
			{
				return m_soundDic[name].channel;
			}
			else
			{
				throw new Error("Sound " + name + " does not exist.");
			}
			return null;
		}
		
		/**
		 * Mutes/unmutes the given sound, or all sounds in the Engine.
		 * @param	name	String	The name of the sound to mute/unmute. Leave out to act on all sounds in the Engine.
		 */
		public function mute(name:String = null):void
		{
			if (name)
			{
				if (m_soundDic[name])
				{
					m_soundDic[name].mute();
					if (!m_soundDic[name].isMuted)
						m_allMuted = false;
				}
				else
				{
					throw new Error("Sound " + name + " does not exist.");
				}
			}
			else
			{
				m_allMuted = !m_allMuted;
				if (m_allMuted)
				{
					for each (var i:SoundObject in m_soundDic)
					{
						i.turnMuteOn();
					}
				}
				else
				{
					for each (var j:SoundObject in m_soundDic)
					{
						j.turnMuteOff();
					}
				}
			}
		}
		
		public function turnAllSoundsOn():void
		{
			if (m_allMuted)
			{
				mute();
			}
		}
		
		public function turnAllSoundsOff():void
		{
			if (!m_allMuted)
			{
				mute();
			}
		}
		
		/**
		 * Pauses/resumes the given sound, or all sounds in the Engine.
		 * @param	name	String	The name of the sound to pause or resume. Leave out to act on all sounds in the Engine.
		 */
		public function pauseSound(name:String = null):void
		{
			if (name)
			{
				if (m_soundDic[name])
				{
					m_soundDic[name].pause();
				}
				else
				{
					throw new Error("Sound " + name + " does not exist.");
				}
			}
			else
			{
				for each (var i:String in m_soundDic)
					m_soundDic[i].pause();
			}
		}
		
		/**
		 * Returns whether or not a given sound is currently playing.
		 * @param	name	String		The name of the sound to check.
		 * @return			Boolean		True if playing, false otherwise. If a sound is only paused, it will still return as playing.
		 */
		public function isPlaying(name:String):Boolean
		{
			if (m_soundDic[name])
			{
				return m_soundDic[name].playing;
			}
			else
			{
				trace("Sound " + name + " does not exist.");
			}
			return false;
		}
		
		/**
		 * Returns whether or not a given sound is currently paused.
		 * @param	name	String		The name of the sound to check.
		 * @return			Boolean		True if sound is paused, false otherwise.
		 */
		public function isPaused(name:String):Boolean
		{
			if (m_soundDic[name])
			{
				return m_soundDic[name].isPaused;
			}
			else
			{
				throw new Error("Sound " + name + " does not exist.");
			}
			return false;
		}
		
		/**
		 * Returns whether or not a given sound is muted.
		 * @param	name	String		The name of the sound to check.
		 * @return			Boolean		True if muted, false otherwise.
		 */
		public function isMuted(name:String = null):Boolean
		{
			if (name)
			{
				if (m_soundDic[name])
				{
					return m_soundDic[name].isMuted;
				}
				else
				{
					throw new Error("Sound " + name + " does not exist.");
				}
				return false;
			}
			else
			{
				return m_allMuted;
			}
			return true;
		}
		
		/**
		 * Disposes of all objects and cleans up memory
		 *
		 * @param null
		 * @return void
		 */
		public function dispose():void
		{
			// Stops All Sounds
			m_instance.stopSound();
			
			// Null Out All Sound Objects
			for (var i:String in m_soundDic)
			{
				m_soundDic[i] = null;
			}
			
			// Nulls Out _soundList
			m_soundDic = null;
			
			// Nulls Out _instance
			m_instance = null;
		
		}
		
		public function GameSound(pvt:PrivateClass)
		{
			if (m_instance)
			{
				throw new Error("GameSound is a Singleton class. Use getInstance() to retrieve the existing instance.");
			}
			
			m_soundDic = new Dictionary(true);
			m_allMuted = false;
		}
		
		private static var m_instance:GameSound; //实例对象
		
		private var m_soundDic:Dictionary;
		private var m_allMuted:Boolean;
	}

}

class PrivateClass
{
	public function PrivateClass()
	{
		trace("包外类，用于实现单例");
	}
}