////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Ruben Buniatyan. All rights reserved.
//
//  This source is subject to the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package flame.crypto.asn1
{
	import flame.utils.DateUtil;
	import flame.utils.StringUtil;
	
	import flash.utils.ByteArray;
	
	
	/**
	 * Represents the Abstract Syntax Notation One (ASN.1) UTCTime type.
	 */
	public class ASN1UTCTime extends ASN1Primitive
	{
		//--------------------------------------------------------------------------
		//
		//  Fields
		//
		//--------------------------------------------------------------------------
		
		private static var _datePattern:RegExp = /^\d{12}Z$/;
		
		private var _time:Number;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Initializes a new instance of the ASN1UTCTime class.
		 * 
		 * @param value The value to use.
		 * 
		 * @throws ArgumentError <code>value</code> parameter is <code>null</code>.
		 */
		public function ASN1UTCTime(value:Date)
		{
			super(ASN1Tag.UTC_TIME);
			
			
			_time = value.time;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Gets the actual content as a Date.
		 */
		public function get value():Date
		{
			return new Date(_time);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Internal methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private 
		 */
		internal static function fromRawValue(value:ByteArray):ASN1UTCTime
		{
			var dateString:String = value.readMultiByte(value.bytesAvailable, "ascii");
			
			if (!_datePattern.test(dateString))
				return null;
			
			var year:int = int(dateString.substr(0, 2));
			
			year += year < 50 ? 2000 : 1900;
			
			var month:int = int(dateString.substr(2, 2));
			
			
			var day:int = int(dateString.substr(4, 2));
			var daysInMonth:int = DateUtil.daysInMonth(year, month);
			
			
			var hours:int = int(dateString.substr(6, 2));
			
			
			var minutes:int = int(dateString.substr(8, 2));
			
			
			var seconds:int = int(dateString.substr(10, 2));
			
			
			var date:Date = new Date();
			
			date.dateUTC = day;
			date.fullYearUTC = year;
			date.hoursUTC = hours;
			date.minutesUTC = minutes;
			date.monthUTC = month - 1;
			date.secondsUTC = seconds;
			
			return new ASN1UTCTime(date);
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
			var date:Date = new Date(_time);
			var year:String = StringUtil.padLeft(date.fullYearUTC.toString().substr(-2, 2), 2, "0");
			var month:String = StringUtil.padLeft((date.month + 1).toString(), 2, "0");
			var day:String = StringUtil.padLeft(date.dateUTC.toString(), 2, "0");
			var hours:String = StringUtil.padLeft(date.hoursUTC.toString(), 2, "0");
			var minutes:String = StringUtil.padLeft(date.minutesUTC.toString(), 2, "0");
			var seconds:String = StringUtil.padLeft(date.secondsUTC.toString(), 2, "0");
			
			buffer.writeMultiByte(year + month + day + hours + minutes + seconds + "Z", "ascii");
			
			buffer.position = 0;
			
			return buffer;
		}
	}
}