<%@page import="javax.servlet.http.Cookie"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.ArrayList.*"%>
<%@ page import="java.text.*"%>
<%@ page import="java.net.URLEncoder"%>

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
<%@ page import="com.diquest.ir.client.command.profile.CommandProfile"%>
<%@ page import="com.diquest.ir.client.command.CommandSearchRequest"%>
<%@ page import="com.diquest.ir.common.msg.collection.CollectionInfo"%>
<%@ page import="com.diquest.ir.common.msg.ext.body.common.ErrorMessage"%>
<%@ page import="com.diquest.ir.client.util.RequestHandler"%>
<%@page import="com.diquest.ir.common.msg.protocol.query.QueryParser"%>

<%
request.setCharacterEncoding("utf-8");

String adminIP = "27.101.161.225";
String adminPORT = "5555";

// *****************************************************************************************
String menu = nullToStr(request.getParameter("menu"), "all");
String searchTerm = nullToStr(request.getParameter("searchTerm"), "");
String re_searchTerm = nullToStr(request.getParameter("re_searchTerm"), searchTerm);
String collection = nullToStr(request.getParameter("collection"), "");
String re_searchCheck = nullToStr(request.getParameter("re_searchCheck"), "");
String sco = nullToStr(request.getParameter("sco"), "all");
String searchArea = nullToStr(request.getParameter("searchArea"), "all");
String currentPage = nullToStr(request.getParameter("currentPage"), "1");
String rowsperPage = menu.equals("all") ? "4" : "10";

