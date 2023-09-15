package m4.extension;

import java.util.ArrayList;
import java.util.Map;

import com.diquest.ir.client.command.CommandSearchRequest;
import com.diquest.ir.common.exception.IRException;
import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.common.msg.protocol.result.Result;
import com.diquest.ir.common.msg.protocol.result.ResultSet;

public class initialReload {
	public static void main(String[] args) throws Exception {
		initialReload();
	}
	
	public static void initialReload(){
		String searchIp = "172.19.90.10";  
		int searchPort = 5555;
		
		String searchIp2 = "172.19.91.10";  
		int searchPort2 = 5555;
		
	

		CommandSearchRequest command = null;
		Result[] resultlist = null;
		
		SelectSet[] selectSet_log = new SelectSet[] {new SelectSet("ALL",(byte) (Protocol.SelectSet.NONE))};
		
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		
		whereList.add(new WhereSet("IDX_ALL", Protocol.WhereSet.OP_HASALL, "A"));
		
		
		WhereSet[] whereSet_log = null;
		whereSet_log = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet_log.length; i++) {
			whereSet_log[i] = whereList.get(i);
		}
		
		Query query = new Query("", "");
		
		QuerySet querySet = null;
		querySet = new QuerySet(1);
		
		query.setSearch(false);
		query.setFrom("MAIN"); 
		query.setSelect(selectSet_log);
		query.setWhere(whereSet_log); 
		query.setResultModifier("typo");
		query.setValue("typo-reload-model", "true");
		query.setValue("typo-options", "ALPHABETS_TO_HANGUL | HANGUL_TO_HANGUL | REMOVE_HANGUL_JAMO_ALL | CORRECT_HANGUL_SPELL");
		query.setResult(0, 0);
		query.setDebug(true);
		querySet.addQuery(query);
		
		int returnCode = 0;
		try {
			command = new CommandSearchRequest(searchIp, searchPort);
			returnCode = command.request(querySet);
			
			command = new CommandSearchRequest(searchIp2, searchPort2);
			returnCode = command.request(querySet);
			
			if (returnCode > 0) {
				System.out.println("initialReload Success");
			
			} else {
			
			}
		} catch (IRException e) {
			e.printStackTrace();
		}

	}
}
