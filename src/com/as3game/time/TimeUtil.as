package com.as3game.time
{
	
	/**
	 * time utils
	 * @author tyler
	 */
	public class TimeUtil
	{
		
		public static function HHMMSS(ut:Number):String
		{
			var timeStr:String = "";
			var date:Date = new Date(ut * 1000);
			timeStr = date.getHours() + "时" + date.getMinutes() + "分" + date.getSeconds() + "秒";
			return timeStr;
		}
		
		public static function DELTA_HHMMSS(delta:Number, split:String = ":"):String
		{
			var h:uint = delta / (60 * 60);
			var m:uint = (delta - h * 60 * 60) / 60;
			var s:uint = delta - h * 60 * 60 - m * 60;
			var timeStr:String = ((h < 10) ? ("0" + h) : h) + //
				split + ((m < 10) ? ("0" + m) : m) + //
				split + ((s < 10) ? ("0" + s) : s);
			return timeStr;
		}
	
	}

}