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
	 * Verifies an Elliptic Curve Digital Signature Algorithm (ECDSA) signature.
	 * <p>This class is used to verify a digital signature made with the ECDSA algorithm.
	 * Use ECDSASignatureFormatter to create digital signatures with the ECDSA algorithm.</p>
	 * 
	 * @see flame.crypto.ECDSASignatureFormatter
	 */
	public class ECDSASignatureDeformatter extends AsymmetricSignatureDeformatter
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
		 * Initializes a new instance of the ECDSASignatureDeformatter class.
		 * 
		 * @param key The instance of the ECDSA algorithm that holds the public key.
		 */
		public function ECDSASignatureDeformatter(key:AsymmetricAlgorithm)
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
		 * Verifies the specified signature data by determining the hash value in the signature
		 * and comparing it to the hash value of the provided data.
		 * <p>You must specify a key and a hash algorithm before calling this method.</p>
		 * 
		 * @param hash The hash value of the data signed with <code>signature</code>.
		 * 
		 * @param signature The signature to be verified for <code>hash</code>.
		 * 
		 * @return <code>true</code> if <code>signature</code> matches the signature
		 * computed using the specified hash algorithm and key on <code>data</code>; otherwise, <code>false</code>.
		 * 
		 * @throws flame.crypto.CryptoError Thrown in the following situations:<ul>
		 * <li>The private key is missing.</li>
		 * <li>The hash algorithm is missing.</li>
		 * </ul>
		 * 
		 * @throws ArgumentError Thrown in the following situations:<ul>
		 * <li><code>hash</code> parameter is <code>null</code>.</li>
		 * <li><code>signature</code> parameter is <code>null</code>.</li>
		 * </ul>
		 */
		public override function verifySignature(hash:ByteArray, signature:ByteArray):Boolean
		{
			
			return _key.verifyHash(hash, signature);
		}
		
		/**
		 * Sets the hash algorithm to use for verifying the signature.
		 * <p>You must set a hash algorithm before calling the <code>verifySignature()</code> method.</p>
		 * 
		 * @param name The name of the hash algorithm to use for verifying the signature.
		 */
		public override function setHashAlgorithm(name:String):void
		{
			_hashAlgorithm = HashAlgorithm(CryptoConfig.createFromName(name || "SHA256"));
		}
		
		/**
		 * Sets the public key to use for verifying the signature.
		 * <p>You must set a key before calling the <code>verifySignature()</code> method.</p>
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