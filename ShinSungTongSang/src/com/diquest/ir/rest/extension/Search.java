package com.diquest.ir.rest.extension;

import java.util.ArrayList;
import java.util.HashMap;
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
import com.diquest.ir.common.msg.protocol.result.Result;
import com.diquest.ir.common.msg.protocol.result.ResultSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
public class Search implements QuerySetExtension, ResultJsonExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub

	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		Map<String, String> SearchUtil = request.getParams();
		String schgubun = SearchUtil.get("schgubun"); // 검색구분

		QuerySet querySet = null;
		querySet = new QuerySet(1);

		//컬렉션 나누기
		int queryCheck = 1;  //main
		int queryCheck2 = 2; //brand
		int queryCheck3 = 3; //pln_ent

		Query query01 = null; // 쿼리1
		Query query02 = null; // 쿼리2

		try {
			if (schgubun.equals("total")) {
				querySet = new QuerySet(2);
				query01 = query_fn(SearchUtil, queryCheck);
				query02 = query_fn(SearchUtil, queryCheck2);
				querySet.addQuery(query01);
				querySet.addQuery(query02);
			} else if (schgubun.equals("ent")) {
				query01 = query_fn(SearchUtil, queryCheck3);
				querySet.addQuery(query01);
			} else if (schgubun.equals("category")) {
				query01 = query_fn(SearchUtil, queryCheck);
				querySet.addQuery(query01);
			} else if (schgubun.equals("shop")) {
				query01 = query_fn(SearchUtil, queryCheck);
				querySet.addQuery(query01);
			}

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return querySet;
	}
	
	
	

	private Query query_fn(Map<String, String> SearchUtil, int queryCheck) throws Exception {
		
		String sch = SearchUtil.get("sch") != null ? SearchUtil.get("sch") : ""; // 검색어
		String currentPage = SearchUtil.get("currentPage") != null ? SearchUtil.get("currentPage") : "1"; // 페이지
		String perDiv = SearchUtil.get("perDiv") != null ? SearchUtil.get("perDiv") : "60"; // 페이지당 노출개수
		String schlist = SearchUtil.get("schlist");if (schlist == null)schlist = sch; // 재검색용 검색어
		String resch = SearchUtil.get("resch") != null ? SearchUtil.get("resch") : "N"; // 결과내 검색 체크
		String price01 = SearchUtil.get("price01") != null ? SearchUtil.get("price01") : ""; // 가격
		String price02 = SearchUtil.get("price02") != null ? SearchUtil.get("price02") : ""; // 가격
		String category01 = SearchUtil.get("category01") != null ? SearchUtil.get("category01") : ""; // 대카테고리 코드-검색용
		String category02 = SearchUtil.get("category02") != null ? SearchUtil.get("category02") : ""; // 중카테고리 코드-검색용
		String category03 = SearchUtil.get("category03") != null ? SearchUtil.get("category03") : ""; // 소카테고리 코드-검색용
		String category04 = SearchUtil.get("category04") != null ? SearchUtil.get("category04") : ""; // 세카테고리 코드-검색용
		String category05 = SearchUtil.get("category05") != null ? SearchUtil.get("category05") : ""; // 세카테고리 코드-검색용
		String brand = SearchUtil.get("brand") != null ? SearchUtil.get("brand") : ""; // 브랜드
		String size = SearchUtil.get("size") != null ? SearchUtil.get("size") : ""; // 사이즈
		String tcgubun = SearchUtil.get("tcgubun") != null ? SearchUtil.get("tcgubun") : ""; // 통합몰/클럽몰 구분
		String order = SearchUtil.get("order") != null ? SearchUtil.get("order") : "BST"; // 정렬
		String color = SearchUtil.get("color") != null ? SearchUtil.get("color") : ""; // 색상
		String style = SearchUtil.get("style") != null ? SearchUtil.get("style") : ""; // 스타일
		String schgubun = SearchUtil.get("schgubun") != null ? SearchUtil.get("schgubun") : ""; // 검색구분
		String tgtMbrAtrbCd  = SearchUtil.get("tgtMbrAtrbCd") != null ? SearchUtil.get("tgtMbrAtrbCd") : ""; // 검색구분
		String dvcCd  = SearchUtil.get("dvcCd") != null ? SearchUtil.get("dvcCd") : ""; // 검색구분
		String testgubun = SearchUtil.get("testgubun") != null ? SearchUtil.get("testgubun") : ""; // 테스트 체크 = dev/stg
		String otltyn = SearchUtil.get("otltyn") != null ? SearchUtil.get("otltyn") : ""; // 아울렛체크
		String rprstGodYn  = SearchUtil.get("rprstGodYn") != null ? SearchUtil.get("rprstGodYn") : ""; // 카데고리 대표상품 여부 체크
		String soldoutYn  = SearchUtil.get("soldoutYn") != null ? SearchUtil.get("soldoutYn") : ""; //

		
		
		if ((!sch.equals("") && resch.equals("Y") )) {
			if(schlist.indexOf(sch) >1) {
				//schlist = schlist;
			}else {
				schlist = schlist + "@@" + sch;
			}
		} else {
			schlist = sch;
		}
		
		//System.out.println("1. schlist>>>>>>>>>>>"+schlist);
		int page2 = Integer.parseInt(currentPage);
		int page3 = Integer.parseInt(perDiv);
		int startPage = (page2 - 1) * page3; // 0 60
		int endPage = startPage + (page3 - 1); // 59 119

		char[] startTag = "".toCharArray();
		char[] endTag = "".toCharArray();
		
		
		SearchUtil.put("schlist", schlist);
		SearchUtil.put("resch", resch);
		SearchUtil.put("currentPage", currentPage);
		SearchUtil.put("price01", price01);
		SearchUtil.put("price02", price02);
		SearchUtil.put("category01", category01);
		SearchUtil.put("category02", category02);
		SearchUtil.put("category03", category03);
		SearchUtil.put("category04", category04);
		SearchUtil.put("category05", category05);
		SearchUtil.put("brand", brand);
		SearchUtil.put("size", size);
		SearchUtil.put("tcgubun", tcgubun);
		SearchUtil.put("perDiv", perDiv);
		SearchUtil.put("order", order);
		SearchUtil.put("color", color);
		SearchUtil.put("style", style);
		SearchUtil.put("schgubun", schgubun);
		SearchUtil.put("tgtMbrAtrbCd", tgtMbrAtrbCd);
		SearchUtil.put("dvcCd", dvcCd);
		SearchUtil.put("testgubun", testgubun);
		SearchUtil.put("otltyn", otltyn);
		SearchUtil.put("rprstGodYn", rprstGodYn);
		SearchUtil.put("soldoutYn", soldoutYn);
		
		//QueryParser queryParser = new QueryParser();

		Query query = new Query(startTag, endTag);
		query.setResult(startPage, endPage);
		query.setDebug(true);
		query.setPrintQuery(true);
		if (!sch.equals("")) {
			query.setLoggable(true);
			query.setLogKeyword(sch.toCharArray());
		}

		if(testgubun.equals("dev")) {
			if (queryCheck == 1) {
				query.setRankingOption((byte) (Protocol.RankingOption.CATEGORY_RANKING|Protocol.RankingOption.DOCUMENT_RANKING));
				query.setCategoryRankingOption((byte) (Protocol.CategoryRankingOption.QUASI_SYNONYM| Protocol.CategoryRankingOption.EQUIV_SYNONYM | Protocol.CategoryRankingOption.MULTI_TERM_KOREAN));
				if(schgubun.equals("total")||schgubun.equals("category")){
					query.setGroupBy(groupSet_fn(SearchUtil, queryCheck));
					if (setKeywordCheck(sch)) {
						query.setResultModifier("typo");
						query.setValue("typo-parameters", sch);
						query.setValue("typo-options","ALPHABETS_TO_HANGUL|HANGUL_TO_HANGUL|REMOVE_HANGUL_JAMO_ALL|CORRECT_HANGUL_SPELL");
						query.setValue("typo-correct-result-num", "1");
					}
					if (!price01.equals("") && !price02.equals("")) {
						query.setFilter(fileterSet_fn(SearchUtil));
					}
				}
				query.setQueryModifier("diver");				
				query.setFrom("MAIN");
				
			}
			if (queryCheck == 2) {
				query.setFrom("BRAND");
			}
			if (queryCheck == 3) {
				query.setFrom("PLN_ENT");
			}
		}else if(testgubun.equals("stg")) {
			if (queryCheck == 1) {
				query.setRankingOption((byte) (Protocol.RankingOption.CATEGORY_RANKING));
				query.setCategoryRankingOption((byte) (Protocol.CategoryRankingOption.QUASI_SYNONYM| Protocol.CategoryRankingOption.EQUIV_SYNONYM | Protocol.CategoryRankingOption.MULTI_TERM_KOREAN));
				if(schgubun.equals("total")||schgubun.equals("category")){
					query.setGroupBy(groupSet_fn(SearchUtil, queryCheck));
					if (setKeywordCheck(sch)) {
						query.setResultModifier("typo");
						query.setValue("typo-parameters", sch);
						query.setValue("typo-options","ALPHABETS_TO_HANGUL|HANGUL_TO_HANGUL|REMOVE_HANGUL_JAMO_ALL|CORRECT_HANGUL_SPELL");
						query.setValue("typo-correct-result-num", "1");
					}
					if (!price01.equals("") && !price02.equals("")) {
						query.setFilter(fileterSet_fn(SearchUtil));
					}
				}
				query.setQueryModifier("diver");				
				query.setFrom("STG_MAIN");
				
			}
			if (queryCheck == 2) {
				query.setFrom("STG_BRAND");
			}
			if (queryCheck == 3) {
				query.setFrom("STG_PLN_ENT");
			}
		}
			
		query.setSelect(selectSet_fn(SearchUtil, queryCheck));
		
		query.setWhere(whereSet_fn(SearchUtil, queryCheck));
		
		query.setOrderby(orderSet_fn(SearchUtil, queryCheck));
		
		
		
	
		// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
		query.setSearchOption((byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));

		// 동의어, 유의어 확장
		query.setThesaurusOption((byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));

		 //System.out.println("::::queryParser::::\n"+queryParser.queryToString(query));
		return query;
	}

	private FilterSet[] fileterSet_fn(Map<String, String> SearchUtil) {

		String[] pricesch = { SearchUtil.get("price01"), SearchUtil.get("price02") };

		FilterSet[] filterSet = new FilterSet[] {
				new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_DQ_PRICE", pricesch) }; // 가격필터

		return filterSet;

	}

	private GroupBySet[] groupSet_fn(Map<String, String> SearchUtil, int queryCheck) {
		GroupBySet[] GroupBySet = null;
		if (queryCheck == 3) {
			GroupBySet = new GroupBySet[] { new GroupBySet("GROUP_DQ_BRAND",
					(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.OP_COUNT), "ASC", "") // 브랜드 그룹핑
			};
		} else if (queryCheck == 1) {
			GroupBySet = new GroupBySet[] {
					new GroupBySet("GROUP_DQ_CATEGORY",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 대카테고리
					new GroupBySet("GROUP_DQ_CATEGORY02",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 중카테고리
					new GroupBySet("GROUP_DQ_CATEGORY03",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 소카테고리
					new GroupBySet("GROUP_DQ_CATEGORY04",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 세카테고리
					new GroupBySet("GROUP_DQ_CATEGORY05",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 전략카테고리
					new GroupBySet("GROUP_DQ_COLOR",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 색상
					new GroupBySet("GROUP_MIN_PRICE",(byte) (Protocol.GroupBySet.OP_INT_MIN | Protocol.GroupBySet.ORDER_COUNT), "ASC 0 0", "","FILTER_DQ_PRICE"), // 최소가격
					new GroupBySet("GROUP_MAX_PRICE",(byte) (Protocol.GroupBySet.OP_INT_MAX | Protocol.GroupBySet.ORDER_COUNT), "DESC 0 0", "","FILTER_DQ_PRICE"), // 최대가격
					new GroupBySet("GROUP_DQ_EN_BRAND",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 브랜드명
					new GroupBySet("GROUP_DQ_KOR_BRAND",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 브랜드
					new GroupBySet("GROUP_DQ_SIZE",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "DESC", ""), // 사이즈
					new GroupBySet("GROUP_DQ_STYLE",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 스타일
			};
		} 
		return GroupBySet;
	}

	private OrderBySet[] orderSet_fn(Map<String, String> SearchUtil, int queryCheck) {
		OrderBySet[] orderBySet = null;
		// 정렬기준 ---->신상품순-----> 상품명--->
		if (queryCheck == 3) {
			orderBySet = new OrderBySet[] {
					new OrderBySet(true, "SORT_DSP_BEG_DT", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 전시일시
		} else if (queryCheck == 1) {
			if (SearchUtil.get("order").equals("BST")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_BST_GOD_SORT_SEQ", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 인기순
			} else if (SearchUtil.get("order").equals("NEW")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_NEW_GOD_DSP_DT", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 신상품순
			} else if (SearchUtil.get("order").equals("LAST")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_DQ_PRICE", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 낮은가격순
			} else if (SearchUtil.get("order").equals("HIGH")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_HIGH_SALE_PRC", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 높은가격순
			} else if (SearchUtil.get("order").equals("DIC")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_GOD_DC_RT", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 할인율
			} else if (SearchUtil.get("order").equals("SCORE")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_EVL_SCORE", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 별점순
			} else {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_BST_GOD_SORT_SEQ", Protocol.OrderBySet.OP_PREWEIGHT) }; // 가중치
			}
		}else if(queryCheck == 2) {
			orderBySet = new OrderBySet[] {
					new OrderBySet(true, "SORT_CTGRY_OUTPT_TP_CD", Protocol.OrderBySet.OP_PREWEIGHT) }; // 가중치
		}

		return orderBySet;
	}

	private WhereSet[] whereSet_fn(Map<String, String> SearchUtil, int queryCheck) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		String[] searchTerm_Array = SearchUtil.get("schlist").split("@@");
		
		if(!SearchUtil.get("schlist").equals("")) {
			for (int i = 0; i < searchTerm_Array.length; i++) {
				// 재검색
				if (i != 0) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				}
				if(queryCheck==1) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_GOD_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1000));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_GOD_NM_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 900));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_BRND_KOR_FLTER_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 500));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_BRND_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 500));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_GOD_SRCH_SNM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 300));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_DQ_CATEGORY_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_DQ_CATEGORY02_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
//					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
//					whereList.add(new WhereSet("IDX_DQ_CATEGORY03_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_DQ_CATEGORY04_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_DQ_CATEGORY05_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("TATAL_SEACH", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_GOD_NO", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}else if(queryCheck==2) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_BRND_NM", Protocol.WhereSet.OP_HASALL, SearchUtil.get("sch"), 500));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_BRND_KOR_FLTER_NM", Protocol.WhereSet.OP_HASALL, SearchUtil.get("sch"), 500));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}else if(queryCheck==3) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_PROMT_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],1000));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_PROMT_NM_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],900));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_PROMT_TAG_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],300));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_BRND_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],500));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("TOTAL_SEARCH", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],1));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_PROMT_SN", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i],100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					// 회원유형 -이벤트 기획전
					if (!SearchUtil.get("tgtMbrAtrbCd").equals("")) {
						whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
						whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
						whereList.add(new WhereSet("IDX_TGT_MBR_ATRB_CD", Protocol.WhereSet.OP_HASANY, SearchUtil.get("tgtMbrAtrbCd")));
						whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					}
							
					// 노출디바이스 -이벤트 기획전
					if (!SearchUtil.get("dvcCd").equals("")) {
						whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
						whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
						whereList.add(new WhereSet("IDX_DVC_CD", Protocol.WhereSet.OP_HASANY, SearchUtil.get("dvcCd")));
						whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					}
				}
			}
		}
		if(queryCheck==1) {
			// 카테고리코드 시작
			if (!SearchUtil.get("category01").equals("") || !SearchUtil.get("category02").equals("")|| !SearchUtil.get("category03").equals("") || !SearchUtil.get("category04").equals("")|| !SearchUtil.get("category05").equals("")) {
	
				boolean categorycheck = false;
	
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
	
				// 대카테고리코드
				if (!SearchUtil.get("category01").equals("")) {
					whereList.add(new WhereSet("IDX_DQ_CATEGORY_CD", Protocol.WhereSet.OP_HASANY,SearchUtil.get("category01"), 0));
					categorycheck = true;
				}
				// 중카테고리코드
				if (!SearchUtil.get("category02").equals("")) {
					if(SearchUtil.get("schgubun").equals("total")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					}
					else if(SearchUtil.get("schgubun").equals("category")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					}
					whereList.add(new WhereSet("IDX_DQ_CATEGORY02_CD", Protocol.WhereSet.OP_HASANY,SearchUtil.get("category02"), 0));
					categorycheck = true;
				}
				// 소카테고리코드
				if (!SearchUtil.get("category03").equals("")) {
					if(SearchUtil.get("schgubun").equals("total")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					}
					else if(SearchUtil.get("schgubun").equals("category")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					}
					whereList.add(new WhereSet("IDX_DQ_CATEGORY03_CD", Protocol.WhereSet.OP_HASANY,SearchUtil.get("category03"), 0));
					categorycheck = true;
				}
				// 세부카테고리코드
				if (!SearchUtil.get("category04").equals("")) {
					if(SearchUtil.get("schgubun").equals("total")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					}
					else if(SearchUtil.get("schgubun").equals("category")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					}
					whereList.add(new WhereSet("IDX_DQ_CATEGORY04_CD", Protocol.WhereSet.OP_HASANY,SearchUtil.get("category04"), 0));
				}
				if (!SearchUtil.get("category05").equals("")) {
					if(SearchUtil.get("schgubun").equals("total")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					}
					else if(SearchUtil.get("schgubun").equals("category")) {
						if (categorycheck)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
					}
					whereList.add(new WhereSet("IDX_DQ_CATEGORY05_CD", Protocol.WhereSet.OP_HASANY,SearchUtil.get("category05"), 0));
				}
	
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			// 브랜드
			if (!SearchUtil.get("brand").equals("")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_BRND_ID", Protocol.WhereSet.OP_HASANY, SearchUtil.get("brand")));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			// 사이즈
			if (!SearchUtil.get("size").equals("")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_STD_SIZE_CD", Protocol.WhereSet.OP_HASANY, SearchUtil.get("size")));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			// 색상
			if (!SearchUtil.get("color").equals("")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_DQ_COLOR2", Protocol.WhereSet.OP_HASANY, SearchUtil.get("color")));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			// 스타일
			if (!SearchUtil.get("style").equals("")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_DQ_STYLE2", Protocol.WhereSet.OP_HASANY, SearchUtil.get("style")));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			// 통합몰과 클럽몰 구분
			if (SearchUtil.get("tcgubun").equals("C")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_BRND_ID", Protocol.WhereSet.OP_HASANY, "MSBR@MKBR@MBBR"));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			// 아울렛여부
			if (!SearchUtil.get("otltyn").equals("")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_OTLT_YN", Protocol.WhereSet.OP_HASANY, SearchUtil.get("otltyn")));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
		
			if (!SearchUtil.get("rprstGodYn").equals("")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_RPRST_GOD_YN", Protocol.WhereSet.OP_HASANY, SearchUtil.get("rprstGodYn")));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			if (!SearchUtil.get("soldoutYn").equals("")) {
				if (whereList.size() > 0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_SOLDOUT_YN", Protocol.WhereSet.OP_HASANY, SearchUtil.get("soldoutYn")));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
		}

		
		WhereSet[] whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
		return whereSet;
	}

	private SelectSet[] selectSet_fn(Map<String, String> SearchUtil, int queryCheck) {
		SelectSet[] selectSet = null;

		if (queryCheck == 1) {
			selectSet = new SelectSet[] { 
					new SelectSet("BRND_ID", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_KOR_FLTER_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BUKMK_CNT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("CTGRYNMS", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("CTGRYNOS", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("CVR_PRC", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY02", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY02_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY02_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY03", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY03_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY03_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY04", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY04_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY04_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY05", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY05_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_CATEGORY05_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("IMG_URL", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_SIZE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DSGN_GRP_NO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EVL_CNT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EVL_SCORE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOD_DC_RT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOD_ICONS", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOD_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOD_NO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOD_SALE_SECT_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOD_TP_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ITM_NO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("LAST_SALE_PRC", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("LGCY_GOD_NO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("OTLT_YN", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("RPRST_GOD_YN", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SALE_DETAIL_BEG_DT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SALE_DETAIL_END_DT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SALE_TP_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SOLDOUT_YN", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("STD_SIZE_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("STD_SIZE_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("STD_SIZE_SECT_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("STD_SIZE_SECT_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("TAG_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("NEW_GOD_DSP_DT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BST_GOD_SORT_SEQ", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOD_SRCH_SNM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("COLOR_CHIP", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_STYLE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_COLOR", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_COLOR2", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_STYLE2", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_PRICE", (byte) (Protocol.SelectSet.NONE)) };
		} else if (queryCheck == 3) {
			selectSet = new SelectSet[] {
					new SelectSet("BRND_ID", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_IMG_ALTRTV_CONT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_IMG_FILE_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_IMG_FILE_URL", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROMT_TAG_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("CTGRY_OUTPT_TP_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DQ_BRAND", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DSP_BEG_DT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DSP_CTGRY_NO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DSP_END_DT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DVC_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MOBILE_IMG_ALTRTV_CONT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MOBILE_IMG_FILE_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MOBILE_IMG_FILE_URL", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("OUTPT_LINK_URL", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("OUTPT_SECT_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PC_IMG_ALTRTV_CONT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PC_IMG_FILE_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PC_IMG_FILE_URL", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROMT_ASSTN_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROMT_GUBUN", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROMT_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROMT_SN", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PROMT_TP_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("TGT_MBR_ATRB_CD", (byte) (Protocol.SelectSet.NONE)) };
		} else if (queryCheck == 2) {
			selectSet = new SelectSet[] { 
					new SelectSet("BRND_ID", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_IMG_ALTRTV_CONT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_IMG_FILE_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_IMG_FILE_URL", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("BRND_KOR_FLTER_NM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("CTGRY_OUTPT_TP_CD", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DSP_CTGRY_NO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("OUTPT_LINK_URL", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("OUTPT_SECT_CD", (byte) (Protocol.SelectSet.NONE)) };
		};

	

	return selectSet;

	}

	/* 오탈자 체크 */
	public static boolean setKeywordCheck(String searchQuery) throws Exception {
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

	@Override
	public String modifyResponseJson(RestHttpRequest request, QuerySet querySet, ResultSet resultSet, String resultJson,
			int returnCode, HashMap<String, String> responseHeaders) {
		String checksch = request.getParams().get("sch");
		String tcgubuncheck = request.getParams().get("tcgubun");
		QueryParser queryParser = new QueryParser();            //QueryParser
		Query query = null;   
		Gson gson=new Gson();
		JsonParser jsonParser=new JsonParser();
		
		if (resultSet != null) {
			Result[] resultList = resultSet.getResultList();
			if (resultList.length >= 2) {
				int totalcheck = resultList[0].getTotalSize();
				setSearchLog(tcgubuncheck, totalcheck, checksch);
			}
		}
		if(returnCode > -100){ 	
			JsonObject resultJsonObj = jsonParser.parse(resultJson).getAsJsonObject();
			JsonArray resultJsonArr = resultJsonObj.get("resultSet").getAsJsonObject().get("result").getAsJsonArray();
			for (int i = 0; i < resultJsonArr.size(); i++) {
				query = querySet.getQuery(i);
				
				if(returnCode < 1){
					System.out.println(returnCode+" ##### total_nanet= " + queryParser.queryToString(query));
				}
				JsonArray groupResultArray = resultJsonArr.get(i).getAsJsonObject().get("groupResult").getAsJsonArray();
				for(int j=0; j < groupResultArray.size(); j++){
					 GroupBySet groupBySet = query.getGroupSelectFields()[j];
					 JsonObject groupResultObj = groupResultArray.get(j).getAsJsonObject();
					 String[] groupCheck= groupResultObj.get("ids").toString().split(",");
					 
					 if(groupCheck.length>2) {
						 for (int k = 0; k < groupCheck.length; k++) {
							 if(groupCheck[k].length()==2 ||groupCheck[k].length()==3) {
								 JsonArray groupCheckArray = (JsonArray) groupResultObj.get("ids");
								 JsonArray groupCheckArray1 = (JsonArray) groupResultObj.get("values");
								 groupCheckArray.remove(k);
								 groupCheckArray1.remove(k);
							 }
						 }
					 }
					 groupResultObj.addProperty("field", String.valueOf(groupBySet.getField()));
					
				}
			}
			//System.out.println(gson.toJson(resultJsonObj));
			return gson.toJson(resultJsonObj);
		}else{
			if(querySet != null){
				query = querySet.getQuery(0);
				System.out.println(returnCode+" ##### total_nanet= " + queryParser.queryToString(query));
			}
		}

		

		return resultJson;
	}

	public static void setSearchLog(String tcgubuncheck, int tatalcheck, String checksch) {

		CommandSearchRequest command = null;
		Query query = new Query();
		QuerySet querySet = new QuerySet(1);

		CommandSearchRequest.setProps("127.0.0.1", 5555, 5000, 100, 100);
		command = new CommandSearchRequest("127.0.0.1", 5555);

		SelectSet[] selectSets = new SelectSet[] { new SelectSet("ALL") };
		WhereSet[] whereSet = null;
		if (tatalcheck > 0) {
			whereSet = new WhereSet[] { new WhereSet("IDX_CHECK", Protocol.WhereSet.OP_HASALL, "a") };
		} else if (tatalcheck <= 0) {
			whereSet = new WhereSet[] { new WhereSet("IDX_CHECK", Protocol.WhereSet.OP_HASALL, "b") };
		}

		query.setFrom("LOG_" + tcgubuncheck.toUpperCase());

		query.setLoggable(true);
		query.setLogKeyword(checksch.toCharArray());
		query.setResult(0, 0);
		query.setDebug(true);
		query.setWhere(whereSet);
		query.setSelect(selectSets);
		querySet.addQuery(query);

		try {
			int returncode = command.request(querySet);
			System.out.println("[ Log search returncode ] = " + returncode + ", [ sch ] = " + checksch);
		} catch (IRException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
