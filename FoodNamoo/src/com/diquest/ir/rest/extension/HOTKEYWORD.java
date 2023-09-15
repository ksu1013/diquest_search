package com.diquest.ir.rest.extension;

import java.util.Map;

import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.OrderBySet;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.rest.common.object.RestHttpRequest;

public class HOTKEYWORD implements QuerySetExtension {

	@Override
	public void init() {
		// TODO Auto-generated method stub
		
	}

	@Override
	public QuerySet makeQuerySet(RestHttpRequest request) {
		String collection = "HOTKEYWORD";
		
		
		Query query = new Query();
		QuerySet qeurySet= new QuerySet(1);

		query.setLoggable(false);
		query.setDebug(true);
		query.setPrintQuery(false);
		query.setSearchKeyword("foodnamoo_hot");
		query.setFrom(collection);
		query.setResult(0, 9);

		SelectSet[] selectSet = new SelectSet[] {

				new SelectSet("KEYWORD"), new SelectSet("RANKING"),new SelectSet("PRV_RANK")

		};

		WhereSet[] whereSet = new WhereSet[] {

				new WhereSet("IDX_TRENDS_ID", Protocol.WhereSet.OP_HASALL, "foodnamoo_hot"),

		};

		OrderBySet[] orderbys = new OrderBySet[] {

				new OrderBySet(true, "SORT_RANKING", Protocol.OrderBySet.OP_NONE)

		};

		query.setSearchOption(
				(byte) (Protocol.SearchOption.CACHE));
		
		
		
		query.setSelect(selectSet);
		query.setWhere(whereSet);
		query.setOrderby(orderbys);
		qeurySet.addQuery(query);
		return qeurySet;

	}
	}


