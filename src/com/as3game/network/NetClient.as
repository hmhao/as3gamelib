package com.as3game.network
{
	import com.as3game.network.event.SocketEvent;
	import com.as3game.network.interfaces.INetClient;
	import com.as3game.network.protocol.HttpProtocolClient;
	import com.as3game.network.protocol.SocketProtocolClient;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author tyler
	 */
	public class NetClient extends EventDispatcher
	{
		public static const HTTP_MODE:uint = 0;
		public static const SOCKET_MODE:uint = 1;
		
		private var _connection:INetClient;
		private var _mode:uint;
		
		public function NetClient(host:String, port:uint, mode:uint = NetClient.HTTP_MODE)
		{
			_mode = mode;
			switch (mode)
			{
				case NetClient.HTTP_MODE: 
					_connection = new HttpProtocolClient(host, port);
					break;
				case NetClient.SOCKET_MODE: 
					_connection = new SocketProtocolClient(host, port);
					_connection.addEventListener(SocketEvent.PUSH_DATA, onPushData);
					break;
				default: 
			}
		}
		
		private function onPushData(e:SocketEvent):void 
		{
			dispatchEvent(e.clone());
		}
		
		public function send(msg:*, onRsp:Function = null, onErr:Function = null, timeout:uint = 10):void 
		{
			_connection.send(msg, onRsp, onErr, timeout);
		}
	
	}

}