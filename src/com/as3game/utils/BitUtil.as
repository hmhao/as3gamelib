package com.as3game.utils
{
	import flash.geom.Vector3D;
	
	/**
	 * 位操作公用类
	 * @author Tylerzhu
	 */
	public class BitUtil
	{
		/**
		 * 获取数值value二进制表示第bit位的值
		 * 如：10对应二进制1010，第1位是0、第二位是1...
		 * @param	bit - bit>=1
		 * @param	value
		 * @return
		 */
		public static function getBitValue(bit:uint, value:uint):uint
		{
			if (bit <= 0)
			{
				throw new Error("bit 必须大于0");
			}
			value >>= bit;
			return value & 1;
		}
		
		/**
		 * 将对应的二进制位置为1或0
		 * @param	bit 第几位
		 * @param	flag 1或0
		 * @param	value
		 * @return
		 */
		public static function setBitValue(bit:uint, flag:uint, val:int):uint 
		{
			if (flag) 
			{
				val |= (1 << bit);
			}
			else 
			{
				val &= (1 << bit);
			}
			return val;
		}
		
		/**
		 * 获取数值value二进制表示每位上的值
		 * 如：10对应二进制1010，返回[0, 1, 0, 1]
		 * @param	value
		 * @return
		 */
		public static function getBits(value:uint):Array
		{
			var bits:Array = new Array();
			while (value > 0)
			{
				bits.push(value & 1);
				value >>= 1;
			}
			return bits;
		}
		
		public function BitUtil()
		{
		
		}
	}

}