package com.diquest.ir.rest.extension;

import java.util.ArrayList;
import java.util.Map;

import com.diquest.ir.client.command.CommandSearchRequest;
import com.diquest.ir.common.exception.IRException;
import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.OrderBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.common.msg.protocol.result.Result;
import com.diquest.ir.common.msg.protocol.result.ResultSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;
import com.diquest.ir.util.encode.Encoder;

public class AutoComplete implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub

	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		Map<String, String> SearchUtil = request.getParams();

		String sch = SearchUtil.get("sword") != null ? SearchUtil.get("sword") : ""; 									// 검색어
		String gubun=SearchUtil.get("gubun") != null ? SearchUtil.get("gubun") : "";							// 병원/약국/도매 구분
		String schTerm=null;
		if(gubun.equals("HOSP")) {
			schTerm="HOSP";
		}else if(gubun.equals("DRUG")) {
			schTerm="SHOP";
		}else if(gubun.equals("DOMAE")) {
			schTerm="DOMAE";
		}

		QuerySet querySet = null;
		querySet = new QuerySet(1);


		Query auto_query = null;

		auto_query = query_fn(sch,schTerm);
		
		CommandSearchRequest command=null;
		
		CommandSearchRequest.setProps("127.0.0.1", 5555, 5000, 100, 100);
		command = new CommandSearchRequest("127.0.0.1", 5555);
		
		querySet.addQuery(auto_query);
		
		int returnCode=0;
		Result result = null;
		Result[] resultlist = null;
		int realSize=0;

				
		try {
			returnCode = command.request(querySet);
			if(returnCode > 0) {
				ResultSet results = command.getResultSet();
				resultlist = results.getResultList();
				result = resultlist[0];
				realSize = result.getRealSize();
				
				String corrected = "";
				String originQuery = "";
				
				if(result.getValue("typo-result") != null) {
					corrected = result.getValue("typo-result");
				}
				
				if(realSize <= 0) {
					String qcQuery = corrected;
					if(qcQuery != null && !qcQuery.equals("")) {
						qcQuery = Encoder.encodeAuto(qcQuery);
						originQuery = qcQuery;
						ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
						whereList.clear();
						whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
						whereList.add(new WhereSet("IDX_KEYWORD_AUTO", Protocol.WhereSet.OP_HASALL, originQuery)); //자동완성
						whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
						whereList.add(new WhereSet("IDX_KEYWORD_CHO", Protocol.WhereSet.OP_HASALL, originQuery)); //초성검색
						whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
						whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
						whereList.add(new WhereSet("IDX_COLLECTION_ID", Protocol.WhereSet.OP_HASALL, schTerm)); // 구분값
						WhereSet[] whereSet = null;
						whereSet = new WhereSet[whereList.size()];
						for (int i = 0; i < whereSet.length; i++) {
							whereSet[i] = whereList.get(i);
						}
						auto_query.setWhere(whereSet);
						querySet.addQuery(auto_query);
						//auto_query.setGroupBy(groupBySet);
					}
				}
			}
			
		} catch(IRException e) {
			e.printStackTrace();
		}

		 return querySet;
	}

	private Query query_fn(String search, String tcgubun) {
		char[] startTag = "<span class=\"text-primary\">".toCharArray();
		char[] endTag = "</span>".toCharArray();
		Query query = new Query(startTag,endTag);
		query.setResult(0, 9);
		query.setDebug(true);
		query.setPrintQuery(true);
		query.setFrom("AUTOCOMPLETE");
		query.setLoggable(false);
		query.setLogKeyword(search.toCharArray());
		query.setSelect(selectSet_fn());
		query.setWhere(whereSet_fn(search,tcgubun));
		query.setOrderby(orderSet_fn());
		
		query.setResultModifier("typo");
		query.setValue("typo-parameters", search);
		
		// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
		query.setSearchOption(
		(byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));

		// 동의어, 유의어 확장
		query.setThesaurusOption(
		(byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));

				
		//System.out.println("::::queryParser::::\n"+queryParser.queryToString(query));
		return query;
	}

	private OrderBySet[] orderSet_fn() {
		OrderBySet[] orderBySet = null;
		
		orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_COUNT", Protocol.OrderBySet.OP_NONE) }; // 검색횟수순
		
		return orderBySet;

	}

	private WhereSet[] whereSet_fn(String search, String schTerm) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		whereList.add(new WhereSet("IDX_KEYWORD_AUTO", Protocol.WhereSet.OP_HASALL, search)); //자동완성
		whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		whereList.add(new WhereSet("IDX_KEYWORD_CHO", Protocol.WhereSet.OP_HASALL, search)); //초성검색
		whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
		whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
		whereList.add(new WhereSet("IDX_COLLECTION_ID", Protocol.WhereSet.OP_HASALL, schTerm)); //구분값
		

		WhereSet[] whereSet =new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}

		return whereSet;
	}

	private SelectSet[] selectSet_fn() {
		SelectSet[] selectSet = new SelectSet[] {

				new SelectSet("KEYWORD", (byte) (Protocol.SelectSet.HIGHLIGHT)),

		};
		return selectSet;
	}

}
