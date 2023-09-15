package com.diquest.ir.rest.extension;

import java.util.ArrayList;
import java.util.Map;

import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.GroupBySet;
import com.diquest.ir.common.msg.protocol.query.OrderBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QueryParser;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;

public class AUTOCOMPLETE implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub

	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		Map<String, String> SearchUtil = request.getParams();

		String sch = SearchUtil.get("sch") != null ? SearchUtil.get("sch") : ""; // 검색어

		QuerySet querySet = null;
		querySet = new QuerySet(1);


		Query auto_query = null;

		auto_query = query_fn(sch);
		querySet.addQuery(auto_query);
		
		 return querySet;
	}

	private Query query_fn(String search) {
		
		Query query = new Query();
		query.setResult(0, 9);
		query.setDebug(true);
		query.setPrintQuery(false);
		query.setFrom("AUTOCOMPLETE");
		query.setLoggable(false);
		query.setLogKeyword(search.toCharArray());
		query.setSelect(selectSet_fn());
		query.setWhere(whereSet_fn(search));
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

	private WhereSet[] whereSet_fn(String search) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();

		whereList.add(new WhereSet("IDX_KEYWORD", Protocol.WhereSet.OP_HASALL, search));
		whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		whereList.add(new WhereSet("IDX_KEYWORD_CHO", Protocol.WhereSet.OP_HASALL, search));//랭킹닭컴용
		//whereList.add(new WhereSet("CHO_IDX_KEYWORD", Protocol.WhereSet.OP_HASALL, search)); //로컬용-nhn다이퀘스트

		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for (int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}

		return whereSet;
	}

	private SelectSet[] selectSet_fn() {
		SelectSet[] selectSet = new SelectSet[] {

				new SelectSet("KEYWORD", (byte) (Protocol.SelectSet.HIGHLIGHT))

		};
		return selectSet;
	}

}
