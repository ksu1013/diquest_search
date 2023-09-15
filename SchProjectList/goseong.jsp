<%@page import="java.lang.invoke.TypeDescriptor.OfMethod"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="java.time.LocalDate"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ page import="java.util.*" %>
<%@ page import="java.util.ArrayList.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.QuerySet" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.Query" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.QueryParser" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.SelectSet" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.WhereSet" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.FilterSet" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.GroupBySet" %>
<%@ page import="com.diquest.ir.common.msg.protocol.query.OrderBySet" %>
<%@ page import="com.diquest.ir.common.msg.protocol.result.ResultSet" %>
<%@ page import="com.diquest.ir.common.msg.protocol.result.Result" %>
<%@ page import="com.diquest.ir.common.msg.protocol.result.GroupResult" %>
<%@ page import="com.diquest.ir.common.msg.protocol.Protocol" %>
<%@ page import="com.diquest.ir.client.command.profile.CommandProfile"%>
<%@ page import="com.diquest.ir.client.command.CommandSearchRequest" %>
<%@ page import="com.diquest.ir.common.msg.collection.CollectionInfo"%>
<%@ page import="com.diquest.ir.common.msg.ext.body.common.ErrorMessage"%>
<%@ page import="com.diquest.ir.client.util.RequestHandler" %>    
<%!

    /*
    *  페이지 네비게이션
    *  @ ps = 한 페이지에 보여줄 결과 수
    *  @ cn = 현재 페이지 번호
    *  @ tn = 전체 결과 수
    */
    public String getPageNav(int ps, int cn, int tn, String collect) {
        String pagenav = "";
        int pageSizeInt = ps;
        int pageBlock = 5;
        int cpage = cn;
        int total = tn;
        int EndNo = pageSizeInt * cpage;
        int StartNo = EndNo - pageSizeInt;
        int totalPage = ((total - 1) / pageSizeInt) + 1;
        int prevPage = (int)((double)((cpage - 1) / pageBlock)) * pageBlock;
        int prevPage2 = 1;
        int nextPage = prevPage + pageBlock + 1;

        if (total > 0) {
            pagenav += "<div class=\"boradNumBtn\"><div class=\"bdNumWrap\">";
            if (cpage != 1){
                if (prevPage > 0){
                	
                    // 첫페이지
                    pagenav += "<a href=\"#\" class=\"bdNumList bdNumFirst\" title=\"게시판 첫번째목록 페이지로 이동합니다.\"/><img src=\"/images/Potal/board/boardFirst.png\"  onclick=\"move_Action('"+ prevPage2 + "','"+ collect + "'); return false;\" alt=\"게시물 처음으로\"/></a>";
                
                    // 이전 페이지
                    pagenav += "<a href=\"#\" class=\"bdNumList bdNumPrev\" title=\"게시판  이전목록 페이지로 이동합니다.\"/><img src=\"/images/Potal/board/boadrPrev.png\"  onclick=\"move_Action('"+ prevPage + "','"+ collect + "'); return false;\"alt=\"게시물 이전 페이지\"/></a>";
                }
            }
            // 리스트
            for(int i = 1 + prevPage; i < nextPage && i <= totalPage; i++){
                if (i == cpage){
                    pagenav += "<a class=\"bdNumList bdNum numOn\""+ i +"\" >"+i+" </a>";
                }else{
                    pagenav += "<a  href=\"#"+i+"\" class=\"bdNumList bdNum\" onclick=\"move_Action('"+i+"','"+ collect + "'); return false;\">"+i+"</a>";
                }
            }

            if (totalPage > cpage){
                if (totalPage >= nextPage){
                    // 다음10 페이지
                   /*  pagenav += "<a href=\"#next\" onclick=\"javascript:move_Action('"+ nextPage + "','"+ collect + "'); return false;\" class=\"next\"><img src=\"/images/board/paging_next.gif\" alt=\"다음페이지\" /></a>"; */
                    pagenav += "<a href=\"#\" class=\"bdNumList bdNumNext\" title=\"게시판 다음목록 페이지로 이동합니다.\"/><img src=\"/images/Potal/board/boadrNext.png\"  onclick=\"move_Action('"+ nextPage + "','"+ collect + "'); return false;\" alt=\"게시물 다음페이지\"/></a>";
                    
                    pagenav += "<a href=\"#\" class=\"bdNumList bdNumLast\" title=\"게시판 마지막목록 페이지로 이동합니다.\"/><img src=\"/images/Potal/board/boardFirst.png\"  onclick=\"move_Action('"+ totalPage + "','"+ collect + "'); return false;\" alt=\"게시물 마지막으로\"/></a>";
                }
            }
            pagenav += "</div></div>";
        }
        return pagenav;
    }



%>

<%
request.setCharacterEncoding("utf-8");
String DETAIL_URL = "";
String DATA_SID = "";
String BOARD_SEQ ="";
String CONTENTS_SID ="";
String CONTENTS_TYPE ="";
String DATASID ="";
String DATA_CONTENT ="";
String DATA_TITLE ="";
String DOMAIN ="";
String FILEMASKS ="";
String FILENAMES ="";
String FILESIDS ="";
String FULL_NM ="";
String MENU_CD ="";
String MENU_DP ="";
String MENU_NM ="";
String MENU_PARENT_CD ="";
String MODI_DATE ="";
String REGISTER_DATE ="";
String REG_DATE ="";
String DQ_ID ="";
String BOARD_ID = "";
String SEQ ="";
String CONTENTS_STYLE ="";
String CONTENTS_CONTENT ="";
String CONTENTS_MODI_DATE ="";
String FILE_THUMBNAIL_PATH ="";
String FILE_PATH ="";
String FILE_SIZE ="";
String FILE_MASK ="";
String FILE_NAME ="";
String FILE_SID ="";
String selectFieldName ="";
String selectField ="";
String OFCPS_NM ="";
String USER_NM ="";
String OFFICE_PT_MEMO ="";
String OFFICE_FAX ="";
String OFFICE_NM ="";
String OFFICE_TEL ="";
String EMAIL_ADRES ="";
String OFFICENMS ="";
String THUMBNAIL_PATH ="";
String CONTENT ="";
String TITLE ="";
String PATH ="";
String URL ="";
String CATEGORY_CODE="";
String BOARD_seq="";
String CATEGORY_CODE1="";
String CATEGORY_CODE2="";
String CATEGORY_CODE3="";


RequestHandler requestHandler = new RequestHandler(request, application);

String searchTerm = request.getParameter("searchTerm")!=null ? request.getParameter("searchTerm") : "";
String searchTermList = request.getParameter("searchTermList"); if(searchTermList == null)searchTermList = searchTerm;				// 재검색시 & 합쳐진 검색어(노출용)
String collection = request.getParameter("collection")!=null ? request.getParameter("collection") : "total";
String detail_range = request.getParameter("detail_range")!=null ? request.getParameter("detail_range") : "all";
String searchField = request.getParameter("searchField")!=null ? request.getParameter("searchField") : "all";

String re_search = request.getParameter("re_search")!=null ? request.getParameter("re_search") : "N";
String date = request.getParameter("date")!=null ? request.getParameter("date") : "all";
String currentPageStr = request.getParameter("currentPage")!=null ? request.getParameter("currentPage") : "1";
String orderby = request.getParameter("orderby")!=null ? request.getParameter("orderby") : "sort";                      		//정렬
System.out.println("orderby>>>"+orderby);

if(!searchTerm.equals("")&&re_search.equals("on")){
	searchTermList = searchTermList + ",," + searchTerm;
	System.out.print("searchTermList>>>>>"+searchTermList);
}else {
	
	searchTermList=searchTerm;
	
}


int currentPage = Integer.parseInt(currentPageStr);


LocalDate now = LocalDate.now(); 																	//현재시간
LocalDate sevenDaysAgo = now.minusDays(7); 															//7일전
LocalDate thirtyDaysAgo = now.minusDays(30); 														//30일전
DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

String endDate="";
String startDate="";


if (date.equals("seven")) {
	endDate = now.format(formatter);
	startDate = sevenDaysAgo.format(formatter);
} else if (date.equals("thirty")) {
	endDate = now.format(formatter);
	startDate = thirtyDaysAgo.format(formatter);
}



String[] search_range = { startDate, endDate };







final String HOST = "27.101.84.54";											// 검색서버 IP
final int PORT = 6666;														// 검색서버 port

QueryParser queryParser = new QueryParser();



SelectSet[] selectSet = null;
WhereSet[] whereSet = null;
FilterSet[] filterSet = null;
OrderBySet[] orderbySet = null;
QuerySet querySet = null;






int totalCount = 0;		// 전체검색결과수
int endNo = 0;
int startNo = 0;
int eimageNo = 0;
int simageNo = 0;
//int timageNo = 0;

Query web_query = null;			//웹페이지
Query board_query = null;		//게시판
Query image_query = null;		//이미지
Query office_query = null;		//업무/직원
Query menu_query = null;		//메뉴
Query news_query = null;		//고성뉴스
Query moonhwa_query = null;		//문화


ResultSet results = null;
Result[] resultlist = null;
Result result = null;
Result result2 = null;
Result result3 = null;
Result result4 = null;
Result result5 = null;
Result result6 = null;
Result result7 = null;



