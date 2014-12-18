package controller
{
	import com.hurlant.util.Hex;
	
	import flame.utils.ByteArrayUtil;
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import model.BlockVO;
	
	public class SQLQue
	{
		
		public var lastStatement:SQLStatement;
		public var statementsSQL:Vector.<SQLStatement> = new Vector.<SQLStatement>();
		protected var util:BitCoinUtil = new BitCoinUtil(true);
		protected var inTransaction:Boolean;
		
		public function SQLQue()
		{
			inTransaction = false;
		}
		public function doStatments(event:SQLEvent = null):void
		{
			
			if(statementsSQL.length == 0 || inTransaction)return;
			
			
			// init sqlStatement object
			
			lastStatement = statementsSQL.shift();
			if(lastStatement.sqlConnection.connected == false)
			{
				statementsSQL.unshift(lastStatement);
				return;
			}
			lastStatement.execute();
			inTransaction = true;
			/*
			public var prev_out:OutPointVO = new OutPointVO();// The previous output transaction reference, as an OutPoint structure
			
			
			public var _in:Vector.<InVO> = new Vector.<InVO>();// A list of 1 or more transaction inputs or sources for coins
			public var _out:Vector.<OutVO> = new Vector.<OutVO>();//A list of 1 or more transaction outputs or destinations for coins
			
			
			public var txns:Vector.<txVO> = new Vector.<txVO>();//Block transactions, in format of "tx" command
			*/
			
			
		}
		
		protected function statResult(event:SQLEvent):void
		{
			lastStatement.removeEventListener(SQLEvent.RESULT, statResult);
			lastStatement.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			inTransaction = false;
			//var sqlresult:SQLResult = lastStatement.getResult();
			
			/*
			
			
			if(sqlStat.text.indexOf("SELECT") == 0)
			{
			//getting info
			if(sqlStat.text.indexOf("blocks") != -1)
			{
			//getting a block
			if(sqlresult.data == null)
			{
			trace("could not find block");
			
			}else
			{
			
			trace("found block");
			getBlocksFromResult(sqlresult.data);
			//lastBlock = ;
			}
			
			}
			}
			*/
			doStatments();
			//datafiled.dataProvider = sqlresult.data;
		}
		protected function errorHandler(event:SQLErrorEvent):void
		{
			inTransaction = false;
			lastStatement.removeEventListener(SQLEvent.RESULT, statResult);
			lastStatement.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			trace("Error code:", event.error);
			trace("Details:", event.error.message);
			//doStatments();
		}
		protected function addListener(state:SQLStatement):void
		{
			state.addEventListener(SQLEvent.RESULT, statResult);//, false, 0, true);
			state.addEventListener(SQLErrorEvent.ERROR, errorHandler);//, false, 0, true);
			lastStatement = state;
			
		}
		protected function removeListener(state:SQLStatement = null):void
		{
			if(state == null)state = lastStatement;
			
			state.removeEventListener(SQLEvent.RESULT, statResult);
			state.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
			
		}
	}
}