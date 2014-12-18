package model
{
	import flash.utils.ByteArray;
	
	public class BlockVO
	{

		public var blockNum:uint;
		public var hash:ByteArray;
		public var ver:uint;//Block version information, based upon the software version creating this block
		public var prev_block:ByteArray;//The hash value of the previous block this particular block references
		public var mrkl_root:ByteArray;// The reference to a Merkle tree collection which is a hash of all transactions related to this block
		public var time:uint;//A unix timestafmp recording when this block was created (Currently limited to dates before the year 2106!)
		public var bits:uint;//The calculated difficulty target being used for this block
		public var nonce:uint;//The nonce used to generate this block… to allow variations of the header and compute different hashes
		public var n_tx:uint;//txn_count  Number of transaction entries
		public var size:uint;
		public var txns:Vector.<txVO> = new Vector.<txVO>();//Block transactions, in format of "tx" command
		
		//public var mrkl_tree:ByteArray;
		
		public function BlockVO()
		{
		}
	}
}
