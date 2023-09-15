package com.diquest.ir.rest.extension;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import com.diquest.ir.client.command.CommandSearchRequest;
import com.diquest.ir.common.exception.IRException;
import com.diquest.ir.common.msg.protocol.Protocol;
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

public class PicoSearch implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		QuerySet querySet = null;
		querySet = new QuerySet(1);
		
		Query query01 = null; // 쿼리1
		//Query query02 = null; // 쿼리2
		//Query query03 = null; // 쿼리3
		
		
		query01 =query_fn(request,1);
		//query02 =query_fn(request,2);
		//query03 =query_fn(request,3);
		
		querySet.addQuery(query01);
		//querySet.addQuery(query02);
		//querySet.addQuery(query03);
		 //System.out.println("::::queryParser::::\n"+queryParser.queryToString(query));
		return querySet;
	}

	private Query query_fn(RestHttpRequest request, int i) {
		Map<String, String> SearchUtil = request.getParams();
		String sword = SearchUtil.get("sword") != null ? SearchUtil.get("sword") : ""; // 검색어
		String schlist = SearchUtil.get("schlist");if (schlist == null)schlist = sword; // 재검색용 검색어
		String resch = SearchUtil.get("resch") != null ? SearchUtil.get("resch") : "N"; // 결과내 검색 체크
		String notsch = SearchUtil.get("notsch") != null ? SearchUtil.get("notsch") : "N"; // 결과내 검색 체크
		String page=SearchUtil.get("page") != null ? SearchUtil.get("page") : "1"; // startindex
		String perDiv=SearchUtil.get("perDiv") != null ? SearchUtil.get("perDiv") : "10"; // endindex
		String userId=SearchUtil.get("userId") != null ? SearchUtil.get("userId") : "";
		String gubun=SearchUtil.get("gubun") != null ? SearchUtil.get("gubun") : "";		
	
		
		if ((!sword.equals("") && resch.equals("Y") )||(!sword.equals("") && notsch.equals("Y") )) {
			if(schlist.indexOf(sword) >1) {
				//schlist = schlist;
			}else {
				schlist = schlist + "@@" + sword;
			}
		} else {
			schlist = sword;
		}
	//	
		int page2 = Integer.parseInt(page);
		int page3 = Integer.parseInt(perDiv);
		int startPage = (page2 - 1) * page3; 
		int endPage = startPage + (page3 - 1); 
		
		char[] startTag = "".toCharArray();
		char[] endTag = "".toCharArray();
		
		
		
		
		Query query = new Query(startTag, endTag);
		
		query.setResult(startPage, endPage);
		query.setDebug(true);
		query.setPrintQuery(true);
		
		if(gubun.equals("HOSP")) {
			query.setFrom("HOSP");
		}else if(gubun.equals("DRUG")) {
			query.setFrom("SHOP");
		}else if(gubun.equals("DOMAE")) {
			query.setFrom("DOMAE");
		}	    
	    
	    query.setUserName(userId);
		
		if (!sword.equals("")) {
			query.setLoggable(true);
			if(resch.equals("Y")) {
				query.setLogKeyword(schlist.replace("@@", " ").toCharArray());
			}else {
				query.setLogKeyword(sword.toCharArray());
			}
			
		}
		
		query.setQueryModifier("diver");				
		query.setRankingOption((byte) (Protocol.RankingOption.CATEGORY_RANKING|Protocol.RankingOption.DOCUMENT_RANKING));
		query.setCategoryRankingOption((byte) (Protocol.CategoryRankingOption.QUASI_SYNONYM| Protocol.CategoryRankingOption.EQUIV_SYNONYM | Protocol.CategoryRankingOption.MULTI_TERM_KOREAN));
		
		try {
			if (setKeywordCheck(sword)) {
				query.setRedirect(sword);
				query.setResultModifier("typo");
				query.setValue("typo-parameters", sword);
				query.setValue("typo-options","ALPHABETS_TO_HANGUL|HANGUL_TO_HANGUL|REMOVE_HANGUL_JAMO_ALL|CORRECT_HANGUL_SPELL");
				query.setValue("typo-correct-result-num", "1");
			}
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		SearchUtil.put("schlist", schlist);
		SearchUtil.put("resch", resch);
		SearchUtil.put("notsch", notsch);
		
		query.setSelect(selectSet_fn(SearchUtil));
		query.setWhere(whereSet_fn(SearchUtil));
		query.setOrderby(orderSet_fn(SearchUtil));
		if(!gubun.equals("DOMAE")) {
			query.setGroupBy(groupSet_fn(SearchUtil));
		}
		
		
		
	
		// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
		query.setSearchOption((byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));
	
		// 동의어, 유의어 확장
		query.setThesaurusOption((byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));
		return query;
		
		
		
	}


private GroupBySet[] groupSet_fn(Map<String, String> searchUtil) {
	GroupBySet[] GroupBySet = null;
		GroupBySet = new GroupBySet[] {
				new GroupBySet("GROUP_EUPMYEONDONG",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 읍동
				new GroupBySet("GROUP_SIGUNGU",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 시
				new GroupBySet("GROUP_SIDO",(byte) (Protocol.GroupBySet.OP_COUNT | Protocol.GroupBySet.ORDER_NAME), "ASC", ""), // 군구
				
		};
	return GroupBySet;
	}

//	private GroupBySet[] groupSet_fn(Map<String, String> searchUtil) {
//		// TODO Auto-generated method stub
//		return null;
//	}

	private OrderBySet[] orderSet_fn(Map<String, String> searchUtil) {
		String sortflag=searchUtil.get("sortflag") !=null ? searchUtil.get("sortflag"):"";
		String gubun=searchUtil.get("gubun") !=null ? searchUtil.get("gubun"):"";
		
		OrderBySet[] orderBySet=null;
		if(gubun.equals("DOMAE")) {
			orderBySet = new OrderBySet[] {
					new OrderBySet(true, "SORT_REGDATE", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 등록일순
		}else {
			if(sortflag.equals("ordqty")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_DAYORDQTY", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 판매량순
			}else if(sortflag.equals("goodsname")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_GOODSNAME", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 상품명순
			}else if(sortflag.equals("dayordusercnt")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_DAYORDUSERCNT", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 구매처순
			}else if(sortflag.equals("maxprice")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_PRICE", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 높은가격순
			}else if(sortflag.equals("minprice")) {
				orderBySet = new OrderBySet[] {
						new OrderBySet(false, "SORT_PRICE", Protocol.OrderBySet.OP_POSTWEIGHT) }; // 낮은가격순
			}else {
				orderBySet = new OrderBySet[] {
						new OrderBySet(true, "SORT_DAYORDQTY", Protocol.OrderBySet.OP_PREWEIGHT) }; // 정확도순
			}
		}
		
		// TODO Auto-generated method stub
		return orderBySet;
	}

	private WhereSet[] whereSet_fn(Map<String, String> searchUtil) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		String[] searchTerm_Array = searchUtil.get("schlist").split("@@");
		String skey=searchUtil.get("skey")!=null? searchUtil.get("skey"):"total";
		String resch=searchUtil.get("resch")!=null? searchUtil.get("resch"):"N";
		String notsch=searchUtil.get("notsch")!=null? searchUtil.get("notsch"):"N";
		String sMafcnm=searchUtil.get("sMafcnm")!=null? searchUtil.get("sMafcnm"):"";  //병원몰 검색창--제조사입력
		
		String lcate=searchUtil.get("lcate") != null ? searchUtil.get("lcate") : "";  //대카테고리
		String mcate=searchUtil.get("mcate") != null ? searchUtil.get("mcate") : "";  //중카테고리
		String scate=searchUtil.get("scate") != null ? searchUtil.get("scate") : "";  //소카테고리
		
		String sido=searchUtil.get("sido") != null ? searchUtil.get("sido") : "";    //시도
		String sigungu=searchUtil.get("sigungu") != null ? searchUtil.get("sigungu") : ""; //시군구
		String eupmyeondong=searchUtil.get("eupmyeondong") != null ? searchUtil.get("eupmyeondong") : ""; //읍동
		
		String gubun=searchUtil.get("gubun") !=null ? searchUtil.get("gubun"):"";
		//************도매몰 파라미터**************
		String dlrno=searchUtil.get("dlrno") !=null ? searchUtil.get("dlrno"):"";  				//공급사번호  ---> 입접업체 검색 도 가능
		String pcatenm=searchUtil.get("pcatenm") !=null ? searchUtil.get("pcatenm"):"";  		//카테고리번호
		String stdcode=searchUtil.get("stdcode") !=null ? searchUtil.get("stdcode"):"";			//표준코드
		String mafcnm=searchUtil.get("mafcnm") !=null ? searchUtil.get("mafcnm"):"";			//제조사
		String godsnm=searchUtil.get("godsnm") !=null ? searchUtil.get("godsnm"):"";			//상품이름
		
		if(!gubun.equals("DOMAE")) {
			if(!searchTerm_Array[0].equals("")) {
				for (int i = 0; i < searchTerm_Array.length; i++) {
					
					if (i != 0) {
						if(resch.equals("Y"))whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
						else if(notsch.equals("Y"))whereList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
					}
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					
						if(skey.equals("total")) {
							whereList.add(new WhereSet("IDX_GOODSNAME", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1000));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_GOODSNAME_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_STDCODE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_POLICYCODE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_ELEMENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_ELEMENT_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_MAFCNM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_MAFCNM_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
						}else if(skey.equals("sGoodsName")) {//상품명
							whereList.add(new WhereSet("IDX_GOODSNAME", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1000));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_GOODSNAME_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
						}else if(skey.equals("sStdcode")) { //표준코드
							whereList.add(new WhereSet("IDX_STDCODE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1000));
						}else if(skey.equals("sPolicycode")) {//보험코드
							whereList.add(new WhereSet("IDX_POLICYCODE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1000));
						}else if(skey.equals("sElement")) {//주요성분
							whereList.add(new WhereSet("IDX_ELEMENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1000));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_ELEMENT_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
						}else if(skey.equals("sMafcnm")) {//제조사
							whereList.add(new WhereSet("IDX_MAFCNM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 1000));
							whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
							whereList.add(new WhereSet("IDX_MAFCNM_BI", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i], 100));
						}
					
					
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
					
				}
			}
		}else if(gubun.equals("DOMAE")) {
			if(!godsnm.equals("")) {
				if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_GOODSNAME", Protocol.WhereSet.OP_HASALL, godsnm, 1000));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_GOODSNAME_BI", Protocol.WhereSet.OP_HASALL, godsnm, 100));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			if(!pcatenm.equals("")) {
				if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet("IDX_PCATEIDX", Protocol.WhereSet.OP_HASALL, pcatenm, 1000));
			}
			if(!stdcode.equals("")) {
				if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet("IDX_STDCODE", Protocol.WhereSet.OP_HASALL, stdcode, 1000));
			}
			if(!dlrno.equals("")) {
				if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet("IDX_DEALERNO", Protocol.WhereSet.OP_HASALL, dlrno, 1000));
			}
			if(!mafcnm.equals("")) {
				if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				whereList.add(new WhereSet("IDX_MAFCNM", Protocol.WhereSet.OP_HASALL, mafcnm, 1000));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_MAFCNM_BI", Protocol.WhereSet.OP_HASALL, mafcnm, 100));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
		}
		
		//카테고리검색
		if(!lcate.equals("")||!mcate.equals("")||!scate.equals("")) {
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
			if(!lcate.equals(""))whereList.add(new WhereSet("IDX_LCATE", Protocol.WhereSet.OP_HASANY, lcate, 300));
			if(!mcate.equals(""))whereList.add(new WhereSet("IDX_MCATE", Protocol.WhereSet.OP_HASANY, mcate, 500));
			if(!scate.equals(""))whereList.add(new WhereSet("IDX_SCATE", Protocol.WhereSet.OP_HASANY, scate, 1000));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		}
		
		//지역별검색
		if(!sido.equals("")||!sigungu.equals("")||!eupmyeondong.equals("")) {
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
			if(!sido.equals("")&&!sigungu.equals("")&&!eupmyeondong.equals("")) {
				whereList.add(new WhereSet("IDX_EUPMYEONDONG", Protocol.WhereSet.OP_HASANY, sido+"@"+sigungu+"@"+eupmyeondong+"#전국", 0));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_SIGUNGU", Protocol.WhereSet.OP_HASANY, sido+"@"+sigungu+"#전국", 0));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_SIDO", Protocol.WhereSet.OP_HASANY, sido+"#전국", 0));
			}else if(!sido.equals("")&&!sigungu.equals("")&&eupmyeondong.equals("")) {
				whereList.add(new WhereSet("IDX_SIGUNGU", Protocol.WhereSet.OP_HASANY, sido+"@"+sigungu+"#전국", 0));
				whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereList.add(new WhereSet("IDX_SIDO", Protocol.WhereSet.OP_HASANY, sido+"#전국", 0));
			}else if(!sido.equals("")&&sigungu.equals("")&&eupmyeondong.equals("")) {
				whereList.add(new WhereSet("IDX_SIDO", Protocol.WhereSet.OP_HASANY, sido+"#전국", 0));
			}
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		}
		
		
		//제조사입력창-병원몰
		if(!sMafcnm.equals("")) {
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
			whereList.add(new WhereSet("IDX_MAFCNM", Protocol.WhereSet.OP_HASALL, sMafcnm, 0));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
			whereList.add(new WhereSet("IDX_MAFCNM_BI", Protocol.WhereSet.OP_HASALL, sMafcnm, 0));
			whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		}
		//입점업체_공급사로 검색
		if(!gubun.equals("DOMAE")&&!dlrno.equals("")) {
			if(whereList.size()>0)whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
			whereList.add(new WhereSet("IDX_DEALERNOSTR", Protocol.WhereSet.OP_HASALL, dlrno, 1000));
		}
		
		
		WhereSet[] whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
		return whereSet;
	}

	private SelectSet[] selectSet_fn(Map<String, String> searchUtil) {
		
		String gubun=searchUtil.get("gubun") !=null ? searchUtil.get("gubun"):"";
		SelectSet[]	selectSet=null;
		if(gubun.equals("DOMAE")) {
			selectSet = new SelectSet[] {
					new SelectSet("GOODSMASTERNO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PCATENAME", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PCATEIDX", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOODSNAME", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MAFCNM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOODSSTND", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PACKUNIT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("POLICYCODE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("STDCODE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ELEMENT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EFFECTIVE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DESCRIPTION", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("IMGPATH", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("IMGFNAME", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DRUGPIC", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DEALERNO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DEALERNAME", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOODSNO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("REGDATE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MODDATE", (byte) (Protocol.SelectSet.NONE)),
					};
		}else {
			selectSet = new SelectSet[] {
					new SelectSet("GOODSMASTERNO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PCATEIDXSTR", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOODSNAME", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MAFCNM", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("GOODSSTND", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PACKUNIT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("STDCODE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("POLICYCODE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ELEMENT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EFFECTIVE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DESCRIPTION", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("IMGFNAME", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("IMGPATH", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DRUGPIC", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DAYORDQTY", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DAYORDUSERCNT", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("PRICE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ISSPC", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ISGRP", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("ISLOWEST", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MODDATE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("LCATE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("MCATE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SCATE", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SIDO", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("SIGUNGU", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("EUPMYEONDONG", (byte) (Protocol.SelectSet.NONE)),
					new SelectSet("DEALERNOSTR", (byte) (Protocol.SelectSet.NONE)),
					};
		}
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
	

}
