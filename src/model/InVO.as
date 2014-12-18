package model
{
	import flash.utils.ByteArray;

	public class InVO
	{
		public var prev_out:OutPointVO = new OutPointVO();// The previous output transaction reference, as an OutPoint structure
		public var  script_length:uint;//The length of the signature script
		public var signature_script:ByteArray;// Computational Script for confirming transaction authorization
		public var sequence:uint;//	 Transaction version as defined by the sender. Intended for "replacement" of transactions when information is updated before inclusion into a block.
		//public var coinbase:String;
		
		public function InVO()
		{
		}
	}
}
