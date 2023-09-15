package com.diquest.ir.rest.extension;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.FilterSet;
import com.diquest.ir.common.msg.protocol.query.GroupBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.rest.common.object.RestHttpRequest;

public class CallCenter implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub

	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		Map<String, String> SearchUtil = request.getParams();
		Calendar cal = Calendar.getInstance();
		LocalDate now = LocalDate.now();
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
		String today = now.format(formatter);

		String StartDate = SearchUtil.get("StartDate") != null ? SearchUtil.get("StartDate") : "19000101"; 						//시작 날짜
		String EndDate = SearchUtil.get("EndDate") != null ? SearchUtil.get("EndDate") : today; 								//끝 날짜
		String cnt = SearchUtil.get("cnt") != null ? SearchUtil.get("cnt") : "49";												//주요키워드 개수
		String Key_Searchword=	SearchUtil.get("Key_Searchword") != null ? SearchUtil.get("Key_Searchword") : "충청남도";						//키워드랭킹_키워드
		String method=SearchUtil.get("method") != null ? SearchUtil.get("method") : "XQ";										//드라마 메소드
		String D_cnt=	SearchUtil.get("D_cnt") != null ? SearchUtil.get("D_cnt") : "49";										//연관키워드 개수
		String only_query=SearchUtil.get("only_query") != null ? SearchUtil.get("only_query") : "8";							//단일 쿼리 / 멀티 쿼리 구분  
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("cnt", cnt);
		params.put("Key_Searchword", Key_Searchword);
		params.put("method", method);
		params.put("D_cnt", D_cnt);
		
		
		String[]search_range;
		search_range = new String[2];
		search_range[0]=StartDate;
		search_range[1]=EndDate;
		Query drama_query = null;
		Query topciker_query = null;
		Query topciker_query1 = null;
		Query topciker_query2 = null;
		Query topciker_query3 = null;
		Query topciker_query4 = null;
		Query topciker_query5 = null;
		Query topciker_query6 = null;
		QuerySet querySet = null;
		String StartDate2=null;
		cal.set(Calendar.YEAR, Integer.parseInt(EndDate.substring(0, 4)));
		cal.set(Calendar.MONTH, Integer.parseInt(EndDate.substring(4, 6))-1);
		SimpleDateFormat sdformat = new SimpleDateFormat("yyyyMMdd");
		StartDate2 = sdformat.format(cal.getTime());
		querySet = new QuerySet(1);
		
		if(only_query.equals("8")) {
			querySet = new QuerySet(8);
			for (int i = 0; i < 1; i++) {
				topciker_query = query_fn(search_range, params,i+1);
				drama_query = query_fn(search_range, params,i+2);
				for (int j = 0; j < 6; j++) {
					cal.add(Calendar.MONTH, -j);
					
					cal.set(Calendar.DAY_OF_MONTH,1); 
					StartDate = sdformat.format(cal.getTime());
					
					cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH)); //말일 구하기

					if(j==0) {
						EndDate=StartDate2;
					}else {
						
						EndDate=sdformat.format(cal.getTime());
						
					}
					cal.add(Calendar.MONTH,+j);
					
					search_range = new String[2];
					search_range[0]=StartDate;
					search_range[1]=EndDate;
					if(j==0) {
						topciker_query1 = query_fn(search_range, params,3);
					}else if(j==1) {
						topciker_query2 = query_fn(search_range, params,3);
						
					}else if (j==2) {
						
						topciker_query3 = query_fn(search_range, params,3);
					}else if (j==3) {
						
						topciker_query4 = query_fn(search_range, params,3);
					}else if (j==4) {
						
						topciker_query5 = query_fn(search_range, params,3);
					}else if (j==5) {
						
						topciker_query6 = query_fn(search_range, params,3);
					}
				}
				
			}
			
			
			querySet.addQuery(topciker_query);
			querySet.addQuery(topciker_query1);
			querySet.addQuery(topciker_query2);
			querySet.addQuery(topciker_query3);
			querySet.addQuery(topciker_query4);
			querySet.addQuery(topciker_query5);
			querySet.addQuery(topciker_query6);
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
			if(i==1||i==3) {
				query.setResult(0, 0);
				query.setDebug(true);
				query.setFrom("CALLCENTER_CHUNGNAM");
				query.setLoggable(false);
				query.setGroupBy(groupSet_fn(params,i));
				query.setFilter(filterSet_fn(search_range,i));
				
			}else if (i==2) {
				query.setSearch(false);
				query.setDebug(true);
				query.setFrom("CALLCENTER_CHUNGNAM");
				query.setValue("dramaCollection", "CHUNGNAM_120");
				query.setValue("dramaField", "MAIN_KEYWORD");
				query.setValue("dramaKeyword", params.get("Key_Searchword"));
				query.setValue("dramaOption", params.get("method"));
				query.setValue("dramaResultSize",params.get("D_cnt") );
				query.setResultModifier("drama");
				
			}
		
		return query;
	}

	private FilterSet[] filterSet_fn(String[] search_range, int i) {
		FilterSet[] filterSet =null;
		if(i==1) {
			filterSet= new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_DATE_M", search_range)};
		}else {
			filterSet=new  FilterSet[] {new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_DATE_D", search_range)};
		}
		//filterSet= new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_DATE_M", search_range)};
		return filterSet;
	}

	private GroupBySet[] groupSet_fn(Map<String, String> params, int i) {
		GroupBySet[] GroupBySet = null;
		
			GroupBySet = new GroupBySet[] { new GroupBySet("GROUP_MAIN_KEYWORD",
					(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + params.get("cnt"), "")};
			
		return GroupBySet;
	}


}
