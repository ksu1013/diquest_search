<%@page import="java.util.regex.Pattern"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.ArrayList.*"%>
<%@ page import="java.text.*"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDate"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.QuerySet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.Query"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.SelectSet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.WhereSet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.FilterSet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.GroupBySet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.query.OrderBySet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.result.ResultSet"%>
<%@ page import="com.diquest.ir.common.msg.protocol.result.Result"%>
<%@ page import="com.diquest.ir.common.msg.protocol.result.GroupResult"%>
<%@ page import="com.diquest.ir.common.msg.protocol.Protocol"%>
<%@ page import="com.diquest.ir.client.command.CommandSearchRequest"%>
<%@page import="com.diquest.ir.common.msg.protocol.query.QueryParser"%>


<%
request.setCharacterEncoding("utf-8");

String adminIP = "127.0.0.1";
String adminPORT = "5555";

// *****************************************************************************************
String menu = nullToStr(request.getParameter("totalSearch"), "total");
String order = nullToStr(request.getParameter("order"), "dateDesc");
String searchTerm = nullToStr(request.getParameter("searchTerm"), "");
String re_searchTerm = nullToStr(request.getParameter("re_searchTerm"), searchTerm);
String collection = nullToStr(request.getParameter("collection"), "");
String re_searchCheck = nullToStr(request.getParameter("re_searchCheck"), "");
String oper = nullToStr(request.getParameter("oper"), "and");
String searchArea = nullToStr(request.getParameter("searchArea"), "all");
String currentPage = nullToStr(request.getParameter("currentPage"), "1");
String notKeyWord = nullToStr(request.getParameter("notKeyWord"), "");
String rseultsize = nullToStr(request.getParameter("rseultsize"), "10");
String detaildate = nullToStr(request.getParameter("date"), "msAll3");
String startDate = nullToStr(request.getParameter("startDate"), "");
String endDate = nullToStr(request.getParameter("endDate"), "");


String rowsperPage = menu.equals("total") ? "2" : rseultsize;   // 미디어 오피스 제외 나머지 2개
String rowsperPage_media = menu.equals("total") ? "4" : rseultsize;  //미디어는 4개
String rowsperPage_office = menu.equals("total") ? "3" : rseultsize;  // 오피스는 3개



if (!searchTerm.equals("") && re_searchCheck.equals("on")) {
	if (re_searchTerm.indexOf(searchTerm) < 0) {
		re_searchTerm = re_searchTerm + "###" + searchTerm;
	}
} else {
	re_searchTerm = searchTerm;
}



Map<String, String> params = new HashMap<String, String>();

params.put("mip", adminIP);
params.put("mport", adminPORT);
params.put("menu", menu);
params.put("searchTerm", searchTerm);
params.put("re_searchTerm", re_searchTerm);
params.put("collection", collection);
params.put("re_searchCheck", re_searchCheck);
params.put("oper", oper);
params.put("searchArea", searchArea);
params.put("currentPage", currentPage);
params.put("rowsperPage", rowsperPage);
params.put("rowsperPage_media", rowsperPage_media);
params.put("rowsperPage_office", rowsperPage_office);
params.put("order", order);
params.put("notKeyWord", notKeyWord);
params.put("detaildate", detaildate);
params.put("startDate", startDate);
params.put("endDate", endDate);

//result
ArrayList<HashMap<String, String>> hotList = getResultHot(params);
Map<String, Object> resultMap = getResult(params);

int totalSize = (int) resultMap.get("totalSize");
int webpageSize = (int) resultMap.get("webpageSize");
int boardSize = (int) resultMap.get("boardSize");
int multimediaSize = (int) resultMap.get("multimediaSize");
int officeSize = (int) resultMap.get("officeSize");
int culturalSize = (int) resultMap.get("culturalSize");

ArrayList<HashMap<String, String>> webpageList = (ArrayList<HashMap<String, String>>) resultMap.get("webpageList");
ArrayList<HashMap<String, String>> boardList = (ArrayList<HashMap<String, String>>) resultMap.get("boardList");
ArrayList<HashMap<String, String>> officeList = (ArrayList<HashMap<String, String>>) resultMap.get("officeList");
ArrayList<HashMap<String, String>> multimediaList = (ArrayList<HashMap<String, String>>) resultMap.get("multimediaList");
ArrayList<HashMap<String, String>> culturalList = (ArrayList<HashMap<String, String>>) resultMap.get("culturalList");

String pageNaviStr = "";

if (!menu.equals("total")) {
	int paramTotalSize = 0;
	if (menu.equals("webpage")) {
		paramTotalSize = webpageSize;
	} else if (menu.equals("board")) {
		paramTotalSize = boardSize;
	} else if (menu.equals("multimedia")) {
		paramTotalSize = multimediaSize;
	} else if (menu.equals("office")) {
		paramTotalSize = officeSize;
	} else if (menu.equals("cultural")) {
		paramTotalSize = culturalSize;
	}
	pageNaviStr = getPageNavi(menu, currentPage, paramTotalSize,rseultsize);
}
// *****************************************************************************************
%>
<%!
public Map<String, Object> getResult(Map<String, String> params) {
	
	//result
	Map<String, Object> resultMap = new HashMap<String, Object>();
	int totalSize =0;
	int webpageSize =0;
	int boardSize =0;
	int multimediaSize =0;
	int officeSize =0;
	int culturalSize=0;
	
	ArrayList<HashMap<String, String>> webpageList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> boardList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> officeList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> multimediaList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> culturalList = new ArrayList<HashMap<String, String>>();
	
	//param
	String mip = params.get("mip");
	String mport = params.get("mport");
	String menu = params.get("menu");
	String searchTerm = params.get("searchTerm");
	String re_searchTerm = params.get("re_searchTerm");
	String collection = params.get("collection");
	String re_searchCheck = params.get("re_searchCheck");
	String oper = params.get("oper");
	String searchArea = params.get("searchArea");
	String notKeyWord = params.get("notKeyWord");
	
	Map<String, Query> queryMap = new HashMap<String, Query>();
	ArrayList<String> menuKey = new ArrayList<String>();
	
	if (menu.equals("total")) {
		
		queryMap.put("webpage", getQuery(params, "webpage"));
		menuKey.add("webpage");
	 
		queryMap.put("board", getQuery(params, "board"));
		menuKey.add("board");
	
		queryMap.put("multimedia", getQuery(params, "multimedia"));
		menuKey.add("multimedia");
	
		queryMap.put("office", getQuery(params, "office"));
		menuKey.add("office");
	
		queryMap.put("cultural", getQuery(params, "cultural"));
		menuKey.add("cultural");
	
	} else {
		queryMap.put(menu, getQuery(params, menu));
		menuKey.add(menu);
	}

	QuerySet querySet = new QuerySet(queryMap.size());
	
	
	for (int i=0; i<queryMap.size(); i++) {
		querySet.addQuery(queryMap.get(menuKey.get(i).toString()));
	}
	
	try {
		CommandSearchRequest.setProps(mip, Integer.parseInt(mport), 10000, 50, 50);	// ip, port, 응답시간, min pool size, max pool size
	    CommandSearchRequest command = new CommandSearchRequest(mip, Integer.parseInt(mport));
		
		int returnCode = command.request(querySet);
		
		if (returnCode > 0) {
			ResultSet resultSet = command.getResultSet();
			Result[] resultlist = resultSet.getResultList();
			
			for (int i=0; i<resultlist.length; i++) {
				Result result = resultlist[i];
				
				int tempTotalSize = result.getTotalSize();
				totalSize = totalSize + tempTotalSize;
				
				String key = menuKey.get(i).toString();
				SelectSet[] selectSet = getSelectSet(key);
    			
    			//Result
    			for (int j=0; j<result.getRealSize(); j++) {
					HashMap<String, String> tempMap = new HashMap<String, String>();
					
					for (int k=0; k < result.getNumField(); k++) {
						String filedname = new String(selectSet[k].getField());
						tempMap.put(filedname, new String(result.getResult(j, k)));
					}
					
					if (key.equals("webpage")) {
						webpageSize = tempTotalSize;
						webpageList.add(tempMap);
					} else if (key.equals("board")) {
						boardSize = tempTotalSize;
						boardList.add(tempMap);
					} else if (key.equals("office")) {
						officeSize = tempTotalSize;
						officeList.add(tempMap);
					} else if (key.equals("multimedia")) {
						multimediaSize = tempTotalSize;
						multimediaList.add(tempMap);
					} else if (key.equals("cultural")) {
						culturalSize = tempTotalSize;
						culturalList.add(tempMap);
					} 
				}
			}
		} else {
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	
	resultMap.put("totalSize", totalSize);
	
	resultMap.put("webpageSize", webpageSize);
	resultMap.put("boardSize", boardSize);
	resultMap.put("officeSize", officeSize);
	resultMap.put("multimediaSize", multimediaSize);
	resultMap.put("culturalSize", culturalSize);
	
	resultMap.put("webpageList", webpageList);
	resultMap.put("boardList", boardList);
	resultMap.put("officeList", officeList);
	resultMap.put("multimediaList", multimediaList);
	resultMap.put("culturalList", culturalList);
	
	
	
	return resultMap;
}

public ArrayList<HashMap<String, String>> getResultHot(Map<String, String> params) {
	
	//result
	ArrayList<HashMap<String, String>> hotList = new ArrayList<HashMap<String, String>>();
	
	//param
	String mip = params.get("mip");
	String mport = params.get("mport");
	String menu = params.get("menu");
	String searchTerm = params.get("searchTerm");
	String re_searchTerm = params.get("re_searchTerm");
	String collection = params.get("collection");
	String re_searchCheck = params.get("re_searchCheck");
	
	SelectSet[] selectSet = getSelectSet("HOT");
	Query query = getQuery(params, "HOT");

	QuerySet querySet = new QuerySet(1);
	querySet.addQuery(query);
	
	try {
		CommandSearchRequest.setProps(mip, Integer.parseInt(mport), 10000, 50, 50);	// ip, port, 응답시간, min pool size, max pool size
	    CommandSearchRequest command = new CommandSearchRequest(mip, Integer.parseInt(mport));
		
		int returnCode = command.request(querySet);
		
		if (returnCode > 0) {
			ResultSet resultSet = command.getResultSet();
			Result[] resultlist = resultSet.getResultList();
			
			for (int i=0; i<resultlist.length; i++) {
				Result result = resultlist[i];
    			
    			//Result
    			for (int j=0; j<result.getRealSize(); j++) {
					HashMap<String, String> tempMap = new HashMap<String, String>();
					
					for (int k=0; k < result.getNumField(); k++) {
						String filedname = new String(selectSet[k].getField());
						tempMap.put(filedname, new String(result.getResult(j, k)));
					}
					
					hotList.add(tempMap); 
				}
			}
		} else {
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	
	return hotList;
}

public Query getQuery(Map<String, String> params, String menu) {
	
	String searchTerm = params.get("searchTerm");
	String re_searchTerm = params.get("re_searchTerm");
	String re_searchCheck = params.get("re_searchCheck");
	String oper = params.get("oper");
	String currentPage = params.get("currentPage");
	String rowsperPage = params.get("rowsperPage");
	String rowsperPage_media = params.get("rowsperPage_media");
	String rowsperPage_office = params.get("rowsperPage_office");
	String order = params.get("order");
	String notKeyWord = params.get("notKeyWord");
	String startDate = params.get("startDate");
	String endDate = params.get("endDate");
	
	String collection = menu;
	String logKeyword = searchTerm;
	int start =0;
	int end=0;
	if(menu.equals("multimedia")){
		start=getPageStart(currentPage, rowsperPage_media);
		end = getPageEnd(currentPage, rowsperPage_media);
	}
	if(menu.equals("office")){
		start=getPageStart(currentPage, rowsperPage_office);
		end = getPageEnd(currentPage, rowsperPage_office);
	}
	if(menu.equals("webpage") || menu.equals("board") || menu.equals("cultural")){
		start=getPageStart(currentPage, rowsperPage);
		end = getPageEnd(currentPage, rowsperPage);
	}
	
	
    
    
    char[] startTag = "<font color='red'>".toCharArray();
    char[] endTag = "</font>".toCharArray();
		
	Query query = new Query(startTag, endTag);
	SelectSet[] selectSet = null;
	WhereSet[] whereSet = null;   
	OrderBySet[] orderBySet = null;
	FilterSet[] filterSet = null;
	
	if (menu.equals("webpage")) {
		collection = "WEBPAGE";
	} 
    
    if (menu.equals("board")) {
    	collection = "BOARD";
	} 
	
    if (menu.equals("multimedia")) {
    	collection = "MULTIMEDIA";
	} 

    if (menu.equals("office")) {
    	collection = "OFFICE";
	} 

    if (menu.equals("cultural")) {
    	collection = "CULTURAL";
	} 


    if (menu.equals("HOT")) {
    	collection = "HOTKEYWORD";
    	start = 0;
    	end = 9;
    	logKeyword = "";
	} 
    
    selectSet = getSelectSet(menu);
    whereSet = getWhereSet(menu, params); 
    orderBySet = getOrderBySet(menu,order);  
    if(!startDate.equals("")&&(menu.equals("board")||menu.equals("multimedia")||menu.equals("cultural"))){
    	filterSet = getfilterSet(menu,params); 
    	query.setFilter(filterSet);
    }
         
    
    query.setSelect(selectSet);
    if(!searchTerm.isEmpty()){
		query.setWhere(whereSet);
    }
	if (orderBySet != null) {
		query.setOrderby(orderBySet);
	}
	query.setResult(start, end);
	query.setFrom(collection);
	query.setDebug(true);
	query.setFaultless(true);
	query.setPrintQuery(true);
	if ( (logKeyword != null || ! logKeyword.equals("") )&&logKeyword.length()!=0) {
		if(setKeywordCheck(logKeyword)){
			query.setLoggable(true);
			query.setLogKeyword(logKeyword.toCharArray());
		}
		
	}
	
	query.setSearchOption((byte)(Protocol.SearchOption.CACHE | Protocol.SearchOption.BANNED | Protocol.SearchOption.STOPWORD));	// 검색 캐시, 금지어, 불용어 사전 사용 설정 
	query.setThesaurusOption((byte)(Protocol.ThesaurusOption.QUASI_SYNONYM | Protocol.ThesaurusOption.EQUIV_SYNONYM));			// 동의어, 유의어 사전 사용 설정 
	
	return query;
	
}


/* 오탈자 체크 */
public boolean setKeywordCheck(String searchQuery) {
	boolean keyBoolean = true;
	/* String temp = searchQuery.substring((searchQuery.length() - 1));
	String reg = "[ㄱ-ㅎ]";
	if(Pattern.matches(temp, reg)){
		return false;
	}  */
	
	char[] charkeyword = searchQuery.toCharArray();
	for (int i = 0; i < charkeyword.length; i++) {
		int ck = (int) charkeyword[i];
		if ((ck >= 12593 && ck <= 12622) || (ck >= 12623 && ck <= 12643) ) {
			keyBoolean = false;
		}
	}
	return keyBoolean;
}



public OrderBySet[] getOrderBySet(String menu,String order) {
		
	OrderBySet[] orderBySet = null;
	
	
	if (menu.equals("HOT")) { 
		orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_RANKING", Protocol.OrderBySet.OP_NONE) };         
	}else if(menu.equals("webpage")){
		
		
		if(order.equals("titleAsc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_MENU_NM", Protocol.OrderBySet.OP_POSTWEIGHT) };     // 이름순
		}else if(order.equals("weighthDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_MENU_NM", Protocol.OrderBySet.OP_PREWEIGHT) };   //정확도
		}else if(order.equals("dateDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_MENU_NM", Protocol.OrderBySet.OP_POSTWEIGHT) };     //날짜순
		} 
		
	}else if(menu.equals("board")){
		if(order.equals("titleAsc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_DATA_TITLE", Protocol.OrderBySet.OP_POSTWEIGHT) };    // 이름순
		}else if(order.equals("weighthDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGISTER_DATE", Protocol.OrderBySet.OP_PREWEIGHT) };   //정확도
		}else if(order.equals("dateDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGISTER_DATE", Protocol.OrderBySet.OP_POSTWEIGHT) };   //날짜순
		}
		
	}else if(menu.equals("multimedia")){
		if(order.equals("titleAsc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_DATA_TITLE", Protocol.OrderBySet.OP_POSTWEIGHT) };  // 이름순
		}else if(order.equals("weighthDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGDATE", Protocol.OrderBySet.OP_PREWEIGHT) };      //정확도
		}else if(order.equals("dateDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGDATE", Protocol.OrderBySet.OP_POSTWEIGHT) };     //날짜순
		}
		
	}else if(menu.equals("office")){
		if(order.equals("titleAsc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_USER_NM", Protocol.OrderBySet.OP_POSTWEIGHT) };  // 이름순
		}else if(order.equals("weighthDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_USER_NM", Protocol.OrderBySet.OP_PREWEIGHT) };      //정확도
		}else if(order.equals("dateDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_USER_NM", Protocol.OrderBySet.OP_POSTWEIGHT) };     //날짜순
		}
		
	}else if(menu.equals("cultural")){
		if(order.equals("titleAsc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_DATA_TITLE", Protocol.OrderBySet.OP_POSTWEIGHT) };  // 이름순
		}else if(order.equals("weighthDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGISTER_DATE", Protocol.OrderBySet.OP_PREWEIGHT) };      //정확도
		}else if(order.equals("dateDesc")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGISTER_DATE", Protocol.OrderBySet.OP_POSTWEIGHT) };     //날짜순
		}
	}
	
	
	
	return orderBySet;
	
}