if(!collection.equals("total")){
	startNo = (currentPage - 1) * 10;
    endNo = startNo + 9;
    simageNo = (currentPage - 1) * 12;  				//0  12 34
    eimageNo = simageNo + 11;							//11 33 45
}




	Map<String, Query> queryMap = new HashMap<String, Query>();
	ArrayList<String> menuKey = new ArrayList<String>();
	
	/****************************************************직원************************************************************************************/
			office_query = query_fn("OFFICE", searchTermList, searchField,"office",search_range,orderby,searchTerm,date);
			office_query.setResult(startNo , endNo );
			if(!collection.equals("office")){
				office_query.setResult(0, 4);
			}
			queryMap.put("office", office_query);
			menuKey.add("office");
	/****************************************************메뉴************************************************************************************/
			menu_query = query_fn("MENU", searchTermList, searchField,"menu",search_range,orderby,searchTerm,date);
			menu_query.setResult(startNo , endNo );
			if(!collection.equals("menu")){
				menu_query.setResult(0, 2);
			}
			queryMap.put("menu", menu_query);
			menuKey.add("menu");
	/****************************************************문화************************************************************************************/		
			moonhwa_query = query_fn("MOONHWA", searchTermList, searchField,"moonhwa",search_range,orderby,searchTerm,date);
			moonhwa_query.setResult(startNo , endNo );
			if(!collection.equals("moonhwa")){
					moonhwa_query.setResult(0, 1);
			}
			queryMap.put("moonhwa", moonhwa_query);
			menuKey.add("moonhwa");
	/****************************************************뉴스************************************************************************************/
			news_query =query_fn("NEWS", searchTermList, searchField,"news",search_range,orderby,searchTerm,date);
			news_query.setResult(startNo , endNo );
			if(!collection.equals("news")){
				news_query.setResult(0, 1);
			}
			queryMap.put("news", news_query);
			menuKey.add("news");
	/****************************************************게시판************************************************************************************/		
			board_query = query_fn("BOARD", searchTermList, searchField,"board",search_range,orderby,searchTerm,date);
			board_query.setResult(startNo , endNo );
			if(!collection.equals("board")){
				board_query.setResult(0, 1);
			}
			queryMap.put("board", board_query);
			menuKey.add("board");
	/****************************************************웹************************************************************************************/	
			web_query = query_fn("WEB", searchTermList, searchField,"web",search_range,orderby,searchTerm,date);
			web_query.setResult(startNo , endNo );
			if(!collection.equals("web")){
				web_query.setResult(0, 1);
			}
			queryMap.put("web",web_query);
			menuKey.add("web");
	/****************************************************이미지************************************************************************************/	
			image_query = query_fn("IMAGE", searchTermList, searchField,"image",search_range,orderby,searchTerm,date);
				image_query.setResult(simageNo , eimageNo );
			if(!collection.equals("image")){
				
				image_query.setResult(0, 3);
			}	
			queryMap.put("image", image_query);
			menuKey.add("image");
	
		
		
		
		querySet = new QuerySet(queryMap.size());
		
		for (int i=0; i<queryMap.size(); i++) {
			querySet.addQuery(queryMap.get(menuKey.get(i).toString()));
		}
		
		
	
	
	int returnCode = 0;
	Map<String, Object> resultMap = new HashMap<String, Object>();
	int totalSize = 0;
	int menuSize = 0;
	int newsSize = 0;
	int bbsSize = 0;
	int officeSize = 0;
	int webSize = 0;
	int imgSize = 0;
	int mohSize = 0;
	
	
	ArrayList<HashMap<String, String>> menuList = new ArrayList<HashMap<String, String>>();        	//메뉴
	ArrayList<HashMap<String, String>> newsList = new ArrayList<HashMap<String, String>>();			//뉴스	
	ArrayList<HashMap<String, String>> bbsList = new ArrayList<HashMap<String, String>>();  		//게시판
	ArrayList<HashMap<String, String>> officeList = new ArrayList<HashMap<String, String>>();		//직원	
	ArrayList<HashMap<String, String>> webList = new ArrayList<HashMap<String, String>>();			//웹사이트
	ArrayList<HashMap<String, String>> imgList = new ArrayList<HashMap<String, String>>();			//이미지
	ArrayList<HashMap<String, String>> mohList = new ArrayList<HashMap<String, String>>();			//문화
	


	CommandSearchRequest command = null;
	if(!searchTerm.equals("")) {
			command = new CommandSearchRequest(HOST, PORT);
			returnCode = command.request(querySet);
			System.out.print("returnCode>>>>"+returnCode);
		if(returnCode > 0) {
			results = command.getResultSet();
			resultlist = results.getResultList();
		}
				//System.out.print("확인>>>>>>>>>>>>>");
				result = resultlist[0];      	//직원
				result2 = resultlist[1];	 	//메뉴
				result3 = resultlist[2];		//문화관광
				result4 = resultlist[3];		//뉴스
				result5 = resultlist[4];		//게시판
				result6 = resultlist[5];		//웹사이트
				result7 = resultlist[6];		//이미지
				
				officeList = getResult("office", result);
				menuList = getResult("menu", result2);
				mohList = getResult("moonhwa", result3);
				newsList = getResult("news", result4);
				bbsList = getResult("board", result5);
				webList = getResult("web", result6);
				imgList = getResult("image", result7);
				
				
				// 검색 건수 
				officeSize = result.getTotalSize();
				menuSize = result2.getTotalSize();
				mohSize = result3.getTotalSize();
				newsSize = result4.getTotalSize();
				bbsSize = result5.getTotalSize();
				webSize = result6.getTotalSize();
				imgSize = result7.getTotalSize();
				
				
	}
	totalSize =  menuSize + mohSize + bbsSize + officeSize + webSize + imgSize+newsSize;

	


	






%>

