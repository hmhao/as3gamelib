package com.as3game.utils
{
	import flash.utils.ByteArray;

	public class StringUtil 
	{
		/**
		 * 解码被安全API编码的JavaScript字符串
		 * @param	str		字符串
		 * @return	返回一个解码后的字符串
		 */
		public static function DecodeJSString(str:String):String
		{
			if (str == null) return null;
            str = str.replace(/\\x/gi, "%");
			
			var result:String
			try 
			{
				result = decodeURIComponent(str);
			}
			catch (err:Error)
			{
				trace("解析昵称出错：" + str)
				result = str;
			}
            return result;
		}
		
		/**
		 * 解码昵称
		 * @param	strNick	昵称
		 * @return	解码后的昵称
		 */
		public static function DecodeNick(strNick:String):String
		{
			if (strNick == null) return null;
			strNick = DecodeJSString(strNick);
			strNick = strNick.replace(/&lt;/gi, "<");
			strNick = strNick.replace(/&gt;/gi, ">");
			strNick = strNick.replace(/&quot;/gi, "\"");
			strNick = strNick.replace(/&#36;/gi, "$");
			strNick = strNick.replace(/&#37;/gi, "%");
			strNick = strNick.replace(/&amp;/gi, "&");
			strNick = strNick.replace("<\\", "");
			strNick = strNick.replace("/>", "");
			return strNick;
		}
		
		/**
		 * 
		 * @param	str
		 * @return
		 */
		public static function EscapeString(str:String):String
        {
			if (str == null) return null;
            var strRet:String = new String(str);
            //strRet = strRet.replace(/\\/g, "\\\\");
            //strRet = strRet.replace(/"/g, "\\\"");待开启
            //strRet = strRet.replace(/'/g, "\\\'");待开启
            strRet = strRet.replace(/\n/g, "\\n");
            strRet = strRet.replace(/\r/g, "\\r");
            return strRet;
        }
		
		/**
		 * 对URL进行编码
		 * @param	str URL
		 * @return	返回一个编码后的字符串
		 */
		public static function encodeURL(str:String):String
		{
			if (str == null)
				return null;
			var strRet:String = new String(str);
			strRet = strRet.replace(/%/g, "%25");
			strRet = strRet.replace(/+/g, "%2B");
            strRet = strRet.replace(/\?/g, "%3F");
			strRet = strRet.replace(/&/g, "%26");
			strRet = strRet.replace(/=/g, "%3D");
			strRet = strRet.replace(/#/g, "%23");
			strRet = strRet.replace(/\//g, "%2F");
			return strRet;
		}
		// strUrl 中要有 http://
		public static function getLinkText(strText : String, strUrl : String, underline : Boolean = false) : String
		{
			var str:String = "<a href='" + strUrl + "' target='_blank'><font color='#0066ff'>" + strText + "</font></a>";
			if (underline)
			{
				str = '<u>' + str + '</u>';
			}
			return str;
		}
		
		// strUrl 中不用带 event:
		public static function getEventText(strText : String, strUrl : String, underline : Boolean = false) : String
		{
			var str:String = "<a href='event:" + strUrl + "'><font color='#0066ff'>" + strText + "</font></a>";
			if (underline)
			{
				str = '<u>' + str + '</u>';
			}
			return str;
		}
		// html text
		public static function getColorText(text : String, color : uint) : String
		{
			return "<font color=\"#" + color.toString(16) + "\">" + text + "</font>";
		}
		
		public static function getBoldText(text : String) : String
		{
			return "<b>" + text + "</b>";
		}
		
		public static function getUnderlineText(text : String) : String
		{
			return "<u>" + text + "</u>";
		}
		
		// 除非你真的必须用http，否则请用 getEventLinkText
		public static function getHttpLinkText(text : String, url : String) : String
		{
			return "<a href=\"" + url + "\">" + text + "</a>";
		}
		
		public static function getEventLinkText(text : String, linkevent : String) : String
		{
			return "<a href=\"event:" + linkevent + "\">" + text + "</a>";
		}
		
		// 除非你真的必须用http，否则请用 getDetailEventLinkText
		public static function getDetailHttpLinkText(text : String, url : String, unColor : uint, bUnderlind : Boolean) : String
		{
			var str : String = getColorText(getHttpLinkText(text, url), unColor);
			if (bUnderlind)
			{
				str = getUnderlineText(str);
			}
			return str;
		}
		
		public static function getDetailEventLinkText(text : String, url : String, unColor : uint, bUnderlind : Boolean) : String
		{
			var str : String = getColorText(getEventLinkText(text, url), unColor);
			if (bUnderlind)
			{
				str = getUnderlineText(str);
			}
			return str;
		}
		
		/**
		 * 生成格式化字符串
		 * @param	text       字符串
		 * @param	...params  要填充参数
		 * @return				返回一个格式化的字符串
		 */
		public static function format(text : String, ...params) : String
        {
        	var subs : Array = [];
        	subs = text.split('%');
        	var formated : String = subs[0];
        	var replace : Object = null;
        	for (var i : int = 1; i < subs.length; ++i)
        	{
        		var sub : String =  subs[i];
        		if (sub.length >= 1)
        		{
	        		replace = params.shift();
	        		if (sub.charAt(0) == 's')
	        		{
	        			formated += sub.replace('s', replace);
	        	    }
	        	    else
	        	    {
	        	    	formated += '%' + sub;
	        	    }
        		}
        	}
        	return formated;
        }
        
        private static function replaceString(text : String, formatSymbol : String, replace : Object) : String
        {
        	if (replace == null)
        	{
        		return text;
        	}
        	switch (formatSymbol)
        	{
        		case 's':
        		case 'd':
        		return text.replace('%' + formatSymbol, replace);
        		default:
        		return text;
        	}
        }
		
		/**
		 * 传入秒数，返回00:00:00格式的时间
		 * @param	second
		 * @return
		 */
		static public function formatTime(second:uint):String
		{
			var reslut:String = "";
			var hour:int = second / 3600;
			if (hour != 0) 
			{
				reslut += (hour > 9?hour:"0" + hour) + ":";
			}
			var min:int = (second - hour * 3600) / 60;
			reslut += (min > 9?min:"0" + min) + ":";
			var sec:int = second % 60;
			reslut += (sec > 9?sec:"0" + sec);
			return reslut;
		}
		
		/**
		 * 传入数字，返回00,000,000格式
		 * @param	value
		 * @return
		 */
		static public function numberToString( value : uint):String
		{
			var str : String = value +'';
			var arr :Array = str.split('');
			var len : int = arr.length ;
			var count : int = Math.ceil(len/3) - 1;
			var i : int;
			while(i <count)
			{
				arr.splice(len - (i+1)*3 ,0 ,',');
				i++;	
			}
			str = arr.join('');
			return str ;
		}
	}
	
}