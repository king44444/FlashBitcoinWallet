////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Ruben Buniatyan. All rights reserved.
//
//  This source is subject to the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flame.crypto.asn1
{
	import flame.utils.ByteArrayUtil;
	
	import flash.utils.ByteArray;
	
	/**
	 * Represents the Abstract Syntax Notation One (ASN.1) BitString type.
	 */
	public class ASN1BitString extends ASN1Primitive
	{
		//--------------------------------------------------------------------------
		//
		//  Fields
		//
		//--------------------------------------------------------------------------
		
		private var _unusedBitCount:int;
		private var _value:ByteArray;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Initializes a new instance of the ASN1BitString class.
		 * 
		 * @param value The value to use.
		 * 
		 * @param unusedBitCount The number of unused bits in the last byte of the <code>value</code> parameter.
		 * 
		 * @throws ArgumentError <code>value</code> parameter is <code>null</code>.
		 * 
		 * @throws RangeError <code>unusedBitCount</code> parameter is less than 0 or greater than 7.
		 */
		public function ASN1BitString(value:ByteArray, unusedBitCount:int = 0)
		{
			super(ASN1Tag.BIT_STRING);
			
			
			_unusedBitCount = unusedBitCount;
			_value = ByteArrayUtil.copy(value);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Gets the number of unused bits in the last byte of <code>value</code> property. 
		 */
		public function get unusedBitCount():int
		{
			return _unusedBitCount;
		}
		
		/**
		 * Gets the actual content as a byte array.
		 */
		public function get value():ByteArray
		{
			return ByteArrayUtil.copy(_value);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private 
		 */
		internal static function fromRawValue(value:ByteArray):ASN1BitString
		{
			var unusedBitCount:int = value.readUnsignedByte();
			
			
			if (unusedBitCount > 0)
			{
				var lastByte:int = value[value.length - 1];
				
			}
			
			var buffer:ByteArray = new ByteArray();
			
			value.readBytes(buffer);
			
			return new ASN1BitString(buffer, unusedBitCount);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		protected override function encodeValue():ByteArray
		{
			var buffer:ByteArray = new ByteArray();
			var hasAllNull:Boolean = true;
			
			for (var i:int = 0, count:int = _value.length; i < count; i++)
				if (_value[i] != 0)
				{
					hasAllNull = false;
					break;
				}
			
			if (hasAllNull)
				buffer.writeByte(0);
			else
			{
				buffer.writeByte(_unusedBitCount);
				buffer.writeBytes(_value);
				
				if (_unusedBitCount > 0)
					buffer[buffer.length - 1] &= 0xFF << _unusedBitCount & 0xFF;
			}
			
			buffer.position = 0;
			
			return buffer;
		}
	}
}