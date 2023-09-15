package com.diquest.ir.rest.extension;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.FilterSet;
import com.diquest.ir.common.msg.protocol.query.GroupBySet;
import com.diquest.ir.common.msg.protocol.query.OrderBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;

public class News implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub

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
		String menu=SearchUtil.get("menu") != null ? SearchUtil.get("menu") : "all";											//메뉴
		String type=SearchUtil.get("type") != null ? SearchUtil.get("type") : "중앙지";											//타입
		String Searchword=	SearchUtil.get("Searchword") != null ? SearchUtil.get("Searchword") : "";							//키워드
		String method=SearchUtil.get("method") != null ? SearchUtil.get("method") : "XQ";										//드라마 메소드
		String D_cnt=	SearchUtil.get("D_cnt") != null ? SearchUtil.get("D_cnt") : "49";										//연관키워드 개수
		String currentPage = SearchUtil.get("currentPage") != null ? SearchUtil.get("currentPage") : "1";						//현재 페이지
		String only_query=SearchUtil.get("only_query") != null ? SearchUtil.get("only_query") : "5";							//단일 쿼리 / 멀티 쿼리 구분  
		
		int page = Integer.parseInt(currentPage);
		
		int startPage = 10 * (page - 1); // 0 10 20
		int endPage = (10 * page) - 1; // 9 19 29
		
		
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("cnt", cnt);
		params.put("menu", menu);
		params.put("type", type);
		params.put("Searchword", Searchword);
		params.put("method", method);
		params.put("D_cnt", D_cnt);
		params.put("startPage", Integer.toString(startPage));
		params.put("endPage", Integer.toString(endPage));
		
		
		String[] search_range = { StartDate, EndDate };
		Query query = null;
		Query Drama_query = null;
		Query op_query = null;
		Query Direct_query = null;
		Query imo_query = null;
		QuerySet querySet = null;
		querySet = new QuerySet(1);
		if(only_query.equals("5")) {
			querySet = new QuerySet(5);
			for (int i = 0; i < 1; i++) {
				query = query_fn(search_range, params,i);
				Drama_query = query_fn(search_range, params,i+1);
				Direct_query = query_fn(search_range, params,i+2);
				op_query = query_fn(search_range, params,i+3);
				imo_query = query_fn(search_range, params,i+4);
				
			}
			querySet.addQuery(query);
			querySet.addQuery(Drama_query);
			querySet.addQuery(Direct_query);
			querySet.addQuery(op_query);
			querySet.addQuery(imo_query);
		}else if(only_query.equals("인기")) {
			query = query_fn(search_range, params,0);
			querySet.addQuery(query);
		}else if(only_query.equals("연관도")) {
			Drama_query = query_fn(search_range, params,1);
			querySet.addQuery(Drama_query);
		}else if(only_query.equals("바로가기")) {
			Direct_query = query_fn(search_range, params,2);
			querySet.addQuery(Direct_query);
		}else if(only_query.equals("인물")) {
			op_query = query_fn(search_range, params,3);
			querySet.addQuery(op_query);
		}else if(only_query.equals("감성")) {
			imo_query = query_fn(search_range, params,4);
			querySet.addQuery(imo_query);
		}
		
		return querySet;
	}



	private Query query_fn(String[] search_range, Map<String, String> params,int i) {
		Query query = new Query();
		if(i==0) {
			query.setResult(0, 0);
			query.setDebug(true);
			query.setPrintQuery(false);
			query.setFrom("CHUNGNAM_NEWS");
			//query.setFrom("CHUNGNAM");
			query.setLoggable(true);
			query.setGroupBy(groupSet_fn(params.get("cnt"),i));
			query.setFilter(filterSet_fn(search_range));
			query.setWhere(whereSet_fn(params));
		}else if (i==1) {
			query.setSearch(false);
			query.setDebug(true);
			query.setFrom("CHUNGNAM_NEWS");
			//query.setFrom("CHUNGNAM");
			query.setValue("dramaCollection", "CHUNGNAM_NEWS");
			query.setValue("dramaField", "MAIN_KEYWORD");
			if(params.get("Searchword").equals("")) {
				query.setValue("dramaKeyword", "충남");
			}else {
				query.setValue("dramaKeyword", params.get("Searchword"));
			}
			
			query.setValue("dramaOption", params.get("method"));
			query.setValue("dramaResultSize",params.get("D_cnt") );
			query.setResultModifier("drama");
			
		}else if(i==2||i==3||i==4) {
			query.setResult(0,0);
			query.setDebug(true);
			query.setPrintQuery(false);
			query.setFrom("CHUNGNAM_NEWS");
			//query.setFrom("CHUNGNAM");
			query.setLoggable(true);
			if(i==2) {
				int startPage= Integer.valueOf(params.get("startPage"));
				int endPage= Integer.valueOf(params.get("endPage"));
				query.setResult(startPage,endPage);
				query.setSelect(selectSet_fn());
				query.setOrderby(orderSet_fn());
			}
			//if(!params.get("Searchword").equals(""))query.setWhere(whereSet_fn(params));
			query.setWhere(whereSet_fn(params));
			query.setFilter(filterSet_fn(search_range));
			if(i==3||i==4) {
				query.setGroupBy(groupSet_fn(params.get("cnt"),i));
			}
			
			// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
			query.setSearchOption(
							(byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));

			// 동의어, 유의어 확장
			query.setThesaurusOption(
							(byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));
			
		}
		return query;
	}

	private FilterSet[] filterSet_fn(String[] search_range) {
		FilterSet[] filterSet = new FilterSet[] {

				new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_DATE", search_range)

		};
		return filterSet;
	}

	private GroupBySet[] groupSet_fn(String cnt, int i) {
		GroupBySet[] GroupBySet = null;
		if(i==0) {
			GroupBySet = new GroupBySet[] { new GroupBySet("GROUP_MAIN_KEYWORD",
					(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + cnt, "")};
		}else if(i==3) {
			GroupBySet = new GroupBySet[] { 
					new GroupBySet("GROUP_KEYWORD_PERSON",
							(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + cnt, ""),
					new GroupBySet("GROUP_KEYWORD_ORGAN",
							(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + cnt, "")
			};
			
		}else if(i==4) {
			GroupBySet = new GroupBySet[] { 
					new GroupBySet("GROUP_EPOTION_TYPE",
							(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "ASC", ""),
					new GroupBySet("GROUP_KEYWORD_POS",
							(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + cnt, ""),
					new GroupBySet("GROUP_KEYWORS_NEG",
							(byte) (Protocol.GroupBySet.ORDER_COUNT | Protocol.GroupBySet.OP_COUNT), "DESC 0 " + cnt, "")
			};
			
		}
		
		return GroupBySet;
	}

	private SelectSet[] selectSet_fn() {
		SelectSet[] selectSet = new SelectSet[] {

				new SelectSet("TITLE", (byte) (Protocol.SelectSet.NONE)),
				new SelectSet("DATE", (byte) (Protocol.SelectSet.NONE)),
				new SelectSet("URL", (byte) (Protocol.SelectSet.NONE)),
				new SelectSet("WEIGHT", (byte) (Protocol.SelectSet.NONE))

		};
		return selectSet;
	}
	
	private WhereSet[] whereSet_fn(Map<String, String> params) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		
		if(params.get("menu").equals("all")) {
			if(!params.get("Searchword").equals("")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_TITLE", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),1000)); 
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_TITLE_B", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),50)); 
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_CONTENT", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),50));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));	
				
			}
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_TYPE", Protocol.WhereSet.OP_HASALL, params.get("type"),50));
		}else {
			if(!params.get("Searchword").equals("")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_TITLE", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),1000)); 
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_TITLE_B", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),50)); 
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_CONTENT", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),50));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
				
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_MENU", Protocol.WhereSet.OP_HASANY, params.get("menu"),50)); 
			whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_TYPE", Protocol.WhereSet.OP_HASALL, params.get("type"),50)); 
		}	
		
		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
	
		return whereSet;
	}
	
	private OrderBySet[] orderSet_fn() {
		OrderBySet[] orderBySet = null;
		
		orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_DATE", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 최신순
		

		return orderBySet;
		
	}

}
