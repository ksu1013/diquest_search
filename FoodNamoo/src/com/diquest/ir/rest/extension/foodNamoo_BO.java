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

public class foodNamoo_BO implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		Map<String, String> SearchUtil = request.getParams();
		
		String sch = SearchUtil.get("sch") != null ? SearchUtil.get("sch") : "";									// 검색어
		String currentPage = SearchUtil.get("currentPage") != null ? SearchUtil.get("currentPage") : "1";			// 페이지		
		String regdt = SearchUtil.get("regdt") != null ? SearchUtil.get("regdt") : "desc";							// 최신순
		String rownm = SearchUtil.get("rownm") != null ? SearchUtil.get("rownm") : "20";							// 페이지당 노출개수
		String schtype = SearchUtil.get("schtype") != null ? SearchUtil.get("schtype") : "all";						// 상태(전체/품절..등등)
		
		Map<String, String> foodsch=new HashMap<String, String>();
		
		foodsch.put("sch", sch);
		foodsch.put("regdt", regdt);
		foodsch.put("rownm", rownm);
		foodsch.put("currentPage", currentPage);
		foodsch.put("schtype", schtype);
		
		
		QuerySet querySet = null;
		querySet = new QuerySet(1);
		
		
		Query bo_query = null; 		// 전체쿼리
		Query bo_query2 = null; 	// 상품구분- 100
		Query bo_query3 = null; 	// 상품구분- 200
		Query bo_query4 = null; 	// 상품구분- 300
		Query bo_query5 = null; 	// 상품구분- 999
		
		if(schtype.equals("all")) {
			bo_query=query_fn(foodsch);
			querySet.addQuery(bo_query);
		}else if(schtype.equals("100")) {  //정상
			bo_query2=query_fn(foodsch);
			querySet.addQuery(bo_query2);
		}else if(schtype.equals("200")) {   //강제품절
			bo_query3=query_fn(foodsch);
			querySet.addQuery(bo_query3);
		}else if(schtype.equals("300")) {  //판매중지
			bo_query4=query_fn(foodsch);
			querySet.addQuery(bo_query4);
		}else if(schtype.equals("999")) {  //픔절
			bo_query5=query_fn(foodsch);
			querySet.addQuery(bo_query5);
		}
		
		
		
		return querySet;
	}

	private Query query_fn(Map<String, String> foodsch) {
		int page2 = Integer.parseInt(foodsch.get("currentPage"));
		int page3 = Integer.parseInt(foodsch.get("rownm"));
		int startPage = (page2 - 1) * page3;     
		int endPage = startPage+(page3-1);
		
		char[] startTag = "<b><u>".toCharArray();
		char[] endTag = "</u></b>".toCharArray();
		
		QueryParser queryParser = new QueryParser();
		
		Query query = new Query(startTag,endTag);
		query.setResult(startPage, endPage);
		query.setDebug(true);
		query.setPrintQuery(false);
		query.setFrom("BO");
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

	private OrderBySet[] orderSet_fn(Map<String, String> foodsch) {
		OrderBySet[] orderBySet = null;
		
		orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_D_REG_DTM", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 최신순
		
		return orderBySet;
	}

	private WhereSet[] whereSet_fn(Map<String, String> foodsch) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		if(!foodsch.get("sch").equals("")) {
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
			whereList.add(new WhereSet("IDX_V_PRODUCTNM", Protocol.WhereSet.OP_HASALL, foodsch.get("sch")));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
			whereList.add(new WhereSet("IDX_V_PRODUCTNM_BI", Protocol.WhereSet.OP_HASALL, foodsch.get("sch")));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			if(!foodsch.get("schtype").equals("all")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet("IDX_V_STATUS", Protocol.WhereSet.OP_HASALL, foodsch.get("schtype")));
			}
		}
		
		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
		
		return whereSet;
	}

	private SelectSet[] selectSet_fn(Map<String, String> foodsch) {
		SelectSet[] selectSet = new SelectSet[] {

				new SelectSet("D_REG_DTM",(byte) (Protocol.SelectSet.NONE)), 
				new SelectSet("N_DLV_MAX_CNT",(byte) (Protocol.SelectSet.NONE)), 
				new SelectSet("N_DLV_MIN_CNT",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("N_INFLU_RATE", (byte) (Protocol.SelectSet.NONE)),
				new SelectSet("N_NUM", (byte) (Protocol.SelectSet.NONE)),
				new SelectSet("N_POINT_RATE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("N_PRICE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("N_SALE_PRICE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("N_SALE_RATE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("N_STOCK",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_ADDPROD_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_ADD_BENEFITSCD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_BIZNM",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_BRAND_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_CATEGORY1NM",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_CATEGORY2NM",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_CATEGORY3NM",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_CATEGORYCD1",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_CATEGORYCD2",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_CATEGORYCD3",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_COMPANY_TYPE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_COMPARE_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_CONNECT_NM",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_COUPON_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_DLV_CHARGE_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_DLV_GROUPNM",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_DLV_GROUP_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_DLV_PRODUCT_TYPE",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_DLV_PROP",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_ERP_PRODCD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_EXPRESS_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_GIFT_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_HIDDEN_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_ICE_GROUP_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_ISLAND_DLV_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_KEYWORD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_MASTER_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_MD_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_NAVER_SALE_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_NOSALW_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_NOTI_MST_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_PARTNER_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_POINT_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_PRODUCTCD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_PRODUCTNM",(byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("V_REVIEW_GROUP_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_ROUTINE_DLV_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_SALE_CD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_SHOW_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_SITECD",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_STATUS",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_STOCK_LIMIT_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_TAXFREE_YN",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_THUMBNAIL_EXT",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_THUMBNAIL_NM",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_THUMBNAIL_PATH",(byte) (Protocol.SelectSet.NONE)),
				new SelectSet("V_WEIGHT_CD",(byte) (Protocol.SelectSet.NONE))

			};
			return selectSet;
	}

}
