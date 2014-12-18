 package
{
	import com.adobe.crypto.SHA256;
	import com.hurlant.util.Hex;
	
	import flash.utils.ByteArray;
	
	import model.Work;
	
	public class ScanHash
	{
		private var hashed:int;
		public function ScanHash()
		{
		}
		public function getCount():int
		{
			var cnt:int = hashed;
			hashed = 0;
			return cnt;
	  	}
		
		
	  	public function scan(work:Work, start:int, count:int):Boolean 
		{
			
			//var sha256:SHA256 = new SHA256();
			var h:Hex
			var _data:ByteArray = Hex.toArray(work.data.substring(128));//  HexUtil.decodeVector(new ByteArray(), work.data.substring(128));
			var _midstate:ByteArray = HexUtil.decodeVector(HexUtil.decodeVector(new ByteArray(), work.hash1), work.midstate);
				 
				                
				                 var __state:ByteArray;
								 var __data:ByteArray;
								 var __hash1:ByteArray;
								 var __hash:ByteArray;
								 
								 for (var nonce:int = start; nonce < start + count; nonce++) 
								 {
					                         _data[3] = nonce; // NONCE is _data[3]
					                         hashed++;
					 
					                         __state = new ByteArray(_midstate.length);
					                         arraycopy(_midstate, 0, __state, 0, _midstate.length);
					                         __data = _data;
					 
											 __state =  SHA256.hashBytes(__data);
					                         __hash1 = __state;
					 
					                        // __state = SHA256.initState();
											 __state = SHA256.hashBytes(__hash1);
					                         __hash = __state;
					 
					                         if (__hash[7] == 0) {
					                                 work.data = work.data.substring(0, 128) + encode(__data);
					                                 return true;
					                         }
					                 }
				 
				                 return false;
				    }
			}
	
		private function arraycopy(src:ByteArray, srcPos:int,  dest:ByteArray, destPos:int, clength:int):void
		{
		
		}
	}
}