package controller
{
	import flame.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;

	public class MurHash
	{
		public function MurHash()
		{
		}
		
		public function hashInt( hashNum:int, object:ByteArray, nTweak:int, dataLength:int):int
		{
			// The following is MurmurHash3 (x86_32), see http://code.google.com/p/smhasher/source/browse/trunk/MurmurHash3.cpp
			var h1:int = (hashNum * 0xFBA4C795 + nTweak);
			const c1:int = 0xcc9e2d51;
			const c2:int = 0x1b873593;
			
			var k1:int;
			
			var numBlocks:int = (object.length / 4) * 4;
			// body
			for(var i:int = 0; i < numBlocks; i += 4) 
			{
				k1 = (object[i] & 0xFF) |
					((object[i+1] & 0xFF) << 8) |
					((object[i+2] & 0xFF) << 16) |
					((object[i+3] & 0xFF) << 24);
				
				k1 *= c1;
				k1 = rotateLeft32(k1, 15);
				k1 *= c2;
				
				h1 ^= k1;
				h1 = rotateLeft32(h1, 13);
				h1 = h1*5+0xe6546b64;
			}
			
			k1= 0;
			switch(object.length & 3)
			{
				case 3:
					k1 ^= (object[numBlocks + 2] & 0xff) << 16;
					// Fall through.
				case 2:
					k1 ^= (object[numBlocks + 1] & 0xff) << 8;
					// Fall through.
				case 1:
					k1 ^= (object[numBlocks] & 0xff);
					k1 *= c1; 
					k1 = rotateLeft32(k1, 15); 
					k1 *= c2; 
					h1 ^= k1;
					// Fall through.
				default:
					// Do nothing.
					break;
			}
			
			// finalization
			h1 ^= object.length;
			h1 ^= h1 >>> 16;
			h1 *= 0x85ebca6b;
			h1 ^= h1 >>> 13;
			h1 *= 0xc2b2ae35;
			h1 ^= h1 >>> 16;
			var reVal:int =  ((h1 &0xFFFFFFFF) % (dataLength * 8));
			return h1;
		}
		
		public function hash(object:ByteArray, nTweak:uint):uint
		{
			
			trace(ByteArrayUtil.toHexString(object));
			
			// The following is MurmurHash3 (x86_32), see http://code.google.com/p/smhasher/source/browse/trunk/MurmurHash3.cpp
			var h1:uint = nTweak;//(hashNum * 0xFBA4C795 + nTweak);
			trace("Seed:", h1.toString(16));
			const c1:uint = 0xcc9e2d51;
			const c2:uint = 0x1b873593;
			
			var k1:uint;
			
			var numBlocks:uint = (object.length / 4);
			
			trace("nblocks", numBlocks);
			
			// body
			for(var i:uint = 0; i < numBlocks; i += 4) 
			{
				k1 = (object[i] & 0xFF) |
					((object[i+1] & 0xFF) << 8) |
					((object[i+2] & 0xFF) << 16) |
					((object[i+3] & 0xFF) << 24);
				
				k1 *= c1;
				k1 = rotateLeft32(k1, 15);
				k1 *= c2;
				
				h1 ^= k1;
				h1 = rotateLeft32(h1, 13);
				h1 = h1*5+0xe6546b64;
			}
			
			k1= 0;
			switch(object.length & 3)
			{
				case 3:
					k1 ^= (object[numBlocks + 2] & 0xff) << 16;
					// Fall through.
				case 2:
					k1 ^= (object[numBlocks + 1] & 0xff) << 8;
					// Fall through.
				case 1:
					k1 ^= (object[numBlocks] & 0xff);
					k1 *= c1; 
					k1 = rotateLeft32(k1, 15); 
					k1 *= c2; 
					h1 ^= k1;
					// Fall through.
				default:
					// Do nothing.
					break;
			}
			
			// finalization
			h1 ^= object.length;
			h1 ^= h1 >>> 16;
			h1 *= 0x85ebca6b;
			h1 ^= h1 >>> 13;
			h1 *= 0xc2b2ae35;
			h1 ^= h1 >>> 16;
			//var reVal:uint =  ((h1 &0xFFFFFFFF) % (dataLength * 8));
			trace("h1:", h1.toString(16), h1);
			return h1;
		}
		private function rotateLeft32( x:uint,  r:uint):uint
		{
			return (x << r) | (x >>> (32 - r));
		}
		
		
		
		public function hash32(key:ByteArray, seed:uint):uint
		{
			var offset:uint = 0;
			var length:uint = key.length
			const nblocks:uint = length / 4;
			
			var h1:uint = seed;
			
			var c1:uint = 0xcc9e2d51;
			var c2:uint = 0x1b873593;
			
			// Body
			
			for (var i:uint = 0; i < nblocks; i++) 
			{
				var k1:uint = getblock32( key, offset, i);
				
				k1 *= c1;
				k1 = rotl32( k1, 15);
				k1 *= c2;
				
				h1 ^= k1;
				h1 = rotl32( h1, 13);
				h1 = h1 * 5 + 0xe6546b64;
			}
			
			// Tail
			
			var tail:uint = offset + nblocks * 4;
			
			var k1:uint = 0;
			
			switch (length & 3) 
			{
				case 3:
				k1 ^= ( key[tail + 2] as uint) << 16;
					
					case 2:
					k1 ^= ( key[ tail + 1]as uint) << 8;
					case 1:
					k1 ^= (key[ tail] as uint);
					k1 *= c1;
					k1 = rotl32( k1, 15);
					k1 *= c2;
					h1 ^= k1;
			};
			
			// Finalization
			/*
			h1 ^= length;
			var reVal:uint = fmix( h1);
			
			return reVal ;
			*/
			h1 ^= length;
			h1 ^= h1 >>> 16;
			h1 *= 0x85ebca6b;
			h1 ^= h1 >>> 13;
			h1 *= 0xc2b2ae35;
			h1 ^= h1 >>> 16;
			trace("h1", h1.toString(16), h1);
			return h1;

		}
		public function fmix(h:uint):uint
		{
			h ^= h >>> 33;
			h *= 0xff51afd7ed558ccd;
			h ^= h >>> 33;
			h *= 0xc4ceb9fe1a85ec53;
			h ^= h >>> 33;
			
			return h;
		}
		
		private function getblock32(data:ByteArray, offset:uint, index:uint):uint
		{
			var i4:uint = offset + index * 4;
			return (data[ i4 + 0] & 0xff) + ((data[ i4 + 1] & 0xff) << 8)
				+ ((data[ i4 + 2] & 0xff) << 16)
				+ ((data[ i4 + 3] & 0xff) << 24);
		}
		
		private function rotl32( val:uint, s:uint):uint
		{
			return ((val << s) | (val >>> (32 - s)));
		}
		private function ROTL32 ( x:uint,  r:uint ):uint
		{
			var r:uint =  (x << r) | (x >> (32 - r));
			return r & 0xFFFFFFFF;
		}
		
		
		private function MurmurHash3_x86_32 ( data:ByteArray, len:uint, seed:uint):uint
		{
			
			/*
			const  nblocks:uint = len / 4;
			
			var h1:uint = seed;
			
			const c1:uint = 0xcc9e2d51;
			const c2:uint = 0x1b873593;
			
			//----------
			// body
			
			//const blocks:uint = (data + nblocks*4);
			
			for(var i:int = -nblocks; i; i++)
			{
				var k1:uint = getblock32(data,i);
				
				k1 *= c1;
				k1 = rotl32(k1,15);
				k1 *= c2;
				
				h1 ^= k1;
				h1 = rotl32(h1,13); 
				h1 = h1*5+0xe6546b64;
			}
			
			//----------
			// tail
			
			const uint8_t * tail = (const uint8_t*)(data + nblocks*4);
			
			var k1:uint = 0;
			
			switch(len & 3)
			{
				case 3: k1 ^= tail[2] << 16;
				case 2: k1 ^= tail[1] << 8;
				case 1: k1 ^= tail[0];
					k1 *= c1; k1 = ROTL32(k1,15); k1 *= c2; h1 ^= k1;
			};
			
			//----------
			// finalization
			
			h1 ^= len;
			
			h1 = fmix32(h1);
			
			return h1;
			*/
			return 0;
		} 
		
		public function murmur3(s:String, seed:uint = 0):String
		{
			var remainder:uint = s.length & 3; // key.length % 4
			var bytes:uint = s.length - remainder;
			var h1:uint = seed;
			var c1:uint = 0xcc9e2d51;
			var c2:uint = 0x1b873593;
			var i:uint = 0;
			var h1b:uint, c1b:uint, c2b:uint, k1:uint;
			
			while (i < bytes)
			{
				k1 = ((s.charCodeAt(i) & 0xff)) | ((s.charCodeAt(++i) & 0xff) << 8) | ((s.charCodeAt(++i) & 0xff) << 16) | ((s.charCodeAt(++i) & 0xff) << 24);
				++i;
				k1 = ((((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16))) & 0xffffffff;
				k1 = (k1 << 15) | (k1 >>> 17);
				k1 = ((((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16))) & 0xffffffff;
				h1 ^= k1;
				h1 = (h1 << 13) | (h1 >>> 19);
				h1b = ((((h1 & 0xffff) * 5) + ((((h1 >>> 16) * 5) & 0xffff) << 16))) & 0xffffffff;
				h1 = (((h1b & 0xffff) + 0x6b64) + ((((h1b >>> 16) + 0xe654) & 0xffff) << 16));
			}
			
			k1 = 0;
			
			switch (remainder)
			{
				case 3:
					k1 ^= (s.charCodeAt(i + 2) & 0xff) << 16;
				case 2:
					k1 ^= (s.charCodeAt(i + 1) & 0xff) << 8;
				case 1:
					k1 ^= (s.charCodeAt(i) & 0xff);
					k1 = (((k1 & 0xffff) * c1) + ((((k1 >>> 16) * c1) & 0xffff) << 16)) & 0xffffffff;
					k1 = (k1 << 16) | (k1 >>> 16);
					k1 = (((k1 & 0xffff) * c2) + ((((k1 >>> 16) * c2) & 0xffff) << 16)) & 0xffffffff;
					h1 ^= k1;
			}
			
			h1 ^= s.length;
			h1 ^= h1 >>> 16;
			h1 = (((h1 & 0xffff) * 0x85ebca6b) + ((((h1 >>> 16) * 0x85ebca6b) & 0xffff) << 16)) & 0xffffffff;
			h1 ^= h1 >>> 13;
			h1 = ((((h1 & 0xffff) * 0xc2b2ae35) + ((((h1 >>> 16) * 0xc2b2ae35) & 0xffff) << 16))) & 0xffffffff;
			h1 ^= h1 >>> 16;
			
			s = (h1 >>> 0).toString(16).toUpperCase();
			i = s.length;
			
			if (i == 10) return s;
			if (i == 9) return "0" + s;
			if (i == 8) return "00" + s;
			if (i == 7) return "000" + s;
			if (i == 6) return "0000" + s;
			if (i == 5) return "00000" + s;
			if (i == 4) return "000000" + s;
			if (i == 3) return "0000000" + s;
			return s;
		}
		public function MurmurHash3(vDataToHash:Vector.<uint>, nHashSeed:uint):uint
		{
			// The following is MurmurHash3 (x86_32), see http://code.google.com/p/smhasher/source/browse/trunk/MurmurHash3.cpp
			
			/*
			for (int j = 0; j<vDataToHash.size(); ++j)
			{
			Serial.print(vDataToHash[j], HEX);
			}
			Serial.println("<-");
			*/
			
			var h1:uint = nHashSeed;
			//Serial.print("seed:");
			//Serial.println(h1, HEX);
			
			const c1:uint = 0xcc9e2d51;
			const c2:uint = 0x1b873593;
			
			const nblocks = vDataToHash.length / 4;
			
			//Serial.print("nblocks:");
			//Serial.println(nblocks);
			
			//----------
			// body
			const  blocks:Vector.<uint> = getBlocksof32(vDataToHash);
			
			for(var i:int = 0;i< nblocks; ++i)
			{
				var k1:uint = blocks[i];
				
				k1 *= c1;
				k1 = ROTL32(k1,15);
				k1 *= c2;
				
				h1 ^= k1;
				h1 = ROTL32(h1,13);
				h1 = h1*5+0xe6546b64;
			}
			
			//----------
			// tail
			const tail:Vector.<uint> = vDataToHash;
			
			var k1:uint = 0;
			
			switch(vDataToHash.length & 3)
			{
				case 3: 
					k1 ^= tail[2] << 16;
					break;
				case 2: 
					k1 ^= tail[1] << 8;
					break;
				case 1: 
					k1 ^= tail[0];
					k1 *= c1; 
					k1 = ROTL32(k1,15); 
					k1 *= c2; 
					h1 ^= k1;
					break;
			};
			
			//----------
			// finalization
			h1 ^= vDataToHash.length;
			h1 ^= h1 >> 16;
			h1 *= 0x85ebca6b;
			h1 ^= h1 >> 13;
			h1 *= 0xc2b2ae35;
			h1 ^= h1 >> 16;
			trace("h1", h1.toString(16), h1);
			return h1;
		}
		private function getBlocksof32(vDataToHash:Vector.<uint>):Vector.<uint>
		{
			var vec:Vector.<uint> = new Vector.<uint>();
			var blocks:uint = vDataToHash.length / 4;
			
			for(var i:uint = 0;i<vDataToHash.length;i+=4)
			{
				
				var u32:uint = (vDataToHash[i+3] & 0xFF) +  + ((vDataToHash[ i + 2] & 0xff) << 8) + ((vDataToHash[ i + 1] & 0xff) << 16) + ((vDataToHash[ i] & 0xff) << 24);
				//trace(vDataToHash[i].toString(16)+vDataToHash[i+1].toString(16)+vDataToHash[i+2].toString(16)+vDataToHash[i+3].toString(16), u32.toString(16));
				vec.push(u32);
				
			}
			
			
			
			return vec;
		}
		
	}
}