<%!
	//getResult
	public ArrayList<HashMap<String, String>> getResult(String collection, Result result) {
		ArrayList<HashMap<String, String>> LIST = new ArrayList<HashMap<String, String>>();
		for(int i = 0; i < result.getRealSize(); i++) {
			HashMap<String, String> tempMap = new HashMap<String, String>();
			
				for(int j = 0; j < result.getNumField(); j++) {
					String filedname = new String(selectSet_fn(collection)[j].getField());
					tempMap.put(filedname, new String(result.getResult(i, j)));
				}
			
			LIST.add(tempMap);
			}
		
		return LIST;
   	}


	public Query query_fn(String menu, String searchTermList, String searchField,String collection,String[] search_range,String orderby,String searchTerm,String date) {
		char[] startTag = "<font color='red'>".toCharArray();  //하이라이팅
		char[] endTag = "</font>".toCharArray();
	
		Query query = null;
		query = new Query(startTag, endTag);
		query.setDebug(true);
		query.setPrintQuery(true);
		query.setFrom(menu);
		query.setLoggable(true);
		query.setLogKeyword(searchTerm.toCharArray());
		query.setSelect(selectSet_fn(collection));
		query.setWhere(whereSet_fn(collection, searchTermList, searchField));
		//if(collection.equals("image")){
		//	query.setOrderby(orderSet_fn("johoe",collection));
			
		if(collection.equals("news")||collection.equals("moonhwa")||collection.equals("board")||collection.equals("image")){
			if(orderby.equals("sort")){
			query.setOrderby(orderSet_fn("sort",collection));
				
			}else if(orderby.equals("weight")) {
				query.setOrderby(orderSet_fn("weight",collection));
			}else{
				query.setOrderby(orderSet_fn("johoe",collection));
			}
			
		}
		if(!date.equals("all")){
			
			query.setFilter(filterSet(collection,search_range));
		}
			
		
		// 검색결과 옵션 설정 (검색 캐쉬, 금지어, 불용어)
		query.setSearchOption((byte) (Protocol.SearchOption.CACHE | Protocol.SearchOption.STOPWORD | Protocol.SearchOption.BANNED));
		
		// 동의어, 유의어 확장
		query.setThesaurusOption((byte) (Protocol.ThesaurusOption.EQUIV_SYNONYM | Protocol.ThesaurusOption.QUASI_SYNONYM));

	
	
		return query;
	}
	public SelectSet[] selectSet_fn(String collection) {
		SelectSet[] selectSet = null;
		if (collection.equals("office")) {
			selectSet = new SelectSet[] {
		            new SelectSet("EMAIL_ADRES", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("OFCPS_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("OFFICENMS", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("OFFICE_DP",Protocol.SelectSet.HIGHLIGHT),
					new SelectSet("OFFICE_FAX",Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("OFFICE_NM",Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("OFFICE_PT_IX",Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("OFFICE_PT_MEMO",(byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
		            new SelectSet("OFFICE_PT_SID",Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("OFFICE_TEL",Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("USER_NMUSER_NM",Protocol.SelectSet.HIGHLIGHT)
		    };
		} 
		if (collection.equals("menu")) {
			selectSet = new SelectSet[] {
		            new SelectSet("DOMAIN", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DOMAIN_ID", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DOMAIN_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_CD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("PATH", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("ROOTCD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("URL", Protocol.SelectSet.HIGHLIGHT)

		    };
		} 
		if (collection.equals("moonhwa")) {
			selectSet = new SelectSet[] {
		            new SelectSet("BOARD_ID", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),250),
		            new SelectSet("BOARD_SEQ", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),250),
		            new SelectSet("CATEGORY_CODE1", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CATEGORY_CODE2", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CATEGORY_CODE3", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CONTENTS_SID", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CONTENTS_TYPE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DATA_CONTENT", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DATA_SID", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DATA_TITLE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DOMAIN", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DQ_ID", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("FILEMASKS", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("FILENAMES", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("FILE_CONTENT", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("FILE_SIDS", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("FULL_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_CD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_DP", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_PARENT_CD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_STR", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MODIFY_DATE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("REGDATE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("REGISTER_DATE", Protocol.SelectSet.HIGHLIGHT)

		    };
		
		}
		if (collection.equals("news")) {
			selectSet = new SelectSet[] {
					 new SelectSet("BOARD_ID", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),250),
			            new SelectSet("BOARD_SEQ", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),250),
			            new SelectSet("CONTENTS_SID", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("CONTENTS_TYPE", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DATA_CONTENT", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
			            new SelectSet("DATA_SID", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DATA_TITLE", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DOMAIN", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DQ_ID", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FILEMASKS", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FILENAMES", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FILE_CONTENT", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FILE_SIDS", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FULL_NM", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_CD", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_DP", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_NM", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_PARENT_CD", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MODIFY_DATE", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("REGDATE", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("REGISTER_DATE", Protocol.SelectSet.HIGHLIGHT)

		    };
		
		}
		if (collection.equals("board")) {
			selectSet = new SelectSet[] {
					 new SelectSet("BOARD_ID", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),100),
			            new SelectSet("BOARD_SEQ", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),100),
			            new SelectSet("CONTENTS_SID", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("CONTENTS_TYPE", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DATA_CONTENT", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
			            new SelectSet("DATA_SID", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DATA_TITLE", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DOMAIN", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("DQ_ID", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FILEMASKS", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FILENAMES", Protocol.SelectSet.HIGHLIGHT),
			           // new SelectSet("FILE_CONTENT", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FILE_SIDS", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("FULL_NM", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_CD", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_DP", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_NM", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("MENU_PARENT_CD", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("REGDATE", Protocol.SelectSet.HIGHLIGHT),
			            new SelectSet("REGISTER_DATE", Protocol.SelectSet.HIGHLIGHT)

		    };
		
		}
		if (collection.equals("web")) {
			selectSet = new SelectSet[] {
		            new SelectSet("CONTENTS_CONTENT", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CONTENTS_MODI_DATE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CONTENTS_SID", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
		            new SelectSet("CONTENTS_STYLE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CONTENTS_TYPE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DOMAIN", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("FULL_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_CD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_DP", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_NM", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
		            new SelectSet("MENU_PARENT_CD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("REGDATE", Protocol.SelectSet.HIGHLIGHT)
		    };
		
		}
		if (collection.equals("image")) {
			selectSet = new SelectSet[] {
					new SelectSet("BOARD_ID", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),250),
		            new SelectSet("BOARD_SEQ", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT),250),
		            new SelectSet("CONTENTS_SID", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("CONTENTS_TYPE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DATA_CONTENT", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DATA_SID", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DATA_TITLE", (byte)(Protocol.SelectSet.SUMMARIZE | Protocol.SelectSet.HIGHLIGHT)),
		            new SelectSet("DOMAIN", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("DQ_ID", Protocol.SelectSet.HIGHLIGHT),
		           	new SelectSet("FILE_MASK", Protocol.SelectSet.HIGHLIGHT),
		          	new SelectSet("FILE_NAME", Protocol.SelectSet.HIGHLIGHT),
		          	new SelectSet("FILE_SID", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("FULL_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_CD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_DP", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_NM", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MENU_PARENT_CD", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("MODIFY_DATE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("REGDATE", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("REGISTER_DT", Protocol.SelectSet.HIGHLIGHT),
		            new SelectSet("VIEW_COUNT", Protocol.SelectSet.HIGHLIGHT)
		    };
		
		}
		return selectSet;
		
	}
	public WhereSet[] whereSet_fn(String collection, String searchTermList, String searchField) {
		ArrayList<WhereSet> whereList = new ArrayList<WhereSet>();
		
		String[] searchTerm_Array = searchTermList.split(",,");
		//System.out.print("searchTerm_Array>>>>>"+searchTerm_Array);
		for(int i = 0; i < searchTerm_Array.length; i++) {
			// 재검색
			 if(i != 0) {
				 whereList.add(new WhereSet(Protocol.WhereSet.OP_AND));
				} 	
			/********************************************************************************************************************
			 * 직원
			 ********************************************************************************************************************/
			if(collection.equals("office")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				
				// 전체
				if(searchField.contains("all")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				    whereList.add(new WhereSet("IDX_OFCPS_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				    whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_OFCPS_NM_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				    whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_USER_NMUSER_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				    whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_OFFICE_PT_MEMO", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				    whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_OFFICE_TEL", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				    whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_EMAIL_ADRES", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				    whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
					
				}
					
				// 제목
				else if(searchField.contains("title")) {
					whereList.add(new WhereSet("IDX_OFCPS_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 300));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_OFCPS_NM_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_USER_NMUSER_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 100));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_OFFICE_PT_MEMO", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 100));
				}
				// 내용
				else if(searchField.contains("content")) {
					whereList.add(new WhereSet("IDX_OFFICE_PT_MEMO", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				}
				
				else{
					
					whereList.add(new WhereSet("IDX_EMAIL_ADRES", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 300));
				}
				
				
				
				whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
			
			
			
			/********************************************************************************************************************
			 *메뉴
			 ********************************************************************************************************************/
			} else if(collection.equals("menu")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				
				// 전체
				if(searchField.contains("all")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				    whereList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				    whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_PATH", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),100));
				    whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));

					
				}
					
				//제목
				else if(searchField.contains("title")) {
					whereList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 150));
				}
				else {
					
					whereList.add(new WhereSet("IDX_MENU_CD", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 300));
				}
				whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
			
			
			
			/********************************************************************************************************************
			 * 문화
			 ********************************************************************************************************************/
			}else if(collection.equals("moonhwa")) {
				//문화 파일내용 필터링 해야함
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				
				// 전체
				if(searchField.contains("all")) {
					   whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				       whereList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_FILE_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
				}
					
				// 제목
				else if(searchField.contains("title")) {
					whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
				}
				//파일 이름으로 검색
				else if(searchField.contains("file_nm")) {
					whereList.add(new WhereSet("IDX_FILENAMES", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_FILENAMES_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 300));
				}
				else {
					
					whereList.add(new WhereSet("IDX_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 300));
				}
				
				
				whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
			
			/********************************************************************************************************************
			 * 뉴스
			 ********************************************************************************************************************/
			} else if(collection.equals("news")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				
				// 전체
				if(searchField.contains("all")) {
					 whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				       whereList.add(new WhereSet("IDX_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
	 	 	    	
				}
				// 제목
				if(searchField.contains("title")) {
					whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
				}
				//파일 이름
				if(searchField.contains("file_nm")) {
					whereList.add(new WhereSet("IDX_FILENAMES", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_FILENAMES_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
				}
				//내용
				if(searchField.contains("content")) {
					whereList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					
				}
					
				
				whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
			
				
			/********************************************************************************************************************
			 * 게시판
			 ********************************************************************************************************************/
			} else if(collection.equals("board")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				
				// 전체
				if(searchField.contains("all")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				       whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
					
				}
					
				
				// 제목
				if(searchField.contains("title")) {
					whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 150));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				}
				
				// 파일 이름
				if(searchField.contains("file_nm")) {
					whereList.add(new WhereSet("IDX_FILENAMES", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_FILENAMES_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
				}
				
				//내용
				if(searchField.contains("content")) {
					whereList.add(new WhereSet("IDX_DATA_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					
				}
				
				whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
			/********************************************************************************************************************
			 * 웹
			 ********************************************************************************************************************/
			} else if(collection.equals("web")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					
					// 전체
					if(searchField.contains("all")) {
						whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
					       whereList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
					       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					       whereList.add(new WhereSet("IDX_FULL_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
					       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					       whereList.add(new WhereSet("IDX_CONTENTS_CONTENT", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
					       whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
					}
						
					// 제목
					else if(searchField.contains("title")) {
						whereList.add(new WhereSet("IDX_MENU_NM", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 150));
					}
					else {
						
						whereList.add(new WhereSet("IDX_MENU_CD", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 300));
					}
					
					whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
							
			
			/********************************************************************************************************************
			 * 이미지
			 ********************************************************************************************************************/
			} else if(collection.equals("image")) {
				whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				
				// 전체
				if(searchField.contains("all")) {
					whereList.add(new WhereSet(Protocol.WhereSet.OP_BRACE_OPEN));
				       whereList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_FILE_NAME_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				       whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				       whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),200));
				       whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
					
				}
				//제목
				else if(searchField.contains("title")) {
					whereList.add(new WhereSet("IDX_DATA_TITLE", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				    whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
				    whereList.add(new WhereSet("IDX_DATA_TITLE_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(),150));
				}
				// 파일 이름
				else if(searchField.contains("file_nm")) {
					whereList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
					whereList.add(new WhereSet(Protocol.WhereSet.OP_OR));
					whereList.add(new WhereSet("IDX_FILE_NAME_B", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 200));
				}	
				else {
					
					whereList.add(new WhereSet("IDX_FILE_NAME", Protocol.WhereSet.OP_HASALL, searchTerm_Array[i].trim(), 300));
				}
				
				
				whereList.add(new WhereSet (Protocol.WhereSet.OP_BRACE_CLOSE));
			
			
			
			}
			
		}
	
	
		WhereSet[] whereSet = null;
		whereSet = new WhereSet[whereList.size()];
		for(int i = 0; i < whereSet.length; i++) {
			whereSet[i] = whereList.get(i);
		}
		
		return whereSet;
	
	}
	
	public OrderBySet[] orderSet_fn(String orderby, String collection) {
		
		OrderBySet[] orderBySet = null;
		
		if(orderby.equals("sort")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGISTER_DATE", Protocol.OrderBySet.OP_NONE) };	//날짜순
			if(collection.equals("image")){
				orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_REGISTER_DT", Protocol.OrderBySet.OP_NONE) };	//날짜순
			}
		}else if(orderby.equals("johoe")){
			
			orderBySet = new OrderBySet[] { new OrderBySet(true, "WEIGHT", Protocol.OrderBySet.OP_POSTWEIGHT) }; //정확도순
			
			if(collection.equals("image")){
			
				orderBySet = new OrderBySet[] { new OrderBySet(true, "SORT_VIEW_COUNT", Protocol.OrderBySet.OP_NONE) }; //조회순 
			}
		}else if(orderby.equals("weight")){
			orderBySet = new OrderBySet[] { new OrderBySet(true, "WEIGHT", Protocol.OrderBySet.OP_POSTWEIGHT) }; //정확도순
			
				
		
		}
		
		
		return orderBySet;
		
	}
	public FilterSet[] filterSet(String collection,String []search_range) {
		
		FilterSet[] filterSet = null;
		
		if(collection.equals("image")){
			filterSet = new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_REGISTER_DT", search_range) };
		}else if(collection.equals("board")||collection.equals("news")||collection.equals("moonhwa")){
			//System.out.println("필터 확인>>>>"+search_range);
			filterSet = new FilterSet[] { new FilterSet(Protocol.FilterSet.OP_RANGE, "FILTER_REGISTER_DATE", search_range) };
		}
			
		
		return filterSet;
		
	}
	
	
	%>
	
	
<%

/**********************************************************핫키워드***********************************************************/
		Result hotResult = null; 				//인기검색용 
		Query hot_query = null;					//인기검색어
		ResultSet hot_results = null;
		Result [] hot_resultlist = null;
		QuerySet hot_querySet = null;
	
		
		CommandSearchRequest command2 = null;
		
		
		
		
		
		selectSet = new SelectSet[]{ new SelectSet("KEYWORD", Protocol.SelectSet.NONE)};
		
		//WhereSet
		//검색필드			
		whereSet = new WhereSet[]{ new WhereSet("IDX_TRENDS_ID", Protocol.WhereSet.OP_HASALL, "trend_goseong", 100) };
		
		
		
		//OrderBySet
		//정렬필드			
		orderbySet = new OrderBySet[1];
		orderbySet[0] = new OrderBySet(true, "SORT_RANKING", Protocol.OrderBySet.OP_POSTWEIGHT);
		
		
		
		
		hot_query = new Query();
		hot_query.setSelect(selectSet);
		hot_query.setWhere(whereSet);;		
		hot_query.setOrderby(orderbySet);
		hot_query.setFrom("HOTKEYWORD");
		hot_query.setResult(0, 9);		
		hot_query.setDebug(true);
		hot_query.setLoggable(true);
		hot_query.setPrintQuery(true);
		
		
		
		
		
		System.out.println("searchTerm ::" + searchTerm);
		
		
			
			hot_querySet = new QuerySet(1);
			hot_querySet.addQuery(hot_query);
			
		
		
		
			
		command2 = new CommandSearchRequest(HOST, PORT);
		//System.out.print("command2>>>>>>>>>."+command2);
		//System.out.println("command2.request(hot_querySet)>>>>>>>>>."+command2.request(hot_querySet));
		if(command2.request(hot_querySet) >= 0){
			//System.out.println("확인1>>>>>>>>>.");
			hot_results = command2.getResultSet();
			//System.out.print("command2.getResultSet()"+command2.getResultSet());
			hot_resultlist = hot_results.getResultList();
		
				for(int q=0; hot_resultlist!=null&&q<hot_resultlist.length; q++) {
						hotResult = hot_resultlist[q];
				}
		
		
		}
		

 

%>	

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <title>고성군청</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0 ,maximum-scale=1.0, minimum-scale=1.0,user-scalable=no,target-densitydpi=medium-dpi">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">

    <link rel="stylesheet" href="Goseong_/_css/common.css">
    <link rel="stylesheet" href="Goseong_/_css/font.css">
    <link rel="stylesheet" href="Goseong_/_css/layout.css"> <!-- 전체 레이아웃 -->
    <link rel="stylesheet" href="Goseong_/Potal/Css/layout.css"> <!-- 대표 레이아웃 -->
    <link rel="stylesheet" href="Goseong_/Potal/Css/slick.css">
    <link rel="stylesheet" href="Goseong_/_css/board.css">
    <link rel="stylesheet" href="Goseong_/_css/search.css">
    <link rel="stylesheet" href="Goseong_/_css/styleDefault.css">
    <link rel="stylesheet" href="Goseong_/Potal/Css/content.css">
    <link rel="stylesheet" href="Goseong_/Potal/Css/mook.css">
    <link rel="stylesheet" href="Goseong_/Potal/Css/mingyu.css">

    <script src="Goseong_/_js/jquery-3.4.1.min.js"></script>
    <script src="Goseong_/Potal/js/slick.js"></script>
    <script src="Goseong_/_js/jquery.rwdImageMaps.js"></script>
    <script src="Goseong_/_js/default.js"></script>
    <script src="Goseong_/_js/board.js"></script>
    <script src="Goseong_/Potal/js/other.js"></script>

</head>
<body>
<div class="container">
    <div id="skipNavi">
        <h1 class="noText">본문 바로가기</h1>
        <ul>
            <li><a href="#main-wrap" class="skipLink" onclick="fnMove('1')">본문바로가기</a></li>
        </ul>
    </div><style>
    .headerBot_cont .totalFormBox {display:flex; align-items: center; justify-content: space-between; width: 820px;}
     .headerBot_cont .totalFormBox .headSearch{ width:500px; margin-right:2%; background-size: 100%;  box-sizing: border-box; border:none; margin-top:0; border:2px solid #009b63;}
     .headerBot_cont .totalFormBox .headSearch form{background:#fff; width:100%; box-sizing: border-box; display: flex;}
     .headerBot_cont .totalFormBox .headSearch form input[type='text']{border:none; background:#fff; padding-left:10px; height:41px; width:100%; font-size:15px; line-height: 41px;}
     .headerBot_cont .totalFormBox .headSearch form input[type='submit']{border:none; background:url("/Goseong_/Potal/images/layout/searchWhite.png") center no-repeat #009b63; width:48px; height:41px; font-size:0; float: right;}

     .headerBot_cont .totalFormBox .formBox select,.headerBot_cont .totalFormBox .formBox input {
         color:#000;
         font-size:15px;
         border:none;
         background:#fff;
         vertical-align:middle;
         padding:10px 5px;
         box-sizing:border-box;
     }
     .headerBot_cont .totalFormBox .formBox select {
         padding:9px 30px 9px 15px;
         -webkit-appearance:none;
         -moz-appearance:none;
         appearance:none;
         background:url('/Goseong_/Potal/images/layout/totalIcon.png') no-repeat 95% 50%;
     }

    .headerBot_cont .totalFormBox .onMoreBox {
        float:right;
    }
    .headerBot_cont .totalFormBox .onMoreBox .oneMoreBtn {
        display: inline-block;
        padding:11px 7px 11px 45px; box-sizing: border-box; margin-left:20px; flex-shrink: 0;
        background-color:#f3f3f3;
        font-size:15px;
        font-family:'NotokrL';
        color:#555;
        position:relative;
    }
    .headerBot_cont .totalFormBox .onMoreBox .oneMoreBtn:before {
        content:'';
        display:block;
        position:absolute;
        width:23px;
        height:23px;
        border:1px solid #d6d6d6;
        background-color:#fff;
        box-sizing:border-box;
        left:5px;
    }
    .headerBot_cont .totalFormBox .onMoreBox .oneMoreBtn.onMoreActive:before {
        background-image:url("http://210.206.69.186/Goseong_/Potal/images/board/msCheck.png");
        background-position:center;
        background-repeat:no-repeat;
    }

    .headerBot_cont .totalFormBox .moreSearchBtn {
        display:inline-block;
        height:45px;
        width:118px;
        text-align:center;
        line-height:45px;
        color:#fff;
        font-size:16px;
        background-color:#3f6281;
        vertical-align:middle;
    }

    .totalFormBox .moreSearchBox {
        display:none;
        position:absolute;
        width:100%;
        left:0;
        top:84px;
        z-index:10;
        background:#3f6281;
        padding:30px 5%;
        box-sizing:border-box;
    }
    .totalFormBox .headCnt .totalFormBox .formBox .moreSearchBox select {
        background:none;
    }
    .totalFormBox .moreSearchBox .msTit {
        font-size:22px;
        font-family:'NotokrM';
        color:#fff;
        text-align:center;
    }
    .totalFormBox .moreSearchBox form {
        display: flex;
        align-items: center;
        justify-content: space-between;
        width:100%;
        max-width:1400px;
        margin:0 auto;
        background:#fff;
        box-sizing:border-box;
        height:67px;
        border:3px solid #324e67;
        padding-left:5%;
    }
    .totalFormBox .moreSearchBox form .msLabel {
        float:left;
        font-size:16px;
        font-family:'NotokrM';
        color:#1e3779;
        padding-left:30px;
        background-position:left center;
        background-repeat:no-repeat;
        vertical-align:middle;
        line-height:38px;
        margin-right:30px;
    }
    .totalFormBox .moreSearchBox form .msLabel1 {
        background-image:url("/Goseong_/Potal/images/board/totalIcon1.png");
    }
    .totalFormBox .moreSearchBox form .msLabel2 {
        background-image:url("/Goseong_/Potal/images/board/totalIcon2.png");
    }
    .totalFormBox .moreSearchBox form .msLabel3 {
        background-image:url("/Goseong_/Potal/images/board/totalIcon3.png");
    }
    .totalFormBox .moreSearchBox form .chk-select select {
        float:left;
        width:172px;
        border:1px solid #d6d6d6;
        border-radius:50px;
    }
    .totalFormBox .moreSearchBox form .msBtn {
        font-size:18px;
        font-family:'NotokrM';
        color:#fff;
        background-image:none;
        width:108px;
        height:100%;
        background-color:#009b63;
        float:right;
        border:none;
    }
    .totalFormBox .moreSearchBox .msTerm .msTermCheck {
        padding-left:30px;
        height:38px;
        line-height:38px;
        position:relative;
        display:inline-block;
        margin-right:15px;
        font-family:'NotokrL';
        color:#555;
    }
    .totalFormBox .moreSearchBox .msTerm .msTermCheck:before {
        content:'';
        display:block;
        position:absolute;
        width:24px;
        height:24px;
        border:1px solid #d7d7d7;
        background-color:#fff;
        box-sizing:border-box;
        border-radius:50%;
        left:0;
        top:50%;
        margin-top:-12px;
    }
    .totalFormBox .moreSearchBox .msTerm .msTermCheck.msTermActive:before {
        background-image:url("http://210.206.69.186/Goseong_/Potal/images/board/msCheck.png");
        background-position:center;
        background-repeat:no-repeat;
    }

    @media screen and (max-width:1400px){
        .totalFormBox .moreSearchBox form{padding-left:1%;}
    }
    @media screen and (max-width:1200px){
        .headerBot_cont .totalFormBox{width:640px;}
        .headerBot_cont .totalFormBox .headSearch{width:350px}
        .totalFormBox .moreSearchBox form{flex-wrap: wrap;}
        .totalFormBox .moreSearchBox form .msTerm{}
    }
</style>
<script>
    $(document).ready(function () {
        $(".moreSearchBtn").bind("click", function () {
        	//alert('확인0');
            if($(".moreSearchBox").css("display") == "none"){
                $(".moreSearchBox").slideDown();
            }else{
                $(".moreSearchBox").slideUp();
            }
        });

        $(".oneMoreBtn").bind("click", function () {
        	//alert('확인1');
            $(this).toggleClass("onMoreActive");
            if($(".oneMoreBtn").hasClass("onMoreActive") == true){
            	$('#re_sch').val('on')
                $("#oneMoreSearch").attr("value","oneMoreSearch");
                //$(".noLink oneMoreBtn").addClass("onMoreActive");
                console.log($('#re_sch').val());
            }else{
            	$('#re_sch').val('N')
                $("#oneMoreSearch").attr("value","");
                console.log($('#re_sch').val());
            }
        });
        $(".msTermCheck").bind("click", function () {
        	//alert('확인2');
            $(".msTermCheck").removeClass("msTermActive");
            $(this).addClass("msTermActive");
            let msTerm = $(this).attr("data-term");
            $("#msTermInput").attr("value",msTerm);
        });
        
        $(".totalBtn").on("click", function(){
        	//alert('확인3');
        	var searchName =$("#totalText").val();
        	console.log(searchName);
        	if (searchName==''){
        		alert('검색어를 입력하세요');
        		return false;
        	}else{
        		//setSearchCookie('cookieName',searchName);
        		document.frmSearch.submit();
        		
        	}
        });
        
        
        
    });
    
    //------ 메뉴이동 -----
    function menu_Submit(collection){
        document.pageNavigator.collection.value = collection;
        document.pageNavigator.currentPage.value = 1;
        document.pageNavigator.submit();
    }

    //------ 페이지이동 -----
    function move_Action(param){
        document.pageNavigator.currentPage.value=param;
        document.pageNavigator.submit();
    }
   	//------ 날짜설정 -----
    function date_search_btn(type) {
    	
    	$('#date').val(type);
    	
    }
  	
   
    function hotKeySearch(hotKeyword) {
	    var searchCheck = document.frmSearch;
	    searchCheck.searchTerm.value = hotKeyword;

	    searchCheck.submit();
	}
</script>


<div id="popWrap" class="popWrap">
    <div class="popShow"></div>
    <div class="popRle">
        <div class="popSlide slideCnt popPc">
            <div>
                <a href="#">
                    <img src="/Goseong_/Potal/images/layout/visual_01.jpg" alt="" class="">
                    <img src="/Goseong_/Potal/images/layout/m_visual_01.jpg" alt="" class="popMo">
                </a>
            </div>
            <div>
                <a href="#">
                    <img src="/Goseong_/Potal/images/layout/visual_02.jpg" alt="" class="popPc">
                    <img src="/Goseong_/Potal/images/layout/m_visual_02.jpg" alt="" class="popMo">
                </a>
            </div>
        </div>
        <div class="popSlide slideCnt popMo">
            <div>
                <a href="#">
                    <img src="/Goseong_/Potal/images/layout/m_visual_01.jpg" alt="" class="">
                </a>
            </div>
            <div>
                <a href="#">
                    <img src="/Goseong_/Potal/images/layout/m_visual_02.jpg" alt="" class="popMo">
                </a>
            </div>
        </div>
        <div class="slideBtns typeWhite">
            <p class="slideNum popSlideNum"><span class="nowNum">1</span>/<span class="totalNum">1</span></p>
            <a href="#" class="slideLeft">이전슬라이드</a>
            <a href="#" class="slideStop">정지</a>
            <a href="#" class="slideRight">다음슬라이드</a>
            <a href="#" class="slideMore">배너모음페이지로 이동</a>
        </div>
    </div>
    <div class="pop_toggleBtn">
        <a href="#" class="noLink popToggle">팝업닫기</a>
    </div>
</div>
<header>
    <div class="headerTop_cont">
        <div class="hd_inner">
            <ul class="linkSites">
                <li><a href="#" class="active" target="_blank" title="새창으로열림">고성군청</a></li>
                <li><a href="#" target="_blank" title="새창으로열림">통합예약</a></li>
                <li><a href="#" target="_blank" title="새창으로열림">문화관광</a></li>
                <li><a href="#" target="_blank" title="새창으로열림">고성군의회</a></li>
                <li class="linkCorona" target="_blank" title="새창으로열림"><a href="#">코로나19</a></li>
            </ul>
            <ul class="headerOther">
                <li class="hto_fonts">
                    <a href="#" class="noLink fontPlus">글자크기 증가</a>
                    <p>글자크기</p>
                    <a href="#" class="noLink fontMinus">글자크기 축소</a>
                </li>
                <li class="hto_mySelf">
                    <a href="#">본인인증</a>
                </li>
                <li class="hto_language">
                    <a href="#" class="noLink languageBtn">한국어</a>
                    <ul class="hto_language_inner">
                        <li><a href="#">영어</a></li>
                        <li><a href="#">일본어</a></li>
                        <li><a href="#">중국어</a></li>
                    </ul>
                </li>
                <li class="snsWarp">
                    <a href="#" class="snsFace" target="_blank" title="새창으로열림">페이스북바로가기</a>
                    <a href="#" class="snsBlog" target="_blank" title="새창으로열림">블로그바로가기</a>
                    <a href="#" class="snsInst" target="_blank" title="새창으로열림">인스타그램바로가기</a>
                    <a href="#" class="snsBand" target="_blank" title="새창으로열림">밴드바로가기</a>
                    <a href="#" class="snsYout" target="_blank" title="새창으로열림">유튜브바로가기</a>
                </li>
            </ul>
        </div>
    </div>
    <div class="headerBot_cont">
        <div class="hd_inner">
            <h1 class="logoBox">
                <a href="#"><img src="/Goseong_/Potal/images/layout/logo.jpg" alt="고성군"></a>
                <img src="/Goseong_/Potal/images/layout/guckgi.jpg" alt="태극기">
            </h1>
            <div class="totalFormBox">
                <div class="formBox headSearch totalHead">
                    <form action="/Goseong/goseong.jsp" method="get" name="frmSearch" id="frmSearch">
						<input type="hidden" id="re_sch" name="re_search" value="<%=re_search%>">
						<input type="hidden" id="searchTermList" name="searchTermList" value="<%=searchTermList%>">
						
                        <label for="totalSearch" class="hide">검색옵션</label>
                        <select name="collection" id="totalSearch">
                            <option value="total" <%if(collection.equals("total")){%> selected="selected"<%}%>>통합검색 </option>
							<option value="office" <%if(collection.equals("office")){%> selected="selected"<%}%>>직원검색</option>
							<option value="menu" <%if(collection.equals("menu")){%> selected="selected"<%}%>>메뉴검색</option>
							<option value="moonhwa" <%if(collection.equals("moonhwa")){%> selected="selected"<%}%>>문화관광</option>
							<option value="news" <%if(collection.equals("news")){%> selected="selected"<%}%>>고성군뉴스</option>
							<option value="board" <%if(collection.equals("board")){%> selected="selected"<%}%>>게시판</option>
							<option value="web" <%if(collection.equals("web")){%> selected="selected"<%}%>>웹페이지</option>
							<option value="image" <%if(collection.equals("image")){%> selected="selected"<%}%>>이미지</option>
                            
						</select>
                        <label for="totalText" class="hide">검색어를 입력하세요</label>
                        <input type="text" id="totalText" name="searchTerm" placeholder="검색어를 입력하세요" value="<%=searchTerm%>">
                        <input type="submit" class="totalBtn">
                        <input type="hidden" value="" id="oneMoreSearch">
                    </form>
                    <div id="ark"></div>
                </div>
                <a href="#" title="상세검색 메뉴가 나옵니다." class="noLink moreSearchBtn">상세검색</a>
                <div class="moreSearchBox">
                    <p class="msTit">상세검색 (검색조건)</p>
                    <p class="gap20"></p>
                    <form action="/Goseong/new_index_version2.jsp" method="get" name="sch_frmdatail" id="sch_frmdatail">
                    	<input type="hidden" name="date" id="date" value="<%=date%>">
                    	<input type="hidden" name="searchTerm" id="sch_detail" value="<%=searchTerm%>">
                    	<input type="hidden" name="collection" id="collection" value="<%=collection%>">
                    	
                        <p class="chk-select">
                            <label for="msSelect1" class="msLabel msLabel1">검색영역</label>
                            <select id="msSelect1" name="searchField" >
                                <option value="all" 		<%if(searchField.equals("all")){%> selected="selected"<%}%> >전체</option>
                                <option	value="title" 		<%if(searchField.equals("title")){%> selected="selected"<%}%>>제목</option>
                                <option	value="content" 	<%if(searchField.equals("content")){%> selected="selected"<%}%>>내용</option>
                                <option	value="file_nm" 	<%if(searchField.equals("file_nm")){%> selected="selected"<%}%>>첨부파일</option>
                            </select>
                        </p>
                        <p class="chk-select">
                            <label for="msSelect2" class="msLabel msLabel2">검색정렬</label>
                            <select id="msSelect2" name="orderby">
                                <option value="sort" 		<%if(orderby.equals("sort")){%> selected="selected"<%}%>>날짜순</option>
                                <option value="johoe"		<%if(orderby.equals("johoe")){%> selected="selected"<%}%>>조회순</option>
                                <option	value="weight" 		<%if(orderby.equals("weight")){%> selected="selected"<%}%>>정확도순</option>
                            </select>
                        </p>
                        <div class="msTerm">
                            <p class="msLabel msLabel3">검색기간</p>
                            <input type="hidden" value="" id="msTermInput">
                            <a href="#" title="전체 선택"   onclick="javascript:date_search_btn('all'); return false;" data-term="msAll" <%if(date.equals("all")){%> class="noLink msTermCheck msTermActive"<%}else{%>class="noLink msTermCheck"<%} %> >전체</a>
                            <a href="#" title="일주일 선택"  onclick="javascript:date_search_btn('seven'); return false;"data-term="msWeek" <%if(date.equals("seven")){%> class="noLink msTermCheck msTermActive"<%}else{%>class="noLink msTermCheck"<%} %>>일주일</a>
                            <a href="#" title="1개월 선택"   onclick="javascript:date_search_btn('thirty'); return false;" data-term="msMonth" <%if(date.equals("thirty")){%> class="noLink msTermCheck msTermActive"<%}else{%>class="noLink msTermCheck"<%} %>>1개월</a>
                        </div>
                        <input type="submit" value="적용" class="msBtn">
                    </form>
                </div>
                <div class="onMoreBox">
                    <a href="#" title="클릭시 결과내 재검색 기능 온오프 버튼"  <%if(re_search.equals("on")){%> class="noLink oneMoreBtn onMoreActive"<%}else{%>class="noLink oneMoreBtn"<%} %>>결과내 재검색</a>
                </div>
            </div>
            <div class="headerBot_other">
                <div class="headSearch_box">
                    <a href="#" class="hbo_bnt1 noLink">통합검색창 열기</a>
                    <div class="hsForm_box">
                        <form action="">
                            <label for="hs_search" class="hide"></label>
                            <input type="text" class="hs_box" id="hs_search" placeholder="검색어를 입력하세요">
                            <input type="submit" class="hs_btn">
                        </form>
                    </div>
                </div>
                <a href="#" class="hbo_bnt2"><span>사이트맵 페이지로 이동</span><i></i><i></i><i></i></a>
            </div>
        </div>
    </div>
    <div class="chatBot">
        <a href="#">고성챗봇</a>
    </div>
</header>
<script>
	$(document).ready(function () {

		$(".wordDel").on("click",function () {
			$(this).parent("li.mswList").remove();
		});
	});
</script>
	

<!-- s: search-wrap -->
<div class="search-wrap" id="main-wrap">

	<!-- s: content-wrap -->
	<div class="content-wrap">
		<!-- s: contents -->
		<div class="contents">
			<div class="searchTotal">
				<p class="searchTit">검색어 <span>'<%=searchTerm%>'</span>에 대한 전체 <span><%=totalSize%></span>개의 결과를 찾아냈습니다.</p>
				<ul class="schTtBox cont-list step01">
					<li class="schTtList">
					
					<a href="#" onclick="menu_Submit('office'); return false;">직원검색 <span class="schTtNum">(<%=officeSize%>/<%=totalSize %>)</span></a>
					
					
					</li>
					<li class="schTtList">
						<a href="#" onclick="menu_Submit('menu'); return false;">메뉴검색 <span class="schTtNum">(<%=menuSize%>/<%=totalSize %>)</span></a>
						
					</li>
					<li class="schTtList">
						 <a href="#" onclick="menu_Submit('moonhwa'); return false;">문화관광 <span class="schTtNum">(<%=mohSize%>/<%=totalSize %>)</span></a> 
						
					</li>
					<li class="schTtList">
						<a href="#" onclick="menu_Submit('news'); return false;">고성군뉴스 <span class="schTtNum">(<%=newsSize%>/<%=totalSize %>)</span></a>
						
					</li>
					<li class="schTtList">
						<a href="#" onclick="menu_Submit('board'); return false;">게시판 <span class="schTtNum">(<%=bbsSize%>/<%=totalSize %>)</span></a>
						
					</li>
					<li class="schTtList">
						<a href="#" onclick="menu_Submit('web'); return false;">웹페이지 <span class="schTtNum">(<%=webSize%>/<%=totalSize %>)</span></a>
						
					</li>
					<li class="schTtList">
						<a href="#" onclick="menu_Submit('image'); return false;">이미지/동영상 <span class="schTtNum">(<%=imgSize%>/<%=totalSize %>)</span></a>
						
					</li>
				</ul>
			</div>
<!-- ******************************************************************************************************************************** -->
<!-- ****직원-->
<!-- ******************************************************************************************************************************** -->	

<%		if(officeSize>0){
			if(collection.equals("total") || collection.equals("office")){ 
%>
			<div class="search-results">
				<div class="schRsTitBox">
					<h3 class="title"><span class="totalTit">직원검색</span> (총<span class="pointColor"><%=officeSize%></span>건)</h3>
				</div>
				<div class="results-list tableRes">
					<div class="table-wrap">
						<div class="scroll-guide">
							<p></p>
						</div>
						<div class="scroll-table">
							<table class="type01 scroll">
								<caption>이름 소속부서 담당업무 전화번호가 적힌 표입니다.</caption>
								<colgroup>
									<col style="width:20%">
									<col style="width:35%">
									<col style="width:25%">
									<col style="width:20%">
								</colgroup>
								<thead>
								<tr>
									<th>이름</th>
									<th>소속부서</th>
									<th>담당업무</th>
									<th>메일</th>
								</tr>
								</thead>
								<tbody>
<%
							for (int i=0; i<officeList.size(); i++) {
								HashMap<String, String> tempMap = officeList.get(i);
								USER_NM = tempMap.get("USER_NMUSER_NM");
								OFFICE_NM = tempMap.get("OFFICE_NM");
								OFFICE_PT_MEMO = tempMap.get("OFFICE_PT_MEMO");
								OFFICE_TEL = tempMap.get("OFFICE_TEL");
								
								EMAIL_ADRES = tempMap.get("EMAIL_ADRES");
								String OFFICE_PT_MEMO2= OFFICE_PT_MEMO.replace("...", "");

%>
								<tr>
									<td><a href="#" target="_blank" title="새창열림"><%=USER_NM %></a></td>
									<td><%=OFFICE_NM %></td>
									<td>
										<ul class="cont-list step01 l">
<%


%>
										 	
										 	<li><%=OFFICE_PT_MEMO2%></li>
<%											

%>
											
										</ul>
									</td>
									<td><%=EMAIL_ADRES %>
									<br>/<%=OFFICE_TEL %></td>
								</tr>
<%
                    		}
							
%> 
								
								</tbody>
							</table>
						</div>
					</div>
				</div>
				
<%
			if(collection.equals("total")){
%>				
				<p class="tr">
					<a href="#n" class="more-btn" onclick="menu_Submit('office'); return false;">더보기</a>
				</p>
<%
				}
%>				
			</div>
			<div class="paging" align="center">
<%
                if(!collection.equals("total")){
                    out.print(getPageNav(10, currentPage, officeSize,"office"));
     
                  }
%>                    
			</div>
<%            }
		}
%>			
<!-- ******************************************************************************************************************************** -->
<!-- ****메뉴-->
<!-- ******************************************************************************************************************************** -->	
<%	 
	if(searchTermList.equals("공약")){
		menuSize=0;
	}
	if(menuSize>0){ 	
		if(collection.equals("total") || collection.equals("menu")){
%>
			<div class="search-results">
				<div class="schRsTitBox">
<% 	
        	//검색어가 공약이면 검색결과 0건
        	//if(searchTerm.equals("공약")){
%>
        			<!-- <h3 class="title"><span class="totalTit">메뉴검색</span>(총<span class="pointColor">0</span>건)</h3> -->
<%			//}else{ 
%>					 <h3 class="title"><span class="totalTit">메뉴검색</span>(총<span class="pointColor"><%=menuSize%></span>건)</h3>
<% 			//} 
%>
			<!-- s: search-results -->
			
					
				</div>
				<div class="results-list">
					<ul class="menuLinkBox">
<%            
					for (int i=0; i<menuList.size(); i++) {
						HashMap<String, String> tempMap = menuList.get(i);
						URL = tempMap.get("URL");
						MENU_NM = tempMap.get("MENU_NM");
						MENU_CD = tempMap.get("MENU_CD");
						PATH = tempMap.get("PATH");
						DOMAIN = tempMap.get("DOMAIN");

                    
 %>
 						<li class="menu_link"><a href="http://<%=DOMAIN%>:8088/index.goseong?menuCd=<%=MENU_CD%>" target="_blank"><span class="menuList_cate">[<%=MENU_NM%>]</span> <%=PATH%></a></li>
<%	
                }
%>						
					</ul>
				</div>

<%
			if(collection.equals("total")){
%>				
				<p class="tr">
					<a href="#n" class="more-btn" onclick="menu_Submit('menu'); return false;">더보기</a>
				</p>
<%
				}
%>		
			</div>
			<div class="paging" align="center">
<%
                if(!collection.equals("total")){
                    out.print(getPageNav(10, currentPage, menuSize,"menu"));
     
                              }
%>                    
			</div>
<%            }
		}	
%>			
			
			<!-- e: search-results -->
<!-- ******************************************************************************************************************************** -->
<!-- ****문화-->
<!-- ******************************************************************************************************************************** -->			
			
<%			
 	if(mohSize>0){
		if(collection.equals("total")|| collection.equals("moonhwa")){
%>
			
			<!-- s: search-results -->
			<div class="search-results">
				<div class="schRsTitBox">
					<h3 class="title"><span class="totalTit">문화관광</span> (총<span class="pointColor"><%=mohSize%></span>건)</h3>
				</div>
				<div class="results-list">
					<ul class="tourSearchBox">
<% 						
					for (int i=0; i<mohList.size(); i++) {
						HashMap<String, String> tempMap = mohList.get(i);
						DATA_TITLE = tempMap.get("DATA_TITLE");
						REG_DATE = tempMap.get("REGISTER_DATE");
					String	REG_DATE2 = REG_DATE.substring(0,4)+"-"+REG_DATE.substring(4,6)+"-"+REG_DATE.substring(6,8);
						FILENAMES = tempMap.get("FILENAMES");
					String	FILE_SIDS = tempMap.get("FILE_SIDS");
						BOARD_ID = tempMap.get("BOARD_ID");
						DATA_SID = tempMap.get("DATA_SID");
						MENU_CD = tempMap.get("MENU_CD");
						FULL_NM = tempMap.get("FULL_NM");
						DOMAIN = tempMap.get("DOMAIN");
						
						

 %>
						<li>
							<div class="totalSearch_listTit">
								<a href="/board/view.goseong?boardId=<%=BOARD_ID%>&menuCd=<%=MENU_CD%>&startPage=1&dataSid=<%=DATA_SID %>" target="_blank" class="tsl_tit"><%=DATA_TITLE %></a>
								<p class="tsl_datebBox"><span>작성일</span><%=REG_DATE2 %></p>
							</div>
							<div class="tourImg_location">
								
									
<%

							if(!FILE_SIDS.equals("")){
								//String fsid2=FILE_SIDS.replace(",", ",,");
								//String fname2=FILENAMES.replace(",", ",,");
								
								//System.out.println("fsid2문화>>>"+fsid2);
								//System.out.println("fname2문화>>>"+fname2);
							    
								String[] fsid = FILE_SIDS.split(",,");
							    String[] fname = FILENAMES.split(",,");
							    
							    
							    
							    //System.out.println("fsid문화>>>"+fsid);
								//System.out.println("fname문화>>>"+fname);
							    
							if(!FILE_SIDS.equals("")){
%>
								<ul class="tourImg_list">
								<li>
								
<%										for(int r=0;r<fsid.length;r++){
%>
									<a href="http://<%=DOMAIN%>/board/download.goseong?boardId=<%=BOARD_ID%>&amp;dataSid=<%=DATA_SID%>&amp;fileSid=<%=fsid[r]%>"><%=fname[r] %></a>&nbsp;
<%
										}

										%>
								</li>
								</ul>
<%	
								}
%>									
									
									
<%
							    	
							} 
%>
								
								<a href="#" class="tour_location"><%=FULL_NM %></a>
							</div>
						</li>
						
<%
						}
			           
%>
					</ul>
				</div>
<%
			if(collection.equals("total")){
%>				
				<p class="tr">
					<a href="#n" class="more-btn" onclick="menu_Submit('moonhwa'); return false;">더보기</a>
				</p>
<%
				}
%>					</div>
			
			<div class="paging" align="center">
<%
                if(!collection.equals("total")){
                    out.print(getPageNav(10, currentPage, mohSize,"moonhwa"));
     
                              }
%>                    
			</div>
<%            }
            }
 	
%>	
			<!-- e: search-results -->
<!-- ******************************************************************************************************************************** -->
<!-- ****뉴스-->
<!-- ******************************************************************************************************************************** -->			
			
			
<%			
	if(newsSize>0){
		if(collection.equals("total") || collection.equals("news")){
%>
			<!-- s: search-results -->
			<div class="search-results">
				<div class="schRsTitBox">
					<h3 class="title"><span class="totalTit">고성군뉴스</span> (총<span class="pointColor"><%=newsSize%></span>건)</h3>
				</div>
				<div class="results-list">
					<ul class="tourSearchBox">
<% 					
					for (int i=0; i<newsList.size(); i++) {
						HashMap<String, String> tempMap = newsList.get(i);
						TITLE = tempMap.get("DATA_TITLE");
						REG_DATE = tempMap.get("REGISTER_DATE");
						String	REG_DATE2 = REG_DATE.substring(0,4)+"-"+REG_DATE.substring(4,6)+"-"+REG_DATE.substring(6,8);
						CONTENT = tempMap.get("DATA_CONTENT");
						FILENAMES = tempMap.get("FILENAMES");
						FULL_NM = tempMap.get("FULL_NM");
						String	FILE_SIDS = tempMap.get("FILE_SIDS");
						BOARD_ID = tempMap.get("BOARD_ID");
						DATA_SID = tempMap.get("DATA_SID");
						MENU_CD = tempMap.get("MENU_CD");
						DOMAIN = tempMap.get("DOMAIN");
						
						String CONTENT2=CONTENT.replace("...", "");

%>
						<li>
							<div class="totalSearch_listTit">
								<a href="/board/view.goseong?boardId=<%=BOARD_ID%>&menuCd=<%=MENU_CD%>&startPage=1&dataSid=<%=DATA_SID %>" target="_blank" title="새창열림" class="tsl_tit"><%=TITLE %></a>
								<p class="tsl_datebBox"><span>작성일</span><%=REG_DATE2 %></p>
							</div>
							<p class="totalSearch_cnt"><%=CONTENT2 %></p>
							<div class="tourImg_location">
								
<%

							if(!FILE_SIDS.equals("")){
								//String fsid2=FILE_SIDS.replace(",", ",,");
								//String fname2=FILENAMES.replace(",", ",,");
							    
								
								//System.out.println("fsid2뉴스>>>"+fsid2);
								//System.out.println("fname2뉴스>>>"+fname2);
								
								String[] fsid = FILE_SIDS.split(",,");
							    String[] fname = FILENAMES.split(",,");
							if(!FILE_SIDS.equals("")){
%>
								<ul class="tourImg_list">
								<li>
								
								
<%								

								for(int r=0;r<fsid.length;r++){
%>
									<a href="http://<%=DOMAIN%>/board/download.goseong?boardId=<%=BOARD_ID%>&amp;dataSid=<%=DATA_SID%>&amp;fileSid=<%=fsid[r]%>"><%=fname[r] %></a>&nbsp;
<%
										}

										%>
								</li>
								</ul>
<%	
								}
							}
%>					
							    	
							 

								
								<a href="#" class="tour_location"><%=FULL_NM %></a>
							</div>
						</li>
						
<%
						}
					
%>
					</ul>
				</div>
<%
			if(collection.equals("total")){
%>				
				<p class="tr">
					<a href="#n" class="more-btn" onclick="menu_Submit('news'); return false;">더보기</a>
				</p>
<%
				}
%>		
			</div>
			
			<div class="paging" align="center">
<%
                if(!collection.equals("total")){
                    out.print(getPageNav(10, currentPage, newsSize,"news"));
     
               }
%>                    
			</div>
<%            }
	}
%>
<!-- ******************************************************************************************************************************** -->
<!-- ****게시판-->
<!-- ******************************************************************************************************************************** -->

 <%			
		if(bbsSize>0){
			if( collection.equals("total") || collection.equals("board")){
%>
			<!-- s: search-results -->
			<div class="search-results">
				<div class="schRsTitBox">
					<h3 class="title"><span class="totalTit">게시판</span> (총<span class="pointColor"><%=bbsSize%></span>건)</h3>
				</div>
				<div class="results-list">
					<ul class="tourSearchBox">
<% 				
						for (int i=0; i<bbsList.size(); i++) {
							HashMap<String, String> tempMap = bbsList.get(i);
							DATA_TITLE = tempMap.get("DATA_TITLE");
							REG_DATE = tempMap.get("REGISTER_DATE");
							String	REG_DATE2 = REG_DATE.substring(0,4)+"-"+REG_DATE.substring(4,6)+"-"+REG_DATE.substring(6,8);
							DATA_CONTENT = tempMap.get("DATA_CONTENT");
							FILENAMES = tempMap.get("FILENAMES");
							FULL_NM = tempMap.get("FULL_NM");
							String	FILE_SIDS = tempMap.get("FILE_SIDS");
							BOARD_ID = tempMap.get("BOARD_ID");
							DATA_SID = tempMap.get("DATA_SID");
							MENU_CD = tempMap.get("MENU_CD");
							DOMAIN = tempMap.get("DOMAIN");
							
							String DATA_CONTENT2=DATA_CONTENT.replace("...", "");

%>
						<li>
							<div class="totalSearch_listTit">
								<a href="/board/view.goseong?boardId=<%=BOARD_ID%>&menuCd=<%=MENU_CD%>&startPage=1&dataSid=<%=DATA_SID %>" target="_blank" title="새창열림" class="tsl_tit"><%=DATA_TITLE %></a>
								<p class="tsl_datebBox"><span>작성일</span><%=REG_DATE2 %></p>
							</div>
							<p class="totalSearch_cnt"><%=DATA_CONTENT2 %></p>
							<div class="tourImg_location">
								
<%


							if(!FILE_SIDS.equals("")){
							   System.out.println("FILE_SIDS1111>>>>"+FILE_SIDS);
								
								//String fsid2=FILE_SIDS.replace(",", ",,");
								//String fname2=FILENAMES.replace(",", ",,");
							  // System.out.println("fsid2>>>>"+fsid2);
							   //System.out.println("fname2>>>>"+fname2);
								String[] fsid = FILE_SIDS.split(",,");
							    String[] fname = FILENAMES.split(",,");
								if(!FILE_SIDS.equals("")){
%>
									<ul class="tourImg_list">
									<li>
																	
<%										for(int r=0;r<fsid.length;r++){
%>
										<a href="http://<%=DOMAIN%>/board/download.goseong?boardId=<%=BOARD_ID%>&amp;dataSid=<%=DATA_SID%>&amp;fileSid=<%=fsid[r]%>"><%=fname[r] %></a>&nbsp;
<%
											}

%>
									</li>
									</ul>
<%	
							}
%>						
<%
							    	
							} 
%>
								
								<a href="#" class="tour_location"><%=FULL_NM %></a>
							</div>
						</li>
<%
					}
%>
					</ul>
				</div>
<%
			if(collection.equals("total")){
%>				
				<p class="tr">
					<a href="#n" class="more-btn" onclick="menu_Submit('board'); return false;">더보기</a>
				</p>
<%
				}
%>		
			</div>
			<div class="paging" align="center">
<%
                if(!collection.equals("total")){
                    out.print(getPageNav(10, currentPage, bbsSize,"board"));
     
                              }
%>                    
			</div>
<%            }
		}
%>
 
<!-- ******************************************************************************************************************************** -->
<!-- ****웹페이지-->
<!-- ******************************************************************************************************************************** -->			
	
<%		

	if(webSize>0){
		 if(collection.equals("total") || collection.equals("web")){
%>
			<!-- s: search-results -->
			<div class="search-results">
				<div class="schRsTitBox">
					<h3 class="title"><span class="totalTit">웹페이지</span> (총<span class="pointColor"><%=webSize%></span>건)</h3>
				</div>
				<div class="results-list">
					<ul class="tourSearchBox">
<% 						for (int i=0; i<webList.size(); i++) {
							HashMap<String, String> tempMap = webList.get(i);
							FULL_NM = tempMap.get("FULL_NM");
							DOMAIN = tempMap.get("DOMAIN");
							MENU_NM = tempMap.get("MENU_NM");
							MENU_CD = tempMap.get("MENU_CD");
							CONTENTS_CONTENT = tempMap.get("CONTENTS_CONTENT");
							String CONTENTS_CONTENT2=CONTENTS_CONTENT.replace("...", "");

						if(!MENU_CD.equals("DOM_000000104017006000")) {
%>
						<li>
							<div class="totalSearch_listTit">
								<a href="https://<%=DOMAIN%>:8443/index.goseong?menuCd=<%=MENU_CD%>" class="basicText">
									<span class="tsl_tit"><%=MENU_NM %></span>
								</a>
								<p class="totalSearch_cnt"><%=CONTENTS_CONTENT2 %></p>
								<%-- <p ><%=CONTENTS_CONTENT2 %></p> --%>
								<p class="icon_map"><%=FULL_NM%></p>
							</div>
						</li>
<%
						}
					}					
%>
					</ul>
				</div>
						
<%						
					
				
%>						
						
<%
			if(collection.equals("total")){
%>				
				<p class="tr">
					<a href="#n" class="more-btn" onclick="menu_Submit('web'); return false;">더보기</a>
				</p>
<%
				}
%>		
			</div>
			<div class="paging" align="center">
<%
                if(!collection.equals("total")){
                    out.print(getPageNav(10, currentPage, webSize,"web"));
     
                              }
%>                    
			</div>
<%            }
		}
%>
<!-- ******************************************************************************************************************************** -->
<!-- ****이미지-->
<!-- ******************************************************************************************************************************** -->

			<!-- e: search-results -->
<%			
		if(imgSize>0){
		 if(collection.equals("total")|| collection.equals("image")){
%>
			<!-- s: search-results -->
			<div class="search-results">
				<div class="schRsTitBox">
					<h3 class="title"><span class="totalTit">이미지</span> (총<span class="pointColor"><%=imgSize%></span>건)</h3>
				</div>
				<div class="results-list board-list">
					<ul class="gallery01">
<% 				
					for (int i=0; i<imgList.size(); i++) {
						HashMap<String, String> tempMap = imgList.get(i);
						DATA_TITLE = tempMap.get("DATA_TITLE");
						REG_DATE = tempMap.get("REGISTER_DT");
					String	REG_DATE2 = REG_DATE.substring(0,4)+"-"+REG_DATE.substring(4,6)+"-"+REG_DATE.substring(6,8);
					String VIEW_COUNT = tempMap.get("VIEW_COUNT");
					//String	FILE_SIDS = tempMap.get("FILE_SIDS");
						BOARD_ID = tempMap.get("BOARD_ID");
						DATA_SID = tempMap.get("DATA_SID");
						MENU_CD = tempMap.get("MENU_CD");
						DOMAIN = tempMap.get("DOMAIN");
						FILE_MASK = tempMap.get("FILE_MASK");
					String[] FILE_MASK2 = FILE_MASK.split(",,");
						
					//System.out.println("FILE_MASK2.이미지>>>>>>>>"+FILE_MASK2.length);
						
%>

						<li>
							<a href="/board/view.goseong?boardId=<%=BOARD_ID%>&menuCd=<%=MENU_CD%>&startPage=1&dataSid=<%=DATA_SID %>" title="클릭(엔터)시 해당게시물로 이동합니다.">
								<span class="img">
<%
								
						if(FILE_MASK2.length>=2){
%>								
								<img src="/images/Potal/board/photoBg.jsp" alt="<%=DATA_TITLE%> 이미지" onerror="/images/Potal/board/photoBg.jsp"  width="90" height="90" >
<%
						}else{
%>
								<img src="/upload_data/board_data/<%=BOARD_ID%>/<%=FILE_MASK %>" alt="<%=DATA_TITLE%> 이미지" onerror="/images/Potal/board/photoBg.jsp"  width="90" height="90" >
<%	
						}
%>
								</span>
								<div class="bdiInfoBox">
									<p class="tit"><%=DATA_TITLE %></p>
									<div class="datehit_box">
										<p class="dh_date"><%=REG_DATE2 %></p>
										<p class="dh_hit"><span>조회수</span> <%=VIEW_COUNT %></p>
									</div>
								</div>
							</a>
						</li>
								
								
						
<%						}
				
%>
					</ul>
				</div>
<%
			if(collection.equals("total")){
%>				
				<p class="tr">
					<a href="#n" class="more-btn" onclick="menu_Submit('image'); return false;">더보기</a>
				</p>
<%
				}
%>		
			</div>
			<div class="paging" align="center">
<%
                if(!collection.equals("total")){
                    out.print(getPageNav(12, currentPage, imgSize,"image"));
     
                }	
%>                    
			</div>
<%            }
		}
		
 %>
		</div>

		<!-- s: ranks-warp -->
		<div class="ranks-warp">
			<div class="weekDay">
				<p class="wdTit">인기 검색어</p>
				<ul class="weekDayBox">
<%
			System.out.print("hot_resultlist"+hot_resultlist);
            hotResult = hot_resultlist[0];
            if(hotResult != null && hotResult.getTotalSize() > 0) {  
            	 for (int i=0; i < hotResult.getRealSize(); i++) { 
%>
            	

         
				
				 <li class="wd2List"><a href="#" onclick="hotKeySearch('<%=new String(hotResult.getResult(i,0))%>'); return false;"><%= i+1%>. <%=new String(hotResult.getResult(i,0))%></a></li> 
					<!-- <li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">일자리</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">고시공고</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">사이버공룡테마파크</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">농업기술센터</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">코로나</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">보건소</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">문화관광</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">예산</a></li>
					<li class="wd2List"><a href="#" title="해당검색어로 검색합니다.">환경과</a></li> -->
<%
					}
            	 } 
%>
				</ul>
			</div>
		</div>
		<!-- e: ranks-warp -->


	</div>
	<!-- e: content-wrap -->

</div>
<!-- e: search-wrap -->
<form name="pageNavigator" method="get" action="">
    <input type="hidden" name="searchTerm" value="<%=searchTerm%>"/>
    <input type="hidden" name="collection" value="<%=collection%>" />
    <input type="hidden" name="detail_range" value="<%=detail_range%>"/>
    <input type="hidden" name="currentPage" value="<%=currentPage%>"/>
    <input type="hidden" name="searchField" value="<%=searchField%>"/>
    <input type="hidden" name="orderby" value="<%=orderby%>"/>
</form>

    <div class="satisWrap">
        <!--<form action="#">
            <div class="satis_top">
                <p>이 페이지에서 제공하는 정보에 대하여 만족하십니까?</p>
                <div class="radiotBox">
                    <p>
                        <input type="radio" id="satis1" name="satisRadio">
                        <label for="satis1">매우만족</label>
                    </p>
                    <p>
                        <input type="radio" id="satis2" name="satisRadio">
                        <label for="satis2">만족</label>
                    </p>
                    <p>
                        <input type="radio" id="satis3" name="satisRadio">
                        <label for="satis3">보통</label>
                    </p>
                    <p>
                        <input type="radio" id="satis4" name="satisRadio">
                        <label for="satis4">불만족</label>
                    </p>
                    <p>
                        <input type="radio" id="satis5" name="satisRadio">
                        <label for="satis5">매우불만족</label>
                    </p>
                </div>
            </div>
            <div class="satis_input">
                <label for="satis_text" class="hide">의견적기</label>
                <input type="text" id="satis_text" name="satis_text" placeholder="의견을 남겨주세요">
                <input type="submit" id="satis_btn" value="의견등록">
            </div>
        </form>-->
        <div class="gongBox">
            <!--
            이미지 파일명, alt값
             1유형 : new_img_opentype01.png
             2유형 : new_img_opentype02.png
             3유형 : new_img_opentype03.png
             4유형 : new_img_opentype04.png
             0유형 : new_img_opencode0.png
             -->
            <img src="http://www.kogl.or.kr/open/web/images/images_2014/codetype/new_img_opentype01.png" alt="공공누리 1유형 이미지">
            <p>본 공공저작물은 공공누리 <span>“공고누리 제1유형 : 출처표시 (상업적 이용 및 변경 가능)”</span> 조건에 따라 이용할 수있습니다. </p>
        </div>
        <div class="satis-bot">
            <div class="satb_left">
                <p class="satb_depart">
                    <span>담당부서</span>기획예산담당관 기획담당
                </p>
                <p class="satb_tel">
                    <span>전화(FAX)</span>055-670-2291(2259)
                </p>
            </div>
            <div class="satb_right">
                <p class="satb_fixday">
                    <span>최종수정일</span>2020-01-22
                </p>
            </div>
        </div>
    </div>
</div>
</div>
    <!--subContent 영역끝-->
</div>
<!--sub-container 영역끝-->
    <div class="bannerWrap">
        <div class="bannerInner">
            <div class="slideBtns typeBlack">
                <a href="#" class="slideLeft">이전슬라이드</a>
                <a href="#" class="slidePlay">재생</a>
                <a href="#" class="slideRight">다음슬라이드</a>
            </div>
            <p>배너모음</p>
            <div class="ftSlide slideCnt">
                <div class="ftSlideCnt"><a href="#">공원누리</a></div>
                <div class="ftSlideCnt"><a href="#">국민추천제</a></div>
                <div class="ftSlideCnt"><a href="#">정부24</a></div>
                <div class="ftSlideCnt"><a href="#">안전신문고</a></div>
                <div class="ftSlideCnt"><a href="#">정보공개시스템</a></div>
                <div class="ftSlideCnt"><a href="#">고성군 다문화 가족 지원센터</a></div>
                <div class="ftSlideCnt"><a href="#">e나라도움</a></div>
                <div class="ftSlideCnt"><a href="#">국민안전방송</a></div>
                <div class="ftSlideCnt"><a href="#">고성군귀농협의회</a></div>
                <div class="ftSlideCnt"><a href="#">공원누리</a></div>
                <div class="ftSlideCnt"><a href="#">국민추천제</a></div>
                <div class="ftSlideCnt"><a href="#">정부24</a></div>
                <div class="ftSlideCnt"><a href="#">안전신문고</a></div>
                <div class="ftSlideCnt"><a href="#">정보공개시스템</a></div>
                <div class="ftSlideCnt"><a href="#">고성군 다문화 가족 지원센터</a></div>
                <div class="ftSlideCnt"><a href="#">e나라도움</a></div>
                <div class="ftSlideCnt"><a href="#">국민안전방송</a></div>
                <div class="ftSlideCnt"><a href="#">고성군귀농협의회</a></div>
            </div>
        </div>
    </div>
    <div class="footer_tap">
        <ul class="footer_cnt">
            <li class="">
                <div>
                    <a href="#" class="noLink">부서</a>
                    <ul class="ftc_inner">
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                    </ul>
                </div>
            </li>
            <li class="">
                <div>
                    <a href="#" class="noLink">읍/면</a>
                    <ul class="ftc_inner">
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                    </ul>
                </div>
            </li>
            <li class="">
                <div>
                    <a href="#" class="noLink">유관기관</a>
                    <ul class="ftc_inner">
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                    </ul>
                </div>
            </li>
            <li class="">
                <div>
                    <a href="#" class="noLink">도내 자치단체</a>
                    <ul class="ftc_inner">
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                        <li><a href="#">하위메뉴</a></li>
                    </ul>
                </div>
            </li>
        </ul>
    </div>
    <footer>
        <div class="ft_inner">
            <ul class="ft_cnt">
                <li class="ftm_1"><a href="">개인정보처리방침</a></li>
                <li><a href="">저작권정책</a></li>
                <li><a href="">전화번호안내</a></li>
                <li><a href="">찾아오시는길</a></li>
            </ul>
            <div class="ft_info_box">
                <p>(우 52943) 경상남도 고성군 고성읍 성내로 130, 고성군청&nbsp;&nbsp;&nbsp;대표전화 : 055-670-2114</p>
                <p><span>GYEONGNAM GOSEONG.</span> All Rights Reserved.</p>
            </div>
        </div>
    </footer>
</div>
<!-- container 영역끝-->
</body>
</html>