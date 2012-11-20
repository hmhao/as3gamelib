package com.as3game.sound
{
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	/**
	 * SoundObject - 游戏中的声音对象，可以是嵌在swf中的一段声音，也可以是外部链接的一个声音文件。
	 * @author Tylerzhu
	 */
	public class SoundObject extends EventDispatcher
	{
		
		public function SoundObject(name:String, sound:Sound)
		{
			m_name = name;
			m_sound = sound;
			
			m_playing = false;
			m_paused = false;
		}
		
		public function play(offset:Number = 0, loops:int = 0, transform:SoundTransform = null):SoundChannel
		{
		
		}
		
		public function stop():void
		{
		
		}
		
		public function isPlaying():Boolean 
		{
			return m_playing;
		}
		
		private var m_name:String;
		private var m_sound:Sound;
		private var m_channel:SoundChannel;
		private var m_transform:SoundTransform;
		private var m_playing:Boolean;
		private var m_paused:Boolean;
		private var m_loops:uint;
		private var m_offset:Number;
	}

}