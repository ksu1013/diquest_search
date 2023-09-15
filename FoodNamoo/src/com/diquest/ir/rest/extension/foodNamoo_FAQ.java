package com.diquest.ir.rest.extension;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.OrderBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QueryParser;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;
import com.diquest.ir.rest.extension.QuerySetExtension;

public class foodNamoo_FAQ implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		
		Map<String, String> SearchUtil = request.getParams();
		
		String sch = SearchUtil.get("sch") != null ? SearchUtil.get("sch") : "";									// 검색어
		String type = SearchUtil.get("type") != null ? SearchUtil.get("type") : "all";								// 타입(전체/주문결제/배송/포인트/기타)
		String codenm = SearchUtil.get("codenm") != null ? SearchUtil.get("codenm") : "all";						// 코드네임(전체/주문결제/배송/포인트/기타)
		String currentPage = SearchUtil.get("currentPage") != null ? SearchUtil.get("currentPage") : "1";			// 페이지		
		String regdt = SearchUtil.get("regdt") != null ? SearchUtil.get("regdt") : "desc";							// 최신순
		
		Map<String, String> foodsch=new HashMap<String, String>();
		
		foodsch.put("sch", sch);
		foodsch.put("type", type);
		foodsch.put("codenm", codenm);
		foodsch.put("currentPage", currentPage);
		foodsch.put("regdt", regdt);
		
		
		QuerySet querySet = null;
		querySet = new QuerySet(1);
		
		
		Query faq_query = null; 	// 전체쿼리
		Query prdt_query = null; 	// 상품쿼리
		Query oder_query = null; 	// 주문및결제쿼리
		Query bsg_query = null; 	// 배송관련쿼리
		Query pint_query = null; 	// 포인트쿼리
		Query kita_query = null; 	// 기타쿼리
		
		if(codenm.equals("all")||type.equals("all")) {
			faq_query=query_fn(foodsch);
			querySet.addQuery(faq_query);
		}else if(codenm.equals("product")||type.equals("F001")) {
			prdt_query=query_fn(foodsch);
			querySet.addQuery(prdt_query);
		}else if(codenm.equals("oder")||type.equals("F002")) {
			oder_query=query_fn(foodsch);
			querySet.addQuery(oder_query);
		}else if(codenm.equals("bsg")||type.equals("F003")) {
			bsg_query=query_fn(foodsch);
			querySet.addQuery(bsg_query);
		}else if(codenm.equals("point")||type.equals("F004")) {
			pint_query=query_fn(foodsch);
			querySet.addQuery(pint_query);
		}else if(codenm.equals("kita")||type.equals("F005")) {
			kita_query=query_fn(foodsch);
			querySet.addQuery(kita_query);
		}
		
		return querySet;
		
	}

	public static Query query_fn(Map<String, String> foodsch) {
		
		int page2 = Integer.parseInt(foodsch.get("currentPage"));
		int startPage = (page2 - 1) * 10;     
		int endPage = startPage+9;
		
		char[] startTag = "<b><u>".toCharArray();
		char[] endTag = "</u></b>".toCharArray();
		
		QueryParser queryParser = new QueryParser();
		
		Query query = new Query(startTag,endTag);
		query.setResult(startPage, endPage);
		query.setDebug(true);
		query.setPrintQuery(false);
		query.setFrom("FAQ");
		query.setLoggable(true);
		query.setLogKeyword(foodsch.get("sch").toCharArray());
		query.setSelect(selectSet_fn(foodsch));
		query.setWhere(whereSet_fn(foodsch));
		query.setOrderby(orderSet_fn(foodsch));
	
		

		// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
		query.setSearchOption(
				(byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));

		// 동의어, 유의어 확장
		query.setThesaurusOption(
				(byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));

		
		//System.out.println("::::queryParser::::\n"+queryParser.queryToString(query));
		return query;
		
	}

	private static OrderBySet[] orderSet_fn(Map<String, String> foodsch) {
		OrderBySet[] orderBySet = null;
		
		orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_D_REG_DTM", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 최신순
		
		return orderBySet;
	}

	private static WhereSet[] whereSet_fn(Map<String, String> foodsch) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		
		if(!foodsch.get("sch").equals("")) {
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
			whereList.add(new WhereSet("IDX_V_FAQ_TITLE", Protocol.WhereSet.OP_HASALL, foodsch.get("sch")));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
			whereList.add(new WhereSet("IDX_V_FAQ_TITLE_BI", Protocol.WhereSet.OP_HASALL, foodsch.get("sch")));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
			whereList.add(new WhereSet("IDX_V_DESC_PC", Protocol.WhereSet.OP_HASALL, foodsch.get("sch")));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			if(!foodsch.get("codenm").equals("all")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet("IDX_V_SUB_CODENM", Protocol.WhereSet.OP_HASALL, foodsch.get("codenm")));
				
			}else if(!foodsch.get("type").equals("all")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet("IDX_V_FAQ_TYPE", Protocol.WhereSet.OP_HASALL, foodsch.get("type")));
				
			}
		}else if(!foodsch.get("codenm").equals("all")) {
			whereList.add(new WhereSet("IDX_V_SUB_CODENM", Protocol.WhereSet.OP_HASALL, foodsch.get("codenm")));
		}else if(!foodsch.get("type").equals("all")) {
			whereList.add(new WhereSet("IDX_V_FAQ_TYPE", Protocol.WhereSet.OP_HASALL, foodsch.get("type")));
		}
		
	
		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
	
		return whereSet;
	}

	private static SelectSet[] selectSet_fn(Map<String, String> foodsch) {
		SelectSet[] selectSet = new SelectSet[] {

				new SelectSet("D_REG_DTM",(byte) (Protocol.SelectSet.NONE)), 
				new SelectSet("V_BEST_YN",(byte) (Protocol.SelectSet.NONE)), 
				new SelectSet("V_DESC_MOBILE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_DESC_PC", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("V_FAQID", (byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_FAQ_TITLE",(byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("V_FAQ_TYPE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_SHOW_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_SITECD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_SUB_CODE1",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_SUB_CODENM",(byte) (Protocol.SelectSet.NONE))

			};
			return selectSet;
	}
	
	
}
