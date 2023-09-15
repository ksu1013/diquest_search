package com.diquest.ir.rest.extension;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import com.diquest.ir.client.command.CommandSearchRequest;
import com.diquest.ir.common.exception.IRException;
import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.FilterSet;
import com.diquest.ir.common.msg.protocol.query.GroupBySet;
import com.diquest.ir.common.msg.protocol.query.OrderBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QueryParser;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.common.msg.protocol.repository.CFRecommendReq;
import com.diquest.ir.common.msg.protocol.result.Result;
import com.diquest.ir.common.msg.protocol.result.ResultSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;

public class foodNamoo_Main implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		Map<String, String> SearchUtil = request.getParams();
		
		String sch = SearchUtil.get("sch") != null ? SearchUtil.get("sch") : "";									// 검색어
		String currentPage = SearchUtil.get("currentPage") != null ? SearchUtil.get("currentPage") : "1";			// 페이지		
		String schlist=SearchUtil.get("schlist"); if(schlist == null)schlist = sch;									// 재검색용 검색어
		String resch=SearchUtil.get("resch") != null ? SearchUtil.get("resch") : "N";								// 결과내 검색 체크
		String express = SearchUtil.get("express") != null ? SearchUtil.get("express") : "";						// 배송-특급배송여부
		String paldlv = SearchUtil.get("paldlv") != null ? SearchUtil.get("paldlv") : "";							// 배송-무료배송여부
		String category1 = SearchUtil.get("category1") != null ? SearchUtil.get("category1") : "";					// 카테고리1
		String category2 = SearchUtil.get("category2") != null ? SearchUtil.get("category2") : "";					// 카테고리2
		String category3 = SearchUtil.get("category3") != null ? SearchUtil.get("category3") : "";					// 카테고리3
		String weight = SearchUtil.get("weight") != null ? SearchUtil.get("weight") : "";							// 중량
		String gift = SearchUtil.get("gift") != null ? SearchUtil.get("gift") : "";									// 혜택-선물여부
		String coupon = SearchUtil.get("coupon") != null ? SearchUtil.get("coupon") : "";							// 혜택-쿠폰여부
		String orange = SearchUtil.get("orange") != null ? SearchUtil.get("orange") : "";							// 혜택-오렌지할인율
		String dlv = SearchUtil.get("dlv") != null ? SearchUtil.get("dlv") : "";									// 혜택-무료배송여부
		String brand = SearchUtil.get("brand") != null ? SearchUtil.get("brand") : "";								// 브랜드
		String price = SearchUtil.get("price") != null ? SearchUtil.get("price") : "";								// 가격
		String oder = SearchUtil.get("oder") != null ? SearchUtil.get("oder") : "ALL_SALES_NUM";					// 정렬 
		String rownm = SearchUtil.get("rownm") != null ? SearchUtil.get("rownm") : "40";							// 페이지당 노출개수
		String schnm=SearchUtil.get("schnm") != null ? SearchUtil.get("schnm") : "all";								// 메뉴-전체/기획/일반
		String hidden=SearchUtil.get("hidden") != null ? SearchUtil.get("hidden") : "";							// 히든여부
		String nosalw=SearchUtil.get("nosalw") != null ? SearchUtil.get("nosalw") : "";							// 개별판매금지여부
		String schtype = SearchUtil.get("schtype") != null ? SearchUtil.get("schtype") : "all";						// 상태(전체/품절..등등)
		String dspc = SearchUtil.get("dspc") != null ? SearchUtil.get("dspc") : "";								// pc묶음상품여
		String dsmb = SearchUtil.get("dsmb") != null ? SearchUtil.get("dsmb") : "";								// 모바일 묶음상품여부
		String biness = SearchUtil.get("biness") != null ? SearchUtil.get("biness") : "";								// 추가사항1
		String option1 = SearchUtil.get("option1") != null ? SearchUtil.get("option1") : "";								// 기타 추가사항1
		String option2 = SearchUtil.get("option2") != null ? SearchUtil.get("option2") : "";								// 기타 추가사항2
		String option3 = SearchUtil.get("option3") != null ? SearchUtil.get("option3") : "";								// 기타 추가사항3
		String ointype = SearchUtil.get("ointype") != null ? SearchUtil.get("ointype") : "";								// all,any 타입 설정
		String notcheck = SearchUtil.get("notcheck") != null ? SearchUtil.get("notcheck") : "N";								// 제외검색
		String option6 = SearchUtil.get("option6") != null ? (String)SearchUtil.get("option6") : "";
	    String option7 = SearchUtil.get("option7") != null ? (String)SearchUtil.get("option7") : "";
	    String dlvyn = SearchUtil.get("dlvyn") != null ? (String)SearchUtil.get("dlvyn") : "";
		
		
		if((!sch.equals("")&&resch.equals("Y"))||(!sch.equals("")&&notcheck.equals("Y"))){
			schlist = schlist + "@@" + sch;
		}else {
			schlist=sch;
			
		}
		
		
		Map<String, String> foodsch=new HashMap<String, String>();
		
		foodsch.put("sch", sch);
	    foodsch.put("schlist", schlist);
	    foodsch.put("resch", resch);
	    foodsch.put("express", express);
	    foodsch.put("paldlv", paldlv);
	    foodsch.put("category1", category1);
	    foodsch.put("category2", category2);
	    foodsch.put("category3", category3);
	    foodsch.put("weight", weight);
	    foodsch.put("gift", gift);
	    foodsch.put("coupon", coupon);
	    foodsch.put("orange", orange);
	    foodsch.put("dlv", dlv);
	    foodsch.put("brand", brand);
	    foodsch.put("price", price);
	    foodsch.put("currentPage", currentPage);
	    foodsch.put("oder", oder);
	    foodsch.put("rownm", rownm);
	    foodsch.put("schnm", schnm);
	    foodsch.put("hidden", hidden);
	    foodsch.put("nosalw", nosalw);
	    foodsch.put("schtype", schtype);
	    foodsch.put("dspc", dspc);
	    foodsch.put("dsmb", dsmb);
	    foodsch.put("biness", biness);
	    foodsch.put("option1", option1);
	    foodsch.put("option2", option2);
	    foodsch.put("option3", option3);
	    foodsch.put("ointype", ointype);
	    foodsch.put("notcheck", notcheck);
	    foodsch.put("option6", option6);
	    foodsch.put("option7", option7);
	    foodsch.put("dlvyn", dlvyn);
		
		
		QuerySet querySet = null;
		querySet = new QuerySet(1);
		
		
		Query main_query = null; 	// 전체쿼리
		
		try {
			main_query=query_fn(foodsch);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		querySet.addQuery(main_query);
		
		
		return querySet;
	}

	private Query query_fn(Map<String, String> foodsch) throws Exception {
		int page2 = Integer.parseInt(foodsch.get("currentPage"));
		int page3 = Integer.parseInt(foodsch.get("rownm"));
		int startPage = (page2 - 1) * page3;     
		int endPage = startPage+(page3-1);
		
		char[] startTag = "".toCharArray();
		char[] endTag = "".toCharArray();
		
		QueryParser queryParser = new QueryParser();
		
		Query query = new Query(startTag,endTag);
		query.setResult(startPage, endPage);
		query.setDebug(true);
		query.setPrintQuery(false);
		query.setSelect(selectSet_fn(foodsch));
		if(!foodsch.get("sch").equals("")) {
			query.setLoggable(setKeywordCheck(foodsch.get("sch")));
		}
		query.setFrom("MAIN");
		query.setLogKeyword(foodsch.get("sch").toCharArray());
		
		query.setWhere(whereSet_fn(foodsch));
		query.setOrderby(orderSet_fn(foodsch));
		query.setGroupBy(groupSet_fn(foodsch));
		if(!foodsch.get("price").equals(""))query.setFilter(fileterSet_fn(foodsch));
		
		query.setSearch(true);
		
		CFRecommendReq cfRecommendReq = new CFRecommendReq();
		cfRecommendReq.setKeyword(foodsch.get("sch"));
		cfRecommendReq.setNeighborCutOff(9);
		cfRecommendReq.setRecommendCutOff(9);
		query.setCFRecommendQuery(true);
		query.setCFRecommend(cfRecommendReq);
		
		
		query.setResultModifier("typo");
		query.setValue("typo-parameters", foodsch.get("sch"));
		//query.setValue("typo-options", "CORRECT_HANGUL_SPELL");
		query.setValue("typo-options","ALPHABETS_TO_HANGUL|HANGUL_TO_HANGUL|REMOVE_HANGUL_JAMO_ALL|CORRECT_HANGUL_SPELL");
		query.setValue("typo-correct-result-num", "1");
		
		
		//문서랭킹/카테고리랭킹/클릭랭킹 사용(문서아이디 필터(문서랭킹/클릭랭킹), 카테고리 필드(카테고리랭킹) 생성 후 사용 가능)
        query.setRankingOption((byte)(Protocol.RankingOption.DOCUMENT_RANKING | Protocol.RankingOption.CATEGORY_RANKING | Protocol.RankingOption.CLICK_RANKING));
//        //카테고리랭킹 옵션 사용(유의어로 카테고리랭킹 확장, 동의어로 카테고리 랭킹 확장, 형태소 분석별 다중 키워드로 카테고리 랭킹 확장)  - 어절별/형태소 둘중 하나만 적용
        query.setCategoryRankingOption((byte)(Protocol.CategoryRankingOption.QUASI_SYNONYM| Protocol.CategoryRankingOption.EQUIV_SYNONYM | Protocol.CategoryRankingOption.MULTI_TERM_KOREAN));    
//        //diver 기능 사용
        query.setQueryModifier("diver");


		// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
		query.setSearchOption(
				(byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));

		// 동의어, 유의어 확장
		query.setThesaurusOption(
				(byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));

		//System.out.println("::::queryParser::::\n"+queryParser.queryToString(query));
		
		
		
		return query;
	}

	private FilterSet[] fileterSet_fn(Map<String, String> foodsch) {
		
		String[] pricesch=foodsch.get("price").split("to");
		
		
		FilterSet[]	filterSet = new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_N_SALE_PRICE", pricesch) };	//온라인 가격필터
			
		
		return filterSet;
		
	}

	private GroupBySet[] groupSet_fn(Map<String, String> foodsch) {
		GroupBySet[] GroupBySet = null;
			GroupBySet=new GroupBySet[] {
					new GroupBySet ("GROUP_V_BRANDNM", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_COUNT),"DESC",""),  //브랜드
					new GroupBySet ("GROUP_V_CATEGORY1NM", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME),"ASC", ""),	//대카테고리
					new GroupBySet ("GROUP_V_CATEGORY2NM", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME),"ASC", ""),	//중카테고리
					new GroupBySet ("GROUP_V_CATEGORY3NM", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "ASC",""),	//소카테고리
					new GroupBySet ("GROUP_V_GIFT_YN", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5", ""),		//혜택-선물여부
					new GroupBySet ("GROUP_V_COUPON_YN", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5", ""),	//혜택-쿠폰여부
					new GroupBySet ("GROUP_N_ORANGE_SALE_RATE", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC",""),	//헤택-오렌지 할인율
					new GroupBySet ("GROUP_V_DLV_CHARGE_YN", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5", ""),	//혜택-무료배송여부
					new GroupBySet ("GROUP_V_WEIGHT_CD", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_COUNT), "DESC",""),	//무게
					new GroupBySet ("GROUP_V_EXPRESS_YN", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5", ""),	//배송 특급배송
					new GroupBySet ("GROUP_V_PAID_DELIVERY_YN", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5", ""),	//배송 무료배송
					new GroupBySet ("GROUP_N_SALE_PRICE", (byte) (Protocol.GroupBySet.OP_INT_MIN|Protocol.GroupBySet.ORDER_COUNT), "ASC 0 0","","FILTER_N_SALE_PRICE"),	//최소가격
					new GroupBySet ("GROUP_N_SALE_PRICE", (byte) (Protocol.GroupBySet.OP_INT_MAX|Protocol.GroupBySet.ORDER_COUNT), "DESC 0 0","","FILTER_N_SALE_PRICE"),	//최대가격
					new GroupBySet ("GROUP_SEARCH_NUM", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5",""),	//상품종류
					new GroupBySet ("GROUP_ETC_OPTION1", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5",""),	//기타 추가상항1
					new GroupBySet ("GROUP_ETC_OPTION2", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5",""),	//기타 추가상항2
					new GroupBySet ("GROUP_ETC_OPTION3", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5",""),	//기타 추가상항3
					new GroupBySet ("GROUP_ETC_OPTION6", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5",""),	//기타 추가상항3
					new GroupBySet ("GROUP_ETC_OPTION7", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5",""),	//기타 추가상항3
					new GroupBySet ("GROUP_V_ROUTINE_DELIVERY_YN", (byte) (Protocol.GroupBySet.OP_COUNT|Protocol.GroupBySet.ORDER_NAME), "DESC 0 5","")	//기타 추가상항3
			};
		
		
		
		
		return GroupBySet;
	}

	private OrderBySet[] orderSet_fn(Map<String, String> foodsch) {
		OrderBySet[] orderBySet = null;
		
		if(foodsch.get("oder").equals("ALL_NEW_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_ALL_PROD_NEW_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) };	//전체상품-신상품순정렬
		}else if(foodsch.get("oder").equals("ALL_REC_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_ALL_PROD_REC_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //전체상품-추천순정렬
		}else if(foodsch.get("oder").equals("ALL_SALES_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_ALL_PROD_SALES_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //전체상품-판매량순정렬
		}else if(foodsch.get("oder").equals("D_UPDATE_DTM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_D_UPDATE_DTM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //수정일자
		}else if(foodsch.get("oder").equals("EX_NEW_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_EX_PROD_NEW_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //기획전상품-신상품순정렬
		}else if(foodsch.get("oder").equals("EX_REC_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_EX_PROD_REC_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //기획전상품-추천순정렬
		}else if(foodsch.get("oder").equals("EX_SALES_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_EX_PROD_SALES_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //기획전상품-판매량순정렬
		}else if(foodsch.get("oder").equals("GE_NEW_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_GE_PROD_NEW_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //일반상품-신상품순정렬
		}else if(foodsch.get("oder").equals("GE_REC_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_GE_PROD_REC_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //일반상품-추천순정렬
		}else if(foodsch.get("oder").equals("GE_SALES_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_GE_PROD_SALES_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //일반상품-판매량순정렬
		}else if(foodsch.get("oder").equals("N_REVIEW_CNT")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_N_REVIEW_CNT", Protocol.OrderBySet.OP_POSTWEIGHT) }; //리뷰수
		}else if(foodsch.get("oder").equals("N_REV_AVG")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_N_REV_AVG", Protocol.OrderBySet.OP_POSTWEIGHT) }; //상품후기평균점수
		}else if(foodsch.get("oder").equals("N_REV_CNT")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_N_REVIEW_CNT", Protocol.OrderBySet.OP_POSTWEIGHT) }; //상품후기수
		}else if(foodsch.get("oder").equals("ASC_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_PROD_PRICE_ASC_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //낮은가격순정렬
		}else if(foodsch.get("oder").equals("DESC_NUM")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_PROD_PRICE_DESC_NUM", Protocol.OrderBySet.OP_POSTWEIGHT) }; //높은가격순정렬
		}else if(foodsch.get("oder").equals("REVIEW_GRADE")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_V_REVIEW_GRADE", Protocol.OrderBySet.OP_POSTWEIGHT) }; //별점
		}else if(foodsch.get("oder").equals("JNG_HDO")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_ALL_PROD_SALES_NUM", Protocol.OrderBySet.OP_PREWEIGHT) }; //정확도정렬
		}
		
		
		return orderBySet;
	}

	private WhereSet[] whereSet_fn(Map<String, String> foodsch) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		String[] searchTerm_Array = foodsch.get("schlist").split("@@");
		String[] brand_Array = foodsch.get("brand").split("@@");
		String[] category2_Array = foodsch.get("category2").split("@@");
		String[] weight_Array = foodsch.get("weight").split("@@");
		String[] schtype_Array = foodsch.get("schtype").split("@@");
		
		
		
		for(int i = 0; i < searchTerm_Array.length; i++) {
			// 재검색
			 if(i != 0) {
				 if(foodsch.get("resch").equals("Y")) {
					 whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				 }else if(foodsch.get("notcheck").equals("Y")) {
					 whereList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
				 }
				
			 } 	
		
			if(!foodsch.get("schlist").equals("")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				if(foodsch.get("ointype").equals("1")) {
					whereList.add(new WhereSet("IDX_V_PRODUCTNM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],1000));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("V_PRODUCTNM_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],1000));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_KEYWORD", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],1000));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_PRODUCTCD", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],1000));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_PRODUCTNM_HOKHAB", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],1000));
				}else if(foodsch.get("ointype").equals("2")) {
					whereList.add(new WhereSet("IDX_V_PRODUCTNM", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("V_PRODUCTNM_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_KEYWORD", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_PRODUCTCD", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_PRODUCTNM_HOKHAB", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
				}else if(foodsch.get("ointype").equals("3")) {
					whereList.add(new WhereSet("IDX_V_PRODUCTNM", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("V_PRODUCTNM_BI", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_KEYWORD", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_PRODUCTCD", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_PRODUCTNM_HOKHAB", Protocol.WhereSet.OP_HASANY, searchTerm_Array[i],10));
				}
				
				
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				//브랜드
				if(!foodsch.get("brand").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					for(int j = 0; j < brand_Array.length; j++) {
						 if(j != 0) {
							 whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
						 } 
						whereList.add(new WhereSet("IDX_V_BRANDNM", Protocol.WhereSet.OP_HASALL, brand_Array[j]));
					}
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				boolean isCheck = false;
				//헤택 -선물/쿠폰/무료배송/오렌지
				if(!foodsch.get("gift").equals("")||!foodsch.get("coupon").equals("")||!foodsch.get("dlv").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				}
				
				if(!foodsch.get("gift").equals("")) {
					if(isCheck) whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_GIFT_YN", Protocol.WhereSet.OP_HASALL, foodsch.get("gift")));
					isCheck = true;
				}
				if(!foodsch.get("coupon").equals("")) {
					if(isCheck) whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_COUPON_YN", Protocol.WhereSet.OP_HASALL, foodsch.get("coupon")));
					isCheck = true;
				}
				
				if(!foodsch.get("dlv").equals("")) {     //y-유료배송 n-무료배송
					if(isCheck) whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_DLV_CHARGE_YN", Protocol.WhereSet.OP_HASALL, foodsch.get("dlv")));
					isCheck = true;
				}
				if(!foodsch.get("gift").equals("")||!foodsch.get("coupon").equals("")||!foodsch.get("dlv").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				//오렌지 할인률 - 0보다 큰값들만 조회
				if(!foodsch.get("orange").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_N_ORANGE_SALE_RATE", Protocol.WhereSet.OP_HASALL, "0"));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_N_ORANGE_SALE_RATE", Protocol.WhereSet.OP_HASALL, "0.0"));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					isCheck = true;
				}
				//카테고리
				if(!foodsch.get("category1").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet("IDX_V_CATEGORY1NM", Protocol.WhereSet.OP_HASALL, foodsch.get("category1")));
				}
				if(!foodsch.get("category2").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					for (int j = 0; j < category2_Array.length; j++) {
						if(j != 0) {
							 whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
						 } 
						whereList.add(new WhereSet("IDX_V_CATEGORY2NM2", Protocol.WhereSet.OP_HASALL, category2_Array[j]));
					}
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				Boolean check=false;
				//배송- 특급배송/무료배송
				if(!foodsch.get("express").equals("")||!foodsch.get("paldlv").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				}
				if(!foodsch.get("express").equals("")) {
					whereList.add(new WhereSet("IDX_V_EXPRESS_YN", Protocol.WhereSet.OP_HASALL, foodsch.get("express")));
					check=true;
				}
				if(!foodsch.get("paldlv").equals("")) {
					if(check)whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_V_PAID_DELIVERY_YN", Protocol.WhereSet.OP_HASALL, foodsch.get("paldlv")));
				}
				if(!foodsch.get("express").equals("")||!foodsch.get("paldlv").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				
				//중량
				if(!foodsch.get("weight").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					for(int j = 0; j < weight_Array.length; j++) {
						 if(j != 0) {
							 whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
						 } 
						 whereList.add(new WhereSet("IDX_V_WEIGHT_CD", Protocol.WhereSet.OP_HASALL, weight_Array[j]));
					}
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				//pc묶음상품여부
				if(!foodsch.get("dspc").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_V_CHANNEL_DSP_PC", Protocol.WhereSet.OP_HASALL, foodsch.get("dspc")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					
				}//모바일 묶음상품여부
				if(!foodsch.get("dsmb").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_V_CHANNEL_DSP_MB", Protocol.WhereSet.OP_HASALL, foodsch.get("dsmb")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					
				}
				
				//상품구분
				if(!foodsch.get("schnm").equals("all")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_SEARCH_NUM", Protocol.WhereSet.OP_HASALL, foodsch.get("schnm")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					
				}
				
				//히든상품여부
				if(!foodsch.get("hidden").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_V_HIDDEN_YN", Protocol.WhereSet.OP_HASALL,foodsch.get("hidden")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				//개별판매금지여부
				if(!foodsch.get("nosalw").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_V_NOSALW_YN", Protocol.WhereSet.OP_HASALL,foodsch.get("nosalw")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				//상품종류 하기 복수로
				if(!foodsch.get("schtype").equals("all")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					for(int j = 0; j < schtype_Array.length; j++) {
						 if(j != 0) {
							 whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
						 } 
						 whereList.add(new WhereSet("IDX_V_PROD_KIND", Protocol.WhereSet.OP_HASALL, schtype_Array[j]));
					}
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				
				//추가사항1
				if(!foodsch.get("biness").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_V_BUSINESS_GROUP", Protocol.WhereSet.OP_HASALL,foodsch.get("biness")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				//기타 추가상항 1
				if(!foodsch.get("option1").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_ETC_OPTION1", Protocol.WhereSet.OP_HASALL,foodsch.get("option1")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				//기타 추가상항 2
				if(!foodsch.get("option2").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_ETC_OPTION2", Protocol.WhereSet.OP_HASALL,foodsch.get("option2")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				//기타 추가상항 3
				if(!foodsch.get("option3").equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_ETC_OPTION3", Protocol.WhereSet.OP_HASALL,foodsch.get("option3")));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
				 if (!foodsch.get("option6").equals("")) {
				  whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				  whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		          whereList.add(new WhereSet("IDX_ETC_OPTION6",Protocol.WhereSet.OP_HASALL,foodsch.get("option6")));
		          whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		        }
		        if (!foodsch.get("option7").equals("")) {
		          whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				  whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		          whereList.add(new WhereSet("IDX_ETC_OPTION7",Protocol.WhereSet.OP_HASALL,foodsch.get("option7")));
		          whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		        }
		        if (!foodsch.get("dlvyn").equals("")) {
		          whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				  whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		          whereList.add(new WhereSet("IDX_V_ROUTINE_DELIVERY_YN", Protocol.WhereSet.OP_HASALL,foodsch.get("dlvyn")));
		          whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		        }
				
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

					new SelectSet("ALL_PROD_NEW_NUM",(byte) (Protocol.SelectSet.NONE)), 
					new SelectSet("ALL_PROD_REC_NUM",(byte) (Protocol.SelectSet.NONE)), 
					new SelectSet("ALL_PROD_SALES_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("D_SOLDOUT_REOPEN_TIME", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("D_UPDATE_DTM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EX_PROD_NEW_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EX_PROD_REC_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EX_PROD_SALES_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GE_PROD_NEW_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GE_PROD_REC_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GE_PROD_SALES_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_CATEGORY_SORT2",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_FREE_DLV_PRICE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_HIT_SALES",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_MAX_PACK_AMT",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_MAX_UNIT_PER_PRICE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_MIN_PACK_AMT",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_MIN_UNIT_PER_PRICE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_ORANGE_SALE_RATE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_POINT_RATE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_PRD_UNIT_PER_PRICE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_PRICE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_REVIEW_CNT",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_REV_AVG",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_REV_CNT",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_SALE_PRICE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("N_SALE_RATE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROD_PRICE_ASC_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROD_PRICE_DESC_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SEARCH_NUM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_ADDPROD_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_ADD_OPTION_SHOW_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_ADD_OPTION_USE_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_BRANDNM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_BRAND_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_BUNDLE_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CATEGORY1NM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CATEGORY2NM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CATEGORY3NM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CATEGORYCD1",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CATEGORYCD2",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CATEGORYCD3",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CHANNEL_DSP_MB",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_CHANNEL_DSP_PC",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_COMPANY_TYPE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_COMPARE_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_COUPON_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_DLV_CHARGE_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_DLV_CHARGE_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_DLV_GROUP_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_EXPRESS_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_GIFT_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_HIDDEN_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_KEYWORD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_NOSALW_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_OPEN_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_OPTION_NM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_OPTION_SHOW_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_OPTION_TYPE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_OPTION_USE_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_PACK_TYPE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_PAID_DELIVERY_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_PRD_STATUS",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_PRD_WEIGHT_UNIT",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_PRODUCTCD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_PRODUCTNM",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_PROD_KIND",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_RESTOCK_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_REVIEW_GRADE",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_REVIEW_GROUP_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_SALE_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_SALE_DSP_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_SITECD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_SOLDOUT_OPTION_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_SOLDOUT_REOPEN_TIME_SHOW_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_SOLDOUT_SHOW_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_SOLD_OUT_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_THUMBNAIL",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_UNIT_PRICE_TEXT",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_UNIT_PRICE_TEXT_SHOW_YN",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_WEIGHT_CD",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_WEIGHT_UNIT",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_BADGE_ICON_THUMBNAIL",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_LIST_ICON_THUMBNAIL",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_BUSINESS_GROUP",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION1",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION2",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION3",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION4",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION5",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION6",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION7",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ETC_OPTION8",(byte) (Protocol.SelectSet.NONE)),
					new SelectSet("V_ROUTINE_DELIVERY_YN",(byte) (Protocol.SelectSet.NONE)),
			};
				
			return selectSet;
		
		
	}
	
	/* 오탈자 체크 */
	public static boolean setKeywordCheck(String searchQuery) throws Exception{
		boolean keyBoolean = true;
		char[] charkeyword = searchQuery.toCharArray();
		for (int i = 0; i < charkeyword.length; i++) {
			int ck = (int) charkeyword[i];
			if ((ck >= 12593 && ck <= 12622) || (ck >= 12623 && ck <= 12643)) {
				keyBoolean = false;
			}
		}
		return keyBoolean;
	}

}
