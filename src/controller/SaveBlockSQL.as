package controller
{
	import com.hurlant.util.Hex;
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	
	import model.BlockVO;
	import model.InVO;
	import model.OutPointVO;
	import model.OutVO;
	import model.txVO;

	public class SaveBlockSQL extends SQLQue
	{
		private static const SAVINGOUTTXS:uint = 0;
		private static const SAVINGINTXS:uint = 1;
		private static const SAVINGTXN:uint = 2;
		private static const SAVINGBLOCK:uint = 3;
		
		private var currentState:uint;
		private var block:BlockVO;
		private var dc:DatabaseController;
		
		private var currentI:uint;
		private var currentTrans:uint;
		private var savedBlockNum:uint;
		private var savedTxnID:uint;
		
		public function SaveBlockSQL(_dc:DatabaseController)
		{
			dc = _dc;
			
		}
		public function saveBlock(_block:BlockVO):void
		{
			block = _block;
			//dc.sqlStat.addEventListener(SQLEvent.RESULT, statResult, false, 0, true);
			//dc.sqlStat.addEventListener(SQLErrorEvent.ERROR, errorHandler, false, 0, true);
			
			//dc.statementsSQL.push(getSaveBlockStr(block));
			//dc.statementsSQL.push(getOutPointStr(block.));
			currentTrans = 0;
			currentI = 0;
			
			doSaveBlock();
			
		}
		
		override protected function statResult(event:SQLEvent):void
		{
			
			
			var sqlresult:SQLResult = lastStatement.getResult();
			removeListener();
			
			switch (currentState)
			{
				case SAVINGBLOCK:
					savedBlockNum = sqlresult.lastInsertRowID;// dc.sqlConnection.lastInsertRowID;
					doSaveTx();
					break;
				case SAVINGTXN:
					savedTxnID = sqlresult.lastInsertRowID;// dc.sqlConnection.lastInsertRowID;
					doSaveOut();
					break;
				case SAVINGOUTTXS:
					doSaveOut();
					break;
				case SAVINGINTXS:
					doSaveIn();
					break;
			}
			
		}
		override protected function errorHandler(event:SQLErrorEvent):void
		{
			
			super.errorHandler(event);
		}
		private function doSaveBlock():void
		{
			currentI = 0;
			currentState = SAVINGBLOCK;
			lastStatement = this.getSaveBlockState(block);
			addListener(lastStatement);
			dc.statementsSQL.push(lastStatement);
			dc.doStatments();
		}
		private function doSaveTx():void
		{
			if(currentTrans >= block.txns.length)
			{
				//done done
				trace("DONE DONE");
				dc.getLastBlock();
				dc = null;
				removeListener();
				lastStatement = null;
			}else
			{
				
				currentState = SAVINGTXN;
				lastStatement = getTxnState(block.txns[currentTrans]);
				addListener(lastStatement);
				dc.statementsSQL.push(lastStatement);
				dc.doStatments();	
			}
		}
		private function doSaveOut():void
		{
			var currentTx:txVO = block.txns[currentTrans];
			if(currentI >= currentTx._out.length)
			{
				//done
				currentI = 0;
				doSaveIn();
				
			}else
			{
				currentState = SAVINGOUTTXS;
				lastStatement = getOutTxsState(currentTx._out[currentI]);
				addListener(lastStatement);
				dc.statementsSQL.push(lastStatement);
				++currentI;
				dc.doStatments();
			}
		}
		
		private function doSaveIn():void
		{
			var currentTx:txVO = block.txns[currentTrans];
			if(currentI >= currentTx._in.length)
			{
				//done
				currentI = 0;
				//next transaction
				++currentTrans;
				doSaveTx();
			}else
			{
				currentState = SAVINGINTXS;
				lastStatement = getInTxsState(currentTx._in[currentI]);
				++currentI;
				addListener(lastStatement);
				dc.statementsSQL.push(lastStatement);
				dc.doStatments();
			}
		}
		
		private function getInTxsState(inTx:InVO):SQLStatement
		{
			
			var sqlupdate:String = "Insert into inTxns (txid, prev_out_hash, prev_out_num, script_length, signature_script, sequence) values('" +
				savedTxnID +
				"','" +
				Hex.fromArray(inTx.prev_out.hash) +
				"','" +
				inTx.prev_out.n +
				"','" +
				inTx.script_length +
				"'," +
				":signature_script" +
				",'" +
				inTx.sequence +
				"')";
			
			var insertRecord:SQLStatement = dc.getState(sqlupdate);
			insertRecord.parameters[":signature_script"] = inTx.signature_script;
			return insertRecord;
			
		}
		private function getTxnState(tx:txVO):SQLStatement
		{
			var sqlupdate:String = "Insert into txns (blockNum, hash, ver, vin_sz, vout_sz, lock_time, size) values('" +
				savedBlockNum +
				"','" +
				Hex.fromArray(tx.hash) +
				"','" +
				tx.ver +
				"','" +
				tx.vin_sz +
				"','" +
				tx.vout_sz +
				"','" +
				tx.lock_time +
				"','" +
				tx.size +
				"')";
			
			var insertRecord:SQLStatement = dc.getState(sqlupdate);
			return insertRecord;
			
		}
		private function getOutTxsState(out:OutVO):SQLStatement
		{
			
			var sqlupdate:String = "Insert into outTxns (txid, value, lengthPubKey, scriptPubKey) values('" +
				savedTxnID +
				"'," +
				":outvalue" +
				",'" +
				out.lengthPubKey +
				"'," +
				":outscriptPubKey" +
				")";
			
			
			var insertRecord:SQLStatement = dc.getState(sqlupdate);
			insertRecord.parameters[":outvalue"] = out.value;
			// The ByteArray should be added as a parameter; this makes the whole process of storing the image in the blob field very easy
			insertRecord.parameters[":outscriptPubKey"] = out.scriptPubKey;
			return insertRecord;
		}
		
		
		
		private function getSaveBlockState(block:BlockVO):SQLStatement
		{
			
			var sqlupdate:String = "Insert into blocks(hash,ver, prev_block, mrkl_root, time, bits, nonce, n_tx, size) values('" +
				Hex.fromArray( block.hash ) +
				"','" +
				block.ver +
				"','" +
				Hex.fromArray( block.prev_block ) +
				"','" +
				Hex.fromArray( block.mrkl_root) +
				"','" +
				block.time +
				"','" +
				block.bits +
				"','" +
				block.nonce +
				"','" +
				block.n_tx +
				"','" +
				block.size +
				"')";
			
			return dc.getState(sqlupdate);
			
		}
	}
}