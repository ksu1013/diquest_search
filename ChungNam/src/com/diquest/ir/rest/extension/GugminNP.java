package com.diquest.ir.rest.extension;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.FilterSet;
import com.diquest.ir.common.msg.protocol.query.GroupBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;


public class GugminNP implements QuerySetExtension {


	@Override
	public void init() {
	

	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {

		Map<String, String> SearchUtil = request.getParams();

		LocalDate now = LocalDate.now();
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
		String today = now.format(formatter);

		String StartDate = SearchUtil.get("StartDate") != null ? SearchUtil.get("StartDate") : "19000101"; 						//시작 날짜
		String EndDate = SearchUtil.get("EndDate") != null ? SearchUtil.get("EndDate") : today; 								//끝 날짜
		String cnt = SearchUtil.get("cnt") != null ? SearchUtil.get("cnt") : "49";												//주요키워드 개수
		String Key_Searchword=	SearchUtil.get("Key_Searchword") != null ? SearchUtil.get("Key_Searchword") : "충청남도";			//키워드랭킹_키워드
		String Searchword1=	SearchUtil.get("Searchword1") != null ? SearchUtil.get("Searchword1") : "충청남도";					//키워드(ex)충청남도)
		String Searchword2=	SearchUtil.get("Searchword2") != null ? SearchUtil.get("Searchword2") : "";							//키워드(ex)천안시,아산시,당진시...)
		String method=SearchUtil.get("method") != null ? SearchUtil.get("method") : "XQ";										//드라마 메소드
		String D_cnt=	SearchUtil.get("D_cnt") != null ? SearchUtil.get("D_cnt") : "49";										//연관키워드 개수
		String only_query=SearchUtil.get("only_query") != null ? SearchUtil.get("only_query") : "2";							//단일 쿼리 / 멀티 쿼리 구분  
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("cnt", cnt);
		params.put("Key_Searchword", Key_Searchword);
		params.put("Searchword1", Searchword1);
		params.put("Searchword2", Searchword2);
		params.put("method", method);
		params.put("D_cnt", D_cnt);
		
		
		String[] search_range = { StartDate, EndDate };
		Query drama_query = null;
		Query topciker_query = null;
		QuerySet querySet = null;
		querySet = new QuerySet(1);
		if(only_query.equals("2")) {
			querySet = new QuerySet(2);
			for (int i = 0; i < 1; i++) {
				topciker_query = query_fn(search_range, params,i+1);
				drama_query = query_fn(search_range, params,i+2);
				
			}
			querySet.addQuery(topciker_query);
			querySet.addQuery(drama_query);
		}else if(only_query.equals("topciker")) {
			topciker_query = query_fn(search_range, params,1);
			querySet.addQuery(topciker_query);
		}else if(only_query.equals("drama")) {
			drama_query = query_fn(search_range, params,2);
			querySet.addQuery(drama_query);
		}
		
		return querySet;
	}

	private Query query_fn(String[] search_range, Map<String, String> params,int i) {
		Query query = new Query();
			if(i==1) {
				query.setResult(0, 0);
				query.setDebug(true);
				query.setPrintQuery(false);
				query.setFrom("EPEOPLE");
				query.setLoggable(false);
				query.setGroupBy(groupSet_fn(params,i));
				query.setFilter(filterSet_fn(search_range));
				query.setWhere(whereSet_fn(params));
				
			}else if (i==2) {
				query.setSearch(false);
				query.setDebug(true);
				query.setFrom("EPEOPLE");
				query.setValue("dramaCollection", "CHUNGNAM_GUGMINNP");
				query.setValue("dramaField", "MAIN_KEYWORD");
				query.setValue("dramaKeyword", params.get("Key_Searchword"));
				query.setValue("dramaOption", params.get("method"));
				query.setValue("dramaResultSize",params.get("D_cnt") );
				query.setResultModifier("drama");
				
			}
		
		return query;
	}

	private FilterSet[] filterSet_fn(String[] search_range) {
		FilterSet[] filterSet = new FilterSet[] {

				new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_REG_DT_D", search_range)

		};
		return filterSet;
	}

	private GroupBySet[] groupSet_fn(Map<String, String> params, int i) {
		GroupBySet[] GroupBySet = null;
		
			GroupBySet = new GroupBySet[] { new GroupBySet("GROUP_MAIN_KEYWORD",
					(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + params.get("cnt"), "")};
			
					
		
		
		return GroupBySet;
	}

	private WhereSet[] whereSet_fn(Map<String, String> params) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		whereList.add(new WhereSet("IDX_REGION1", Protocol.WhereSet.OP_HASALL, params.get("Searchword1"),50)); 
		if(!params.get("Searchword2").equals("")) {
			whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_REGION2", Protocol.WhereSet.OP_HASALL, params.get("Searchword2"),50)); 
		}
		
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));	
				
		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
	
		return whereSet;
	}

	
	

}
