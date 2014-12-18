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
	 * Represents the Abstract Syntax Notation One (ASN.1) GeneralizedTime type.
	 */
	public class ASN1GeneralizedTime extends ASN1Primitive
	{
		//--------------------------------------------------------------------------
		//
		//  Fields
		//
		//--------------------------------------------------------------------------
		
		private static var _datePattern:RegExp = /^\d{14}(\.\d{1,3})?Z$/;
		
		private var _time:Number;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Initializes a new instance of the ASN1GeneralizedTime class.
		 * 
		 * @param value The value to use.
		 * 
		 * @throws ArgumentError <code>value</code> parameter is <code>null</code>.
		 */
		public function ASN1GeneralizedTime(value:Date)
		{
			super(ASN1Tag.GENERALIZED_TIME);
			
			
			_time = value.time;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Gets the actual content as a Date
		 */
		public function get value():Date
		{
			return new Date(_time);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private 
		 */
		internal static function fromRawValue(value:ByteArray):ASN1GeneralizedTime
		{
			var dateString:String = value.readMultiByte(value.bytesAvailable, "ascii");
			
			
			var year:int = int(dateString.substr(0, 4));
			var month:int = int(dateString.substr(4, 2));
			
			
			var day:int = int(dateString.substr(6, 2));
			var daysInMonth:int = DateUtil.daysInMonth(year, month);
			
			
			var hours:int = int(dateString.substr(8, 2));
			
			
			var minutes:int = int(dateString.substr(10, 2));
			
			
			var seconds:int = int(dateString.substr(12, 2));
			
			
			var milliseconds:int = dateString.indexOf(".") != -1 ? parseFloat(dateString.substring(14, dateString.indexOf("Z") - 1)) * 1000 : 0;
			var date:Date = new Date();
			
			date.dateUTC = day;
			date.fullYearUTC = year;
			date.hoursUTC = hours;
			date.minutesUTC = minutes;
			date.monthUTC = month - 1;
			date.secondsUTC = seconds;
			date.millisecondsUTC = milliseconds;
			
			return new ASN1GeneralizedTime(date);
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
			var year:String = StringUtil.padLeft(date.fullYearUTC.toString().substr(-4, 4), 4, "0");
			var month:String = StringUtil.padLeft((date.month + 1).toString(), 2, "0");
			var day:String = StringUtil.padLeft(date.dateUTC.toString(), 2, "0");
			var hours:String = StringUtil.padLeft(date.hoursUTC.toString(), 2, "0");
			var minutes:String = StringUtil.padLeft(date.minutesUTC.toString(), 2, "0");
			var seconds:String = StringUtil.padLeft(date.secondsUTC.toString(), 2, "0");
			var milliseconds:String = date.milliseconds > 0 ? "." + date.millisecondsUTC.toString().replace(/0$/, "") : "";
			
			buffer.writeMultiByte(year + month + day + hours + minutes + seconds + milliseconds + "Z", "ascii");
			
			buffer.position = 0;
			
			return buffer;
		}
	}
}