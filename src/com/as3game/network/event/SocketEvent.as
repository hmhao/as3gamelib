package com.as3game.network.event
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author tyler
	 */
	public class SocketEvent extends Event
	{
		public static const PUSH_DATA:String = "push_data";
		
		public var info:Object; //事件数据
		
		public function SocketEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.info = data;
		}
		
		public override function clone():Event
		{
			return new SocketEvent(type, info, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("SocketEvent", "type", "bubbles", "cancelable", "eventPhase", info);
		}
	}

}