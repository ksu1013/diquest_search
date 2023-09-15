package com.diquest.ir.rest.extension;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;


import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.FilterSet;
import com.diquest.ir.common.msg.protocol.query.GroupBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;

public class GugminNP_sub implements QuerySetExtension{
	
	@Override
	public void init() {

	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {

		Map<String, String> SearchUtil = request.getParams();
		Calendar cal = Calendar.getInstance();
		LocalDate now = LocalDate.now();
															//30일전
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
		String today = now.format(formatter);

		String StartDate = SearchUtil.get("StartDate") != null ? SearchUtil.get("StartDate") : "19000101"; 						//시작 날짜
		String EndDate = SearchUtil.get("EndDate") != null ? SearchUtil.get("EndDate") : today; 								//끝 날짜
		String cnt = SearchUtil.get("cnt") != null ? SearchUtil.get("cnt") : "49";												//주요키워드 개수
		String Key_Searchword=	SearchUtil.get("Key_Searchword") != null ? SearchUtil.get("Key_Searchword") : "";				//키워드랭킹_키워드
		String Searchword1=	SearchUtil.get("Searchword1") != null ? SearchUtil.get("Searchword1") : "충청남도";					//키워드(ex)충청남도)
		String Searchword2=	SearchUtil.get("Searchword2") != null ? SearchUtil.get("Searchword2") : "";							//키워드(ex)천안시,아산시,당진시...)
		String method=SearchUtil.get("method") != null ? SearchUtil.get("method") : "XQ";										//드라마 메소드
		String D_cnt=	SearchUtil.get("D_cnt") != null ? SearchUtil.get("D_cnt") : "49";										//연관키워드 개수
		
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("cnt", cnt);
		params.put("Key_Searchword", Key_Searchword);
		params.put("Searchword1", Searchword1);
		params.put("Searchword2", Searchword2);
		params.put("method", method);
		params.put("D_cnt", D_cnt);
		
		Query topciker_query = null;
		Query topciker_query1 = null;
		Query topciker_query2 = null;
		Query topciker_query3 = null;
		Query topciker_query4 = null;
		Query topciker_query5 = null;
		Query topciker_query6 = null;
		
		QuerySet querySet = null;
		querySet = new QuerySet(7);
		String[]search_range;
		search_range = new String[2];
		search_range[0]=StartDate;
		search_range[1]=EndDate;
		topciker_query = query_fn(search_range, params);
		String StartDate2=null;
		cal.set(Calendar.YEAR, Integer.parseInt(EndDate.substring(0, 4)));
		cal.set(Calendar.MONTH, Integer.parseInt(EndDate.substring(4, 6))-1);
		cal.set(Calendar.DATE, Integer.parseInt(EndDate.substring(6, 8)));
		SimpleDateFormat sdformat = new SimpleDateFormat("yyyyMMdd");
		StartDate2 = sdformat.format(cal.getTime());
		
		for (int i = 0; i < 6; i++) {
			
			cal.add(Calendar.MONTH, -i);
			
			cal.set(Calendar.DAY_OF_MONTH,1); 
			StartDate = sdformat.format(cal.getTime());
			
			cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH)); //말일 구하기

			if(i==0) {
				EndDate=StartDate2;
			}else {
				
				EndDate=sdformat.format(cal.getTime());
			}
			
			cal.add(Calendar.MONTH,+i);
			
			
			
			search_range = new String[2];
			search_range[0]=StartDate;
			search_range[1]=EndDate;
			if(i==0) {
				topciker_query1 = query_fn(search_range, params);
			}else if(i==1) {
				topciker_query2 = query_fn(search_range, params);
				
			}else if (i==2) {
				
				topciker_query3 = query_fn(search_range, params);
			}else if (i==3) {
				
				topciker_query4 = query_fn(search_range, params);
			}else if (i==4) {
				
				topciker_query5 = query_fn(search_range, params);
			}else if (i==5) {
				
				topciker_query6 = query_fn(search_range, params);
			}
			
			
		}
		querySet.addQuery(topciker_query);
		querySet.addQuery(topciker_query1);
		querySet.addQuery(topciker_query2);
		querySet.addQuery(topciker_query3);
		querySet.addQuery(topciker_query4);
		querySet.addQuery(topciker_query5);
		querySet.addQuery(topciker_query6);
		return querySet;
		
		
	}



	private Query query_fn(String[] search_range, Map<String, String> params) {
		Query query = new Query();
			query.setResult(0, 0);
			query.setDebug(true);
			query.setPrintQuery(false);
			query.setFrom("EPEOPLE");
			query.setLoggable(false);
			query.setGroupBy(groupSet_fn(params.get("cnt")));
			query.setFilter(filterSet_fn(search_range));
			query.setWhere(whereSet_fn(params));
			
		return query;
	}

	private FilterSet[] filterSet_fn(String[] search_range) {
		FilterSet[] filterSet = new FilterSet[] {

				new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_REG_DT_D", search_range)

		};
		return filterSet;
	}

	private GroupBySet[] groupSet_fn(String cnt) {
		GroupBySet[] GroupBySet = null;
			GroupBySet = new GroupBySet[] { new GroupBySet("GROUP_MAIN_KEYWORD",
					(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + cnt, "")};
			
		return GroupBySet;
	}

	private WhereSet[] whereSet_fn(Map<String, String> params) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		whereList.add(new WhereSet("IDX_TYPE", Protocol.WhereSet.OP_HASALL, "EPOUMB",50)); 
		whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
		whereList.add(new WhereSet("IDX_REGION1", Protocol.WhereSet.OP_HASALL, params.get("Searchword1"),50)); 
		if(!params.get("Searchword2").equals("")) {
			whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_REGION2", Protocol.WhereSet.OP_HASALL, params.get("Searchword2"),50)); 
		}
		if(!params.get("Key_Searchword").equals("")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet("IDX_CATEGORY_CODE", Protocol.WhereSet.OP_HASALL, params.get("Key_Searchword"),50)); 
		}
		
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));	
				
		
			
		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for (int k = 0; k < whereSet.length; k++) {
			whereSet[k] = whereList.get(k);
		}
	
		return whereSet;
	}

	
		
	
	

}
