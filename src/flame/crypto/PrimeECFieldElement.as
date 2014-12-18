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

	internal class PrimeECFieldElement extends ECFieldElement
	{
		//--------------------------------------------------------------------------
		//
		//  Fields
		//
		//--------------------------------------------------------------------------
		
		private var _q:BigInteger;
		private var _x:BigInteger;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function PrimeECFieldElement(q:BigInteger, x:BigInteger)
		{
			super();
			
			
			
			_q = q;
			_x = x;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		override public function add(value:ECFieldElement):ECFieldElement
		{
			return new PrimeECFieldElement(_q, _x.add(value.toBigInteger()).mod(_q));
		}
		
		override public function divide(value:ECFieldElement):ECFieldElement
		{
			return new PrimeECFieldElement(_q, _x.multiply(value.toBigInteger().modInverse(_q)).mod(_q));
		}
		
		override public function equals(value:ECFieldElement):Boolean
		{
			if (value == this)
				return true;
			
			return value is PrimeECFieldElement && _q.equals(PrimeECFieldElement(value)._q) && super.equals(value);
		}
		
		override public function multiply(value:ECFieldElement):ECFieldElement
		{
			return new PrimeECFieldElement(_q, _x.multiply(value.toBigInteger()).mod(_q));
		}
		
		override public function negate():ECFieldElement
		{
			return new PrimeECFieldElement(_q, _x.negate().mod(_q));
		}
		
		override public function square():ECFieldElement
		{
			return new PrimeECFieldElement(_q, _x.square().mod(_q));
		}
		
		override public function subtract(value:ECFieldElement):ECFieldElement
		{
			return new PrimeECFieldElement(_q, _x.subtract(value.toBigInteger()).mod(_q));
		}
		
		override public function toBigInteger():BigInteger
		{
			return _x;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Internal properties
		//
		//--------------------------------------------------------------------------
		
		override public function get fieldSize():int
		{
			return _q.bitLength;
		}
		// D.1.4 91
		/**
		 * return a sqrt root - the routine verifies that the calculation
		 * returns the right value - if none exists it returns null.
		 * 
		 * Copyright (c) 2000 - 2011 The Legion Of The Bouncy Castle (http://www.bouncycastle.org)
		 * Ported to JavaScript by bitaddress.org
		 */
		override public function sqrt(ec:EllipticCurve):ECFieldElement
		{
			
			if (this._q.isEven) throw new Error("even value of q");
			
			// p mod 4 == 3
			if (this._q._bits[1] > 0) {
				// z = g^(u+1) + p, p = 4u + 3
				   
				var z =  ec.bigIntegerToFieldElement( this._x.modPow(_q.shiftRight(2).add(BigInteger.ONE), this._q));
				
				return z.square().equals(this) ? z : null;
			}
			
			// p mod 4 == 1
			var qMinusOne = this._q.subtract(BigInteger.ONE);
			var legendreExponent = qMinusOne.shiftRight(1);
			if (!(this._x.modPow(legendreExponent, this._q).equals(BigInteger.ONE))) return null;
			var u = qMinusOne.shiftRight(2);
			var k = u.shiftLeft(1).add(BigInteger.ONE);
			var Q = this._x;
			var fourQ = Q.shiftLeft(2).mod(this._q);
			var U, V;
			/*
			do {
				//var rand = new SecureRandom();
				var P;
				do {
					P = new BigInteger(this._q.bitLength(), rand);
				}
				while (P.compareTo(this.q) >= 0 || !(P.multiply(P).subtract(fourQ).modPow(legendreExponent, this.q).equals(qMinusOne)));
				
				var result = ec.FieldElementFp.fastLucasSequence(this._q, P, Q, k);
				
				U = result[0];
				V = result[1];
				if (V.multiply(V).mod(this._q).equals(fourQ)) {
					// Integer division by 2, mod q
					if (V.testBit(0)) {
						V = V.add(this.q);
					}
					V = V.shiftRight(1);
					return new ec.FieldElementFp(this.q, V);
				}
			}
			while (U.equals(BigInteger.ONE) || U.equals(qMinusOne));
			*/
			return null;
		};

	}
}