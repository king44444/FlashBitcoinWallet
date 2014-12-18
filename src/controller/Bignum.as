package controller
{
	import com.hurlant.math.BigInteger;

	public class Bignum extends BigInteger
	{
		public function Bignum(value:* = null, radix:int = 0) 
		{
			
			super(value, radix);
		}
		public function getvch():int
		{
			return 0;
		}
		public function getint():int
		{
			return 0;
		}
		
	}
}

