package com.as3game.network.protocol
{
	import com.as3game.network.event.SocketEvent;
	import com.as3game.network.interfaces.INetClient;
	import com.as3game.network.NetClientError;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author tyler
	 */
	public class SocketProtocolClient extends EventDispatcher implements INetClient
	{
		private var _sock:Socket;
		private var _host:String;
		private var _port:uint;
		private var _timeout:uint;
		private var _onresp:Function; // 收到完整响应包以后的回调函数
		private var _onerror:Function; // 出错以后的回调函数
		private var _receiveBuf:ByteArray;
		private var _msgBuf:ByteArray = new ByteArray();
		private var _msgLen:uint;
		
		public function SocketProtocolClient(host:String, port:uint)
		{
			_host = host;
			_port = port;
			_receiveBuf = new ByteArray();
			_sock = new Socket(host, port);
			_sock.addEventListener(ProgressEvent.SOCKET_DATA, onEventData);
			_sock.addEventListener(IOErrorEvent.IO_ERROR, onEventError);
			_sock.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onEventError);
			_sock.addEventListener(Event.CLOSE, onEventClose);
		}
		
		/* INTERFACE INetClient */
		public function send(buf:*, onRsp:Function = null, onErr:Function = null, timeout:uint = 10):void
		{
			if (onErr != _onerror)
			{
				_onerror = onErr;
			}
			
			if (onRsp != _onresp)
			{
				_onresp = onRsp;
			}
			
			if (!_sock.connected)
			{
				var onconnect:Function = null;
				var timer:Timer = new Timer(timeout, 1); // 超时检测定时器，只需生效一次。只能用来检测连接超时。
				var ontimer:Function = function():void
				{
					timer.stop();
					_sock.removeEventListener(TimerEvent.TIMER, ontimer);
					_sock.removeEventListener(Event.CONNECT, onconnect);
					
					if (null != _onerror)
					{
						_onerror(NetClientError.ERR_TIMEOUT, "服务器无响应，连接超时!");
					}
				};
				
				onconnect = function(event:Event):void
				{
					timer.stop();
					_sock.removeEventListener(TimerEvent.TIMER, ontimer);
					_sock.removeEventListener(Event.CONNECT, onconnect);
					
					try
					{
						_sock.writeBytes(buf);
						_sock.flush();
					}
					catch (error:Error)
					{
						if (null != _onerror)
						{
							_onerror(NetClientError.ERR_IOERROR, "Flash与服务器通信时出现错误！" + error.message);
						}
						close();
						return;
					}
				};
				
				_sock.addEventListener(Event.CONNECT, onconnect);
				timer.addEventListener(TimerEvent.TIMER, ontimer);
				
				try
				{
					_sock.connect(_host, _port);
				}
				catch (error:SecurityError)
				{
					if (null != _onerror)
					{
						_onerror(NetClientError.ERR_SECURITY, "安全错误：" + error.message);
					}
					timer.stop();
					_sock.removeEventListener(TimerEvent.TIMER, ontimer);
					_sock.removeEventListener(Event.CONNECT, onconnect);
					close();
					return;
				}
				catch (error:Error)
				{
					if (null != _onerror)
					{
						_onerror(NetClientError.ERR_CONNECT_FAIL, "连接服务器时出错！" + error.message);
					}
					timer.stop();
					_sock.removeEventListener(TimerEvent.TIMER, ontimer);
					_sock.removeEventListener(Event.CONNECT, onconnect);
					close();
					return;
				}
			}
			else
			{
				try
				{
					_sock.writeBytes(buf);
					_sock.flush();
				}
				catch (error:Error)
				{
					if (null != _onerror)
					{
						_onerror(NetClientError.ERR_IOERROR, "Flash与服务器通信时出现错误！" + error.message);
					}
					close();
					return;
				}
			}
		}
		
		public function setTimeout(timeout:uint):void
		{
			_timeout = timeout;
		}
		
		public function close():void
		{
			try
			{
				if (_sock.connected)
				{
					_sock.close();
				}
			}
			catch (error:Error)
			{
			}
		}
		
		private function onEventData(e:ProgressEvent):void
		{
			_sock.readBytes(_receiveBuf, _receiveBuf.length);
			_receiveBuf.position = 0;
			
			while (true)
			{ //循环读包（包长度+消息数据）
				if (_receiveBuf.bytesAvailable <= 4)
				{
					break;
				}
				_msgLen = _receiveBuf.readUnsignedInt();
				if (_receiveBuf.bytesAvailable >= _msgLen - 4 && _msgLen > 0)
				{
					_receiveBuf.position = _receiveBuf.position - 4;
					_msgBuf.length = 0;
					_receiveBuf.readBytes(_msgBuf, 0, _msgLen);
					if (null != _onresp)
					{
						_onresp(_msgBuf);
						_onresp = null;
					}
					else
					{ //服务器推消息
						dispatchEvent(new SocketEvent(SocketEvent.PUSH_DATA, _msgBuf));
					}
				}
				else
				{ //如果不够一个包，就把长度回退
					_receiveBuf.position -= 4;
					break;
				}
			}
			
			var len:int = _receiveBuf.bytesAvailable;
			if (len > 0)
			{
				var p:uint = _receiveBuf.position;
				var ba:ByteArray = new ByteArray();
				ba.position = 0;
				
				ba.writeBytes(_receiveBuf, p, len);
				_receiveBuf = ba;
			}
			_receiveBuf.length = len;
		}
		
		private function onEventError(event:ErrorEvent):void
		{
			if (null != _onerror)
			{
				if (event.type == IOErrorEvent.IO_ERROR)
				{
					_onerror(NetClientError.ERR_IOERROR, "Flash与服务器通信时出现错误! " + event.text);
				}
				else if (event.type == SecurityErrorEvent.SECURITY_ERROR)
				{
					_onerror(NetClientError.ERR_SECURITY, "安全错误：" + event.text);
				}
				else
				{
					_onerror(NetClientError.ERR_UNKNOWN, "错误：" + event.text);
				}
			}
		}
		
		private function onEventClose(event:Event):void
		{
			if (null != _onerror)
			{
				_onerror(NetClientError.ERR_CONNECT_CLOSE, "服务端已关闭连接。");
			}
			close();
		}
	
	}

}