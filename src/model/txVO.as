package model
{
	import flash.utils.ByteArray;

	public class txVO
	{
		public var includedInBlock:uint;
		public var indexInBlock:uint;
		public var hash:ByteArray;
		public var ver:uint;//Transaction data format version
		public var vin_sz:uint;//var_int	 Number of Transaction inputs
		public var vout_sz:uint;//Number of Transaction outputs
		public var lock_time:uint;// The block number or timestamp at which this transaction is locked:
		/*
		0	 Always locked
		< 500000000	 Block number at which this transaction is locked
		>= 500000000	 UNIX timestamp at which this transaction is locked
		A non-locked transaction must not be included in blocks, and it can be modified by broadcasting a new version before the time has expired (replacement is currently disabled in Bitcoin, however, so this is useless).

		
		*/
		public var size:uint;
		public var _in:Vector.<InVO> = new Vector.<InVO>();// A list of 1 or more transaction inputs or sources for coins
		public var _out:Vector.<OutVO> = new Vector.<OutVO>();//A list of 1 or more transaction outputs or destinations for coins
		
		public function txVO()
		{
		}
	}
}


