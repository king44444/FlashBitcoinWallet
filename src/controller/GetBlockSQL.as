package controller
{
	import com.hurlant.util.Hex;
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import model.BlockVO;

	public class GetBlockSQL extends SQLQue
	{
		private static const GETTINGLASTBLOCK:uint = 0;
		private static const GETTINGBLOCK:uint = 1;
		
		public var blocksResult:Vector.<BlockVO> = new Vector.<BlockVO>();
		private var currentState:uint;
		private var dc:DatabaseController;
		
		public function GetBlockSQL(_dc:DatabaseController)
		{
			dc = _dc;
		}
		public function getLastBlock():void
		{
			currentState = GETTINGLASTBLOCK;
		//	lastStatement = dc.getState("SELECT * FROM blocks, txns WHERE txns.blockNum = blocks.blockNum ORDER BY blockNum DESC LIMIT 1");
			lastStatement = dc.getState("SELECT * FROM blocks ORDER BY blockNum DESC LIMIT 1");
			addListener(lastStatement);
			dc.statementsSQL.push(lastStatement);
			dc.doStatments();
		}
		
		override protected function statResult(event:SQLEvent):void
		{
			var sqlresult:SQLResult = lastStatement.getResult();
			
			
			switch(currentState)
			{
				case GETTINGLASTBLOCK:
					//getting a block
					getBlocksFromResult(sqlresult.data);
					if(blocksResult.length == 0)
					{
						trace("Problem!");
					}else
					{
						trace("found block");
						dc.lastBlock = blocksResult.pop();
					}
				break;	
			}
			
			
			
			//datafiled.dataProvider = sqlresult.data;
		}
		override protected function errorHandler(event:SQLErrorEvent):void
		{
			
			super.errorHandler(event);
		}
		public function getBlockFromHash(hash:String):void
		{
			
		}
		public function getBlocksFromResult(blocksAry:Array):void
		{
			for(var i:int = 0;i<blocksAry.length;++i)
			{
				var resultObj:Object = blocksAry[i];
				var block:BlockVO = new BlockVO();
				block.bits = resultObj.bits;
				block.blockNum = resultObj.blockNum;
				block.hash = Hex.toArray( resultObj.hash );
				block.mrkl_root = Hex.toArray( resultObj.mrkl_root );
				block.nonce = resultObj.nonce;
				block.n_tx = resultObj.n_tx;
				block.prev_block = Hex.toArray( resultObj.prev_block );
				block.size = resultObj.size;
				block.time = resultObj.time;
				block.ver = resultObj.ver;
				blocksResult.push(block);
			}
			
		}
	}
}