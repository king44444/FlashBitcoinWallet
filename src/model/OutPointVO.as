package model
{
	import flash.utils.ByteArray;

	public class OutPointVO
	{
		public var hash:ByteArray;//The hash of the referenced transaction.
		public var n:uint;//The index of the specific output in the transaction. The first output is 0, etc
		
		public function OutPointVO()
		{
		}
	}
}