if (!searchTerm.equals("") && re_searchCheck.equals("on")) {
	if (re_searchTerm.indexOf(searchTerm) < 0) {
		re_searchTerm = re_searchTerm + "#,#" + searchTerm;
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
params.put("sco", sco);
params.put("searchArea", searchArea);
params.put("currentPage", currentPage);
params.put("rowsperPage", rowsperPage);

//result
ArrayList<HashMap<String, String>> hotList = getResultHot(params);
Map<String, Object> resultMap = getResult(params);
int totalSize = (int) resultMap.get("totalSize");
int menuSize = (int) resultMap.get("menuSize");
int contentSize = (int) resultMap.get("contentSize");
int bbsSize = (int) resultMap.get("bbsSize");
int officeSize = (int) resultMap.get("officeSize");
int fileSize = (int) resultMap.get("fileSize");
int imgSize = (int) resultMap.get("imgSize");
int movSize = (int) resultMap.get("movSize");
ArrayList<HashMap<String, String>> menuList = (ArrayList<HashMap<String, String>>) resultMap.get("menuList");
ArrayList<HashMap<String, String>> contentList = (ArrayList<HashMap<String, String>>) resultMap.get("contentList");
ArrayList<HashMap<String, String>> bbsList = (ArrayList<HashMap<String, String>>) resultMap.get("bbsList");
ArrayList<HashMap<String, String>> officeList = (ArrayList<HashMap<String, String>>) resultMap.get("officeList");
ArrayList<HashMap<String, String>> fileList = (ArrayList<HashMap<String, String>>) resultMap.get("fileList");
ArrayList<HashMap<String, String>> imgList = (ArrayList<HashMap<String, String>>) resultMap.get("imgList");
ArrayList<HashMap<String, String>> movList = (ArrayList<HashMap<String, String>>) resultMap.get("movList");

String pageNaviStr = "";

if (!menu.equals("all")) {
	int paramTotalSize = 0;
	
	if (menu.equals("menu")) {
		paramTotalSize = menuSize;
	} else if (menu.equals("content")) {
		paramTotalSize = contentSize;
	} else if (menu.equals("board")) {
		paramTotalSize = bbsSize;
	} else if (menu.equals("office")) {
		paramTotalSize = officeSize;
	} else if (menu.equals("file")) {
		paramTotalSize = fileSize;
	} else if (menu.equals("image")) {
		paramTotalSize = imgSize;
	} else if (menu.equals("video")) {
		paramTotalSize = movSize;
	} 
	
	pageNaviStr = getPageNavi(menu, currentPage, paramTotalSize);
}
// *****************************************************************************************
%>
<%!
public Map<String, Object> getResult(Map<String, String> params) {
	
	//result
	Map<String, Object> resultMap = new HashMap<String, Object>();
	int totalSize = 0;
	int menuSize = 0;
	int contentSize = 0;
	int bbsSize = 0;
	int officeSize = 0;
	int fileSize = 0;
	int imgSize = 0;
	int movSize = 0;
	ArrayList<HashMap<String, String>> menuList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> contentList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> bbsList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> officeList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> fileList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> imgList = new ArrayList<HashMap<String, String>>();
	ArrayList<HashMap<String, String>> movList = new ArrayList<HashMap<String, String>>();
	
	//param
	String mip = params.get("mip");
	String mport = params.get("mport");
	String menu = params.get("menu");
	String searchTerm = params.get("searchTerm");
	String re_searchTerm = params.get("re_searchTerm");
	String collection = params.get("collection");
	String re_searchCheck = params.get("re_searchCheck");
	String sco = params.get("sco");
	String searchArea = params.get("searchArea");
	
	Map<String, Query> queryMap = new HashMap<String, Query>();
	ArrayList<String> menuKey = new ArrayList<String>();
	
	if (menu.equals("all")) {
		if (searchArea.indexOf("all") > -1 || searchArea.indexOf("title") > -1) {
			queryMap.put("menu", getQuery(params, "menu"));
			menuKey.add("menu");
		}
		 
		if (searchArea.indexOf("all") > -1 || searchArea.indexOf("content") > -1) {
			queryMap.put("content", getQuery(params, "content"));
			menuKey.add("content");
		}
		
		if (searchArea.indexOf("all") > -1 || searchArea.indexOf("title") > -1 || searchArea.indexOf("content") > -1) {
			queryMap.put("board", getQuery(params, "board"));
			menuKey.add("board");
		}
		
		if (searchArea.indexOf("all") > -1) {
			queryMap.put("office", getQuery(params, "office"));
			menuKey.add("office");
		}
		
		if (searchArea.indexOf("all") > -1 || searchArea.indexOf("fileName") > -1 || searchArea.indexOf("fileContent") > -1) {
			queryMap.put("file", getQuery(params, "file"));
			menuKey.add("file");
		}
		
		if (searchArea.indexOf("all") > -1 || searchArea.indexOf("fileName") > -1) {
			queryMap.put("image", getQuery(params, "image"));
			menuKey.add("image");
		}
		
		if (searchArea.indexOf("all") > -1 || searchArea.indexOf("fileName") > -1) {
			queryMap.put("video", getQuery(params, "video"));
			menuKey.add("video");
		}
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
					
					if (key.equals("menu")) {
						menuSize = tempTotalSize;
						menuList.add(tempMap);
					} else if (key.equals("content")) {
						contentSize = tempTotalSize;
						contentList.add(tempMap);
					} else if (key.equals("board")) {
						bbsSize = tempTotalSize;
						bbsList.add(tempMap);
					} else if (key.equals("office")) {
						officeSize = tempTotalSize;
						officeList.add(tempMap);
					} else if (key.equals("file")) {
						fileSize = tempTotalSize;
						fileList.add(tempMap);
					} else if (key.equals("image")) {
						imgSize = tempTotalSize;
						imgList.add(tempMap);
					} else if (key.equals("video")) {
						movSize = tempTotalSize;
						movList.add(tempMap);
					} 
				}
			}
		} else {
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	
	resultMap.put("totalSize", totalSize);
	resultMap.put("menuSize", menuSize);
	resultMap.put("contentSize", contentSize);
	resultMap.put("bbsSize", bbsSize);
	resultMap.put("officeSize", officeSize);
	resultMap.put("fileSize", fileSize);
	resultMap.put("imgSize", imgSize);
	resultMap.put("movSize", movSize);
	
	resultMap.put("menuList", menuList);
	resultMap.put("contentList", contentList);
	resultMap.put("bbsList", bbsList);
	resultMap.put("officeList", officeList);
	resultMap.put("fileList", fileList);
	resultMap.put("imgList", imgList);
	resultMap.put("movList", movList);
	
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
	String sco = params.get("sco");
	
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
	String sco = params.get("sco");
	String currentPage = params.get("currentPage");
	String rowsperPage = params.get("rowsperPage");
	
	String collection = menu;
	String logKeyword = searchTerm;
	int start = getPageStart(currentPage, rowsperPage);
    int end = getPageEnd(currentPage, rowsperPage);
    
    char[] startTag = "<em class='sc_point'>".toCharArray();
    char[] endTag = "</em>".toCharArray();
		
	Query query = new Query(startTag, endTag);
	SelectSet[] selectSet = null;
	WhereSet[] whereSet = null;   
	OrderBySet[] orderBySet = null;
	
	if (menu.equals("menu")) {
		collection = "RFC_COMVNSEARCHMENU";
	} 
    
    if (menu.equals("content")) {
    	collection = "RFC_COMVNSEARCHCONTENT";
	} 
	
    if (menu.equals("board")) {
    	collection = "RFC_COMVNSEARCHBBSDATA";
	} 

    if (menu.equals("office")) {
    	collection = "RFC_COMVNSEARCHOFFICE";
	} 

    if (menu.equals("file")) {
    	collection = "RFC_COMVNSEARCHBBSFILE";
	} 

    if (menu.equals("image")) {
    	collection = "RFC_COMVNSEARCHBBSIMG";
	} 

    if (menu.equals("video")) {
    	collection = "RFC_COMVNSEARCHBBSMOV";
	} 

    if (menu.equals("HOT")) {
    	collection = "TREND_IMSIL";
    	start = 0;
    	end = 9;
    	logKeyword = "";
	}
    
    selectSet = getSelectSet(menu);
    whereSet = getWhereSet(menu, params); 
    orderBySet = getOrderBySet(menu);      
    
    query.setSelect(selectSet);
	query.setWhere(whereSet);
	if (orderBySet != null) {
		query.setOrderby(orderBySet);
	}
	query.setResult(start, end);
	query.setFrom(collection);
	query.setDebug(true);
	query.setFaultless(true);
	query.setPrintQuery(true);
	query.setLoggable(true);
	
	if (logKeyword != null || !logKeyword.equals("")) {
		query.setLogKeyword(logKeyword.toCharArray());
	}
	
	query.setSearchOption((byte)(Protocol.SearchOption.CACHE | Protocol.SearchOption.BANNED | Protocol.SearchOption.STOPWORD));	// 검색 캐시, 금지어, 불용어 사전 사용 설정 
	query.setThesaurusOption((byte)(Protocol.ThesaurusOption.QUASI_SYNONYM | Protocol.ThesaurusOption.EQUIV_SYNONYM));			// 동의어, 유의어 사전 사용 설정 
	
	return query;
	
}

public OrderBySet[] getOrderBySet(String menu) {
		
	OrderBySet[] orderBySet = null;
	
	if (menu.equals("HOT")) {
		orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_RANKING", Protocol.OrderBySet.OP_NONE) };
	}
	
	return orderBySet;
	
}

public WhereSet[] getWhereSet(String menu, Map<String, String> params) {
	
	String searchTerm = params.get("searchTerm");
	
	String re_searchTerm = params.get("re_searchTerm");
	String sco = params.get("sco");
	String searchArea = params.get("searchArea");
	
	String[] searchTermArr = re_searchTerm.split("#,#");
	
	ArrayList<WhereSet> whereSetList = new ArrayList<WhereSet>();
    WhereSet[] whereSet = null;
    
 	for (int i=0; i<searchTermArr.length; i++) {
 		searchTerm = searchTermArr[i];
 		
 		if (i > 0) {
 			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
 		}
 		
 		if (menu.equals("menu")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
			if (searchArea.equals("all")) {
				whereSetList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	    	whereSetList.add(new WhereSet("IDX_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 200));
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	    	whereSetList.add(new WhereSet("IDX_MENU_NM_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
	 	    	whereSetList.add(new WhereSet("IDX_FULL_NM_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    	} else {
 	    		boolean areaYn = false;
 	    		
 	    		if (searchArea.indexOf("title") > -1) {
 	    			if (areaYn) {
 						whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
 		        	}
 	    			whereSetList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
 	    			whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 		 	    	whereSetList.add(new WhereSet("IDX_MENU_NM_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		}
 	    	}
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
 		} 
 	    
 	    if (menu.equals("content")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
 	    	if (searchArea.equals("all")) {
 	    		whereSetList.add(new WhereSet("IDX_CONTENTS_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    	} else {
 	    		boolean areaYn = false;
 	    		
				if (searchArea.indexOf("content") > -1) {
					if (areaYn) {
 						whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
 		        	}
					whereSetList.add(new WhereSet("IDX_CONTENTS_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		}
 	    	}
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
 		} 
 		
 	    if (menu.equals("board")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
 	    	if (searchArea.equals("all")) {
 	    		whereSetList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	 	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm, 200));
 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	 	    	whereSetList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    	} else {
 	    		boolean areaYn = false;
 	    		
 	    		if (searchArea.indexOf("title") > -1) {
 	    			if (areaYn) {
 						whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
 		        	}
 	    			whereSetList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
 	    	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	    	    	whereSetList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm, 200));
 	    		}
 	    		
				if (searchArea.indexOf("content") > -1) {
					if (areaYn) {
 						whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
 		        	}
					whereSetList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		}
 	    	}
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
 		} 

 	    if (menu.equals("office")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
 	    	if (searchArea.equals("all")) {
 	    		whereSetList.add(new WhereSet("IDX_OFFICE_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 300));
 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	 	    	whereSetList.add(new WhereSet("IDX_USER_NM", Protocol.WhereSet.OP_HASALL, searchTerm, 200));
 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	 	    	whereSetList.add(new WhereSet("IDX_OFFICE_PT_MEMO", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	 	    	whereSetList.add(new WhereSet("IDX_OFFICE_FULL_NM_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    	}
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
 		} 

 	    if (menu.equals("file")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
 	    	if (searchArea.equals("all")) {
 	    		whereSetList.add(new WhereSet("IDX_FILE_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 
				100));
				whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereSetList.add(new WhereSet("IDX_FILE_NAME_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
				whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				whereSetList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    	} else {
 	    		boolean areaYn = false;
				
				if (searchArea.indexOf("fileName") > -1) {
					if (areaYn) {
 						whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
 		        	}
					whereSetList.add(new WhereSet("IDX_FILE_NAME_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
					whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereSetList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		}

				if (searchArea.indexOf("fileContent") > -1) {
					if (areaYn) {
 						whereSetList.add(new WhereSet(Protocol.WhereSet.OP_AND));
 		        	}
					whereSetList.add(new WhereSet("IDX_FILE_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
				}
 	    	}
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
 		} 

 	    if (menu.equals("image")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
 	    	if (searchArea.equals("all")) {
 	    		whereSetList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	 	    	whereSetList.add(new WhereSet("IDX_FILE_NAME_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    	} else {
 	    		boolean areaYn = false;
 	    		
				if (searchArea.indexOf("fileName") > -1) {
					whereSetList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		}
 	    	}
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
 		} 

 	    if (menu.equals("video")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
 	    	if (searchArea.equals("all")) {
 	    		whereSetList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		whereSetList.add(new WhereSet(Protocol.WhereSet.OP_OR));
 	 	    	whereSetList.add(new WhereSet("IDX_FILE_NAME_H", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    	} else {
 	    		boolean areaYn = false;
 	    		
				if (searchArea.indexOf("fileName") > -1) {
					whereSetList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm, 100));
 	    		}
 	    	}
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
 		} 

 	    if (menu.equals("HOT")) {
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
 	    	whereSetList.add(new WhereSet("IDX_TRENDS_ID", Protocol.WhereSet.OP_HASALL, "trend_imsil", 100));
 	    	whereSetList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_CLOSE));
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
	
	if (menu.equals("menu")) {
		selectSet = new SelectSet[]{
				new SelectSet("URL"),
				new SelectSet("FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)) //추가한거
		};
	} 

	if (menu.equals("content")) {
		selectSet = new SelectSet[]{
				new SelectSet("URL"), 
				new SelectSet("MENU_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("CONTENTS_CONTENT", (byte) (Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),100),
				new SelectSet("FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("board")) {
		selectSet = new SelectSet[]{
				new SelectSet("URL"), 
				new SelectSet("MENU_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_TITLE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_CONTENT", (byte) (Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT), 100),
				new SelectSet("FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("office")) {
		selectSet = new SelectSet[]{
				//new SelectSet("URL"), 
				new SelectSet("OFFICE_FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("USER_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("OFFICE_PT_MEMO", (byte) (Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT), 100),
				new SelectSet("OFFICE_TEL", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("OFFICE_FAX", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("file")) {
		selectSet = new SelectSet[]{
				new SelectSet("URL"), 
				new SelectSet("MENU_CD", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_CONTENT", (byte) (Protocol.SelectSet.HIGHLIGHT)), //추가한거
				new SelectSet("MENU_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FULL_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_SID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_TITLE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_SID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_NAME", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("image")) {
		selectSet = new SelectSet[]{
				new SelectSet("URL"), 
				new SelectSet("MENU_CD", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("REGISTER_DT", (byte) (Protocol.SelectSet.HIGHLIGHT)), //추가한거
				new SelectSet("MENU_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_SID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_TITLE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_SID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_NAME", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_THUMBNAIL_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("video")) {
		selectSet = new SelectSet[]{
				new SelectSet("URL"), 
				new SelectSet("MENU_CD", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("REGISTER_DT", (byte) (Protocol.SelectSet.HIGHLIGHT)), //추가한거
				new SelectSet("MENU_NM", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_SID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("DATA_TITLE", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_SID", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_NAME", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT)),
				new SelectSet("FILE_THUMBNAIL_PATH", (byte) (Protocol.SelectSet.HIGHLIGHT))
		};
	} 

	if (menu.equals("HOT")) {
		selectSet = new SelectSet[]{
				new SelectSet("KEYWORD", Protocol.SelectSet.NONE)
		};
	}
	
	return selectSet;
	
}

public String getPageNavi(String menu, String currentPage, int totalSize) {
	
	String resultTotalSize = "";
	
	int Curpage = Integer.parseInt(currentPage);
	int PageSize = 10;
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
		pageStr = pageStr + "<a href=\"javascript:paging('" + i + "','" + menu + "')\">" + i + "</a>&nbsp;&nbsp;";
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
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script type="text/javascript">

$(document).ready(function(e) {
	
	$(".tab_tit").each(function(idx) {
		if ($(this).children('a').attr("menu") == $("#menu_1").val()) {
			$(this).addClass("on");
		}
	});
	
	$("#sc_btn").on("click", function(){
			var searchName =$(".sch_txt").val();
			console.log(searchName);
			if ($('.sch_txt').val()==''){
				alert('검색어를 입력하세요');
				return false;
			}else{
				setSearchCookie('cookieName',searchName);
				document.frmSearch.submit();
				
			}
	});
	
	var sarea = $('#searchArea').val();
	$('input:checkbox[name="sco"]').each(function() {
		if(sarea.indexOf(this.value) > -1){
			this.checked = true;
		}
	});

	var cookie2 = getSearchCookie('cookieName');
	var text = "";
	var cookie2Arr = cookie2.split('@/');
	cookie2Arr  = cookie2Arr.filter(function(item) {
	return item !== null && item !== undefined && item !== '';
	});
	if(cookie2!=""){
	for(var i=0 ; i < cookie2Arr.length&& i<5 ; i++){
	
	text +="<li><a href=\"javascript:hotKeySearch('"+cookie2Arr[i]+"')\">"+cookie2Arr[i]+"</a></li>";
	console.log(text);
	}
	}else {
	text += "<li>검색어가 없습니다.</li>";
	}
	$("#recent").html(text); 

});

var page3 = 1;



function p_menu(menu) {
	/* var searchCheck=document.frmSearch.searchTerm.value;
	//alert(searchCheck);
	if(searchCheck==""){
		alert('검색버튼을 눌러주세요')
	}else{ */
	document.p_menu_tap.menu.value = menu;
	document.p_menu_tap.currentPage.value = 1;
	document.p_menu_tap.submit();
		
}

function paging(page, menu) {

	document.p_menu_tap.menu.value = menu
	document.p_menu_tap.currentPage.value = page
	document.p_menu_tap.submit();
}

function prepaging(currentPage, menu) {
	var page = parseInt(currentPage) - parseInt(page3);
	document.p_menu_tap.menu.value = menu
	document.p_menu_tap.currentPage.value = page
	document.p_menu_tap.submit();
}

function nextpaging(currentPage, menu) {
	var page = parseInt(currentPage) + parseInt(page3);
	
	document.p_menu_tap.menu.value = menu
	document.p_menu_tap.currentPage.value = page
	document.p_menu_tap.submit();
	
}

function fn_area_check(type) {
			
	var searchArea = "";

	if (type == 'all') {
		$('input:checkbox[name="sco"]').each(function() {
			if(this.value == 'all'){
				this.checked = true;
				
				searchArea = this.value;
			} else {
				this.checked = false;
			}
		});
	} else {
		$('input:checkbox[name="sco"]').each(function() {
			if(this.value == 'all'){
				this.checked = false;
			} else {
				if(this.checked){
					searchArea = searchArea + " " + this.value;
				}
			}
		});
	}
	
	$('#searchArea').val(searchArea);
	$('#searchArea_1').val(searchArea);
	
}

function hotKeySearch(hotKeyword) {
    var searchCheck = document.frmSearch;
    searchCheck.searchTerm.value = hotKeyword;
    searchCheck.menu.value = "all";
    searchCheck.searchArea.value="all";
    

    searchCheck.submit();
}
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

</script>
<style >

/* 이미지 서치용 */
.sch_imglist_test{padding-bottom:20px;border-bottom:1px solid #dedede;}
.sch_imglist_test:after{display: block; clear: both; content: "";}
.sch_imglist_test li{float:left;width:100%;text-align:center;margin:20px 0 0 0}
.sch_imglist_test li a{display:block}
.sch_imglist_test li img{width:200%;border:1px solid #dedede;}
.sch_imglist_test li span{display:block;margin-top:24px;font-size:14px;color:#717171}
.sch_imglist_test li strong{display:block;color:#333;font-size:18px;margin:0 0 5px 0}
.sch_imglist_test li a:hover strong, .sch_imglist li a:focus strong {text-decoration: underline;}


 
/* 페이징 */
.sch_con .sch_left .paging {text-align:center;margin-top:20px;font-family:돋움;}
.sch_con .sch_left .paging span {display:inline-block;border:1px solid #ccc;border-radius:3px;color:#343434;}
.sch_con .sch_left .paging span a {display:block;padding:3px 6px 1px 6px;border-radius:3px;}
.sch_con .sch_left .paging span a:hover {text-decoration:none;}

.sch_con .sch_left .paging span.compare_thispage {border:none;}

.sch_con .sch_left .paging span:hover {border:1px solid #acacac;background-color:#f7f7f7;}
.sch_con .sch_left .paging span.on {border:1px solid #1ab1c9; font-weight:bold;background-color:#1ab1c9 !important;.margin-bottom:-6px;}
.sch_con .sch_left .paging span.on a{color:#fff;}
.sch_con .sch_left .paging span.prev {margin-right:10px;}
.sch_con .sch_left .paging span.next {margin-left:10px;}
.sch_con .sch_left .paging span.first a {letter-spacing:-1px;padding-left:13px;}
.sch_con .sch_left .paging span.prev a {letter-spacing:-1px;padding-left:13px;}
.sch_con .sch_left .paging span.next a {letter-spacing:-1px;padding-right:13px;}
.sch_con .sch_left .paging span.last a {letter-spacing:-1px;padding-right:18px;}

.sch_con .sch_left .paging span.p_pop {margin-bottom:-0.8em;.margin-bottom:-0.5em;.margin-right:2px;.margin-left:2px;}
.sch_con .sch_left .paging span.prev.p_pop {.margin-right:10px;}
.sch_con .sch_left .paging span.next.p_pop {.margin-left:10px;}

.sch_con .sch_left  .paging span.first.p_pop {_margin-right:2px;}
.sch_con .sch_left  .paging span.last.p_pop {_margin-left:2px;}

.sch_con .sch_left .paging span.p_pop a {background-position:center;width:22px;padding:0;height:22px;display:block;}





@media all and (min-width:768px) {


 /* 이미지 서치용 */
.sch_imglist_test li{width:50%;}
.sch_imglist_test li a{width: 90%;margin: 0 auto;}

}




</style>


<body>
<div class="sub_search">
	<form method="get" action="/index.imsil?menuCd=DOM_000000107007000000" name="frmSearch" id="frmSearch">
	<input type="hidden" name="menuCd" value="DOM_000000107007000000">
	<input type="hidden" name="currentPage" value="1">
	<input type="hidden" name="re_searchTerm" value="<%=re_searchTerm %>">
	<input type="hidden" id="searchArea" name="searchArea" value="<%=searchArea %>">
	
	<fieldset>
		<legend>통합검색</legend>
		<span class="sch_bar"> 
			<select id="menu" name="menu" class="sch_sel">
				<option value="all" <%if (menu.equals("all")) {%>selected="selected" <%}%>>통합검색</option>
				<option value="menu" <%if (menu.equals("menu")) {%>selected="selected" <%}%>>메뉴</option>
				<option value="content" <%if (menu.equals("content")) {%>selected="selected" <%}%>>콘텐츠</option>
				<option value="board" <%if (menu.equals("board")) {%>selected="selected" <%}%>>게시판</option>
				<option value="office" <%if (menu.equals("office")) {%>selected="selected" <%}%>>직원/업무</option>
				<option value="file" <%if (menu.equals("file")) {%>selected="selected" <%}%>>파일</option>
				<option value="image" <%if (menu.equals("image")) {%>selected="selected" <%}%>>이미지</option>
				<option value="video" <%if (menu.equals("video")) {%>selected="selected" <%}%>>동영상</option>
			</select> 
			<input type="text" name="searchTerm" class="sch_txt" title="검색어" value="<%=searchTerm %>">
		</span> 
		<!-- <button class="sc_btn" id="sc_btn" >검색</button> --> 
		<input type="submit" class="sc_btn" id="sc_btn" value="검색">
		<span class="sch_schin" > 
			<input type="checkbox" id="sch_in" name="re_searchCheck"> <label for="sch_in">결과내검색</label>
		</span>
	</fieldset>
	
	<!-- 상세검색 S -->
	<div class="sch_more">
		<ul>
			<li><strong>검색범위</strong> 
				<input type="checkbox" name="sco" id="sch" value="all"  onclick="fn_area_check('all')">
				<label for="sch_sco1">전체</label> <input type="checkbox" name="sco" id="sch_sco2" value="title"   onclick="fn_area_check('title')">
				<label for="sch_sco2">제목</label> <input type="checkbox" name="sco" id="sch_sco3" value="content"   onclick="fn_area_check('content')">
				<label for="sch_sco3">본문</label> <input type="checkbox" name="sco" id="sch_sco4" value="fileName"   onclick="fn_area_check('fileName')">
				<label for="sch_sco4">파일명</label> <input type="checkbox" name="sco" id="sch_sco5" value="fileContent"   onclick="fn_area_check('fileContent')">
				<label for="sch_sco5">파일내용</label>
			</li>
		</ul>
	</div>
	<!-- 상세검색 e -->	
	</form>
</div>
<!-- 검색 e -->
<!-- 탭 s -->
<div class="basic_tab sch_tab">
	<ul>
		<li class="tab_tit"><a href="#" menu="all" onclick="javascript:p_menu('all'); return false;">통합검색</a></li>
		<li class="tab_tit"><a href="#" menu="menu" onclick="javascript:p_menu('menu'); return false;">메뉴</a></li>
		<li class="tab_tit"><a href="#" menu="content" onclick="javascript:p_menu('content'); return false;">콘텐츠</a></li>
		<li class="tab_tit"><a href="#" menu="board" onclick="javascript:p_menu('board'); return false;">게시판</a></li>
		<li class="tab_tit"><a href="#" menu="office" onclick="javascript:p_menu('office'); return false;">직원/업무</a></li>
		<li class="tab_tit"><a href="#" menu="file" onclick="javascript:p_menu('file'); return false;">파일</a></li>
		<li class="tab_tit"><a href="#" menu="image" onclick="javascript:p_menu('image'); return false;">이미지</a></li>
		<li class="tab_tit"><a href="#" menu="video" onclick="javascript:p_menu('video'); return false;">동영상</a></li>
	</ul>
</div>
<!-- 탭 e -->

<!-- 검색결과 s -->
<div class="sch_con">

<div class="sch_left">
<% 
if (totalSize == 0) { 
%>
<!-- 검색결과 없음 s -->
<div class="sch_box">
	<p>검색결과를 찾을 수 없습니다.</p>
	<ul>
		<li>단어의 철자가 정확한 지 확인해주세요.</li>
		<li>보다 일반적인 단어로 검색해보세요.</li>
	</ul>
</div>
<!-- 검색결과 없음 e -->
<% 
} else { 
%>
<!-- 검색결과 s -->
<div class="sch_result">
	<p>
		검색어 
<%
	String[] searchTermArr = re_searchTerm.split("#,#");

	for (int i=0; i<searchTermArr.length; i++) {
		String del = (i+1)==searchTermArr.length ? "" : ",";
%>
		<em class="sc_point"><%=searchTermArr[i] %></em><%=del %>
<%
	}
%>
		에 대한 총 <strong><%=totalSize %>건</strong>의
		검색결과를 찾았습니다.
	</p>
</div>
<!-- 검색결과 e -->
<% 
} 
%>
<!--=================================================메뉴===================================================================================  -->
<div class="sch_col">
<%
if (menuSize > 0) {
	if (menu.equals("all")) {
%>
<div class="tit">
<h4>메뉴</h4>
<p class="num">
검색결과 총 <strong><%=menuSize %></strong>건
</p>
</div>
<%
	} else {
%>
<br /><br />
<%
	}
	
	for (int i=0; i<menuList.size(); i++) {
		HashMap<String, String> tempMap = menuList.get(i);
		String URL = tempMap.get("URL");
		String FULL_NM = tempMap.get("FULL_NM");
%>
<ul class="sch_pagelist">
	<li>
		<a href="<%=URL %>"	target="_blank" title="새창열림"><strong><%=FULL_NM %></strong></a>
	</li>
</ul>
<%
	}

	if (menu.equals("all")) {
%>
<p class="more">
<a href="#" onclick="p_menu('menu'); return false;">메뉴 결과 더보기</a>
</p>
<%
	}
	
	
%>

<%
	
}
%>
</div>

<!--=================================================콘텐츠===================================================================================  -->
<div class="sch_col">
<%
if (contentSize > 0) {
	if (menu.equals("all")) {
%>
<div class="tit">
<h4>콘텐츠</h4>
<p class="num">
검색결과 총 <strong><%=contentSize %></strong>건
</p>
</div>
<%
	} else {
%>
<br /><br />
<%
	}
	
	for (int i=0; i<contentList.size(); i++) {
		HashMap<String, String> tempMap = contentList.get(i);
		String URL = tempMap.get("URL");
		String MENU_NM = tempMap.get("MENU_NM");
		String CONTENTS_CONTENT = tempMap.get("CONTENTS_CONTENT");
		String FULL_NM = tempMap.get("FULL_NM");
%>
<ul class="sch_conlist">
	<li>
		<strong><a href="<%=URL %>" target="_blank" title="새창열림"><%=MENU_NM %></a></strong>
		<span><%=CONTENTS_CONTENT %></span>
		<span class="sch_local"><%=FULL_NM %></span>
	</li>
</ul>
<%
	}

	if (menu.equals("all")) {
%>
<p class="more">
<a href="#" onclick="p_menu('content'); return false;">콘텐츠 결과 더보기</a>
</p>
<%
	}
	
	
%>

<%
	
}
%>
</div>

<!--=================================================게시판===================================================================================  -->
<div class="sch_col">
<%
if (bbsSize > 0) {
	if (menu.equals("all")) {
%>
<div class="tit">
<h4>게시판</h4>
<p class="num">
검색결과 총 <strong><%=bbsSize %></strong>건
</p>
</div>
<%
	} else {
%>
<br /><br />
<%
	}
	
	for (int i=0; i<bbsList.size(); i++) {
		HashMap<String, String> tempMap = bbsList.get(i);
		String URL = tempMap.get("URL");
		String MENU_NM = tempMap.get("MENU_NM");
		String DATA_TITLE = tempMap.get("DATA_TITLE");
		String DATA_CONTENT = tempMap.get("DATA_CONTENT");
		String FULL_NM = tempMap.get("FULL_NM");
%>
<ul class="sch_conlist">
	<li>
		<strong><a href="<%=URL %>" target="_blank" title="새창열림"><%=DATA_TITLE %></a></strong>
		<span><%=DATA_CONTENT %></span>
		<span class="sch_local"><%=FULL_NM %></span>
	</li>
</ul>
<%
	}

	if (menu.equals("all")) {
%>
<p class="more">
<a href="#" onclick="p_menu('board'); return false;">게시판 결과 더보기</a>
</p>
<%
	}
	
	
%>

<%
	
}
%>
</div>

<!--=================================================직원/업무===================================================================================  -->
<div class="sch_col">
<%
if (officeSize > 0) {
	if (menu.equals("all")) {
%>
<div class="tit">
<h4>직원/업무</h4>
<p class="num">
검색결과 총 <strong><%=officeSize %></strong>건
</p>
</div>
<%
	} else {
%>
<br /><br />
<%
	}
%>
<div class="over_table">
	<table class="basic_table">
		<caption>
			<strong>직원/업무</strong> 부서, 직위, 성명, 담당업무, 전화번호 정보 제공
		</caption>
		<thead>
			<tr>
				<th scope="col">부서</th>
				<!-- <th scope="col">직위</th> -->
				<th scope="col">성명</th>
				<th scope="col">담당업무</th>
				<th scope="col">전화번호</th>
				<!-- <th scope="col">전화번호</th> -->
			</tr>
		</thead>
		<tbody>
<%
	for (int i=0; i<officeList.size(); i++) {
		HashMap<String, String> tempMap = officeList.get(i);
		String URL = tempMap.get("URL");
		String OFFICE_FULL_NM = tempMap.get("OFFICE_FULL_NM");
		String USER_NM = tempMap.get("USER_NM");
		String OFFICE_PT_MEMO = tempMap.get("OFFICE_PT_MEMO");
		String OFFICE_TEL = tempMap.get("OFFICE_TEL");
		String OFFICE_FAX = tempMap.get("OFFICE_FAX");
%>
			<tr>
				<td><%=OFFICE_FULL_NM %></td>
				<!-- <td>주무관</td> -->
				<td><%=USER_NM %></td>
				<td class="txt_left"><%=OFFICE_PT_MEMO %></td>
				<td><%=OFFICE_TEL %></td>
				<%-- <td>${office.OFFICE_FAX }</td> --%>
			</tr>
<%
	}
%>
		</tbody>
	</table>
</div>
<% 
	if (menu.equals("all")) {
%>
<p class="more">
<a href="#" onclick="p_menu('office'); return false;">직원/업무 결과 더보기</a>
</p>
<%
	}
	
	
%>

<%
	
}
%>
</div>

<!--=================================================파일===================================================================================  -->
<div class="sch_col">
<%
if (fileSize > 0) {
	if (menu.equals("all")) {
%>
<div class="tit">
<h4>파일</h4>
<p class="num">
검색결과 총 <strong><%=fileSize %></strong>건
</p>
</div>
<%
	} else {
%>
<br /><br />
<%
	}
	
	for (int i=0; i<fileList.size(); i++) {
		HashMap<String, String> tempMap = fileList.get(i);
		String URL = tempMap.get("URL");
		String MENU_CD = tempMap.get("MENU_CD");
		String FILE_CONTENT = tempMap.get("FILE_CONTENT");
		String MENU_NM = tempMap.get("MENU_NM");
		String FULL_NM = tempMap.get("FULL_NM");
		String DATA_SID = tempMap.get("DATA_SID");
		String DATA_TITLE = tempMap.get("DATA_TITLE");
		String FILE_SID = tempMap.get("FILE_SID");
		String FILE_NAME = tempMap.get("FILE_NAME");
		String FILE_PATH = tempMap.get("FILE_PATH");
%>
<ul class="sch_conlist">
	<li>
		<strong><a href="<%=URL %>" target="_blank" title="새창열림"><%=FILE_NAME %></a></strong>
		<a href="<%=FILE_PATH %>" class="sbtn_down"><span>다운로드</span></a>
		<span class="sch_local"><%=FULL_NM %></span>
	</li>
</ul>
<%
	}

	if (menu.equals("all")) {
%>
<p class="more">
<a href="#" onclick="p_menu('file'); return false;">파일 결과 더보기</a>
</p>
<%
	}
	
	if (!pageNaviStr.equals("")) {
%>
<!-- 페이징 처리 해야 할 부분 -->
<div class="paging" align="center">
<%=pageNaviStr %>
</div>
<!--  페이징 처리 끝 -->
<%
	}
}
%>
</div>

<!--=================================================이미지===================================================================================  -->
<div class="sch_col">
<%
if (imgSize > 0) {
	if (menu.equals("all")) {
%>
<div class="tit">
<h4>이미지</h4>
<p class="num">
검색결과 총 <strong><%=imgSize %></strong>건
</p>
</div>
<%
	} else {
%>
<br /><br />
<%
	}
	HashMap<String, String> tempMap=new HashMap<String, String>();
	for (int i=0; i< imgList.size() ; i++) {
			
			 tempMap = imgList.get(i);
			//System.out.print("tempMap: " + tempMap);
				
			String URL = tempMap.get("URL");
			String MENU_CD = tempMap.get("MENU_CD");
			String REGISTER_DT = tempMap.get("REGISTER_DT");	
			String MENU_NM = tempMap.get("MENU_NM");
			String DATA_SID = tempMap.get("DATA_SID");
			String DATA_TITLE = tempMap.get("DATA_TITLE");
			String FILE_SID = tempMap.get("FILE_SID");
			String FILE_NAME = tempMap.get("FILE_NAME");
			String FILE_PATH = tempMap.get("FILE_PATH");
			//String FILE_THUMBNAIL_PATH = tempMap.get("FILE_THUMBNAIL_PATH");
%>

 <div style="float:left; margin-right: 10px" > 
<ul class="sch_imglist_test" >
	<li >
		<a href="<%=URL %>" target="_blank" title="새창열림">
			<img src="/images/bbs/no_img.gif" alt="테스트중." onerror="this.src='http://imsil-www.skoinfo.co.kr/images/bbs/no_img.gif';"/> <span><strong><%=FILE_NAME %></strong><%=REGISTER_DT %></span>
		</a>
	</li>
</ul>
 </div>



<%		
//System.out.println("imgList.size()>>>>>>>" + imgList.size());
	}
	int cnt = imgList.size();
	if(cnt%2==1) {
		 tempMap = imgList.get(cnt-1);
		//System.out.print("tempMap: " + tempMap);
			
		String URL = tempMap.get("URL");
		String MENU_CD = tempMap.get("MENU_CD");
		String REGISTER_DT = tempMap.get("REGISTER_DT");	
		String MENU_NM = tempMap.get("MENU_NM");
		String DATA_SID = tempMap.get("DATA_SID");
		String DATA_TITLE = tempMap.get("DATA_TITLE");
		String FILE_SID = tempMap.get("FILE_SID");
		String FILE_NAME = tempMap.get("FILE_NAME");
		String FILE_PATH = tempMap.get("FILE_PATH");
		String FILE_THUMBNAIL_PATH = tempMap.get("FILE_THUMBNAIL_PATH");
	
		%>
 
 <div style="float: left; visibility: hidden;">
	<ul class="sch_imglist_test" >
		<li >
			<a href="" target="_blank" title="새창열림">
				<img src="/images/bbs/no_img.gif" alt="테스트중." onerror="this.src='http://imsil-www.skoinfo.co.kr/images/bbs/no_img.gif';"/> <span><strong><%=FILE_NAME %></strong><%=REGISTER_DT %></span>
			</a>
		</li>
	</ul>
</div> 


		<%	
	
	 }	 

	
	if (menu.equals("all")) {
%>
<p class="more" style="width: 619px;">
<a href="#" onclick="p_menu('image'); return false;">이미지 결과 더보기</a>
</p>
<%
	}
	
	
}
%>
</div>

<!--=================================================동영상===================================================================================  -->
<div class="sch_col">
<%
if (movSize > 0) {
	if (menu.equals("all")) {
%>
<div class="tit">
<h4>동영상</h4>
<p class="num">
검색결과 총 <strong><%=movSize %></strong>건
</p>
</div>
<%
	} else {
%>
<br /><br />
<%
	}
	HashMap<String, String> tempMap=new HashMap<String, String>();
	for (int i=0; i<movList.size(); i++) {
		tempMap = movList.get(i);
		String URL = tempMap.get("URL");
		String MENU_CD = tempMap.get("MENU_CD");
		String REGISTER_DT = tempMap.get("REGISTER_DT");
		String MENU_NM = tempMap.get("MENU_NM");
		String DATA_SID = tempMap.get("DATA_SID");
		String DATA_TITLE = tempMap.get("DATA_TITLE");
		String FILE_SID = tempMap.get("FILE_SID");
		String FILE_NAME = tempMap.get("FILE_NAME");
		String FILE_PATH = tempMap.get("FILE_PATH");
		String FILE_THUMBNAIL_PATH = tempMap.get("FILE_THUMBNAIL_PATH");
%>
<div style="float:left; margin-right: 10px" >
<ul class="sch_imglist_test" >
	<li>
		<a href="<%=URL %>" target="_blank" title="새창열림">
			<img src="/images/bbs/no_img.gif" alt="테스트중." onerror="this.src='http://imsil-www.skoinfo.co.kr/images/bbs/no_img.gif';"/> <span><strong><%=FILE_NAME %></strong><%=REGISTER_DT %></span>
		</a>
	</li>
</ul>
</div>
<%
}
	int cnt = movList.size(); 
	if(cnt%2==1) {
		 tempMap = movList.get(cnt);
			
		String URL = tempMap.get("URL");
		String MENU_CD = tempMap.get("MENU_CD");
		String REGISTER_DT = tempMap.get("REGISTER_DT");	
		String MENU_NM = tempMap.get("MENU_NM");
		String DATA_SID = tempMap.get("DATA_SID");
		String DATA_TITLE = tempMap.get("DATA_TITLE");
		String FILE_SID = tempMap.get("FILE_SID");
		String FILE_NAME = tempMap.get("FILE_NAME");
		String FILE_PATH = tempMap.get("FILE_PATH");
		String FILE_THUMBNAIL_PATH = tempMap.get("FILE_THUMBNAIL_PATH");
	
		%>
 
 <div style="float: left; visibility: hidden;">
	<ul class="sch_imglist_test" >
		<li >
			<a href="" target="_blank" title="새창열림">
				<img src="/images/bbs/no_img.gif" alt="테스트중." onerror="this.src='http://imsil-www.skoinfo.co.kr/images/bbs/no_img.gif';"/> <span><strong><%=FILE_NAME %></strong><%=REGISTER_DT %></span>
			</a>
		</li>
	</ul>
</div> 


		<%		
	
	 
	}

	if (menu.equals("all")) {
%>
<p class="more">
<a href="#" onclick="p_menu('video'); return false;">동영상 결과 더보기</a>
</p>
<%
	}
	
	
%>

<%

}
%>
</div>

<%if (!pageNaviStr.equals("")) {
%>
<!-- 페이징 처리 해야 할 부분 -->
<div class="paging" align="center" >
<%=pageNaviStr %>
</div>
<!--  페이징 처리 끝 -->
<%
	}
%>
<!-- ====================================================검색 왼쪽 끝===================================================================== -->		
</div>	
		
<div class="sch_right">
	<!-- 인기검색어 s -->
	<div class="best_sch">
	<h4>
	<span>인기</span> 검색어
	</h4>
	<% 
		if(hotList.size() > 0) { 
	%>
	<ul>
	<%	
			for (int i=0; i<hotList.size(); i++) {
				HashMap<String, String> tempMap = hotList.get(i);
				String KEYWORD = tempMap.get("KEYWORD");
				int rank = i+1;
	%>			
	<li>
		<span><%=rank %></span>
		<a href="#" onclick="hotKeySearch('<%=KEYWORD %>'); return false;"><%=KEYWORD %></a>
	</li>
	<% 
			} 
	%>
	</ul>
	<% 
		} 
	%>
	</div>
	<!-- 인기검색어 e -->
	<!-- 내가찾은 검색어 s -->
	
	
	<div class="my_sch">
		<h4>
		<span>내가 찾은</span> 검색어
		</h4>
		
		<ul id="recent">
		<!-- 
		<li><a href="">일자리</a></li>
		<li><a href="">인사</a></li>
		<li><a href="">검색어</a></li>
		-->
		</ul>
	</div>
	<!-- 내가찾은 검색어 e -->
</div>
<!-- ====================================================검색 끝===================================================================== -->		
</div>	

<form action="/index.imsil?menuCd=DOM_000000107007000000" name="p_menu_tap" method="get">
	<input type="hidden" name="menuCd" value="DOM_000000107007000000">
	<input type="hidden" id="menu_1" name="menu" value="<%=menu %>">
	<input type="hidden" id="" name="searchTerm" value="<%=searchTerm %>">
	<input type="hidden" id="" name="re_searchTerm" value="<%=re_searchTerm %>">
	<input type="hidden" id="" name="currentPage" value="<%=currentPage %>">
	<input type="hidden" id="searchArea_1" name="searchArea" value="<%=searchArea %>">
</form>
</body>
</html>                  