public FilterSet[] getfilterSet(String menu,Map<String, String> params) {
	
	String[] schRange={params.get("startDate")+"000000",params.get("endDate")+"000000"};
	FilterSet[] filterSet = null;
	
	if(menu.equals("board")){
		filterSet = new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_REGISTER_DATE", schRange) };	//날짜 필터
	}else if(menu.equals("multimedia")){
		filterSet = new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_REGDATE", schRange) };	//날짜 필터
	}else if(menu.equals("cultural")){
		filterSet = new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_REGISTER_DATE", schRange) };	//날짜 필터
	}
	
	return filterSet;
	//return null;
	
}


public WhereSet[] getWhereSet(String menu, Map<String, String> params) {
	
	String searchTerm = params.get("searchTerm");
	
	String re_searchTerm = params.get("re_searchTerm");
	String oper = params.get("oper");
	String searchArea = params.get("searchArea");
	String notKeyWord = params.get("notKeyWord");
	
	
	byte operation=0;;
	byte notwhereSetOption=0;
	
	//연산자 부분 whereset 옵션에 넣기
	if(oper.equals("and")||oper.equals("not")){
		operation=Protocol.WhereSet.OP_HASALL;
	}else if(oper.equals("or")){
		operation=Protocol.WhereSet.OP_HASANY;
	}
	
	String[] searchTermArr = re_searchTerm.split("###");
	
	ArrayList<WhereSet> whereSetList = new ArrayList<WhereSet>();
    WhereSet[] whereSet = null;
    
    if (menu.equals("HOT")) {
    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
    	whereSetList.add(new WhereSet("IDX_TRENDS_ID", Protocol.WhereSet.OP_HASALL, "trend_jangsu"));
    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
	} else {
		for (int i=0; i<searchTermArr.length; i++) {
	 		searchTerm = searchTermArr[i];
	 		
	 		if (i > 0) {
 				whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
	 		}
	 		
	 		if (menu.equals("webpage")) {
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				if (searchArea.equals("all")) {
					whereSetList.add(new WhereSet("IDX_MENU_NM", operation, searchTerm, 300));
		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		 	    	whereSetList.add(new WhereSet("IDX_FULL_NM", operation, searchTerm, 200));
		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		 	    	whereSetList.add(new WhereSet("IDX_MENU_NM_BI", operation, searchTerm, 10));
		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		 	    	whereSetList.add(new WhereSet("IDX_FULL_NM_BI", operation, searchTerm, 10));
		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		 	    	whereSetList.add(new WhereSet("IDX_CONTENTS_CONTENT", operation, searchTerm, 100));
		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		 	    	whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", operation, searchTerm, 1));
	 	    	}  else {
	 	    		
	 	    		if (searchArea.indexOf("title") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_MENU_NM", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_MENU_NM_BI", operation, searchTerm, 100));
	 	    		}
	 	    		if (searchArea.indexOf("content") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_CONTENTS_CONTENT", operation, searchTerm, 300));
	 	    		}
	 	    		if (searchArea.indexOf("total") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_MENU_NM", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_MENU_NM_BI", operation, searchTerm, 100));
	 		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_CONTENTS_CONTENT", operation, searchTerm, 300));
	 	    		}
	 	    	} 
				
				if(oper.equals("not")){
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", operation, notKeyWord));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
	 		} 
	 	    
	 	    if (menu.equals("board")) {
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
	 	    	if (searchArea.equals("all")) {
	 	    		whereSetList.add(new WhereSet("IDX_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm, 200));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_FULL_NM_BI", Protocol.WhereSet.OP_HASALL, searchTerm, 10));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", Protocol.WhereSet.OP_HASALL, searchTerm, 10));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", Protocol.WhereSet.OP_HASALL, searchTerm, 1));
	 	    	}  else {
	 	    		if (searchArea.indexOf("title") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", operation, searchTerm, 100));
	 	    		}
	 	    		if (searchArea.indexOf("content") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_CONTENT", operation, searchTerm, 300));
	 	    		}
	 	    		if (searchArea.indexOf("total") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", operation, searchTerm, 100));
	 		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_CONTENT", operation, searchTerm, 300));
	 	    		}
	 	    	} 
	 	    	
	 	    	if(oper.equals("not")){
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", operation, notKeyWord));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
	 	    	
	 	    	
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
	 		} 

	 	    if (menu.equals("office")) {
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
	 	    	if (searchArea.equals("all")) {
	 	    		whereSetList.add(new WhereSet("IDX_USER_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_OFFICENMS", Protocol.WhereSet.OP_HASALL, searchTerm, 200));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_OFFICE_PT_MEMO", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_OFFICE_TEL", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_USER_NM_BI", Protocol.WhereSet.OP_HASALL, searchTerm, 10));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_OFFICENMS_BI", Protocol.WhereSet.OP_HASALL, searchTerm, 10));
	 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	 	    	whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", Protocol.WhereSet.OP_HASALL, searchTerm, 1));
	 	    	}else {
	 	    		if (searchArea.indexOf("title") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_USER_NM", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_USER_NM_BI", operation, searchTerm, 100));
	 	    		}
	 	    		if (searchArea.indexOf("content") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_OFFICE_PT_MEMO", operation, searchTerm, 300));
	 	    		}
	 	    		if (searchArea.indexOf("total") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_USER_NM", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_USER_NM_BI", operation, searchTerm, 100));
	 		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_OFFICE_PT_MEMO", operation, searchTerm, 300));
	 	    		}
	 	    	} 
	 	    	
	 	    	if(oper.equals("not")){
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", operation, notKeyWord));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
	 	    	
	 	    	
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
	 		} 
	 	    
	 	   if (menu.equals("multimedia")) {
		    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
		    	if (searchArea.equals("all")) {
		    		whereSetList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", Protocol.WhereSet.OP_HASALL, searchTerm, 10));
		    	}else {
	 	    		if (searchArea.indexOf("title") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", operation, searchTerm, 100));
	 	    		}
	 	    		if (searchArea.indexOf("content") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", operation, searchTerm, 300));   // 내용 부분이 없어서 타이틀 바이그램으로 넣음
	 	    		}
	 	    		if (searchArea.indexOf("total") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", operation, searchTerm, 100));
	 	    		}
	 	    	} 
		    	
		    	//total 복합필드 만들어서 넣기
		    	if(oper.equals("not")){
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereSetList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm));
		 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", Protocol.WhereSet.OP_HASALL, searchTerm));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
		    	
		    	
		    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
			} 

	 	    if (menu.equals("cultural")) {
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
	 	    	if (searchArea.equals("all")) {
	 	    		whereSetList.add(new WhereSet("IDX_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereSetList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereSetList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereSetList.add(new WhereSet("IDX_FULL_NM_BI", Protocol.WhereSet.OP_HASALL, searchTerm, 10));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", Protocol.WhereSet.OP_HASALL, searchTerm, 10));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", Protocol.WhereSet.OP_HASALL, searchTerm, 1));
	 	    	}  else {
	 	    		if (searchArea.indexOf("title") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", operation, searchTerm, 100));
	 	    		}
	 	    		if (searchArea.indexOf("content") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_CONTENT", operation, searchTerm, 300));   // 내용 부분이 없어서 타이틀 바이그램으로 넣음
	 	    		}
	 	    		if (searchArea.indexOf("total") > -1) {
	 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE", operation, searchTerm, 300));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_BI", operation, searchTerm, 100));
	 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 		 	    	whereSetList.add(new WhereSet("IDX_DATA_CONTENT", operation, searchTerm, 100));
	 	    		}
	 	    	} 
	 	    	
	 	    	if(oper.equals("not")){
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_NOT));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					whereSetList.add(new WhereSet("IDX_TOTAL_SEARCH", operation, notKeyWord));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
				}
	 	    	
	 	    	
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
	 		} 
	 	}
	}
    whereSet = new WhereSet[whereSetList.size()];
    
    for(int i = 0; i < whereSetList.size(); i++){
    	whereSet[i] = whereSetList.get(i);
    }
	
    return whereSet;
    
}

