package com.as3game.network.protocol
{
	import com.as3game.network.interfaces.INetClient;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author tyler
	 */
	public class HttpProtocolClient extends EventDispatcher implements INetClient
	{
		
		public function HttpProtocolClient(host:String, port:uint)
		{
		
		}
		
		/* INTERFACE INetClient */
		public function send(msg:*, onRsp:Function = null, onErr:Function = null, timeout:uint = 10):void
		{
		
		}
		
		public function setTimeout(timeout:uint):void
		{
		
		}
		
		public function close():void
		{
		
		}
	
	}

}