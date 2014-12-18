package 
{
	import flash.utils.ByteArray;

	public class HexUtil 
	{
		
		public static function  encodeVector(data:ByteArray):String
		{
			
			
			//StringBuilder sb = new StringBuilder(data.length * 8);
			var sb:String = "";
			
			while ( data.bytesAvailable ) 
			{
				sb += data.readByte().toString(16);
				
			}
			trace(sb);
			return sb;
			/*
			sb += (encode((data[i] >>> 4) & 0xf));
			sb += (encode((data[i] >>> 0) & 0xf));
			sb += (encode((data[i] >>> 12) & 0xf));
			sb += (encode((data[i] >>> 8) & 0xf));
			sb +=  (encode((data[i] >>> 20) & 0xf));
			sb += (encode((data[i] >>> 16) & 0xf));
			sb += (encode((data[i] >>> 28) & 0xf));
			sb += (encode((data[i] >>> 24) & 0xf));
		
		return sb.toString();
			*/
		}
	

	private static function encode(data:int):String
	{
		var hex:Array = [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a',
				'b', 'c', 'd', 'e', 'f' ];
		return hex[data];
	}

	public static function  decodeVector(data:ByteArray, hex:String):ByteArray
	{
		var len:int = hex.length;
		for (var i:int = 0; i < len / 8; i++) 
		{
			data.writeByte( decode(hex.charAt(i * 8 + 0)) << 4
					^ decode(hex.charAt(i * 8 + 1)) << 0
					^ decode(hex.charAt(i * 8 + 2)) << 12
					^ decode(hex.charAt(i * 8 + 3)) << 8
					^ decode(hex.charAt(i * 8 + 4)) << 20
					^ decode(hex.charAt(i * 8 + 5)) << 16
					^ decode(hex.charAt(i * 8 + 6)) << 28
					^ decode(hex.charAt(i * 8 + 7)) << 24);
		}
		return data;
	}

	public static function decode(hex:String):int
	{
		switch (hex) {
		case '0':
			return 0;
		case '1':
			return 1;
		case '2':
			return 2;
		case '3':
			return 3;
		case '4':
			return 4;
		case '5':
			return 5;
		case '6':
			return 6;
		case '7':
			return 7;
		case '8':
			return 8;
		case '9':
			return 9;
		case 'a':
			return 10;
		case 'b':
			return 11;
		case 'c':
			return 12;
		case 'd':
			return 13;
		case 'e':
			return 14;
		case 'f':
				return 15;
			}
			return 0;
		}
	}
}
