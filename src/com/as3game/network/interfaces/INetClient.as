package com.as3game.network.interfaces
{
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author tyler
	 */
	public interface INetClient extends IEventDispatcher
	{
		function send(msg:*, onRsp:Function = null, onErr:Function = null, timeout:uint = 10):void;
		function setTimeout(timeout:uint):void;
		function close():void;
	}

}