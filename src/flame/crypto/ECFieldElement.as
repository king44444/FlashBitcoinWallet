////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2011 Ruben Buniatyan. All rights reserved.
//
//  This source is subject to the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flame.crypto
{
	import flame.numerics.BigInteger;
	public class ECFieldElement
	{
		//--------------------------------------------------------------------------
		//
		//  Fields
		//
		//--------------------------------------------------------------------------
		
		/**
		 * A reference to the IResourceManager object which manages all of the localized resources.
		 * 
		 * @see mx.resources.IResourceManager
		 */
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function ECFieldElement()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		public function add(value:ECFieldElement):ECFieldElement
		{
			return null;
		}
		
		public function divide(value:ECFieldElement):ECFieldElement
		{
			return null;
		}
		
		public function equals(value:ECFieldElement):Boolean
		{
			return toBigInteger().equals(value.toBigInteger());
		}
		
		public function multiply(value:ECFieldElement):ECFieldElement
		{
			return null;
		}
		
		public function negate():ECFieldElement
		{
			return null;
		}
		
		public function square():ECFieldElement
		{
			return null;
		}
		
		public function subtract(value:ECFieldElement):ECFieldElement
		{
			return null;
		}
		
		public function toBigInteger():BigInteger
		{
			return null;
		}
		public function sqrt(ec:EllipticCurve):ECFieldElement
		{
			return null;
		}
		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		public function get fieldSize():int
		{
			return 0;
		}
	}
}