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

public class YouTube implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		
		Map<String, String> SearchUtil = request.getParams();
		
		LocalDate now = LocalDate.now(); 
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
		String today=now.format(formatter);

		String StartDate = SearchUtil.get("StartDate") != null ? SearchUtil.get("StartDate") : "19000101";						//시작 날짜
		String EndDate = SearchUtil.get("EndDate") != null ? SearchUtil.get("EndDate") : today;									//끝 날짜
		String cnt=	SearchUtil.get("cnt") != null ? SearchUtil.get("cnt") : "49";												//주요키워드 개수
		String Searchword=	SearchUtil.get("Searchword") != null ? SearchUtil.get("Searchword") : "";							//키워드
		String method=SearchUtil.get("method") != null ? SearchUtil.get("method") : "XQ";										//드라마 메소드
		String D_cnt=	SearchUtil.get("D_cnt") != null ? SearchUtil.get("D_cnt") : "49";										//연관키워드 개수
		String currentPage = SearchUtil.get("currentPage") != null ? SearchUtil.get("currentPage") : "1";						//현재 페이지
		String only_query=SearchUtil.get("only_query") != null ? SearchUtil.get("only_query") : "8";							//단일 쿼리 / 멀티 쿼리 구분  
		
		String[] search_range = { StartDate, EndDate };
		Query query = null;
		Query Drama_query = null;
		Query Direct_query = null;
		Query tag_query = null;
		Query imo_query = null;
		Query p_query = null;
		Query n_query = null;
		Query m_query = null;
		QuerySet querySet=null;
		
		int page = Integer.parseInt(currentPage);
		int startPage = 10 * (page - 1); 	// 0 10 20
		int endPage = (10 * page) - 1; 		// 9 19 29
		
		
		
		Map<String, String> params = new HashMap<String, String>();
		params.put("cnt", cnt);
		params.put("Searchword", Searchword);
		params.put("method", method);
		params.put("D_cnt", D_cnt);
		params.put("startPage", Integer.toString(startPage));
		params.put("endPage", Integer.toString(endPage));
		
		querySet = new QuerySet(1);
		if(only_query.equals("8")) {
			querySet = new QuerySet(8);
			for (int i = 0; i < 1; i++) {
				query = query_fn(search_range, params,i);
				Drama_query = query_fn(search_range, params,i+1);
				Direct_query = query_fn(search_range, params,i+2);
				tag_query = query_fn(search_range, params,i+3);
				imo_query = query_fn(search_range, params,i+4);
				p_query = query_fn(search_range, params,i+5);
				n_query = query_fn(search_range, params,i+6);
				m_query = query_fn(search_range, params,i+7);
				
			}	
			querySet.addQuery(query);
			querySet.addQuery(Drama_query);
			querySet.addQuery(Direct_query);
			querySet.addQuery(tag_query);
			querySet.addQuery(imo_query);
			querySet.addQuery(p_query);
			querySet.addQuery(n_query);
			querySet.addQuery(m_query);
		}else if(only_query.equals("인기")) {
			query = query_fn(search_range, params,0);
			querySet.addQuery(query);
		}else if(only_query.equals("연관도")) {
			Drama_query = query_fn(search_range, params,1);
			querySet.addQuery(Drama_query);
		}else if(only_query.equals("바로가기")) {
			Direct_query = query_fn(search_range, params,2);
			querySet.addQuery(Direct_query);
		}else if(only_query.equals("태그")) {
			tag_query = query_fn(search_range, params,3);
			querySet.addQuery(tag_query);
		}else if(only_query.equals("감성")) {
			imo_query = query_fn(search_range, params,4);
			querySet.addQuery(imo_query);
		}else if(only_query.equals("비율")) {
			querySet = new QuerySet(3);
			p_query = query_fn(search_range, params,5);
			n_query = query_fn(search_range, params,6);
			m_query = query_fn(search_range, params,7);
			querySet.addQuery(p_query);
			querySet.addQuery(n_query);
			querySet.addQuery(m_query);
		}
		

		return querySet;
	}

	private Query query_fn(String[] search_range, Map<String, String> params, int i) {
		Query query = new Query();
		if(i==0||i==3||i==4||i==5||i==6||i==7) {
			query.setResult(0, 0);
			query.setDebug(true);
			query.setPrintQuery(false);
			query.setFrom("CHUNGNAM_YOUTUBE");
			query.setLoggable(false);
			query.setGroupBy(groupSet_fn(params.get("cnt"),i));
			query.setFilter(filterSet_fn(search_range));
			query.setWhere(whereSet_fn(params,i));
		}else if (i==1) {
			query.setSearch(false);
			query.setFrom("CHUNGNAM_YOUTUBE");
			query.setValue("dramaCollection", "CHUNGNAM_YOUTUBE");
			query.setValue("dramaField", "MAIN_KEYWORD");
			if(params.get("Searchword").equals("")) {
				query.setValue("dramaKeyword", "충남");
			}else {
				
				query.setValue("dramaKeyword", params.get("Searchword"));
			}
			
			query.setValue("dramaOption", params.get("method"));
			query.setValue("dramaResultSize",params.get("D_cnt") );
			query.setResultModifier("drama");
			
		}else if(i==2) {
			int startPage= Integer.valueOf(params.get("startPage"));
			int endPage= Integer.valueOf(params.get("endPage"));
			query.setResult(startPage,endPage);
			query.setSelect(selectSet_fn());
			query.setDebug(true);
			query.setPrintQuery(false);
			query.setFrom("CHUNGNAM_YOUTUBE");
			query.setLoggable(false);
			query.setFilter(filterSet_fn(search_range));
			query.setWhere(whereSet_fn(params,i));
			query.setOrderby(orderSet_fn());
			//query.setGroupBy(groupSet_fn(params.get("cnt"),i));
			
			
			// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
			query.setSearchOption(
							(byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));

			// 동의어, 유의어 확장
			query.setThesaurusOption(
							(byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));
		}
		return query;
	}

	private OrderBySet[] orderSet_fn() {
		OrderBySet[] orderBySet = null;
		orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_DATE", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 최신순
		return orderBySet;
	}

	private SelectSet[] selectSet_fn() {
		SelectSet[] selectSet = new SelectSet[] {

				new SelectSet("TITLE",(byte) (Protocol.SelectSet.NONE)), 
				new SelectSet("DATE",(byte) (Protocol.SelectSet.NONE)), 
				new SelectSet("URL",(byte) (Protocol.SelectSet.NONE)),

			};
			return selectSet;
	}

	private WhereSet[] whereSet_fn(Map<String, String> params, int k) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		if(params.get("Searchword")!=null && !params.get("Searchword").equals("") ) {
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		whereList.add(new WhereSet("IDX_TITLE", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),1000)); 
		whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		whereList.add(new WhereSet("IDX_TITLE_B", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),50)); 
		whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		whereList.add(new WhereSet("IDX_CONTENT", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),50));
		whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		whereList.add(new WhereSet("IDX_TEG", Protocol.WhereSet.OP_HASALL, params.get("Searchword"),50));
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		}
		if(k==5) {
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_EPOTION_TYPE", Protocol.WhereSet.OP_HASALL, "긍정",50));
		}if(k==6) {
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_EPOTION_TYPE", Protocol.WhereSet.OP_HASALL, "부정",50));
		}if(k==7) {
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_EPOTION_TYPE", Protocol.WhereSet.OP_HASALL, "중립",50));
		}
		
		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
		return whereSet;
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
			GroupBySet=new GroupBySet[] {
					new GroupBySet ("GROUP_MAIN_KEYWORD", (byte) (Protocol.GroupBySet.ORDER_COUNT|Protocol.GroupBySet.OP_COUNT), "DESC 0 "+cnt, "")
			};
		}else if (i==3){
			GroupBySet=new GroupBySet[] {
					new GroupBySet ("GROUP_MAIN_KEYWORD2", (byte) (Protocol.GroupBySet.ORDER_COUNT|Protocol.GroupBySet.OP_COUNT), "DESC 0 "+cnt, "")
			};
					
		}else if(i==4) {
			GroupBySet=new GroupBySet[] {
					new GroupBySet ("GROUP_EPOTION_TYPE", (byte) (Protocol.GroupBySet.ORDER_COUNT|Protocol.GroupBySet.OP_COUNT), "DESC 0 "+cnt, ""),
					new GroupBySet ("GROUP_KEYWORD_POS", (byte) (Protocol.GroupBySet.ORDER_COUNT|Protocol.GroupBySet.OP_COUNT), "DESC 0 "+cnt, ""),
					new GroupBySet ("GROUP_KEYWORS_NEG", (byte) (Protocol.GroupBySet.ORDER_COUNT|Protocol.GroupBySet.OP_COUNT), "DESC 0 "+cnt, ""),
			};
			
		}else if(i==5||i==6||i==7) {
			GroupBySet=new GroupBySet[] {
					new GroupBySet ("GROUP_DATE_D", (byte) (Protocol.GroupBySet.ORDER_COUNT|Protocol.GroupBySet.OP_COUNT), "ASC", "")
			};
			
		}
		
		return GroupBySet;
	}

}
