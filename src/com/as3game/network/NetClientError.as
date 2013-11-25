package com.as3game.network
{
	
	/**
	 * ...
	 * @author tyler
	 */
	public class NetClientError
	{
		
		public static const ERR_UNKNOWN:uint = 0; //
		public static const ERR_TIMEOUT:uint = 1; //服务器无响应，连接超时!
		public static const ERR_IOERROR:uint = 2; //Flash与服务器通信时出现错误！
		public static const ERR_SECURITY:uint = 3; //安全错误
		public static const ERR_CONNECT_FAIL:uint = 4; //连接服务器时出错！
		public static const ERR_CONNECT_CLOSE:uint = 5; //服务端已关闭连接。
	
	}

}