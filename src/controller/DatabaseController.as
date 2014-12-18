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

	
	public class DatabaseController extends SQLQue
	{
		
		private var initComplete:Boolean = false;
		public var sqlConnection:SQLConnection;
		private var bitcoinDBName:String = "bitcoin.db";
		private var databaseDir:File = File.desktopDirectory.resolvePath(BitCoinUtil.MAINDIRECTORYNAME);
		public var lastBlock:BlockVO;
		//controlers
		//private var saveBlockCon:SaveBlockSQL;
		//private var getBlockCon:GetBlockSQL;
		
		public function DatabaseController()
		{
			
			if(databaseDir.exists == false)
			{
				databaseDir.createDirectory();
			}
			
			openDatabaseConnection();
		}
	

		public function openDatabaseConnection():void
		{
			// create new sqlConnection
			sqlConnection = new SQLConnection();
			sqlConnection.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			// get currently dir
			var dbFile:File = databaseDir.resolvePath(bitcoinDBName);
			if(dbFile.exists)
			{
				var getBlockCon:GetBlockSQL = new GetBlockSQL(this);
				getBlockCon.getLastBlock();
				//
			}else
			{
				
				var blockSql:String ="CREATE TABLE IF NOT EXISTS blocks (blockNum INTEGER PRIMARY KEY AUTOINCREMENT, hash TEXT(32) not null, ver INTEGER not null, prev_block TEXT not null, mrkl_root TEXT not null, time INTEGER not null, bits INTEGER not null, nonce INTEGER not null, n_tx INTEGER not null, size INTEGER not null);";
				var transSql:String ="CREATE TABLE IF NOT EXISTS txns (uid INTEGER PRIMARY KEY AUTOINCREMENT, blockNum INTEGER, hash TEXT(32) not null, ver INTEGER not null, vin_sz INTEGER not null, vout_sz INTEGER not null, lock_time INTEGER not null, size INTEGER not null, FOREIGN KEY(blockNum) REFERENCES blocks(blockNum));";
				var transOutSql:String ="CREATE TABLE IF NOT EXISTS outTxns (uid INTEGER PRIMARY KEY AUTOINCREMENT,txid INTEGER, value BLOB(8) not null, lengthPubKey INTEGER not null, scriptPubKey BLOB not null, FOREIGN KEY(txid) REFERENCES txns(uid));";
				var transInSql:String ="CREATE TABLE IF NOT EXISTS inTxns (uid INTEGER PRIMARY KEY AUTOINCREMENT,txid INTEGER, prev_out_hash TEXT(32) not null, prev_out_num INTEGER not null, script_length INTEGER not null, signature_script BLOB not null, sequence INTEGER not null, FOREIGN KEY(txid) REFERENCES txns(uid));";
				
				statementsSQL.push(getState(blockSql));
				statementsSQL.push(getState(transSql));
				statementsSQL.push(getState(transOutSql));
				statementsSQL.push(getState(transInSql));
				var saveGenesis:SaveBlockSQL = new SaveBlockSQL(this);
				saveGenesis.saveBlock(util.getGenisisBlock());
				 saveGenesis = new SaveBlockSQL(this);
				saveGenesis.saveBlock(util.getGenisisBlock());
			 saveGenesis = new SaveBlockSQL(this);
				saveGenesis.saveBlock(util.getGenisisBlock());
				
			}
			// open database,If the file doesn't exist yet, it will be created
			sqlConnection.addEventListener(SQLEvent.OPEN, doStatments);
			sqlConnection.openAsync(dbFile);
		}
		public function getState(str:String):SQLStatement
		{
			var state:SQLStatement = new SQLStatement();
			state.addEventListener(SQLEvent.RESULT, statResult, false, 0, true);
			state.addEventListener(SQLErrorEvent.ERROR, errorHandler, false, 0, true);
			state.sqlConnection = sqlConnection;
			state.text = str;
			return state;
		}
		
		public function getLastBlock():void
		{
			var getBlockCon:GetBlockSQL = new GetBlockSQL(this);
			getBlockCon.getLastBlock();
			
		}
		public function saveBlock(block:BlockVO):void
		{
			//need to check that this is the next block
			if(lastBlock == null)
			{
				//can't save untill we know what block is last
				getLastBlock();
			}else
			{
				if(ByteArrayUtil.toHexString(block.prev_block) == ByteArrayUtil.toHexString(lastBlock.hash))
				{
					var saveBlockCon:SaveBlockSQL = new SaveBlockSQL(this);
					saveBlockCon.saveBlock(block);
					
				}else
				{
					trace("not the next block, save to random table");
				}
				
			}
		}
		
		
		

	}
}