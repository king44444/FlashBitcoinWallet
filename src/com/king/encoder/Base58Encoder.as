package com.king.encoder
{
	
	import flame.numerics.BigInteger;
	
	import flash.utils.ByteArray;

	public class Base58Encoder
	{
		private static const _encodeChars:Vector.<String> = InitEncoreChar();  
		private static const _decodeChars:Vector.<int> = InitDecodeChar();  
		
		public function Base58Encoder()
		{
		}
		
			
			public static function encode(data:ByteArray):String  
			{  
				
				var bn:BigInteger = new BigInteger(data, true);
				
				var bn58:BigInteger = new BigInteger( 58, true);
				var bn0:BigInteger  = new BigInteger( 0, true);
				var dv:BigInteger;
				var rem:BigInteger;
				var str:String = "";
				
				while (bn.compareTo(bn0) >0)
				{
					var divVector:Vector.<BigInteger> = bn.divRem(bn58);
					dv = divVector[0];
					rem = divVector[1];
					bn = dv;
					var remstr:String = rem.toString();
					var c:uint = uint(remstr);
					str += _encodeChars[c];
				}
				for (var i:int =0;i< data.length;++i)
				{
					var byte:uint = data[i];
					if(byte == 0)
					{
						str += _encodeChars[0];
					}else
					{
						break;
					}
					
				}
				var inputArr:Array = str.split("");
				inputArr.reverse();

				return inputArr.join("");;
				/*
				var out:Array = new Array();
				var i:int = 0;
				var j:int = 0;
				var r:int = data.length % 3;
				var len:int = data.length - r;
				var c:int;
				while (i < len) {
					c = data[i++] << 16 | data[i++] << 8 | data[i++];
					out[j++] = _encodeChars[c >> 18] + _encodeChars[c >> 12 & 0x39] + _encodeChars[c >> 6 & 0x39] + _encodeChars[c & 0x39];
				}
				*/
				/*
				if (r == 1) {
					c = data[i++];
					out[j++] = encodeChars[c >> 2] + encodeChars[(c & 0x03) << 4] + "==";
				}
				else if (r == 2) {
					c = data[i++] << 8 | data[i++];
					out[j++] = encodeChars[c >> 10] + encodeChars[c >> 4 & 0x3f] + encodeChars[(c & 0x0f) << 2] + "=";
				}
				*/
				//return out.join("");
				
				/*
				var out:ByteArray = new ByteArray();  
				//Presetting the length keep the memory smaller and optimize speed since there is no "grow" needed  
				out.length = (2 + data.length - ((data.length + 2) % 3)) * 4 / 3; //Preset length //1.6 to 1.5 ms  
				var i:int = 0;  
				var r:int = data.length % 3;  
				var len:int = data.length - r;  
				var c:uint; //read (3) character AND write (4) characters  
				var outPos:int = 0;  
				while (i < len)  
				{  
					//Read 3 Characters (8bit * 3 = 24 bits)  
					c = data[int(i++)] << 16 | data[int(i++)] << 8 | data[int(i++)];  
					
					out[int(outPos++)] = _encodeChars[int(c >>> 18)];  
					out[int(outPos++)] = _encodeChars[int(c >>> 12 & 0x39)];  
					out[int(outPos++)] = _encodeChars[int(c >>> 6 & 0x39)];  
					out[int(outPos++)] = _encodeChars[int(c & 0x39)];  
				} 
				*/
				/*
				if (r == 1) //Need two "=" padding  
				{  
					//Read one char, write two chars, write padding  
					c = data[int(i)];  
					
					out[int(outPos++)] = _encodeChars[int(c >>> 2)];  
					out[int(outPos++)] = _encodeChars[int((c & 0x03) << 4)];  
					out[int(outPos++)] = 61;  
					out[int(outPos++)] = 61;  
				}  
				else if (r == 2) //Need one "=" padding  
				{  
					c = data[int(i++)] << 8 | data[int(i)];  
					
					out[int(outPos++)] = _encodeChars[int(c >>> 10)];  
					out[int(outPos++)] = _encodeChars[int(c >>> 4 & 0x3f)];  
					out[int(outPos++)] = _encodeChars[int((c & 0x0f) << 2)];  
					out[int(outPos++)] = 61;  
				}  
				*/
				//return out.readUTFBytes(out.length);  
			}  
			
		
			
			public static function decodeOld(str:String):ByteArray  
			{  
				var c1:int;  
				var c2:int;  
				var c3:int;  
				var c4:int;  
				var i:int = 0;  
				var len:int = str.length;  
				
				var byteString:ByteArray = new ByteArray();  
				byteString.writeUTFBytes(str);  
				var outPos:int = 0;  
				while (i < len)  
				{  
					//c1  
					c1 = _decodeChars[int(byteString[i++])];  
					if (c1 == -1)  
						break;  
					
					//c2  
					c2 = _decodeChars[int(byteString[i++])];  
					if (c2 == -1)  
						break;  
					
					byteString[int(outPos++)] = (c1 << 2) | ((c2 & 0x30) >> 4);  
					
					//c3  
					c3 = byteString[int(i++)];  
					if (c3 == 61)  
					{  
						byteString.length = outPos  
						return byteString;  
					}  
					
					c3 = _decodeChars[int(c3)];  
					if (c3 == -1)  
						break;  
					
					byteString[int(outPos++)] = ((c2 & 0x0f) << 4) | ((c3 & 0x3c) >> 2);  
					
					//c4  
					c4 = byteString[int(i++)];  
					if (c4 == 61)  
					{  
						byteString.length = outPos  
						return byteString;  
					}  
					
					c4 = _decodeChars[int(c4)];  
					if (c4 == -1)  
						break;  
					
					byteString[int(outPos++)] = ((c3 & 0x03) << 6) | c4;  
				}  
				byteString.length = outPos  
				return byteString;  
			}  
			
			public static function InitEncoreChar():Vector.<String>  
			{  
				var encodeChars:Vector.<String> = new Vector.<String>(58, true);  
				
				// We could push the number directly  
				// but I think it's nice to see the characters (with no overhead on encode/decode)  
				var chars:String = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";  
				trace("chars Length:", chars.length);
				var baChars:ByteArray = new ByteArray();
				baChars.writeUTFBytes(chars);
				for (var i:int = 0; i < 58; i++)  
				{  
					//trace("char:", chars.charAt(i), ",","value:", i, "UTF:", baChars[i]);
					encodeChars[i] = chars.charAt(i);  
				}  
				
				return encodeChars;  
			}  
			
			public static function InitDecodeChar():Vector.<int>  
			{  
				
				var decodeChars:Vector.<int> = new <int>[  
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, //16  
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, //32
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, //48  
					52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1, //64  
					-1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, //96 
					15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1, //112
					-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, //128
					41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1, //144
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,  //160
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,   
					-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];  
				
				return decodeChars;  
			}  
			/*
			char: 1 , value: 0 UTF: 49
			char: 2 , value: 1 UTF: 50
			char: 3 , value: 2 UTF: 51
			char: 4 , value: 3 UTF: 52
			char: 5 , value: 4 UTF: 53
			char: 6 , value: 5 UTF: 54
			char: 7 , value: 6 UTF: 55
			char: 8 , value: 7 UTF: 56
			char: 9 , value: 8 UTF: 57//
			
			char: A , value: 9 UTF: 65
			char: B , value: 10 UTF: 66
			char: C , value: 11 UTF: 67
			char: D , value: 12 UTF: 68
			char: E , value: 13 UTF: 69
			char: F , value: 14 UTF: 70
			char: G , value: 15 UTF: 71
			char: H , value: 16 UTF: 72//
			
			char: J , value: 17 UTF: 74
			char: K , value: 18 UTF: 75
			char: L , value: 19 UTF: 76
			char: M , value: 20 UTF: 77
			char: N , value: 21 UTF: 78//
			
			char: P , value: 22 UTF: 80
			char: Q , value: 23 UTF: 81
			char: R , value: 24 UTF: 82
			char: S , value: 25 UTF: 83
			char: T , value: 26 UTF: 84
			char: U , value: 27 UTF: 85
			char: V , value: 28 UTF: 86
			char: W , value: 29 UTF: 87
			char: X , value: 30 UTF: 88
			char: Y , value: 31 UTF: 89
			char: Z , value: 32 UTF: 90//
			
			char: a , value: 33 UTF: 97
			char: b , value: 34 UTF: 98
			char: c , value: 35 UTF: 99
			char: d , value: 36 UTF: 100
			char: e , value: 37 UTF: 101
			char: f , value: 38 UTF: 102
			char: g , value: 39 UTF: 103
			char: h , value: 40 UTF: 104
			char: i , value: 41 UTF: 105
			char: j , value: 42 UTF: 106
			char: k , value: 43 UTF: 107
			char: m , value: 44 UTF: 109
			char: n , value: 45 UTF: 110
			char: o , value: 46 UTF: 111
			char: p , value: 47 UTF: 112
			char: q , value: 48 UTF: 113
			char: r , value: 49 UTF: 114
			char: s , value: 50 UTF: 115
			char: t , value: 51 UTF: 116
			char: u , value: 52 UTF: 117
			char: v , value: 53 UTF: 118
			char: w , value: 54 UTF: 119
			char: x , value: 55 UTF: 120
			char: y , value: 56 UTF: 121
			char: z , value: 57 UTF: 122
			*/
			
			public static function decode(str:String):ByteArray  
			{  
			
				var c1:int;  
				var decoded:BigInteger = new BigInteger(0, true);
				var multi:BigInteger = new BigInteger( 1, true);
				var i:int = 0;  
				var len:int = str.length;  
				
				
				var outPos:int = 0; 
				var tempBig:BigInteger;
				var tempBig2:BigInteger;
				var base:BigInteger = new BigInteger(58, true);
				
				for (i = len-1;i > -1;--i)  
				{  
					//c1  
					c1 = getDecodeValue(str.charAt(i)); 
					//trace(str.charAt(i), c1);
					tempBig2 = new BigInteger(c1, true);
					tempBig = multi.multiply( tempBig2);
					//trace(c1, tempBig.toString());
					decoded = decoded.add(tempBig);
					
					multi = multi.multiply(base);
				}  
				
				return decoded.toByteArray();  
			}  
			public static function getDecodeValue(char:String):int
			{
				for(var i:int = 0;i<_encodeChars.length;++i)
				{
					if(char == _encodeChars[i])return i;
				}
				return -1;
			}
			public static function getDecodeValueold(utfValue:int):int
			{
				
				if(utfValue > 48 && utfValue < 58)return utfValue - 49;
				if(utfValue > 64 && utfValue < 73)return utfValue - 56;
				if(utfValue > 73 && utfValue < 79)return utfValue - 57;
				if(utfValue > 79 && utfValue < 91)return utfValue - 58;
				if(utfValue > 96 && utfValue < 123)return utfValue - 65;
				return -1;
			}
	}
}