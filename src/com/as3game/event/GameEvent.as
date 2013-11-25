package com.as3game.event
{
	import flash.events.Event;
	
	/**
	 * GameEvent
	 * @author tyler
	 */
	public class GameEvent extends Event
	{
		public var info:Object; //事件数据
		
		public function GameEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.info = data;
		}
		
		public override function clone():Event
		{
			return new GameEvent(type, info, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("GameEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	
	}

}