public SelectSet[] getSelectSet(String menu) {
	
	SelectSet[] selectSet = null;
	
	if (menu.equals("webpage")) {
		selectSet = new SelectSet[]{
				new SelectSet("CONTENTS_CONTENT",(byte) (Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),100),
				new SelectSet("FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)), 
				new SelectSet("MENU_CD", (byte) (Protocol.SelectSet.HIGHLIGHT)), 
				new SelectSet("MENU_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)), 
				new SelectSet("SUB_CONTEXT_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT)) 
		};
	} 

	if (menu.equals("board")) {
		selectSet = new SelectSet[]{
				new SelectSet("BOARD_ID",(byte) (Protocol.SelectSet.HIGHLIGHT)), 
				new SelectSet("DATASID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_CONTENT", (byte) (Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),100),
				new SelectSet("DATA_TITLE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DQ_ID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILENAMES", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILES", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_SIDS", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("MENU_CD", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("REGISTER_DATE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("SUB_CONTEXT_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("multimedia")) {
		selectSet = new SelectSet[]{
				new SelectSet("BOARD_ID"), 
				new SelectSet("DATA_SID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_TITLE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DQ_ID", (byte) (Protocol.SelectSet.HIGHLIGHT), 100),
				new SelectSet("FILE_THUMBNAIL_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("MENU_CD", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("REGDATE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("SUB_CONTEXT_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("office")) {
		selectSet = new SelectSet[]{
				new SelectSet("DQ_ID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("OFFICENMS", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("OFFICE_PT_MEMO", (byte) (Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("OFFICE_TEL", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("USER_NM", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("cultural")) {
		selectSet = new SelectSet[]{
				new SelectSet("BOARD_ID", (byte) (Protocol.SelectSet.HIGHLIGHT)), 
				new SelectSet("DATASID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_CONTENT", (byte) (Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_TITLE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DQ_ID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILENAMES", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILES", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_SIDS", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("MENU_CD", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("REGISTER_DATE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("SUB_CONTEXT_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT)),
		};
	} 

	if (menu.equals("HOT")) {
		selectSet = new SelectSet[]{
				new SelectSet("KEYWORD", Protocol.SelectSet.NONE)
		};
	}
	
	return selectSet;
	
}

public String getPageNavi(String menu, String currentPage, int totalSize, String rseultsize) {
	
	String resultTotalSize = "";
	
	int Curpage = Integer.parseInt(currentPage);
	
	int PageSize = Integer.parseInt(rseultsize);
	
	int pageBlock = 10;
	int startpage = ((Curpage - 1) / pageBlock) * pageBlock + 1;
	int endpage = startpage + pageBlock - 1;
	int lastPage = totalSize / PageSize + (totalSize % PageSize == 0 ? 0 : 1);
	if (endpage > lastPage) {
		endpage = lastPage;
	}
	String pageStr = "<span class=\"first\"><a href=\"javascript:paging('1','" + menu + "');\">처음으로</a></span>&nbsp;&nbsp;";
	
	if (startpage > pageBlock) {
		pageStr = pageStr + "<span class=\"prev\"><a href=\"javascript:prepaging('" + currentPage + "','" + menu + "');\">이전</a></span>&nbsp;&nbsp;";
	}
	
	for (int i=startpage; i<= endpage; i++) {
		
		if(i==Curpage){
			pageStr = pageStr + "<a href=\"javascript:paging('" + i + "','" + menu + "')\" class=\"currentPageNumList currentPageNumOn \">" + i + "</a>&nbsp;&nbsp;";
		}else{
			pageStr = pageStr + "<a href=\"javascript:paging('" + i + "','" + menu + "')\" class=\"currentPageNumList \">" + i + "</a>&nbsp;&nbsp;";

		}
	}
	
	if (endpage < lastPage) {
		pageStr = pageStr + "<span class=\"next\"><a href=\"javascript:nextpaging('" + currentPage + "','" + menu + "');\">다음</a></span>&nbsp;&nbsp;";
	}
	
	pageStr = pageStr + "<span class=\"last\"><a href=\"javascript:paging('" + lastPage + "','" + menu + "');\">끝으로</a></span>";

	return pageStr;
	
}

public String nullToStr(Object object, String convertStr) {
	String tempStr = convertStr == null ? "" : convertStr;

	if(object == null || object.equals("")) {
		return trimStr(tempStr);
	}

	return trimStr(object.toString());
}

public String trimStr(String object) {
	if(object == null) {
		return "";
	}

	return object.trim();
}

public int getPageStart(String currentPage, String rowsperPage) {
	return Integer.parseInt(rowsperPage)*(Integer.parseInt(currentPage)-1);
}

public int getPageEnd(String currentPage, String rowsperPage) {
	return (Integer.parseInt(rowsperPage)*Integer.parseInt(currentPage))-1;
}

%>
    
<!DOCTYPE html>
<html lang="ko">

<head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>장수군청</title>

        <link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/238.css" /> <!-- common.css -->
        <link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/248.css" /> <!-- font.css -->
        <link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/9.css" /> <!-- layout.css -->
        <link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/256.css" /> <!-- 대표layout.css -->
        <link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/242.css" /> <!-- slick.css -->
	<link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/241.css" /> <!-- styleDefault.css -->
        <link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/239.css" /> <!-- 통합검색 css -->
	<link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/255.css" /> <!-- board.css --> <!-- 게시판 공통 -->
	<link rel="stylesheet" type="text/css" href="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/325.css" /> <!-- content.css -->
		

        <script type="text/javascript" src="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/258.js"></script> <!-- jquery-3.4.1.min.js -->
        <script type="text/javascript" src="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/257.js"></script> <!-- slick.js -->
        <script type="text/javascript" src="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/259.js"></script> <!-- defalut.js -->
        <script type="text/javascript" src="http://jangsu-www.skoinfo.co.kr/rfc3/user/domain/jangsu-www.skoinfo.co.kr.80/0/260.js"></script> <!-- defalut.js -->

<link rel="stylesheet" href="//code.jquery.com/ui/1.11.4/themes/smoothness/jquery-ui.css">
 <script type="text/javascript">

$(document).ready(function(e) {
	
	/* 메뉴 불 들어오기*/
	$(".searchTab li a").each(function(idx) {
		if ($(this).attr("menu") == $("#menu_1").val()) {
			$(this).parent().addClass("active");
		}
	});
	
	
	/* 검색어 유무 판단 */
	$(".totalBtn").on("click", function(){
			var searchName =$(".sch_txt").val();
			if ($('.sch_txt').val()==''){
				alert('검색어를 입력하세요');
				return false;
			}else{
				setSearchCookie('cookieName',searchName);
				document.frmSearch.submit();
				
			}
	});
	
	
	var sarea = $('#searchArea').val();
	/* $('input:checkbox[name="sco"]').each(function() {
		if(sarea.indexOf(this.value) > -1){
			this.checked = true;
		}
	}); */

	
	/* 최근검색어  */
	var cookie2 = getSearchCookie('cookieName');
	var text = "";
	var cookie2Arr = cookie2.split('@/');
	cookie2Arr  = cookie2Arr.filter(function(item) {
	return item !== null && item !== undefined && item !== '';
	});
	if(cookie2!=""){
	for(var i=0 ; i < cookie2Arr.length&& i<5 ; i++){
	
	text +="<li><a href=\"javascript:hotKeySearch('"+cookie2Arr[i]+"')\">"+cookie2Arr[i]+"</a></li>";
	}
	}else {
	text += "<li>검색어가 없습니다.</li>";
	}
	$("#recent").html(text); 
	

});

var page3 = 1;

/* 탭 검색 */
function p_menu(menu) {
	document.p_menu_tap.totalSearch.value = menu;
	document.p_menu_tap.currentPage.value = 1;
	document.p_menu_tap.submit();
}

/* 페이지 이동 */
function paging(page, menu) {

	document.p_menu_tap.totalSearch.value = menu
	document.p_menu_tap.currentPage.value = page
	document.p_menu_tap.submit();
}
/* 전 페이지 이동 */
function prepaging(currentPage, menu) {
	var page = parseInt(currentPage) - parseInt(page3);
	document.p_menu_tap.totalSearch.value = menu
	document.p_menu_tap.currentPage.value = page
	document.p_menu_tap.submit();
}

/* 다음페이지 이동 */
function nextpaging(currentPage, menu) {
	var page = parseInt(currentPage) + parseInt(page3);
	
	document.p_menu_tap.totalSearch.value = menu
	document.p_menu_tap.currentPage.value = page
	document.p_menu_tap.submit();
	
}


//상세검색
function fn_area_check(type,check) {
	
	var typeCheck=type;
	
	if(check==1)$('#detail_searchArea').val(typeCheck);   // 검색영역 부분
	if(check==2){										  // 검색 연산자
		if(typeCheck ==="not"){   							// not 검색
			var detailnotKeword=$('#notText').val();
			$('#notKeyWord').val(detailnotKeword)
		}												//not 검색이 아니면 무시
		$('#detail_oper').val(typeCheck);				// 연산자 상세검색 포맷에 넣기
		$('#oper').val(typeCheck);						// 연산자 통합섬색 포맷에 넣기
	}
	
	if(check==3){
		// 현재 날짜 생성
		var currentDate = new Date();
		var MonthDaysAgo = new Date();
		
		if(typeCheck ==='msWeek'){
			MonthDaysAgo.setDate(currentDate.getDate() - 7);
		}else if(typeCheck==='msMonth'){
			MonthDaysAgo.setDate(currentDate.getDate() - 30);
		}else if(typeCheck==='msMonth3'){
			MonthDaysAgo.setMonth(currentDate.getMonth() - 3);
		}else if(typeCheck==='msMonth6'){
			MonthDaysAgo.setMonth(currentDate.getMonth() - 6);
		}
		
		
		
		if(typeCheck != 'msAll3'){
			//날짜가 전체가 아닐경우
			$('#calendar1').val(formatDate(MonthDaysAgo)); //시작날짜
			$('#calendar2').val(formatDate(currentDate)); //끝날짜 
			
			$('#startDate').val(formatDate(MonthDaysAgo)); //통합검색포팻 시작날짜 
			$('#detail_startDate').val(formatDate(MonthDaysAgo)); //상세검색포맷 시작날짜
			
			
			$('#endDate').val(formatDate(currentDate)); //통합검색포팻 끝날짜 
			$('#detail_endDate').val(formatDate(currentDate)); //통합검색포팻 끝날짜
			
		}else if(typeCheck === 'msAll3'){
			//날자가 전체일 경우
			$('#calendar1').val("");
			$('#calendar2').val("");
			
			$('#startDate').val("");
			$('#detail_startDate').val("");
			
			$('#endDate').val("");
			$('#detail_endDate').val("");
		}
		
		
		$('#detail_date').val(typeCheck);   // 전체인지, 최근 1일 ,최근 3개월 등 값 상세검색포맷에 넣기
		$('#date').val(typeCheck);          // 전체인지, 최근 1일 ,최근 3개월 등 값 통합검색포맷에 넣기
		
		
	}
	if(check==4){
		//rseultsize
		$('#detail_rseultsize').val(typeCheck);
		$('#rseultsize').val(typeCheck);
	}
			
	
	
}

//포맷팅 함수
function formatDate(date) {
    var year = date.getFullYear();
    var month = (date.getMonth() + 1).toString().padStart(2, '0');
    var day = date.getDate().toString().padStart(2, '0');
    
    return year + month + day;
}


/* 인기검색어 검색 */
function hotKeySearch(hotKeyword) {
    var searchCheck = document.frmSearch;
    searchCheck.searchTerm.value = hotKeyword;
    searchCheck.totalSearch.value = "total";
    searchCheck.searchArea.value="all";
    searchCheck.oper.value="and";
    searchCheck.notKeyWord.value="";
    searchCheck.rseultsize.value="10";
    searchCheck.date.value="msAll3";
    searchCheck.startDate.value="";
    searchCheck.endDate.value="";
    searchCheck.order.value="";
    searchCheck.submit();
}


/* 최근검색어 쿠키 셋팅 */
function setSearchCookie(cookieName, cookieValue) {
	/*document.frmSearch.submit();*/
	
	var ckName = cookieName.replace("\r","").replace("\n","");
	var ckValue = cookieValue.replace("\r","").replace("\n","");
	
	var ex = getSearchCookie(ckName);
	var index = ex.indexOf(ckValue);
	if(index == -1) {
	document.cookie = ckName + "=" + escape(ckValue + "@/" + ex ).replace("undefined","") + ";";
	}
	var cookie_1 = unescape(document.cookie);
	
	
}


/* 최근검색어 쿠기 가져오기 */
function getSearchCookie(cookieName) {
	var cookie = document.cookie;
	if( cookie.length > 0 ) {
		startIndex = cookie.indexOf(cookieName);
		if( startIndex != -1 ) {
			startIndex += cookieName.length;
			endIndex = cookie.indexOf( ";", startIndex );
			if( endIndex == -1 )
				endIndex = cookie.length;
			return unescape(cookie.substring(startIndex + 1, endIndex));
		} else {
			return "";
		}
	}
	else {
		return "";
	}
}






var index = 0;

//자동완성
function auto_search(){
	var searchTerm = $("#totalText").val();	// 입력된 검색어
	$("#detail_searchTerm").val(searchTerm); //상세 검색에 검색어 저장하기
	// 자동완성 검색 입력 시 자동완성 창 노출
	if(searchTerm == ""){
		$("#autoSearchArea").css('display','none');
		index=0;
	}else{
		$("#autoSearchArea").css('display','block').css('border','1px solid rgb(213, 213, 213)');
	}
	
	/* 방향키 이동 S */
	var e = window.event;
	var key = e.keyCode;
	var listsize = $("#autoSearchList").children().length;
	
	
	if(key == 38){	// 방향키 위
		if(index > 1){
			index--;
		}else if(index == 0 || index == 1){
			index = listsize;
		}
		backcolor();
	}
	
	if(key == 40){	// 방향키 아래
		if(index < listsize){
			index++;
		}else if(index == listsize){
			index = 1;
		}
		backcolor();
	}
	
	/* 방향키 이동 E */
	
	if(!(key == 38||key == 40)){
		/* /* 자동완성 controller 에서 데이터 받아오는 부분 S */
		  $.ajax({
			url:"http://localhost:9090/JangSu/autoKeyword.jsp?menu=auto&searchTerm="+searchTerm,
			type : "POST",
			success: function(data){
				var auto = data;
				$("#autoSearchList").html(auto);
		    },
		    error: function (error){        
		    }
		});  
		/* 자동완성 controller 에서 데이터 받아오는 부분 E */
	}
	
	 
	
}
//현재 선택된 자동완성 데이터 backgroundcolor 바꾸는 함수
function backcolor(){
	var size = $("#autoSearchList").children().length;
	for (i = 1; i <= size; i++) {
		idVal = $("#autokey"+i);
		if (idVal != null) {
			if (i == index){
				//$(idVal).css('background-color','red');
				  var auto_value=idVal.find('span').text();
				  $('#totalText').val(auto_value);
				  $('#detail_searchTerm').val(auto_value);
			}else{
				//$(idVal).css('background-color','');
			}
		}
	}
}

//자동완성 하이라이팅 
function highlight(searchTerm, data){
	if(searchTerm == ''){
		return data;
	}
	var regex = new RegExp(searchTerm,'gi');
	var matchedWord = data.match(regex);
	if(matchedWord != null){
		for (var i = 0; i < matchedWord.length; i++) {
			var regex2 = new RegExp(matchedWord[i],'g');
			data = data.replace(regex2,"<em>" + matchedWord[i] + "</em>");
		}
	}
	
	return data;
}

//달력 출력
$( function() {
    $( "#calendar1" ).datepicker({
    	dateFormat: 'yymmdd'
   });
    $( "#calendar2" ).datepicker({
    	dateFormat: 'yymmdd' });
} );

function checkOrder() {
	var selectedValue = $("#orderCheck").val();
	document.frmSearch.order.value=selectedValue;
	document.frmSearch.submit();
	
}


</script>
<script src="//code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
</head>
<body>
<div class="container">
    <div id="skipNavi">
        <h1 class="noText">본문 바로가기</h1>
        <ul>
            <li><a href="#main-wrap" class="skipLink" onclick="fnMove('1')">본문바로가기</a></li>
        </ul>
    </div>
	<style>
	.currentPageNumList {
	    text-align: center;
	    box-sizing: border-box;
	    font-size: 1em;
	    color: #555;
	    font-family: 'NotokrR';
	    border: 1px solid #d6d6d6;
	    line-height: 38px;
	    border-right: 1px solid #d6d6d6;
	    margin-left: -1px;
        
    }
    .currentPageNumOn{
    
    	    background: #e56534;
    		color: #fff;
    		border-color: #666;
    }
	
	</style> 











<header>
            <div class="headerWrap topHeader">
                <div class="topInner">
                    <a href="#" class="closeBtn"></a>
                    <div class="topLeft">
                        <div class="siteWrap">
                            <a href="#" class="mo_siteBtn">주요 사이트</a>
                            <ul class="siteList">
                                <li><a href="/index.jangsu">장수군청</a></li>
                                <li><a href="/mayor/index.jangsu">열린군수실</a></li>
                                <li><a href="/tour/index.jangsu">문화관광</a></li>
                                <li><a href="/reserve/index.jangsu">통합예약</a></li>
                                <li><a href="/town/index.jangsu">읍면포털</a></li>
                                <li><a href="/health/index.jangsu">보건의료원</a></li>
                                <li><a href="/farming/index.jangsu">농업기술센터</a></li>
                            </ul>
                        </div>
                    </div>

                    <ul class="topRight">
                        <!-- <li class="corona"><a href="#">코로나-19현황</a></li> -->
			<li class="login">
						
							<a href="/j_spring_security_logout?returnUrl=http%3A%2F%2Fjangsu-www.skoinfo.co.kr%2Findex.jangsu%3FcontentsSid%3D1494"  class="mMySelf_btn">로그아웃</a>
						   
			</li>
                        <li class="fonts">
                            <p>글자크기</p>
                            <a href="#n" class="fontPlus">글자크기 증가</a>
                            <a href="#n" class="fontMinus">글자크기 축소</a>
                        </li>
                        <li class="langBox moBox">
                            <label>LANGUAGE</label>
                            <select onchange="transGo()" id="trans">
                        <option>LANGUAGE</option>
                        <option value="1">한국어</option>
                        <option value="2">영어</option>
                        <option value="3">중국어</option>
                        <option value="4">일본어</option>
                        <option value="5">베트남어</option>
                        <option value="6">필리핀어</option>
                    </select>

                    <script>
                        function transGo() {
                            var val = $('#trans').val();
                            if (val == 1) { }
                            else if (val == 2) {
                                window.open('http://jangsu-www.skoinfo.co.kr/eng/index.jangsu');
                            } else if (val == 3) {
                                window.open('http://jangsu-www.skoinfo.co.kr/chi/index.jangsu');
                            } else if (val == 4) {
                                window.open('http://jangsu-www.skoinfo.co.kr/jap/index.jangsu');
                            } else if (val == 5) {
                                window.open('http://jangsu-www.skoinfo.co.kr/viet/index.jangsu');
                            } else if (val == 6) {
                                window.open('http://jangsu-www.skoinfo.co.kr/phil/index.jangsu');
                            }
                        }
                    </script>

                    <div class="mo_langBox">
                        <a href="#n" class="mb_langBtn">LANGUAGE</a>
                        <ul class="mb_langList">
                            <li>
                                <a href="http://jangsu-www.skoinfo.co.kr/index.jangsu">한국어</a>
                            </li>

                            <li>
                                <a href="http://jangsu-www.skoinfo.co.kr/eng/index.jangsu">영어</a>
                            </li>

                            <li>
                                <a href="http://jangsu-www.skoinfo.co.kr/chi/index.jangsu">중국어</a>
                            </li>
                            <li>
                                <a href="http://jangsu-www.skoinfo.co.kr/jap/index.jangsu">일본어</a>
                            </li>
                            <li>
                                <a href="http://jangsu-www.skoinfo.co.kr/viet/index.jangsu">베트남어</a>
                            </li>
                            <li>
                                <a href="http://jangsu-www.skoinfo.co.kr/phil/index.jangsu">필리핀어</a>
                            </li>
                        </ul>
                    </div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="gnb-wrap">
                <div class="header-wrap">
                    <div class="gnb-box-flex">
                        <h1 class="logo">
                            <a href="/index.jangsu">장수군청</a>
                        </h1>

                        <div class="gnb">
                            <ul class="dl">
								

								
								<li class="secs"><!-- crtMenuCd : DOM_000000101 / gnb_menuCd : DOM_000000101  -->
									<a href="/index.jangsu?menuCd=DOM_000000101000000000" class="level1-1"><span>종합민원</span></a>
									
									<div class="sub-gnb type01 ">
										<div class="sub-gnb-wrap">
										<div class="nav">
											
											<div class="nav-tit">
												<p class="tit">종합민원</p>
												<p class="btxt">새롭게 도약하는 행복장수 !</p>
											</div>
											
										<div class="bunch5">
										
										
										
											
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101001000000" class="level2-1  " >
														
														<span>민원안내</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001001000"><span>민원실안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001002000"><span>민원서식</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001003000"><span>민원편람</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001004000"><span>무인민원발급</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001005000"><span>어디서나민원처리제</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001006000"><span>민원편의상담창구</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001007000"><span>폐업신고간소화서비스안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001008000"><span>사전심사청구제도</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001009000"><span>수수료안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001010000"><span>본인서명사실확인제도</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101001011000"><span>가족관계등록</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101002000000" class="level2-1  " >
														
														<span>민원신청</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101002001000"><span>민원신청</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101002002000"><span>정부24</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101002003000"><span>민원처리공개</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101002004000"><span>행정처분공개</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101002005000"><span>선거인명부 이의신청</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101003000000" class="level2-1  " >
														
														<span>여권안내</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101003001000"><span>여권신청발급</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101003002000"><span>여권 재발급</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101003003000"><span>여권민원서식</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101004000000" class="level2-1  " >
														
														<span>지방세안내</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004001000"><span>지방세개요</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004002000"><span>세목별지방세 납부안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004003000"><span>지방세구제제도</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004004000"><span>조회 및 납부(위택스)</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004005000"><span>지방세 상담쳇봇</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004006000"><span>마을세무사</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004007000"><span>납세자보호관</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004008000"><span>표준지방세 개인정보 처리방침</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101004009000"><span>표준지방세외수입 개인정보 처리방침</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101005000000" class="level2-1  " >
														
														<span>교통</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101005001000"><span>차량등록</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101005002000"><span>이륜자동차</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101005003000"><span>버스시간표</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101006000000" class="level2-1  " >
														
														<span>부동산</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101006001000"><span>개별공시지가</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101006002000"><span>개별주택가격</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101006003000"><span>부동산중개업및실거래신고안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101006004000"><span>지적</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101006005000"><span>토지이용계획확인서</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101006006000"><span>등기부열람</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101007000000" class="level2-1  " >
														
														<span>건축/정보통신</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101007001000"><span>건축민원안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101007002000"><span>건축민원처리절차</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101007003000"><span>정보통신검사 민원</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000101008000000" class="level2-1  " >
														
														<span>영조물배상책임보험</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000101008001000"><span>영조물배상책임보험</span></a></li>
														
													
												</ul>
												
											</div>

									
								
								</div>
								</div>
								</div>
								</div>
						
								</li>
								
								<li class="secs"><!-- crtMenuCd : DOM_000000101 / gnb_menuCd : DOM_000000102  -->
									<a href="/index.jangsu?menuCd=DOM_000000102000000000" class="level1-1"><span>소통참여</span></a>
									
									<div class="sub-gnb type01 ">
										<div class="sub-gnb-wrap">
										<div class="nav">
											
											<div class="nav-tit">
												<p class="tit">소통참여</p>
												<p class="btxt">새롭게 도약하는 행복장수 !</p>
											</div>
											
										<div class="bunch5">
										
										
										
											
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102001000000" class="level2-1  " >
														
														<span>장수소식</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001001000"><span>공지사항</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001002000"><span>읍면공지사항</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001003000"><span>읍면이장회보</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001004000"><span>주간행사계획</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001005000"><span>고시·공고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001006000"><span>입법예고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001007000"><span>시험공고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001008000"><span>공시송달</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001009000"><span>장수군보</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001010000"><span>분묘개장공고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001011000"><span>인사발령</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001012000"><span>언론보도</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001013000"><span>포토뉴스</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001014000"><span>문화행사</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102001015000"><span>군정소식지</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102002000000" class="level2-1  " >
														
														<span>계약알림</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102002001000"><span>발주계획</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102002002000"><span>입찰공고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102002003000"><span>개찰결과</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102002004000"><span>계약현황</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102002005000"><span>대가지급현황</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102002006000"><span>법령및서식</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102003000000" class="level2-1  " >
														
														<span>군민의소리</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102003001000"><span>자유게시판</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102003002000"><span>군수에게 바란다</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102003003000"><span>공기관 갑질 피해 제보 창구</span></a></li>
														
															<li class=" blank"><a href="/index.jangsu?menuCd=DOM_000000102003004000" target="_blank" title="새창열림" class="deps3Link" ><span>구인/구직</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102003005000"><span>칭찬합시다</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102003006000"><span>홈페이지개선의견</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102004000000" class="level2-1  " >
														
														<span>정책토론</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102004001000"><span>정책포럼</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102004002000"><span>설문조사</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102004003000"><span>전자공청회</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102005000000" class="level2-1  " >
														
														<span>군민제안</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102005001000"><span>군민제안신청</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102006000000" class="level2-1  " >
														
														<span>고향사랑기부제</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102006001000"><span>고향사랑기부제</span></a></li>
														
															<li class=" blank"><a href="/index.jangsu?menuCd=DOM_000000102006002000" target="_blank" title="새창열림" class="deps3Link" ><span>고향사랑e음</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102007000000" class="level2-1  " >
														
														<span>적극행정</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102007001000"><span>적극행정이란</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102007002000"><span>장수군 적극행정 실행계획</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102007003000"><span>적극행정 우수 공무원 추천</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102007004000"><span>소극행정신고센터</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102008000000" class="level2-1  " >
														
														<span>신고센터</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102008001000"><span>국민신문고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102008002000"><span>환경신고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102008003000"><span>청탁금지신고방</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102008004000"><span>예산낭비신고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102008005000"><span>청렴마당</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000102008006000"><span>국무조정실 규제개혁신문고</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000102009000000" class="level2-1  " >
														
														<span>장수소셜뉴스</span>
													</a>

												
											</div>

									
								
								</div>
								</div>
								</div>
								</div>
						
								</li>
								
								<li class="secs"><!-- crtMenuCd : DOM_000000101 / gnb_menuCd : DOM_000000103  -->
									<a href="/index.jangsu?menuCd=DOM_000000103000000000" class="level1-1"><span>장수안내</span></a>
									
									<div class="sub-gnb type01 ">
										<div class="sub-gnb-wrap">
										<div class="nav">
											
											<div class="nav-tit">
												<p class="tit">장수안내</p>
												<p class="btxt">새롭게 도약하는 행복장수 !</p>
											</div>
											
										<div class="bunch5">
										
										
										
											
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000103001000000" class="level2-1  " >
														
														<span>군청안내</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103001001000"><span>청사안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103001002000"><span>행정조직</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103001003000"><span>부서별전화·팩스번호</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103001004000"><span>직원검색</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103001005000"><span>오시는길</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000103002000000" class="level2-1  " >
														
														<span>장수소개</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002001000"><span>일반현황</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002002000"><span>장수의 역사</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002003000"><span>장수군지</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002004000"><span>행정지도</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002005000"><span>군민헌장</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002006000"><span>상징</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002007000"><span>장수의노래</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002008000"><span>교류도시</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103002009000"><span>생활정보</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000103003000000" class="level2-1  " >
														
														<span>유관기관</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103003001000"><span>공공기관</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103003002000"><span>교육기관</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103003003000"><span>금융기관</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103003004000"><span>장수한우지방공사</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103003005000"><span>(재)장수군애향교육진흥재단</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000103004000000" class="level2-1  " >
														
														<span>부서안내</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103004001000"><span>기획조정실</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103004002000"><span>행정복지국</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103004003000"><span>농산업건설국</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103004004000"><span>보건의료원</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103004005000"><span>농업기술센터</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000103004006000"><span>체육맑은물사업소</span></a></li>
														
													
												</ul>
												
											</div>

									
								
								</div>
								</div>
								</div>
								</div>
						
								</li>
								
								<li class="secs"><!-- crtMenuCd : DOM_000000101 / gnb_menuCd : DOM_000000104  -->
									<a href="/index.jangsu?menuCd=DOM_000000104000000000" class="level1-1"><span>정보공개</span></a>
									
									<div class="sub-gnb type01 ">
										<div class="sub-gnb-wrap">
										<div class="nav">
											
											<div class="nav-tit">
												<p class="tit">정보공개</p>
												<p class="btxt">새롭게 도약하는 행복장수 !</p>
											</div>
											
										<div class="bunch5">
										
										
										
											
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104001000000" class="level2-1  " >
														
														<span>정보공개제도안내</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104001001000"><span>제도안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104001002000"><span>대상기관</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104001003000"><span>비공개세부기준</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104001004000"><span>정보공개처리절차</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104001005000"><span>불복구제절차</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104001006000"><span>수수료안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104001007000"><span>고객수요분석</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104002000000" class="level2-1  " >
														
														<span>정보목록(원문)</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104002001000"><span>정보목록</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104002002000"><span>정보목록(2014년 3월이전)</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104003000000" class="level2-1  " >
														
														<span>사전정보공표</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104003001000"><span>사전정보공개</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104003002000"><span>사전정보공표</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104004000000" class="level2-1  " >
														
														<span>정보공개청구</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104004001000"><span>정보공개청구</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104005000000" class="level2-1  " >
														
														<span>정보공개모니터단</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104005001000"><span>정보공개모니터단</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104006000000" class="level2-1  " >
														
														<span>공공데이터개방</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104006001000"><span>공공데이터개방</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104006002000"><span>공공데이터 수요조사</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104006003000"><span>개인정보 목적 외 이용 및 제3자 제공 현황</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104006004000"><span>공공저작물 이용안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104006005000"><span>공공저작물 자료실</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104007000000" class="level2-1  " >
														
														<span>정책실명제</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104007001000"><span>정책실명제 안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104007002000"><span>정책실명공개과제</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104007003000"><span>국민신청실명제</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104008000000" class="level2-1  " >
														
														<span>업무추진비공개</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104008001000"><span>업무추진비공개</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104009000000" class="level2-1  " >
														
														<span>상품권구매/사용내역 공개</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104009001000"><span>상품권구매/사용내역 공개</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104010000000" class="level2-1  " >
														
														<span>계약정보공개</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104010001000"><span>계약정보공개</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000104011000000" class="level2-1  " >
														
														<span>조직정보공개</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000104011001000"><span>조직정보공개</span></a></li>
														
													
												</ul>
												
											</div>

									
								
								</div>
								</div>
								</div>
								</div>
						
								</li>
								
								<li class="secs"><!-- crtMenuCd : DOM_000000101 / gnb_menuCd : DOM_000000105  -->
									<a href="/index.jangsu?menuCd=DOM_000000105000000000" class="level1-1"><span>행정정보</span></a>
									
									<div class="sub-gnb type01 ">
										<div class="sub-gnb-wrap">
										<div class="nav">
											
											<div class="nav-tit">
												<p class="tit">행정정보</p>
												<p class="btxt">새롭게 도약하는 행복장수 !</p>
											</div>
											
										<div class="bunch5">
										
										
										
											
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000105001000000" class="level2-1  " >
														
														<span>예산/재정</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001001000"><span>예산서</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001002000"><span>기금운용계획</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001003000"><span>중기지방재정계획</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001004000"><span>재정공시·결산</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001005000"><span>지방공기업</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001006000"><span>세입·세출현황</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001007000"><span>주민참여예산제도</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001008000"><span>지방보조금</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105001009000"><span>학술연구</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000105002000000" class="level2-1  " >
														
														<span>자치법규</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105002001000"><span>자치법규검색</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105002002000"><span>조례규칙입법예고</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105002003000"><span>법무행정정보</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000105003000000" class="level2-1  " >
														
														<span>통계</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105003001000"><span>인구통계</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105003002000"><span>사업체통계</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105003003000"><span>사회조사보고서</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105003004000"><span>통계연보</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105003005000"><span>차량등록현황</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000105004000000" class="level2-1  " >
														
														<span>행정규제개혁</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105004001000"><span>규제개혁안내</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105004002000"><span>등록규제현황</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105004003000"><span>규제입증요청</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105004004000"><span>지방기업 규제 애로 신고센터</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000105005000000" class="level2-1  " >
														
														<span>행정서비스헌장</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105005001000"><span>민원행정</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105005002000"><span>건축행정</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105005003000"><span>복지행정</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105005004000"><span>환경위생행정</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105005005000"><span>농∙임∙축산∙지도행정</span></a></li>
														
													
												</ul>
												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000105006000000" class="level2-1  " >
														
														<span>군정정보</span>
													</a>

												
												<ul class="level3-1 ">
													
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105006001000"><span>주간업무계획</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105006002000"><span>주간행사계획</span></a></li>
														
															<li class=" "><a href="/index.jangsu?menuCd=DOM_000000105006003000"><span>수상내역</span></a></li>
														
													
												</ul>
												
											</div>

									
								
								</div>
								</div>
								</div>
								</div>
						
								</li>
								
								<li class="secs"><!-- crtMenuCd : DOM_000000101 / gnb_menuCd : DOM_000000106  -->
									<a href="/index.jangsu?menuCd=DOM_000000106000000000" class="level1-1"><span>분야별정보</span></a>
									
									<div class="sub-gnb field ">
										<div class="sub-gnb-wrap">
										<div class="nav">
											
										<div class="bunch5">
										
										
										
											
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106001000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon1.png"/>
															</div>
														
														<span>안전</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106002000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon2.png"/>
															</div>
														
														<span>농업·축산업·임업</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106003000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon3.png"/>
															</div>
														
														<span>산업경제</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106004000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon4.png"/>
															</div>
														
														<span>귀농귀촌지원</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106005000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon5.png"/>
															</div>
														
														<span>인구정책</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106006000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon6.png"/>
															</div>
														
														<span>보건의료</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106007000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon7.png"/>
															</div>
														
														<span>복지</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106008000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon8.png"/>
															</div>
														
														<span>도로명주소</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106009000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon9.png"/>
															</div>
														
														<span>환경·위생</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106010000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon10.png"/>
															</div>
														
														<span>문화·체육</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106011000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon11.png"/>
															</div>
														
														<span>교통</span>
													</a>

												
											</div>

									
											<div class="level ">

													<a href="/index.jangsu?menuCd=DOM_000000106012000000" class="level2-1 list " >
														
															<div>
																<img src="/images/layout/field_icon12.png"/>
															</div>
														
														<span>한누리전당</span>
													</a>

												
											</div>

									
								
								</div>
								</div>
								</div>
								</div>
						
								</li>
								

                                


                            </ul>

                        </div>

                        <div class="gnb_right">
                            <a href="/index.jangsu?menuCd=DOM_000000107001000000" class="siteMapBtn">
                                <div class="img"></div>
                                <span>사이트맵</span>
                            </a>

                            <a href="#n" class="nuriBtn">
                                <div class="img"></div>
                                <span>주요누리집</span>
                            </a>
                        </div>

                        <div class="mb-btn-wrap">
                            <a href="#n" class="toggle">메뉴</a>

                            <div class="search-wrap">
                                <a href="#n">검색</a>
                                <div class="search-box"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
</header>





<script>

        // 메뉴 mouseover 이벤트    
        const gnb = document.querySelector('.gnb');
        const header = document.querySelector('header')
        
        // mouseover
        gnb.addEventListener('mouseover', function (e) {
            // 이벤트버블링 막기
            e.preventDefault();
            e.stopPropagation()
            header.classList.add('active');
            header.classList.add('gnbOn');
        })

        // mouseout
        gnb.addEventListener('mouseout', function (e) {
            // 이벤트버블링 막기
            e.preventDefault();
            e.stopPropagation();
            header.classList.remove('active');
            header.classList.remove('gnbOn');
        })

        // window 스크롤시 header 스타일변경 이벤트
    window.addEventListener('scroll', function (e) {
        // 이벤트버블링 막기
        e.preventDefault();
        e.stopPropagation();

        let scrollY = window.scrollY;

        if (scrollY > 0) {
            header.classList.add('active')

            // 스크롤 후 active class 고정
            gnb.addEventListener('mouseout', function (e) {
                e.preventDefault();
                e.stopPropagation();
                header.classList.add('active');
            })
        } else if (scrollY == 0) {
            header.classList.remove('active')

            gnb.addEventListener('mouseout', function (e) {
                e.preventDefault();
                e.stopPropagation();
                header.classList.remove('active');
            })
        }

        else {
            header.classList.remove('active');
        }
    })
</script>

                                                      
                                                                                                                                                                          <!-- header -->

		



	









<!-- subCntArea :s -->
<div class="searchWrap">
    <div class="content-wrap">
        <!-- s: contents -->
        <div class="contents">
            <div class="totalSearchWrap">
                <!-- 통합검색영역 -->
                <div class="searchBox">
                    <div class="formBox headSearch totalHead">
                    
                        <form method="get" action="JangSu.jsp" name="frmSearch" id="frmSearch">
                       <!-- <form method="get" action="index.jangsu" name="frmSearch" id="frmSearch"> -->
							<input type="hidden" name="contentSid" value="1494">
							<input type="hidden" name="currentPage" value="1">
							<input type="hidden" name="re_searchTerm" value="<%=re_searchTerm %>">
							<input type="hidden" id="re_searchCheck" name="re_searchCheck" value="<%=re_searchCheck %>">
							<input type="hidden" id="searchArea" name="searchArea" value="<%=searchArea %>">
							<input type="hidden" id="oper" name="oper" value="<%=oper %>">
							<input type="hidden" id="notKeyWord" name="notKeyWord" value="<%=notKeyWord %>">
							<input type="hidden" id="rseultsize" name="rseultsize" value="<%=rseultsize %>">
							<input type="hidden" id="date" name="date" value="<%=detaildate %>">
							<input type="hidden" id="startDate" name="startDate" value="<%=startDate %>">
							<input type="hidden" id="endDate" name="endDate" value="<%=endDate %>">
							<input type="hidden" id="order" name="order" value="<%=order %>">
							  
                            <label for="totalSearch" class="hide">검색옵션</label>
                            <select name="totalSearch" id="totalSearch">
                                <option value="total" <%if (menu.equals("total")) {%>selected="selected" <%}%>>통합검색</option>
								<option value="webpage" <%if (menu.equals("webpage")) {%>selected="selected" <%}%>>웹페이지</option>
								<option value="board" <%if (menu.equals("board")) {%>selected="selected" <%}%>>게시판</option>
								<option value="multimedia" <%if (menu.equals("multimedia")) {%>selected="selected" <%}%>>멀티미디어</option>
								<option value="office" <%if (menu.equals("office")) {%>selected="selected" <%}%>>직원/업무</option>
								<option value="cultural" <%if (menu.equals("cultural")) {%>selected="selected" <%}%>>문화관광</option>
							 </select>
                            <label for="totalText" class="hide">검색어를 입력하세요</label>
                            <input type="text" name="searchTerm" class="sch_txt" id="totalText" placeholder="검색어를 입력하세요" value="<%=searchTerm %>" onkeyup="auto_search();">
                            <input type="submit" class="totalBtn"   value="검색">
                            <input type="hidden" value="oneMoreSearch" id="oneMoreSearch">
                        </form>
                        <div id="ark"></div>
                    </div>
                    <a href="#" title="상세검색 메뉴가 나옵니다." class="noLink moreSearchBtn">상세검색</a>
                    <div class="moreSearchBox" style="display: none;">
                        <a href="#n" class="closeBtn">닫기</a>

                         <form action="JangSu.jsp" method="get" name="sch_frmdatail" id="sch_frmdatail">
                        <!-- <form action="index.jangsu" method="get" name="sch_frmdatail" id="sch_frmdatail"> -->
                        <input type="hidden" name="contentSid" value="1494">
                        <input type="hidden" id="detail_menu" name="totalSearch" value="<%=menu %>">
                        <input type="hidden" id="detail_searchArea" name="searchArea" value="<%=searchArea %>">
                        <input type="hidden" name="searchTerm" id="detail_searchTerm" value="<%=searchTerm%>">
                        <input type="hidden" name="currentPage" value="1">
						<input type="hidden" name="re_searchTerm" value="<%=re_searchTerm %>">
						<input type="hidden" id="detail_re_searchCheck" name="re_searchCheck" value="<%=re_searchCheck %>">
                        <input type="hidden" id="detail_oper" name="oper" value="<%=oper %>">
                        <%-- <input type="hidden" id="detail_notKeyWord" name="notKeyWord" value="<%=notKeyWord %>"> --%>
                        <input type="hidden" id="detail_rseultsize" name="rseultsize" value="<%=rseultsize %>">
                        <input type="hidden" id="detail_date" name="date" value="<%=detaildate %>">
                        <input type="hidden" id="detail_order" name="order" value="<%=order %>">
                            <div class="checkWrap">
                                <!-- 검색대상 -->
                                <div class="msTerm">
                                    <p class="msLabel msLabel3">검색대상</p>
                                    <input type="hidden" value="msAll" id="msTermInput">
                                    <a href="#" title="전체 선택" onclick="fn_area_check('all','1'); return false;" data-term="msAll" <%if(searchArea.equals("all")){%> class="noLink msTermCheck msTermActive"<%}else{%>class="noLink msTermCheck"<%} %>>전체</a>
                                    <a href="#" title="제목 선택" onclick="fn_area_check('title','1'); return false;" data-term="msTitle" <%if(searchArea.equals("title")){%> class="noLink msTermCheck msTermActive"<%}else{%>class="noLink msTermCheck"<%} %>>제목</a>
                                    <a href="#" title="내용 선택" onclick="fn_area_check('content','1'); return false;" data-term="msContent" <%if(searchArea.equals("content")){%> class="noLink msTermCheck msTermActive"<%}else{%>class="noLink msTermCheck"<%} %>>내용</a>
                                    <a href="#" title="제목+내용 선택" onclick="fn_area_check('total','1'); return false;" data-term="msTotal" <%if(searchArea.equals("total")){%> class="noLink msTermCheck msTermActive"<%}else{%>class="noLink msTermCheck"<%} %>>제목+내용</a>
                                </div>

                                <!-- 연산자 -->
                                <div class="msTerm">
                                    <p class="msLabel msLabel3">연산자</p>
                                    <input type="hidden" value="msAll2" id="msTermInput2">
                                    <a href="#" title="모든 단어 포함 (AND) 선택" onclick="fn_area_check('and','2'); return false;" <%if(oper.equals("and")){%> class="noLink msTermCheck  msTermActive"<%}else{%>class="noLink msTermCheck "<%} %> data-term="msAll2">모든 단어 포함 (AND)</a>
                                    <a href="#" title="한 단어만 포함(OR) 선택" onclick="fn_area_check('or','2'); return false;" <%if(oper.equals("or")){%> class="noLink msTermCheck  msTermActive"<%}else{%>class="noLink msTermCheck "<%} %> data-term="msOr" >한단어만 포함(OR)</a>
                                    <div class="notWrap">
                                        <label for="notText" class="msNot" >NOT</label>
                                        <input type="text" id="notText" name="notKeyWord" onkeyup="fn_area_check('not','2'); return false;" onclick="fn_area_check('not','2'); return false;" value=<%=notKeyWord %>>
                                    </div>
                                </div>

                                <!-- 등록일 -->
                                <div class="msTerm">
                                    <p class="msLabel msLabel3">등록일</p>
                                    <input type="hidden" value="msAll3" id="msTermInput3">
                                    <a href="#" title="전체 선택" data-term="msAll3"
                                     onclick="fn_area_check('msAll3','3'); return false;"   <%if(detaildate.equals("msAll3")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>전체</a>
                                    <a href="#" title="최근 1주 선택" data-term="msWeek" onclick="fn_area_check('msWeek','3'); return false;" <%if(detaildate.equals("msWeek")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>최근 1주</a>
                                    <a href="#" title="최근 1개월 선택" data-term="msMonth" onclick="fn_area_check('msMonth','3'); return false;" <%if(detaildate.equals("msMonth")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>최근
                                        1개월</a>
                                    <a href="#" title="최근 3개월 선택" data-term="msMonth3" onclick="fn_area_check('msMonth3','3'); return false;" <%if(detaildate.equals("msMonth3")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>최근
                                        3개월</a>
                                    <a href="#" title="최근 6개월 선택" data-term="msMonth6" onclick="fn_area_check('msMonth6','3'); return false;" <%if(detaildate.equals("msMonth6")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>최근
                                        6개월</a>
                                    <div class="boardTop_calendar">
                                        <p class="inputs">
                                            <label for="calendar1" class="hide">시작일선택</label>
                                            <input type="text" name="startDate" value="<%=startDate %>" class="board_cal" id="calendar1">
                                        </p>
                                        <span>~</span>
                                        <p class="inputs">
                                            <label for="calendar2" class="hide">종료일선택</label>
                                            <input type="text" name="endDate" value="<%=endDate %>" class="board_cal" id="calendar2">
                                        </p>
                                    </div>
                                </div>

                                <!-- 결과수 -->
                                <div class="msTerm">
                                    <p class="msLabel msLabel3">결과수</p>
                                    <input type="hidden" value="msAll4" id="msTermInput4">
                                    <a href="#" title="전체 선택" onclick="fn_area_check('10','4'); return false;" data-term="msAll4" <%if(rseultsize.equals("10")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %> >10줄</a>
                                    <a href="#" title="20줄 선택" onclick="fn_area_check('20','4'); return false;" data-term="msline20" <%if(rseultsize.equals("20")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>20줄</a>
                                    <a href="#" title="30줄 선택" onclick="fn_area_check('30','4'); return false;" data-term="msline30" <%if(rseultsize.equals("30")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>30줄</a>
                                    <a href="#" title="40줄 선택" onclick="fn_area_check('40','4'); return false;" data-term="msline40" <%if(rseultsize.equals("40")){%> class="noLink msTermCheck msTermActive" <%}else{%>class="noLink msTermCheck "<%} %>>40줄</a>
                                </div>
                            </div>
                            <input type="submit" value="적용" class="msBtn">
                        </form>
                    </div>
                    <div class="onMoreBox">
                        <a href="#"  title="클릭시 결과내 재검색 기능 온오프 버튼" <%if(re_searchCheck.equals("on")){%>  class="noLink oneMoreBtn onMoreActive"<%}else{%>class="noLink oneMoreBtn"<%} %>>결과내 재검색</a>
                    </div>
                </div>
                
                			 <!-- 검색어 자동완성:s -->
								<div class="sch_item" id="autoSearchArea" style="width:100%; display:none;">
									<ul id='autoSearchList'>
									</ul>
								</div>
                
                <!-- 추천검색어 -->
                <div class="recomSearch">
                    <p class="tit">추천검색어</p>
                    <ul class="list">
                        <li><a href="#n" onclick="hotKeySearch('장수'); return false;">장수</a></li>
                        <li><a href="#n" onclick="hotKeySearch('장수사과'); return false;">장수사과</a></li>
                        <li><a href="#n" onclick="hotKeySearch('장수한우랑사과랑 축제'); return false;">장수한우랑사과랑 축제</a></li>
                    </ul>
                </div>
            </div>

            <!-- 검색탭 -->
            <ul class="searchTab">
                <li class=""><a href="#" menu="total" onclick="javascript:p_menu('total'); return false;">통합검색</a></li>
                <li class=""><a href="#" menu="webpage" onclick="javascript:p_menu('webpage'); return false;" >웹페이지</a></li>
                <li class=""><a href="#" menu="board" onclick="javascript:p_menu('board'); return false;" >게시판</a></li>
                <li class=""><a href="#" menu="multimedia" onclick="javascript:p_menu('multimedia'); return false;" >멀티미디어</a></li>
                <li class=""><a href="#" menu="office" onclick="javascript:p_menu('office'); return false;" >직원/업무</a></li>
                <li class=""><a href="#" menu="cultural" onclick="javascript:p_menu('cultural'); return false;">문화관광</a></li>
            </ul>

            <!-- 검색결과 타이틀 -->
            <div class="searchSelWrap">
                <div class="searchTitBox">
<% 
				if (totalSize == 0) { 
%>
					<p class="searchTit" >검색결과를 찾을 수 없습니다.</p>
					
<% 
				} else { 
					String[] searchTermArr = re_searchTerm.split("###");
%>					
					<p class="searchTit">
<%
					for (int i=0; i<searchTermArr.length; i++) {
						String del = (i+1)==searchTermArr.length ? "" : ",";
%>
                        <span class="blue">‘<%=searchTermArr[i]%>’<%=del %></span> 
<% 
					} 
%>
 					에 대한 검색 결과 :</p>
                    <p class="searchTit under">
                        <span>총</span> <span class="blue"><%=totalSize%></span><span>건</span>
                    </p>
<% 
				} 
%>
                </div>
<% 
				if (totalSize != 0) { 
%>
                <div class="select">
                    <select name="order" id="orderCheck">
                        <option value="dateDesc"  <%if (order.equals("dateDesc")) {%>selected="selected" <%}%> >날짜역순</option>
                        <option value="weighthDesc" <%if (order.equals("weighthDesc")) {%>selected="selected" <%}%>  >정확도순</option>
                        <option value="titleAsc" <%if (order.equals("titleAsc")) {%>selected="selected" <%}%>  >제목정순</option>
                    </select>

                   <!--  <select name="" id="">
                        <option value="정확도순">정확도순</option>
                        <option value="정확도순">정확도순</option>
                        <option value="정확도순">정확도순</option>
                        <option value="정확도순">정확도순</option>
                    </select>

                    <select name="" id="">
                        <option value="제목정순">제목정순</option>
                        <option value="제목정순">제목정순</option>
                        <option value="제목정순">제목정순</option>
                        <option value="제목정순">제목정순</option>
                    </select> -->

                    <a href="#n" onclick="checkOrder()">정렬확인</a>
                </div>
<% 
					} 
%>
            </div>
            
            
<!-- ******************************************************************************************************************************** -->
<!-- ****웹페이지 검색결과-->
<!-- ******************************************************************************************************************************** -->	

<%		if(webpageSize>0){
			if(menu.equals("total") || menu.equals("webpage")){ 
%>

            <!-- 웹페이지 검색결과 -->
            <div class="searchResultWrap">
            
<%
            	if(menu.equals("total")){
%>
	                <div class="resultTit">
	                    <div class="titBox">
	                        <p class="tit">웹페이지</p>
	                        <p class="subTit">검색결과 총<span><%=webpageSize%></span>건</p>
	                    </div>
	
	                    <a href="#n" onclick="p_menu('webpage'); return false;" class="more">웹페이지 결과 더보기</a>
	                </div>
<%
            	}
%>
                <ul class="resultCon">
<% 						
					for (int i=0; i<webpageList.size(); i++) {
						HashMap<String, String> tempMap = webpageList.get(i);
						String MENU_NM = tempMap.get("MENU_NM");
						String FULL_NM = tempMap.get("FULL_NM");
					    String CONTENTS_CONTENT = tempMap.get("CONTENTS_CONTENT");
					    String MENU_CD = tempMap.get("MENU_CD");
					    String SUB_CONTEXT_PATH = tempMap.get("SUB_CONTEXT_PATH");
 %>
                    <li>
                        <p class="tit">
                            <a href="https://www.jangsu.go.kr/<%=SUB_CONTEXT_PATH%>/index.jangsu?menuCd=<%=MENU_CD%>"><%=MENU_NM %></a>
                        </p>

                         <p class="txt"><%=CONTENTS_CONTENT %></p>
                         
                        <a href="#" class="siteLink"><%=FULL_NM %></a>
                    </li>
<%
					}
			           
%>    
                </ul>
            </div>
 <%
            	if (!pageNaviStr.equals("")) {
 %>
            		<div class="paging" align="center">
						<%=pageNaviStr %>
					</div>
            
<%          
            	}
			}
     	}
 	
%>	

<!-- ******************************************************************************************************************************** -->
<!-- ****게시판 검색결과-->
<!-- ******************************************************************************************************************************** -->	
<%		if(boardSize>0){
			if(menu.equals("total") || menu.equals("board")){ 
%>
            <!-- 게시판 검색결과 -->
            <div class="searchResultWrap">
<%
            	if(menu.equals("total")){
%>
	                <div class="resultTit">
	                    <div class="titBox">
	                        <p class="tit">게시판</p>
	                        <p class="subTit">검색결과 총<span><%=boardSize %></span>건</p>
	                    </div>
	                    <a href="#n" onclick="p_menu('board'); return false;" class="more">게시판 결과 더보기</a>
                	</div>
<%
            	}
%>
                    

                <ul class="resultCon">
<% 				
						for (int i=0; i<boardList.size(); i++) {
							HashMap<String, String> tempMap = boardList.get(i);
							String BOARD_ID = tempMap.get("BOARD_ID");
							String DATASID = tempMap.get("DATASID");
							String DATA_CONTENT = tempMap.get("DATA_CONTENT");
							String DATA_TITLE = tempMap.get("DATA_TITLE");
							String DQ_ID = tempMap.get("DQ_ID");
							String FILENAMES = tempMap.get("FILENAMES");
							String FILES = tempMap.get("FILES");
							String FILE_SIDS = tempMap.get("FILE_SIDS");
							String FULL_NM = tempMap.get("FULL_NM");
							String MENU_CD = tempMap.get("MENU_CD");
							String REGISTER_DATE = tempMap.get("REGISTER_DATE");
							String SUB_CONTEXT_PATH = tempMap.get("SUB_CONTEXT_PATH");
							
%>
                    <li>
                        <p class="tit">
                            <a href="https://www.jangsu.go.kr/<%=SUB_CONTEXT_PATH%>/board/view.jangsu?menuCd=<%=MENU_CD%>&boardId=<%=BOARD_ID%>&dataSid=<%=DATASID%>"><%=DATA_TITLE %></a>
                        </p>

                        <p class="txt"><%=DATA_CONTENT %></p>
                        
<%
                        if(!FILENAMES.isEmpty()){
 %>             

                        <ul class="downList">
                            <li>
                                <a href="#n" class="fileDown"><%=FILENAMES %></a>
                            </li>
                        </ul>
<%
                        }
%>


                        <a href="#" class="siteLink"><%=FULL_NM %></a>
                    </li>
<%
					}
%>
                    
                </ul>
            </div>
            
<%
            	if (!pageNaviStr.equals("")) {
%>
            		<div class="paging" align="center">
						<%=pageNaviStr %>
					</div>
            
<%          
            	}
            }
     	}
 	
%>	
<!-- ******************************************************************************************************************************** -->
<!-- ****멀티미디어 검색결과-->
<!-- ******************************************************************************************************************************** -->	
<%		if(multimediaSize>0){
			if(menu.equals("total") || menu.equals("multimedia")){ 
%>
            <!-- 멀티미디어 검색결과 -->
            <div class="searchResultWrap">
<%
            	if(menu.equals("total")){
%>
	                <div class="resultTit">
	                    <div class="titBox">
	                        <p class="tit">멀티미디어</p>
	                        <p class="subTit">검색결과 총<span><%=multimediaSize %></span>건</p>
	                    </div>
	                    <a href="#n" onclick="p_menu('multimedia'); return false;" class="more">멀티미디어 결과 더보기</a>
	                </div>
<%
            	}
%>
                    

                <div class="resultCon">
                    <div class="photoListBox">
                        <ul class="photoListUl">
<% 				
						for (int i=0; i<multimediaList.size(); i++) {
							HashMap<String, String> tempMap = multimediaList.get(i);
							String BOARD_ID = tempMap.get("BOARD_ID");
							String DATASID = tempMap.get("DATASID");
							String DATA_TITLE = tempMap.get("DATA_TITLE");
							String DQ_ID = tempMap.get("DQ_ID");
							String MENU_CD = tempMap.get("MENU_CD");
							String REGDATE = tempMap.get("REGDATE");
							String SUB_CONTEXT_PATH = tempMap.get("SUB_CONTEXT_PATH");
							String FILE_THUMBNAIL_PATH = tempMap.get("FILE_THUMBNAIL_PATH");

							SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMddHHmmss");
					        SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd");
					        
					        try {
					            Date date = inputFormat.parse(REGDATE);
					            REGDATE = outputFormat.format(date);
					            
					        } catch (ParseException e) {
					            e.printStackTrace();
					        }
					        
					        

							
%>
                            <li class="htoListCnt">
                                <a href="https://www.jangsu.go.kr/<%=SUB_CONTEXT_PATH%>/board/view.jangsu?menuCd=<%=MENU_CD%>&boardId=<%=BOARD_ID%>&dataSid=<%=DATASID%>">
                                    <div class="photoImg">
                                        <img src="<%=FILE_THUMBNAIL_PATH %>" alt="">
                                    </div>
                                    <div class="photoInfoBox">
                                        <p class="photoTitle"><%=DATA_TITLE %></p>
                                        <ul class="phptoInfo">
                                            <p class="photoDate"><%=REGDATE %></p>
                                        </ul>
                                    </div>
                                </a>
                            </li>
<%
						}
%>
                        </ul>
                    </div>
                </div>
            </div>
<%
            	if (!pageNaviStr.equals("")) {
%>
            		<div class="paging" align="center">
						<%=pageNaviStr %>
					</div>
            
<%          
            	}
			}
     	}
 	
%>

<!-- ******************************************************************************************************************************** -->
<!-- ****직원/업무 검색결과-->
<!-- ******************************************************************************************************************************** -->	
<%		if(officeSize>0){
			if(menu.equals("total") || menu.equals("office")){ 
%>
           <!-- 직원/업무 검색결과 -->
            <div class="searchResultWrap">
<%
            	if(menu.equals("total")){
%>
	                <div class="resultTit">
	                    <div class="titBox">
	                        <p class="tit">직원/업무</p>
	                        <p class="subTit">검색결과 총<span><%=officeSize %></span>건</p>
	                    </div>
	
	                    <a href="#n" onclick="p_menu('office'); return false;" class="more">직원/업무 결과 더보기</a>
	                </div>
<%
				}
%>
                <div class="resultCon">
                    <p class="gap30"></p>
                    <!-- s: table-wrap scroll -->
                    <div class="table-wrap">
                        <div class="scroll-guide">
                            <p></p>
                        </div>
                        <div class="scroll-table">
                            <table class="type01 scroll">
                                <caption>이름, 소속부서, 담당업무, 전화번호의 정보를 나타내는 직원/업무 표입니다.</caption>
                                <colgroup>
                                    <col style="width:20%">
                                    <col style="width:25%">
                                    <col style="width:40%">
                                    <col style="width:15%">
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th scope="col">이름</th>
                                        <th scope="col">소속부서</th>
                                        <th scope="col">담당업무</th>
                                        <th scope="col">전화번호</th>
                                    </tr>
                                </thead>
                                <tbody>
 <%
							for (int i=0; i<officeList.size(); i++) {
								HashMap<String, String> tempMap = officeList.get(i);
								String DQ_ID = tempMap.get("DQ_ID");
								String OFFICENMS = tempMap.get("OFFICENMS").replace("/", ">");
								String OFFICE_PT_MEMO = tempMap.get("OFFICE_PT_MEMO");
								String OFFICE_TEL = tempMap.get("OFFICE_TEL");
								String USER_NM = tempMap.get("USER_NM");

%>
                                    <tr>
                                        <td><%=USER_NM %></td>
                                        <td><%=OFFICENMS %></td>
                                        <td><%=OFFICE_PT_MEMO %></td>
                                        <td><%=OFFICE_TEL %></td>
                                    </tr>
<%
                    		}
%> 
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <!-- e: table-wrap scroll -->
                </div>
            </div>
<%
            	if (!pageNaviStr.equals("")) {
%>
            		<div class="paging" align="center">
						<%=pageNaviStr %>
					</div>
            
<%          
            	}
			}
     	}
 	
%>

<!-- ******************************************************************************************************************************** -->
<!-- ****문화관광-->
<!-- ******************************************************************************************************************************** -->			
<%			
 	if(culturalSize>0){
		if(menu.equals("total")|| menu.equals("cultural")){
%>

            <!-- 문화관광 검색결과 -->
            <div class="searchResultWrap cul">
<%
            	if(menu.equals("total")){
%>
	                <div class="resultTit">
	                    <div class="titBox">
	                        <p class="tit">문화관광</p>
	                        <p class="subTit">검색결과 총<span><%=culturalSize %></span>건</p>
	                    </div>
	
	                    <a href="#n" onclick="p_menu('cultural'); return false;" class="more">문화관광 결과 더보기</a>
	                </div>
<%
                }
%>
                <ul class="resultCon">
<% 						
					for (int i=0; i<culturalList.size(); i++) {
						HashMap<String, String> tempMap = culturalList.get(i);
						String BOARD_ID = tempMap.get("BOARD_ID");
						String DATASID = tempMap.get("DATASID");
						String DATA_CONTENT = tempMap.get("DATA_CONTENT");
						String DATA_TITLE = tempMap.get("DATA_TITLE");
						String DQ_ID = tempMap.get("DQ_ID");
						String FILENAMES = tempMap.get("FILENAMES");
						String FILES = tempMap.get("FILES");
						String FILE_SIDS = tempMap.get("FILE_SIDS");
						String FULL_NM = tempMap.get("FULL_NM");
						String MENU_CD = tempMap.get("MENU_CD");
						String REGISTER_DATE = tempMap.get("REGISTER_DATE");
						String SUB_CONTEXT_PATH = tempMap.get("SUB_CONTEXT_PATH");
 %>
                    <li>
                        <p class="tit">
                            <a href="https://www.jangsu.go.kr/<%=SUB_CONTEXT_PATH%>/board/view.jangsu?menuCd=<%=MENU_CD%>&boardId=<%=BOARD_ID%>&dataSid=<%=DATASID%>"><%=DATA_TITLE %></a>
                        </p>

                        <p class="txt"><%=DATA_CONTENT %></p>
                    </li>
<%
                    }
%>
                </ul>
            </div>
<%
            	if (!pageNaviStr.equals("")) {
%>
            		<div class="paging" align="center">
						<%=pageNaviStr %>
					</div>
            
<%          
            	}
			}
     }
 	
%> 
        </div>
        <!-- e: contents -->
        
        
<!-- ******************************************************************************************************************************** -->
<!-- ****인기검색어-->
<!-- ******************************************************************************************************************************** -->			
        <div class="sideSearch">
            <!-- s: ranks-warp -->
            <div class="ranks-warp">
                <div class="weekDay">
                    <p class="wdTit">인기 검색어</p>
                    <ul class="weekDayBox">
<%	
			for (int i=0; i<hotList.size(); i++) {
				HashMap<String, String> tempMap = hotList.get(i);
				String KEYWORD = tempMap.get("KEYWORD");
				//int rank = i+1;
%>
                        <li class="wd2List"><a href="#" onclick="hotKeySearch('<%=KEYWORD %>'); return false;" title="해당검색어로 검색합니다."><%=KEYWORD %></a></li>
<% 
			} 
%>
                    </ul>
                </div>
            </div>
            <!-- e: ranks-warp -->
<!-- ******************************************************************************************************************************** -->
<!-- ****내가 찾은 검색어-->
<!-- ******************************************************************************************************************************** -->			
            <!-- s: 내가 찾은 검색어 -->
            <div class="ranks-warp">
                <div class="weekDay">
                    <p class="wdTit">내가 찾은 검색어</p>
                    <ul class="cont-list step01" id="recent">
                        <!-- <li><a href="#" title="해당검색어로 검색합니다.">장수군청</a></li>
                        <li><a href="#" title="해당검색어로 검색합니다.">장수군</a></li> -->
                    </ul>
                </div>
            </div>
            <!-- e: 내가 찾은 검색어 -->
        </div>


    </div>
</div>
<!-- subCntArea :e -->

<script>
    $(document).ready(function () {
        $(".moreSearchBtn").bind("click", function () {
            if ($(".moreSearchBox").css("display") == "none") {
                $(".moreSearchBox").slideDown();
            } else {
                $(".moreSearchBox").slideUp();
            }
        });

        $(".closeBtn").bind("click", function () {
            if ($(".moreSearchBox").css("display") == "none") {
                $(".moreSearchBox").slideDown();
            } else {
                $(".moreSearchBox").slideUp();
            }
        });

        $(".oneMoreBtn").bind("click", function () {
            $(this).toggleClass("onMoreActive");
            if ($(".oneMoreBtn").hasClass("onMoreActive") == true) {
            	$('#re_searchCheck').val('on');
            	$('#detail_re_searchCheck').val('on');
                $("#oneMoreSearch").attr("value", "oneMoreSearch");
            } else {
            	$('#re_searchCheck').val('N')
            	$('#detail_re_searchCheck').val('N');
                $("#oneMoreSearch").attr("value", "");
            }
        });
        $(".msTermCheck").bind("click", function () {
            $(".msTermCheck").removeClass("msTermActive");
            $(this).addClass("msTermActive");
            let msTerm = $(this).attr("data-term");
            $("#msTermInput").attr("value", msTerm);
        });
        
        
        
        
        
        
    });
</script>       



	










		
     
            <!--subContent 영역끝-->
    </div>
    <!--subWrap 영역끝-->
</div>
<!--sub-container 영역끝-->
	<?
include_once("../../Inc/sub_footer.php");
?>


<img src="/visitcounter/visitcounter.jangsu?refer=DOM_0000001"
    style="width:0px;height:0px;border:0;display:none;" alt="방문자통계" />

<div class="userMenu">
    <div class="userWrap">
        <div class="userTab">
            <span>이용자별 메뉴</span>
            <ul class="tabList">
                <li class="tab_btn active">군민</li>
                <li class="tab_btn">사업자</li>
                <li class="tab_btn">관광객</li>
            </ul>
        </div>
        <div class="userList">
            <ul class="menu active">
                <li><a href="/index.jangsu?menuCd=DOM_000000101001001000">민원안내</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000101002001000">민원신청</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000101003001000">여권안내</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000101004001000">지방세</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000101005001000">교통</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000101006001000">부동산</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000101007001000">건축/정보통신</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000102008001000">신고센터</a></li>
                <li><a
                        href="/board/list.jangsu?boardId=BBS_0000003&menuCd=DOM_000000102001001000&contentsSid=13&cpath=">장수소식</a>
                </li>
            </ul>

            <ul class="menu">
                <li><a href="/index.jangsu?menuCd=DOM_000000102002001001">계약알림</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000102008004001">예산/재정</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000106002001001">농업정보</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000106002002000">축산정보</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000106002003000">임업정보</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000106003001000">농공단지현황</a></li>
                <li><a href="/index.jangsu?menuCd=DOM_000000106003003000">시장현황</a></li>
                <li><a
                        href="/board/list.jangsu?boardId=BBS_0000076&menuCd=DOM_000000106003005000&contentsSid=228&cpath=">물가정보</a>
                </li>
                <li><a href="https://jeonbuk.work.go.kr/jangsu/main.do?cpath=">구인/구직</a></li>
            </ul>

            <ul class="menu">
                <li><a href="/tour/board/list.jangsu?boardId=BBS_0000034&menuCd=DOM_000000405002000000&contentsSid=327&cpath=%2Ftour"
                        target="_blank" title="새창열림">안내책자신청</a></li>
                <li><a href="/tour/board/list.jangsu?boardId=BBS_0000137&menuCd=DOM_000000403001000000&contentsSid=299&cpath=%2Ftour"
                        target="_blank" title="새창열림">맛집/숙박/특산물</a>
                </li>
                <li><a href="/tour/index.jangsu?menuCd=DOM_000000401000000000" target="_blank" title="새창열림">추천여행</a>
                </li>
                <li><a href="/tour/board/view.jangsu?boardId=BBS_0000015&dataSid=224&menuCd=DOM_000000402007001000&&cpath=%2Ftour"
                        target="_blank" title="새창열림">축제/행사</a></li>
                <li><a href="/tour/board/view.jangsu?boardId=BBS_0000004&dataSid=177&menuCd=DOM_000000402001001000&&cpath=%2Ftour"
                        target="_blank" title="새창열림">공원/휴양림/관광지</a>
                </li>
                <li><a href="/tour/board/view.jangsu?boardId=BBS_0000005&dataSid=195&menuCd=DOM_000000402002001000&&cpath=%2Ftour"
                        target="_blank" title="새창열림">명산/계곡</a></li>
                <li><a href="/tour/board/list.jangsu?boardId=BBS_0000008&menuCd=DOM_000000402005001001&contentsSid=244&cpath=%2Ftour"
                        target="_blank" title="새창열림">문화유산</a></li>
                <li><a href="/tour/index.jangsu?menuCd=DOM_000000404000000000" target="_blank" title="새창열림">장수가야이야기</a>
                </li>
                <li><a href="/tour/index.jangsu?menuCd=DOM_000000405000000000" target="_blank" title="새창열림">여행도우미</a>
                </li>
            </ul>
        </div>
    </div>
</div>

<footer>

    <div class="ft-bn-wrap">
        <div class="footer-wrap">
            <div class="ft-bn-box">
                <div class="ft-bn-control">
                    <span class="txt">배너모음</span>
                    <div class="control">
                        <a href="#" class="slideLeft">이전슬라이드</a>
                        <a href="#" class="slideRight">다음슬라이드</a>
                        <a href="#" class="slideStop">일시정지</a>
                    </div>
                </div>
                <div class="ftSlide slideCnt">
                
                
				
				
				
                


					
							<div class="ftSlideCnt">
								<a href="https://www.youtube.com/channel/UCKh_-ENlBqRClLHt1S6makA/featured" 
								target="_blank" title="새창열림"
								 >
									전라북도의회 어썸전북
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://blog.naver.com/pro_nps/222464257962" 
								target="_blank" title="새창열림"
								 >
									기초연금 모의계산
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://유권자정치페스티벌.com/question" 
								target="_blank" title="새창열림"
								 >
									유권자정치페스티벌
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.jbshare.kr/" 
								target="_blank" title="새창열림"
								 >
									가치앗이
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="@@https://www.bokjiro.go.kr/ssis-tbu/index.do" 
								target="_blank" title="새창열림"
								 >
									복지로 온라인
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.safekorea.go.kr/idsiSFK/neo/sfk/cs/contents/civil_defense/SDIJKM1402.html?menuSeq=57" 
								target="_blank" title="새창열림"
								 >
									민방위 대피시설
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.sinmungo.go.kr/sz2.prpsl.main.laf" 
								target="_blank" title="새창열림"
								 >
									규제개혁 신문고
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://jb.nec.go.kr/jb/main/main.do" 
								target="_blank" title="새창열림"
								 >
									전북선거관리위원회
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://jangsu-www.skoinfo.co.kr/farming/index.jangsu" 
								target="_blank" title="새창열림"
								 >
									장수군농업기술센터
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.open.go.kr" 
								target="_blank" title="새창열림"
								 >
									정보공개시스템
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.epeople.go.kr" 
								target="_blank" title="새창열림"
								 >
									국민신문고
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.juso.go.kr/index.html" 
								target="_blank" title="새창열림"
								 >
									새주소안내
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.juklim.com" 
								target="_blank" title="새창열림"
								 >
									죽림정사
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.adrc.or.kr/user/main.do" 
								target="_blank" title="새창열림"
								 >
									석면피해구제센터
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://lofin.mois.go.kr/portal/main.do" 
								target="_blank" title="새창열림"
								 >
									지방재정365
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.kilf.re.kr/" 
								target="_blank" title="새창열림"
								 >
									한국지방세연구원
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://health.kdca.go.kr/healthinfo/biz/health/main/mainPage/main.do" 
								target="_blank" title="새창열림"
								 >
									국가건강정보포털
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.airkorea.or.kr" 
								target="_blank" title="새창열림"
								 >
									대기오염정보
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.safekorea.go.kr/idsiSFK/neo/main/main.html" 
								target="_blank" title="새창열림"
								 >
									국가재난정보센터
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.weather.go.kr/weather/forecast/timeseries2_metsky.jsp" 
								target="_blank" title="새창열림"
								 >
									동네예보
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.kma.go.kr/weather/forecast/timeseries.jsp" 
								target="_blank" title="새창열림"
								 >
									기상청날씨ON
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.kcomwel.or.kr" 
								target="_blank" title="새창열림"
								 >
									근로복지공단
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="/index.jangsu?menuCd=DOM_000000106009010000" 
								target="_blank" title="새창열림"
								 >
									위생관리등급
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.lx.or.kr" 
								target="_blank" title="새창열림"
								 >
									LX한국국토정보공사
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.ekape.or.kr" 
								target="_blank" title="새창열림"
								 >
									축산물품질평가원
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://youtu.be/W03EzmuRkZg" 
								target="_blank" title="새창열림"
								 >
									집중호우 피해예방
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.at.or.kr/article/apko368000/view.action?articleId=19645&amp;at.condition.currentPage=3" 
								target="_blank" title="새창열림"
								 >
									쌀관세화 유예종료
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.mafra.go.kr/sites/home/index.do#none" 
								target="_blank" title="새창열림"
								 >
									농림축산식품사업
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.nrc.go.kr/nrc/main.do" 
								target="_blank" title="새창열림"
								 >
									국립재활원
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.osmb.go.kr/sub1/proposal_form.jsp" 
								target="_blank" title="새창열림"
								 >
									중소기업 옴부즈만
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.labs.go.kr/modedg/contentsView.do?ucont_id=CTX000029&amp;menu_nix=kf8GKFf5" 
								target="_blank" title="새창열림"
								 >
									정부3.0
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.mfds.go.kr/index.do?mid=476" 
								target="_blank" title="새창열림"
								 >
									수입식품방사능검사
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.nongae.co.kr" 
								target="_blank" title="새창열림"
								 >
									의암 주 논개
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://ns.service.go.kr/usr/login;jsessionid=YWY9QorHJrV3ZeDRPxyVMzyB.nsservice02" 
								target="_blank" title="새창열림"
								 >
									대한민국정부포탈
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.cleaneye.go.kr" 
								target="_blank" title="새창열림"
								 >
									clean-eye
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="#" 
								target="_self" 
								 onclick="return false;">
									음식물쓰레기줄이기
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.humanrights.go.kr" 
								target="_blank" title="새창열림"
								 >
									국가인권위원회
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.passport.go.kr/home/kor/main.do" 
								target="_blank" title="새창열림"
								 >
									외교통상부
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.kcen.kr/USR_main2016.jsp??=life/life35" 
								target="_blank" title="새창열림"
								 >
									GREEN TOUCH
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.110.go.kr/start.do" 
								target="_blank" title="새창열림"
								 >
									정부민원안내콜센터
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.fbo.or.kr" 
								target="_blank" title="새창열림"
								 >
									FB 농지은행
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.110.go.kr/start.do" 
								target="_blank" title="새창열림"
								 >
									정부민원안내콜센터
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.osmb.go.kr/intro.html" 
								target="_blank" title="새창열림"
								 >
									신규제혁신 플랫폼
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://cafe.daum.net/js-return" 
								target="_blank" title="새창열림"
								 >
									장수귀농귀촌협의회
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.mois.go.kr/frt/sub/a06/b10/safetyReport/screen.do" 
								target="_blank" title="새창열림"
								 >
									안전신문고
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.laiis.go.kr/" 
								target="_blank" title="새창열림"
								 >
									내고장알리미 행정자치부
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.hrdb.go.kr/mrfnRcog/retrieveHRO0401001.do" 
								target="_blank" title="새창열림"
								 >
									국민추천제
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://spam.kisa.or.kr/spam/ss/ssSpamInfo.do?mi=1025" 
								target="_blank" title="새창열림"
								 >
									불법스팸대응센터
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="https://www.wetax.go.kr/main/" 
								target="_blank" title="새창열림"
								 >
									위택스
								</a>
							</div>
						
							<div class="ftSlideCnt">
								<a href="http://www.niceipin.co.kr/index.ni" 
								target="_blank" title="새창열림"
								 >
									공공아이핀 재인증
								</a>
							</div>
						
                </div>
            </div>
        </div>
    </div>
                
                
                
                    <!-- <div class="ftSlideCnt"><a href="#">문서24</a></div>
                    <div class="ftSlideCnt"><a href="#">아이사랑</a></div>
                    <div class="ftSlideCnt"><a href="#">국립전북기상과학원</a></div>
                    <div class="ftSlideCnt"><a href="#">전북투어패스</a></div>
                    <div class="ftSlideCnt"><a href="#">생활안전지도</a></div>
                    <div class="ftSlideCnt"><a href="#">안전디딤돌</a></div>
                    <div class="ftSlideCnt"><a href="#">민방위 대피시설</a></div>
                    <div class="ftSlideCnt"><a href="#">장수몰</a></div>
                    <div class="ftSlideCnt"><a href="#">복지로</a></div>
                    <div class="ftSlideCnt"><a href="#">가치앗이</a></div>
                    <div class="ftSlideCnt"><a href="#">환경부 </a></div>
                    <div class="ftSlideCnt"><a href="#">부패행위익명제보</a></div>
                    <div class="ftSlideCnt"><a href="#">문서24</a></div>
                    <div class="ftSlideCnt"><a href="#">아이사랑</a></div>
                    <div class="ftSlideCnt"><a href="#">국립전북기상과학원</a></div>
                    <div class="ftSlideCnt"><a href="#">전북투어패스</a></div>
                    <div class="ftSlideCnt"><a href="#">생활안전지도</a></div>
                    <div class="ftSlideCnt"><a href="#">안전디딤돌</a></div>
                    <div class="ftSlideCnt"><a href="#">민방위 대피시설</a></div>
                    <div class="ftSlideCnt"><a href="#">장수몰</a></div>
                    <div class="ftSlideCnt"><a href="#">복지로</a></div>
                    <div class="ftSlideCnt"><a href="#">가치앗이</a></div>
                    <div class="ftSlideCnt"><a href="#">환경부 </a></div>
                    <div class="ftSlideCnt"><a href="#">부패행위익명제보</a></div> -->
   

    <div class="footer-wrap">
        <div class="footer_tap">
            <ul class="footer_cnt">
                <li>
                    <div>
                        <a href="#" class="noLink">관련사이트</a>
                        <div class="ftc_inner">
                            <span class="tit">관련사이트</span>
                            <dl>
                                <dt></dt>
                                <dd><a href="https://council.jangsu.go.kr/">장수군의회</a></dd>
                                <dd><a href="https://rtms.jangsu.go.kr/">부동산거래관리시스템</a></dd>
                                <dd><a href="https://www.myapple.go.kr/">장수사과시험장</a></dd>
                                <dd><a href="http://jangsuvol.or.kr/">(사)장수군자원봉사센터</a></dd>
                                <dd><a href="https://www.foresttrip.go.kr/">장수휴양림</a></dd>
                                <dd><a href="https://www.juklim.com/">백융성조사 죽림정사</a></dd>
                                <dd><a href="https://www.xn--352bl9k1ze.com/">장수몰</a></dd>
                                <dd><a href="http://www.jadwc.or.kr/">장수노인·장애인복지관</a></dd>
                                <dd><a href="https://dukyusan.modoo.at/">문성산촌생태마을</a></dd>
                                <dd><a href="http://www.ddyang.co.kr/">땡양지산촌생태마을</a></dd>
                                <dd><a href="https://www.dangure.com/#">당그래마을</a></dd>
                                <dd><a href="https://jangsu.familynet.or.kr/center/index.do">장수군건강가정·다문화가족지원센터</a></dd>
                            </dl>

                        </div>
                    </div>
                </li>
                <li>
                    <div>
                        <a href="#" class="noLink">부서사이트</a>
                        <div class="ftc_inner">
                            <span class="tit">부서사이트</span>
                            <dl>
                                <dt></dt>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108001000000&cpath=">기획조정실</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108002001001">행정지원과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108002002001">주민복지과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108002003001">재무과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108002004001">민원과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108002005001">문화관광과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108002006001">환경위생과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108006002001">농업정책과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108006003001">민생경제과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108006004001">농산유통과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108006005001">축산과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108006006001">산림과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108006007001">안전재난과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108006008001">건설교통과</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108007001001">보건의료원</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108008001000">농업기술센터</a>
                                </dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000108009001000">체육맑은물사업소</a>
                                </dd>
                            </dl>
                        </div>
                    </div>
                </li>
                <li>
                    <div>
                        <a href="#" class="noLink">읍면사이트</a>
                        <div class="ftc_inner">
                            <dl>
                                <dt>읍면사이트</dt>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000701000000000" target="_blank"
                                        title="새창">장수읍</a></dd>
                                <dd><a href="/town/index.jangsu?menuCd=DOM_000001302001001000" target="_blank"
                                        title="새창">산서면</a></dd>
                                <dd><a href="/town/index.jangsu?menuCd=DOM_000001303000000000" target="_blank"
                                        title="새창">번암면</a></dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000001304000000000" target="_blank"
                                        title="새창">장계면</a></dd>
                                <dd><a href="/town/index.jangsu?menuCd=DOM_000001305000000000" target="_blank"
                                        title="새창">천천면</a></dd>
                                <dd><a href="/town/index.jangsu?menuCd=DOM_000001306000000000" target="_blank"
                                        title="새창">계남면</a></dd>
                                <dd><a href="/town/index.jangsu?menuCd=DOM_000001307000000000" target="_blank"
                                        title="새창">계북면</a></dd>

                                <!--<dt class="mg30t">광역자치단체</dt>
                                    <dd><a href="http://www.seoul.go.kr/" target="_blank" title="새창">서울특별시</a>
                                    </dd>
                                    <dd><a href="http://www.busan.go.kr/" target="_blank" title="새창">부산광역시</a>
                                    </dd>
                                    <dd><a href="http://www.daegu.go.kr/" target="_blank" title="새창">대구광역시</a>
                                    </dd>
                                    <dd><a href="http://www.incheon.go.kr/" target="_blank" title="새창">인천광역시</a>
                                    </dd>
                                    <dd><a href="https://www.gwangju.go.kr/intro/index.html" target="_blank" title="새창">광주광역시</a>
                                    </dd>
                                    <dd><a href="http://www.daejeon.go.kr/" target="_blank" title="새창">대전광역시</a>
                                    </dd>
                                    <dd><a href="http://www.ulsan.go.kr/" target="_blank" title="새창">울산광역시</a>
                                    </dd>
                                    <dd><a href="http://www.sejong.go.kr" target="_blank" title="새창">세종특별자치시</a>
                                    </dd>
                                    <dd><a href="http://www.gg.go.kr/" target="_blank" title="새창">경기도</a></dd>
                                    <dd><a href="http://www.provin.gangwon.kr/" target="_blank" title="새창">강원도</a>
                                    </dd>
                                    <dd><a href="http://www.chungbuk.go.kr/" target="_blank" title="새창">충청북도</a>
                                    </dd>
                                    <dd><a href="http://www.chungnam.go.kr/" target="_blank" title="새창">충청남도</a>
                                    </dd>
                                    <dd><a href="http://www.jeonbuk.go.kr/" target="_blank" title="새창">전라북도</a></dd>
                                    <dd><a href="http://www.jeonnam.go.kr/" target="_blank" title="새창">전라남도</a></dd>
                                    <dd><a href="http://www.gb.go.kr/" target="_blank" title="새창">경상북도</a></dd>
                                    <dd><a href="http://www.gyeongnam.go.kr/" target="_blank" title="새창">경상남도</a>
                                    </dd>
                                    <dd><a href="http://www.jeju.go.kr/" target="_blank" title="새창">제주특별자치도</a>
                                    </dd>                                    
                                <dt class="mg30t">중앙행정기관</dt>
                                    <dd><a href="https://www.gov.kr/portal/orgInfo?Mcode=11180" target="_blank" title="새창">중앙행정기관(새창)</a>
                                    </dd>                                    
                                    <dt class="mg30t">유관기관 바로가기</dt>
                                    <dd><a href="http://uredu.gne.go.kr/uredu/main.do" target="_blank" title="새창열림">의령교육지원청</a>
                                    </dd>
                                    <dd><a href="http://www.gnpolice.go.kr/ur/" target="_blank" title="새창열림">의령경찰서</a>
                                    </dd>-->

                            </dl>

                        </div>
                    </div>
                </li>
                <li>
                    <div>
                        <a href="#" class="noLink">유관기관</a>
                        <div class="ftc_inner">
                            <dl>
                                <dt>유관기관</dt>
                                <dd><a href="https://office.jbedu.kr/jbjse" target="_blank" title="새창">장수교육청</a></dd>
                                <dd><a href="https://www.koreapost.go.kr/" target="_blank" title="새창">장수우체국</a></dd>
                                <dd><a href="https://js.jbpolice.go.kr/index.police?contentsSid=2833" target="_blank"
                                        title="새창">장수경찰서</a>
                                </dd>
                                <dd><a href="https://www.nonghyup.com/error/error.html" target="_blank"
                                        title="새창">농협중앙회장수군지부</a></dd>
                                <dd><a href="https://jangsu.nonghyup.com/user/indexMain.do?siteId=jangsu"
                                        target="_blank" title="새창">장수농업협동조합</a></dd>
                                <dd><a href="http://jg.nonghyupi.com/xe/" target="_blank" title="새창">장계농업협동조합</a></dd>
                                <dd><a href="https://www.jsbeef.com/" target="_blank" title="새창">장수축협</a></dd>
                                <dd><a href="https://www.jshanwoo.com/" target="_blank" title="새창">장수한우지방공사</a></dd>
                                <dd><a href="/index.jangsu?menuCd=DOM_000000103003005001" target="_blank"
                                        title="새창">(재)장수군애향교육진흥재단</a></dd>
                                <dd><a href="https://jangsufc.co.kr/" target="_blank" title="새창">장수군 산림조합</a></dd>


                                <!-- <dt class="mg30t">광역자치단체</dt>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">서울특별시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">부산광역시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">대구광역시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">인천광역시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">광주광역시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">대전광역시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">울산광역시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">세종특별자치시</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">경기도</a></dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">강원도</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">충청북도</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">충청남도</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">전라북도</a></dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">전라남도</a></dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">경상북도</a></dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">경상남도</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">제주특별자치도</a>
                                                                                </dd>

                                                                                <dt class="mg30t">중앙행정기관</dt>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창">중앙행정기관(새창)</a>
                                                                                </dd>

                                                                                <dt class="mg30t">유관기관 바로가기</dt>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창열림">의령교육지원청</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창열림">의령경찰서</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창열림">의령우체국</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창열림">의령농협</a>
                                                                                </dd>
                                                                                <dd><a href="#" target="_blank"
                                                                                                title="새창열림">의령축협</a>
                                                                                </dd>
                                                                                <dd><a href="http://www.yuc.or.kr/main/main.php"
                                                                                                target="_blank"
                                                                                                title="새창열림">의령청소년
                                                                                                문화의집</a></dd>

                                                                                <dd><a href="http://council.uiryeong.go.kr/index.uiryeong"
                                                                                                target="_blank"
                                                                                                title="새창열림">의령군의회</a>
                                                                                </dd>
                                                                                <dd><a href="http://www.uiryeong.go.kr/tour/index.uiryeong"
                                                                                                target="_blank"
                                                                                                title="새창열림">문화관광</a>
                                                                                </dd>
                                                                                <dd><a href="https://golf.uiryeong.go.kr/"
                                                                                                target="_blank"
                                                                                                title="새창열림">친환경골프장</a>
                                                                                </dd>
                                                                                <dd><a href="http://www.uiryeong.go.kr/edu/index.uiryeong"
                                                                                                target="_blank"
                                                                                                title="새창열림">의령군장학회</a>
                                                                                </dd>
                                                                                <dd><a href="http://culture.uiryeong.go.kr/"
                                                                                                target="_blank"
                                                                                                title="새창열림">군민문화회관</a>
                                                                                </dd>
                                                                                <dd><a href="http://www.uiryeong.go.kr/aml"
                                                                                                target="_blank"
                                                                                                title="새창열림">농업기계임대</a>
                                                                                </dd>
                                                                                <dd><a href="http://www.uiryeong.go.kr/index.uiryeong?contentsSid=4947"
                                                                                                target="_blank"
                                                                                                title="새창열림">의령야영장</a>
                                                                                </dd>
                                                                                <dd><a href="http://www.uiryeong.go.kr/index.uiryeong?menuCd=DOM_000000506004000000"
                                                                                                target="_blank"
                                                                                                title="새창열림">의병박물관</a>
                                                                                </dd>
                                                                                <dd><a href="https://www.foresttrip.go.kr/indvz/main.do?hmpgId=ID02030113"
                                                                                                target="_blank"
                                                                                                title="새창열림">자굴산자연휴양림</a>
                                                                                </dd>
                                                                                <dd><a href="http://www.ursports.or.kr/"
                                                                                                target="_blank"
                                                                                                title="새창열림">의령군체육회</a>
                                                                                </dd>-->
                            </dl>

                        </div>
                    </div>
                </li>
                <li>
                    <div>
                        <a href="#" class="noLink">도내자치/중앙부</a>
                        <div class="ftc_inner">
                            <dl>
                                <dt>도내자치/중앙부</dt>
                                <dd><a target="_blank" title="새창이동" href="con5"><span>도내자치/중앙부처</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.jeonbuk.go.kr"><span>전북도청</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.jeonju.go.kr/"><span>전주시청</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.gunsan.go.kr/"><span>군산시청</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.iksan.go.kr/"><span>익산시청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.jeongeup.go.kr/"><span>정읍시청</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.namwon.go.kr"><span>남원시청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.gimje.go.kr/"><span>김제시청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.wanju.go.kr/"><span>완주군청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.jinan.go.kr"><span>진안군청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.muju.go.kr"><span>무주군청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.imsil.go.kr"><span>임실군청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.sunchang.go.kr"><span>순창군청</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.gochang.go.kr/"><span>고창군청</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.president.go.kr/"><span>청와대</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.humanrights.go.kr/"><span>국가인권위원회</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.nis.go.kr/"><span>국가정보원</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.bai.go.kr/"><span>감사원</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.kcc.go.kr/"><span>방송통신의원회</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.pmo.go.kr/"><span>국무총리실</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.moleg.go.kr/"><span>법제처</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.mpva.go.kr/"><span>국가보훈처</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.mfds.go.kr/"><span>식품의약안전처</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.ftc.go.kr/"><span>공정거래위원회</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.fsc.go.kr/"><span>금융위원회</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.acrc.go.kr/"><span>국민권익위원회</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.nssc.go.kr/"><span>원자력안전위원회</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.mosf.go.kr/"><span>기획재정부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.nts.go.kr/"><span>- 국세청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.customs.go.kr/"><span>-
                                            관세청</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.pps.go.kr/"><span>- 조달청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://kostat.go.kr/"><span>- 통계청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="https://www.msit.go.kr/"><span>과학기술정보통신부</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.moe.go.kr/"><span>교육부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.mofa.go.kr/"><span>외교부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.unikorea.go.kr/"><span>통일부</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.moj.go.kr/"><span>법무부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.spo.go.kr/"><span>- 검찰청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.mnd.go.kr/"><span>국방부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.mma.go.kr/"><span>- 병무청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.dapa.go.kr/"><span>-
                                            방위사업청</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="https://www.mois.go.kr/"><span>행정안전부</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.police.go.kr/"><span>-
                                            경찰청</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.nfa.go.kr/nfa/"><span>-
                                            소방청</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.mcst.go.kr/"><span>문화체육관광부</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.cha.go.kr/"><span>- 문화재청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.mafra.go.kr/"><span>농림축산식품부</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.rda.go.kr/"><span>-
                                            농촌진흥청</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.forest.go.kr/"><span>-
                                            산림청</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.mke.go.kr/"><span>산업통상자원부</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.smba.go.kr/"><span>-
                                            중소기업청</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.kipo.go.kr/"><span>- 특허청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.mw.go.kr/"><span>보건복지부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.me.go.kr/"><span>환경부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.kma.go.kr/"><span>- 기상청</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.moel.go.kr/"><span>고용노동부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.mogef.go.kr/"><span>여성가족부</span></a></dd>
                                <dd><a target="_blank" title="새창이동"
                                        href="http://www.molit.go.kr/"><span>국토교통부</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.naacc.go.kr/"><span>-
                                            행정중심복합도시건설청</span></a></dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.mof.go.kr/"><span>해양수산부</span></a>
                                </dd>
                                <dd><a target="_blank" title="새창이동" href="http://www.kcg.go.kr/"><span>-
                                            해양경찰청</span></a></dd>
                            </dl>

                        </div>
                    </div>
                </li>
            </ul>
        </div>

        <div class="foot-info-box">
            <ul class="info-link-list">

                <li>
                    <a href="/index.jangsu?menuCd=DOM_000000107005000000" target="_blank" title="새창열림">뷰어다운로드</a>
                </li>

                <li>
                    <a href="/index.jangsu?contentsSid=1494" target="_blank" title="새창열림">검색서비스</a>
                </li>

                <li>
                    <a href="/index.jangsu?menuCd=DOM_000000102003006001" target="_blank" title="새창열림">홈페이지개선의견</a>
                </li>

                <li>
                    <a href="/index.jangsu?menuCd=DOM_000000107003001000" target="_blank" title="새창열림"
                        class="c-green">개인정보처리방침</a>
                </li>
                <li>
                    <a href="/index.jangsu?menuCd=DOM_000000103001005000" target="_blank" title="새창열림">오시는길</a>
                </li>

                <li>
                    <a href="/index.jangsu?menuCd=DOM_000000107006000000" target="_blank" title="새창열림">배너모음</a>
                </li>
            </ul>
            
            
            
            
            
            
            
            
            
            
            
            <div class="copyright-txt-box">
                <p>
                    (55634) 전라북도 장수군 장수읍 호비로 10 <span class="bold">대표전화</span> :
                    063-351-2141<br />
                    Copyright © <span class="c-green">JANGSU COUNTY.</span> All
                    Rights
                    Reserved.
                </p>
                <p class="total">
                    <span class="c-green">Total </span> 681명/
                    <span class="c-green">Today </span>42명
                </p>

            </div>
        </div>


    </div>


</footer>

<script>

    // 이용자별 탭메뉴 이벤트
    const userBtn = document.querySelectorAll('.tab_btn');
    const userMenu = document.querySelectorAll('.userList .menu');

    for (let i = 0; i < userBtn.length; i++) {

        userBtn[i].addEventListener('click', function () {

            // 기존 active class 삭제
            for (let a = 0; a < userBtn.length; a++) {
                userBtn[a].classList.remove('active');
                userMenu[a].classList.remove('active');
            }

            // 클릭한 버튼 & 탭리스트 active class 추가
            this.classList.add('active')
            userMenu[i].classList.add('active')
        })

    }

</script>           <!-- footer -->
</div>
<!-- container 영영끝-->
 <form action="JangSu.jsp" name="p_menu_tap" method="get">
<!-- <form action="index.jangsu" name="p_menu_tap" method="get"> -->
	<input type="hidden" name="contentSid" value="1494">
	<input type="hidden" id="menu_1" name="totalSearch" value="<%=menu %>">
	<input type="hidden" id="" name="searchTerm" value="<%=searchTerm %>">
	<input type="hidden" id="" name="re_searchTerm" value="<%=re_searchTerm %>">
	<input type="hidden" id="" name="re_searchCheck" value="<%=re_searchCheck %>">
	<input type="hidden" id="" name="currentPage" value="<%=currentPage %>">
	<input type="hidden" id="searchArea_1" name="searchArea" value="<%=searchArea %>">
	<input type="hidden" id="" name="oper" value="<%=oper %>">
	<input type="hidden" id="" name="notKeyWord" value="<%=notKeyWord %>">
	<input type="hidden" id="" name="rseultsize" value="<%=rseultsize %>">
	<input type="hidden" id="" name="date" value="<%=detaildate %>">
	<input type="hidden" id="" name="startDate" value="<%=startDate %>">
    <input type="hidden" id="" name="endDate" value="<%=endDate %>">
    <input type="hidden" id="" name="order" value="<%=order %>">
</form>
</body>
</html>                                                                                                     
