<%@ page import="com.diquest.ir.client.command.CommandSearchRequest"%>
<%@ page import="java.util.*"%>
<%@ page import="com.diquest.ir.common.msg.protocol.Protocol"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.FilterSet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.GroupBySet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.OrderBySet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.Query"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.QueryParser"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.QuerySet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.SelectSet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.WhereSet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.result.GroupResult"%>
<%@ page import="com.diquest.ir.common.msg.protocol.result.Result"%>
<%@ page import="com.diquest.ir.common.msg.protocol.result.ResultSet"%>
<%@ page import="com.diquest.ir.util.encode.Encoder"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
	request.setCharacterEncoding("utf-8");
	String adminIP = "127.0.0.1";   //검색어
	String adminPORT = "5555";   //검색어
	
	String searchTerm = nullToStr(request.getParameter("searchTerm"), "");   //검색어
	String menu = "auto";  //검색 메뉴(검색 컬렉션) as
	
	Map<String,String> params = new HashMap<>();
	params.put("adminIP", adminIP);
	params.put("adminPORT", adminPORT);
	params.put("searchTerm", searchTerm); 
	params.put("menu", menu); 
	
	ArrayList<HashMap<String, String>> autoList = getResultAutoKeyword(params);
	
	%>
	<%!
	public ArrayList<HashMap<String, String>> getResultAutoKeyword(Map<String,String> params) {
		
		ArrayList<HashMap<String,String>> autoList = new ArrayList<>();
		
		String adminIp = params.get("adminIP");
		int adminPort = Integer.parseInt(params.get("adminPORT"));
		
		SelectSet[] selectSet = getSelectSet();
		Query query = getQuery(params, "auto");
		
		QuerySet querySet = new QuerySet(1);
		querySet.addQuery(query);
		

		
		int realSize=0;
		
		try{
			CommandSearchRequest.setProps(adminIp, adminPort, 10000, 50, 50);
			CommandSearchRequest command = new CommandSearchRequest(adminIp, adminPort);
			
			int returnCode = command.request(querySet);
			if(returnCode > 0){
				
				ResultSet resultSet = command.getResultSet();
				Result[] resultList = resultSet.getResultList();
				
				
				for(int i=0; i<resultList.length; i++){
					Result result = resultList[i];
					realSize = result.getRealSize();
					String corrected = "";
					String originQuery = "";
					
					if(result.getValue("typo-result") != null) {
						corrected = result.getValue("typo-result");
					}
					
					if(realSize <= 0) {
						
						QuerySet querySet02 = new QuerySet(1);
						
						
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
							WhereSet[] whereSet = null;
							
							whereSet = new WhereSet[whereList.size()];
							
							for (int k = 0; k < whereSet.length; k++) {
								whereSet[k] = whereList.get(k);
							}
							
							OrderBySet[] orderBySet = null;
							
							selectSet = getSelectSet();
							orderBySet = getOrderBySet();
							
							
							
							int start = 0;
							int end = 9;

							Query auto_query = new Query();
							
							auto_query.setSelect(selectSet);
							auto_query.setOrderby(orderBySet);
							auto_query.setResult(start, end);
							auto_query.setWhere(whereSet);
							auto_query.setFrom("AUTO");
							auto_query.setDebug(true);
							auto_query.setFaultless(true);
							auto_query.setPrintQuery(true);
							
							
							
							querySet02.addQuery(auto_query);
							
							//auto_query.setGroupBy(groupBySet);
							
							CommandSearchRequest.setProps(adminIp, adminPort, 10000, 50, 50);
							command = new CommandSearchRequest(adminIp, adminPort);
							
						    returnCode = command.request(querySet02);
							
							resultSet= command.getResultSet();
							resultList = resultSet.getResultList();
							
							for(int u=0; u<resultList.length; u++){
								result = resultList[u];
								realSize = result.getRealSize();
								for(int j=0; j<result.getRealSize(); j++){
									HashMap<String, String> tempMap = new HashMap<>();
									for(int k=0; k<result.getNumField(); k++){
										String fieldNm = new String(selectSet[k].getField());
										tempMap.put(fieldNm, new String(result.getResult(j, k)));
									}
									autoList.add(tempMap);
								}
							}
						}
					}else {
						for(int j=0; j<result.getRealSize(); j++){
							HashMap<String, String> tempMap = new HashMap<>();
							
							for(int k=0; k<result.getNumField(); k++){
								String fieldNm = new String(selectSet[k].getField());
								tempMap.put(fieldNm, new String(result.getResult(j, k)));
							}
								
							autoList.add(tempMap);
						}
					}
					
					
				}
			}
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return autoList;
	}
	
	public Query getQuery(Map<String, String> params, String menu) {
		Map<String, Object> queryMap = null;

		String searchTerm = params.get("searchTerm");
		String collection = "AUTO";
		String logKeyword = searchTerm;
		int start = 0;
		int end = 9;

		char[] startTag = "<em class='sc_point'>".toCharArray();
		char[] endTag = "</em>".toCharArray();

		Query query = new Query(startTag, endTag);
		SelectSet[] selectSet = null;
		WhereSet[] whereSet = null;
		OrderBySet[] orderBySet = null;


		selectSet = getSelectSet();
		whereSet = getWhereSet(params);
		orderBySet = getOrderBySet();

		query.setSelect(selectSet);
		query.setWhere(whereSet);
		query.setOrderby(orderBySet);
		query.setResult(start, end);
		query.setFrom(collection);
		query.setDebug(true);
		query.setFaultless(true);
		query.setPrintQuery(true);

		QueryParser parser = new QueryParser();
		
		query.setResultModifier("typo");
		query.setValue("typo-parameters", searchTerm);
		query.setValue("typo-options","ALPHABETS_TO_HANGUL|HANGUL_TO_HANGUL");  // 한영변환
		
		
		
		
		query.setSearchOption(
				(byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));
		// 동의어, 유의어 확장
		query.setThesaurusOption(
				(byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));

		return query;
	}
	// SelectSet
		public SelectSet[] getSelectSet() {
			SelectSet[] selectSet = null;

			selectSet = new SelectSet[] { 
			new SelectSet("KEYWORD", Protocol.SelectSet.NONE),
			new SelectSet("COUNT", Protocol.SelectSet.NONE) };

			return selectSet;
		}
		//WhereSet 
		public WhereSet[] getWhereSet( Map<String, String> params) {
			WhereSet[] whereSet = null;
			ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();

			String searchTerm = params.get("searchTerm");
			
			if (!searchTerm.equals("")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereList.add(new WhereSet("IDX_KEYWORD_AUTO", Protocol.WhereSet.OP_HASALL, searchTerm));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_KEYWORD_CHO", Protocol.WhereSet.OP_HASALL, searchTerm));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			}
			whereSet = whereList.toArray(new WhereSet[whereList.size()]);

			return whereSet;
		}
		// OrderBy 
		public OrderBySet[] getOrderBySet() {
			OrderBySet[] orderBySet = null;
				orderBySet = new OrderBySet[] {	new OrderBySet(true, "SORT_COUNT", Protocol.OrderBySet.OP_POSTWEIGHT) };			
			return orderBySet;
		}
		
		// null 체크
		public String nullToStr(Object object, String convertStr) {
			String tempStr = convertStr == null ? "" : convertStr;

			if (object == null || object.equals("")) {
				return trimStr(tempStr);
			}

			return trimStr(object.toString());
		}
		 
		// 공백 제거
		public String trimStr(String object) {
			if (object == null) {
				return "";
			}

			return object.trim();
		}

%>
<%		
for (int i = 0; i < autoList.size(); i++) {
	Map<String, String> tempMap = autoList.get(i);
	String KEYWORD = tempMap.get("KEYWORD");
	int k=i+1;
	System.out.println(k);
%>
<li id ='autokey<%=k %>' onclick="hotKeySearch('<%=KEYWORD %>'); return false;"><a href='#'><span><%=KEYWORD %></span></a></li>
<%}%>