package model
{
	import flash.utils.ByteArray;

	public class OutVO
	{
		public var byteStart:uint//what byte does this out start at in the tx?
		public var byteLength:uint//how many bytes is this out in the tx?
		public var outIndex:uint;//what number of out is this in the tx?
		public var value:ByteArray;//Transaction Value -this is a 64 bit number!
		public var lengthPubKey:uint;// Length of the pk_script
		public var scriptPubKey:ByteArray;// Usually contains the public key as a Bitcoin script setting up conditions to claim this output.
		//public var scriptPubKeyBytes:ByteArray;
		//02 79BE667E F9DCBBAC 55A06295 CE870B07 029BFCDB 2DCE28D9 59F2815B16F81798
		public function OutVO()
		{
			
		}
	}
}
	
