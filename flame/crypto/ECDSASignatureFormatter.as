////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Ruben Buniatyan. All rights reserved.
//
//  This source is subject to the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flame.crypto
{
	import flame.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	
	/**
	 * Creates an Elliptic Curve Digital Signature Algorithm (ECDSA) signature.
	 * <p>This class is used to create a digital signature using the ECDSA algorithm.
	 * Use ECDSASignatureDeformatter to verify digital signatures with the ECDSA algorithm.</p>
	 * 
	 * @see flame.crypto.ECDSASignatureDeformatter
	 */
	public class ECDSASignatureFormatter extends AsymmetricSignatureFormatter
	{
		//--------------------------------------------------------------------------
		//
		//  Fields
		//
		//--------------------------------------------------------------------------
		
		private var _hashAlgorithm:HashAlgorithm;
		private var _key:ECDSA;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Initializes a new instance of the ECDSASignatureFormatter class.
		 * 
		 * @param key The instance of the ECDSA algorithm that holds the private key.
		 */
		public function ECDSASignatureFormatter(key:AsymmetricAlgorithm)
		{
			super();
			
			if (key != null)
				setKey(key);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Creates the signature for the specified hash.
		 * <p>You must specify a key and a hash algorithm before calling this method.</p>
		 * 
		 * @param hash The hash value of the data to be signed.
		 * 
		 * @return The digital signature for <code>hash</code>.
		 * 
		 * @throws flame.crypto.CryptoError Thrown in the following situations:<ul>
		 * <li>The private key is missing.</li>
		 * <li>The hash algorithm is missing.</li>
		 * </ul>
		 * 
		 *  @throws ArgumentError <code>data</code> parameter is <code>null</code>.
		 */
		public override function createSignature(hash:ByteArray):ByteArray
		{
			
			return _key.signHash(_hashAlgorithm.computeHash(hash));
		}
		
		/**
		 * Sets the hash algorithm to use for creating the signature.
		 * <p>You must a the hash algorithm before calling the <code>createSignature()</code> method.</p>
		 * 
		 * @param name The name of the hash algorithm to use for creating the signature.
		 */
		public override function setHashAlgorithm(name:String):void
		{
			_hashAlgorithm = HashAlgorithm(CryptoConfig.createFromName(name || "SHA256"));
		}
		
		/**
		 * Sets the private key to use for creating the signature.
		 * <p>You must set the key before calling the <code>createSignature()</code> method.</p>
		 * 
		 * @param key The instance of the ECDSA algorithm that holds the public key.
		 * 
		 * @throws ArgumentError <code>key</code> parameter is <code>null</code>.
		 * 
		 * @see flame.crypto.ECDSA
		 */
		public override function setKey(key:AsymmetricAlgorithm):void
		{
			
			_key = ECDSA(key);
		}
	}
}