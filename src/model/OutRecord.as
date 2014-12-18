package model
{
	import com.adobe.crypto.SHA256;
	
	import flame.numerics.BigInteger;
	import flame.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	
	public class OutRecord
	{
		
	
		public var used:Boolean;
		public var recordIDhash:ByteArray;
		public var blockNum:uint;
		public var outStart:uint;
		public var txNum:uint;
		public var outNum:uint;
		public var value:BigInteger;
		private var _valueBytes:ByteArray;
		
		public function OutRecord()
		{
			used = false;
		}
		public function set valueBytes(ba:ByteArray):void
		{
			_valueBytes = ba;
			value = new BigInteger(ba, true);
		}
		public function get valueBytes():ByteArray
		{
			if(_valueBytes == null)
			{
				_valueBytes = new ByteArray();
			}
			return _valueBytes;
		}
		public static function recordIDHash(transHash:ByteArray, spot:uint):ByteArray
		{
			
			transHash.position = 0;
			var recoredID:ByteArray = new ByteArray();
			recoredID.writeBytes(transHash);
			recoredID.writeUnsignedInt(spot);
			SHA256.hashBytes(recoredID);
			return SHA256.digest;
		}
	
		public static function get defaultRecordSize():uint
		{
			var recordSize:uint = (1 + 32 + 4 + 4 + 4 + 4 + 8);//used, hash, blockNum,  out start, out length, value
			return recordSize;
		}
		public function getBytes():ByteArray
		{
			var ba:ByteArray = new ByteArray();
			if(used)
			{
				ba.writeByte(used? 1:0);
			}else
			{
				ba.writeByte(used? 1:0);
			}
			
			ba.writeBytes(recordIDhash);
			ba.writeUnsignedInt(blockNum);
			ba.writeUnsignedInt(txNum);
			ba.writeUnsignedInt(outNum);
			ba.writeUnsignedInt(outStart);
			ba.writeBytes(_valueBytes);
			if(ba.length != defaultRecordSize)
			{
				trace("there is a problem");
				throw new Error("out Record mess up");
			}
			//trace("from bytes:", ByteArrayUtil.toHexString(ba));
			return ba;
		}
		
		public function fromBytes(ba:ByteArray):Boolean
		{
			//trace("frombytes:", ByteArrayUtil.toHexString(ba));
			ba.position = 0;
			used = (ba.readByte() == 1);
			recordIDhash = new ByteArray();
			recordIDhash.writeBytes(ba, 1, 32);
			//trace("recordIDhash:", ByteArrayUtil.toHexString(recordIDhash));
			ba.position = 33;
			blockNum = ba.readUnsignedInt();
			txNum = ba.readUnsignedInt();
			outNum = ba.readUnsignedInt();
			//start
			outStart = ba.readUnsignedInt();
			//total Outs used
			var value1:uint = ba.readUnsignedInt();
			var value2:uint = ba.readUnsignedInt();
			var valueba:ByteArray = new ByteArray();
			valueba.writeUnsignedInt(value1);
			valueba.writeUnsignedInt(value2);
			this.valueBytes = valueba;
			return true;
			
		}
	}
}