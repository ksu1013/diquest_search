

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.diquest.disa.DISA;
import com.diquest.disa.result.DisaEntity;
import com.diquest.disa.result.DisaRelation;
import com.diquest.disa.result.DisaSenResult;
 
public class dqXMLConvert {
	
	static ArrayList<String> arr = null;
	static Connection conn = null;
	static Statement stmt = null;
	static PreparedStatement pstmt = null;
	static ResultSet rs = null;

	/* DB접속 */
	static String inputDir = null;
	static String db_url = null;
	static String db_user = null;
	static String db_pw = null;
	static String db_driver = null;
	static String index_type = null;
	
	/* DISA */
	static DISA disa = new DISA();
	static String dicHome = "/data/diquest/disa/resources/";
	static String JIANA_DCD_DIR = dicHome + "jiana/dic/korean/dcd";
	static String PLOT_DCD_DIR = dicHome + "plot/dic/korean/dcd";
	static String DISA_DCD_DIR = dicHome + "disa/dic/korean/dcd";
	static String category = "CHUNGNAM_PV";
	
	static String disaRegion1 = null;
	static String disaRegion2 = null;
    static int xmlRowCount = 0;
    
	// 구분자
	private final static String FILE_SEPARATOR 	= System.getProperty("file.separator");
	
	public static void main(String[] args) {
		
		String inputDir = null;

		if(args.length > 0) {
			inputDir = args[1]; 
			db_url = args[2];
			db_user = args[3];
			db_pw = args[4];
			db_driver = args[5];
			dicHome = args[6];
			index_type  = args[7];
		}


		
		disa.init(DISA_DCD_DIR, PLOT_DCD_DIR, JIANA_DCD_DIR, category);
								
		//xml 0Depth 리스트
		String[] xmlType = { "Petition","Receipt","Process","Answer","Extitem","Opinion","Petitioner","SelectInspect","LevelInspect" };
		// DATA 노드 리스트
		String[] nodeType = {"opType","petiNo","title","reason","returnMethodCode","returnMethodName","receivePathCode","receivePathName","parentPetiNo","parentPetiRelation","oldPetiNo","regDate","regDateTime","isOpened","complexCode","isHighst","isHurry","statusCode","statusName","typeCode","typeName","isGroup","isManyPeople","catCode","catName","menuName","deptOpenYn","entCivilYnC","grp3PetiYnC","corpName","corpCode","addCorpName","addCorpCode","mailAttchYnC","civilNo","isMainAnc","abstract","planEndDate","planEndDateTime","ancId","ancName","ancRegDate","ancRegDateTime","firstEndDate","firstEndDateTime","doResultDate","doResultDateTime","activeYN","busiBranCode","busiBranCodeName","orgOpenYn","deptCode","seq","deptName","dutyId","dutyDeptCode","dutyName","isMainDept","doDate","doDateTime","content","restausCode","restatusName","channel","menuCode","code","orderNum","extDesc","extType","txtLen","ansTxt","ansChoose0","ansChoose0_nm","ansChoose1","ansChoose1_nm","ansChoose2","ansChoose2_nm","ansChoose3","ansChoose3_nm","ansChoose4","ansChoose4_nm","ansChoose5","ansChoose5_nm","ansDt","ansZipCd","ansAddr1","ansAddr2","essntlYn","regNm","improve","relatedLaw","complaintCodeTo","complaintCodeFrom","proposalFromCode","proposalFromName","nice","kindCode","kindName","sourceCode","sourceName","gradeCode","gradeName","prize","corpPetiYnC","grpPetiYnc","regId","regName","opinionCode","opinionName","siCodesiName","ansSeq","ansKindCode","ansKindName","ansContent","ansId","ansName","ansDeptCode","ansDeptName","useYn","updDateTime","updId","updName","isMainDep","statusCodestatusName","opinion","actionPlan","updateDate","updateDateTime","depCode","depName","selected","centerNice","id","name","contribution","prizeMoney","prizeMemo","inspectNo","endDate","endDateTime","memo","point","ideaLevelCode","ideaLevelName" , "address1", "address2"};
		arr = new ArrayList<String>();
		Collections.addAll(arr, nodeType);

//		dicHome = getDISAPath();
		String input = inputDir;
		
		File inFile = new File(input);
		File[] fileList = inFile.listFiles();

		SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		System.out.println("%$#@! start time [ "+ format.format(new Date()) +"]");
		SimpleDateFormat format1 = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
				
		
	//	System.out.println("+++++++++++++확인++++++++++++++++");
		
		if(fileList != null){
			for (File file : fileList) {
				System.out.println("dqDocTopickerConvert: extractFile: inputFile = " + inputDir + file.getName() +" start time [ "+ format1.format(new Date()) +"]");
				String fileNm = file.getName().substring(0,file.getName().lastIndexOf("."));
				fileNm = fileNm+".UTF-8";
				assignData(inputDir + file.getName(),file.getName(),index_type,xmlType,fileNm);
			}
		}

		SimpleDateFormat format3 = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		disa.fine();
		System.out.println("%$#@! file all end time [ "+ format3.format(new Date()) +"]");
	}
	
	public static void assignData(String uri, String srcFile, String index_type,String[] strType,String fileNm) {
		
		try {
			
			Class.forName(db_driver);
			conn = DriverManager.getConnection(db_url, db_user, db_pw);
			conn.setAutoCommit(true);
						
			//File file = new File(uri);
			String srcPath="/data/diquest/xmlData/inputDir";      	// recive-->origindata2 디렉토리로 설정(원본)
			String orgPath="/data/diquest/xmlData/origindata";		// origin 디렉토리로 설정
			
			if(index_type.equals("inc")) {
				
				File xmlFile = new File(srcPath + System.getProperty("file.separator")  + srcFile);
				File outFile = new File(orgPath + System.getProperty("file.separator")  +srcFile);
				
				BufferedReader br = null;
				BufferedWriter bw = null;
	
				
				try {
					br = new BufferedReader(new InputStreamReader(new FileInputStream(xmlFile), "UTF-8"));
				} catch (UnsupportedEncodingException e2) {
					e2.printStackTrace();
				} catch (FileNotFoundException e2) {
					e2.printStackTrace();
					System.out.println("================================================ ALERT ================================================");
					System.out.println("stopWordInputDir : " + srcPath + System.getProperty("file.separator")  + srcFile);
					System.out.println("================================================ ALERT ================================================");
				}
				
	
				try {
					bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(outFile), "UTF-8"));
				} catch (UnsupportedEncodingException e2) {
					e2.printStackTrace();
				} catch (FileNotFoundException e2) {
					e2.printStackTrace();
					System.out.println("================================================ ALERT ================================================");
					System.out.println("JianaDisaDocExpander: extractFile: inputFile = " + orgPath + System.getProperty("file.separator")  +srcFile );
					System.out.println("================================================ ALERT ================================================");
				}
				
				String WordTxt = "";
				while ((WordTxt = br.readLine()) != null) {
					bw.write(WordTxt.replaceAll("[^\\u0009\\u000A\\u000D\\u0020-\\uD7FF\\uE000-\\uFFFD\\u10000-\\u10FFF]+", ""));
					bw.newLine();
				}
				bw.close();
				
			}
			File file = new File(orgPath + System.getProperty("file.separator")  +srcFile);
			
			DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
			Document xml = documentBuilder.parse(file);
			Element root = xml.getDocumentElement();
			
			String serviceNm = "";
			String serviceCd = ""; 
			
			Pattern servieNmPt = Pattern.compile("(\\$([aA-zZ]{0,10})\\$)"); // Service 명 추출 Ex) EPOUMB
			Pattern servieCdPt = Pattern.compile("(_([aA-zZ]{0,3})_)"); // Service Code 추출 Ex) pc
			
			Matcher servieNmMt = servieNmPt.matcher(fileNm);
			Matcher servieCdMt = servieCdPt.matcher(fileNm);
			
			if(servieNmMt.find()) serviceNm = servieNmMt.group(2);
			if(servieCdMt.find()) serviceCd = servieCdMt.group(2);
			
			for (int x = 0; x < strType.length; x++) {
				String typeString = strType[x];
				String sql = "";
				
				NodeList nodeList = root.getElementsByTagName(typeString);
				
				if (nodeList.getLength() == 0) continue;
				for (int i = 0; i < nodeList.getLength(); i++) {
					Node nodeItem = nodeList.item(i);
					
					/* 변수 선언 */
					String civilNo = getTagValue("civilNo", (Element) nodeItem).trim() == null ? null : getTagValue("civilNo", (Element) nodeItem).trim();
					String deptCode = getTagValue("deptCode", (Element) nodeItem).trim() == null ? null : getTagValue("deptCode", (Element) nodeItem).trim();
					String id = getTagValue("id", (Element) nodeItem).trim() == null ? null : getTagValue("id", (Element) nodeItem).trim();
					String seq = getTagValue("seq", (Element) nodeItem).trim() == null ? null : getTagValue("seq", (Element) nodeItem).trim();
					String inspectNo = getTagValue("inspectNo", (Element) nodeItem).trim() == null ? null : getTagValue("inspectNo", (Element) nodeItem).trim();
					String inspectSeq = getTagValue("inspectSeq", (Element) nodeItem).trim() == null ? null : getTagValue("inspectSeq", (Element) nodeItem).trim();
					String opType = getTagValue("opType", (Element) nodeItem).trim() == null ? null : getTagValue("opType", (Element) nodeItem).trim();
					String petiNo = getTagValue("petiNo", (Element) nodeItem).trim() == null ? null : getTagValue("petiNo", (Element) nodeItem).trim();
					String catCode = getTagValue("catCode", (Element) nodeItem).trim() == null ? null : getTagValue("catCode", (Element) nodeItem).trim();
					String catName = getTagValue("inspectSeq", (Element) nodeItem).trim() == null ? null : getTagValue("catName", (Element) nodeItem).trim();
					String title = getTagValue("title", (Element) nodeItem).trim() == null ? null : getTagValue("title", (Element) nodeItem).trim().replaceAll("'", "");
					String reason = getTagValue("reason", (Element) nodeItem).trim() == null ? null : getTagValue("reason", (Element) nodeItem).trim().replaceAll("'", "") ;
					String statusCode = getTagValue("statusCode", (Element) nodeItem).trim() == null ? null : getTagValue("statusCode", (Element) nodeItem).trim();
					String statusName = getTagValue("statusName", (Element) nodeItem).trim() == null ? null : getTagValue("statusName", (Element) nodeItem).trim() ;
					String receivePathCode = getTagValue("receivePathCode", (Element) nodeItem).trim() == null ? null : getTagValue("receivePathCode", (Element) nodeItem).trim();
					String receivePathName = getTagValue("receivePathName", (Element) nodeItem).trim() == null ? null : getTagValue("receivePathName", (Element) nodeItem).trim();
					String regDateTime = getTagValue("regDateTime", (Element) nodeItem).trim() == null ? null : getTagValue("regDateTime", (Element) nodeItem).trim() ;
					String isOpened = getTagValue("isOpened", (Element) nodeItem).trim() == null ? null : getTagValue("isOpened", (Element) nodeItem).trim() ;
					String ansAddr1 = getTagValue("ansAddr1", (Element) nodeItem).trim() == null ? null : getTagValue("ansAddr1", (Element) nodeItem).trim() ;
					String ansAddr2 = getTagValue("ansAddr2", (Element) nodeItem).trim() == null ? null : getTagValue("ansAddr2", (Element) nodeItem).trim() ;
					String birthDate = getTagValue("birthDate", (Element) nodeItem).trim() == null ? null : getTagValue("birthDate", (Element) nodeItem).trim() ;
					String sex = getTagValue("sex", (Element) nodeItem).trim() == null ? null : getTagValue("sex", (Element) nodeItem).trim() ;
					String cancel_yn_c = getTagValue("cancel_yn_c", (Element) nodeItem).trim() == null ? null : getTagValue("cancel_yn_c", (Element) nodeItem).trim() ;
					String planEndDateTime = getTagValue("planEndDateTime", (Element) nodeItem).trim() == null ? null : getTagValue("planEndDateTime", (Element) nodeItem).trim() ;
					String ancRegDateTime = getTagValue("ancRegDateTime", (Element) nodeItem).trim() == null ? null : getTagValue("ancRegDateTime", (Element) nodeItem).trim() ;
					String doResultDateTime = getTagValue("doResultDateTime", (Element) nodeItem).trim() == null ? null : getTagValue("doResultDateTime", (Element) nodeItem).trim() ;
					String firstEndDateTime = getTagValue("firstEndDateTime", (Element) nodeItem).trim() == null ? null : getTagValue("firstEndDateTime", (Element) nodeItem).trim() ;
					String doDateTime = getTagValue("doDateTime", (Element) nodeItem).trim() == null ? null : getTagValue("doDateTime", (Element) nodeItem).trim() ;
					String content = getTagValue("content", (Element) nodeItem).trim() == null ? null : getTagValue("content", (Element) nodeItem).trim().replaceAll("'", "");
					String abstract1 = getTagValue("abstract", (Element) nodeItem).trim() == null ? null : getTagValue("abstract", (Element) nodeItem).trim();
					String updateDateTime = getTagValue("updateDateTime", (Element) nodeItem).trim() == null ? null : getTagValue("updateDateTime", (Element) nodeItem).trim() ;
					String deptName = getTagValue("deptName", (Element) nodeItem).trim() == null ? null : getTagValue("deptName", (Element) nodeItem).trim();
					String address1 = getTagValue("address1", (Element) nodeItem).trim() == null ? null : getTagValue("address1", (Element) nodeItem).trim();
					String address2 = getTagValue("address2", (Element) nodeItem).trim() == null ? null : getTagValue("address2", (Element) nodeItem).trim();

					//DQ_ID 설정
					String DQ_ID = "";
					DQ_ID = (serviceNm + "_" + typeString +"_" + opType + "_" + petiNo + "_" + regDateTime).replaceAll("'", "");
					
					if(typeString.equals("Opinion")) DQ_ID = DQ_ID + "_" + civilNo + "_" + deptCode + "_" + seq;
					else if(typeString.equals("Petitioner")) DQ_ID = DQ_ID + "_" + deptName;
					else if(typeString.equals("SelectInspect")) DQ_ID = DQ_ID + "_" + inspectNo + "_" + seq;
					else if(typeString.equals("LevelInspect")) DQ_ID = DQ_ID + "_" + inspectSeq + "_" + seq;
					
					int count = 0; // 데이터가 몇개 변경 되었는지 확인하는 변수
					String address = null;
					if(!address1.equals("") && address1 != null && !address2.equals("") && address2 != null) {
						address = (address1 + "/" + address2) == "/" ? null : (address1 + "/" + address2);
					}

					if(typeString.equals("Petition") && serviceNm.equals("EPOUMB")) {
						String[] regionArr = new String[2]; 
						disaRegion1 = "";
						disaRegion2 = "";
						if(address != null && !address.equals("")) {
							//DISA disa = new DISA();
							regionArr = setDisa(address, disa);
							if (regionArr[0] != null) disaRegion1 = regionArr[0]; else disaRegion1 ="";
							if (regionArr[1] != null) disaRegion2 = regionArr[1]; else disaRegion2 ="";
						//	System.out.println("disaRegion = " + disaRegion1 + "/"+ disaRegion2);
							 
						}
					
						sql = " values ('" + DQ_ID +"', '"+petiNo+"', '"+catCode +"', '"+catName +"', '"+title +"', '"+reason.replaceAll("\\p{Punct}", " ") +"', '"+statusName +"', '"+receivePathName +"', '"+regDateTime +"', '"+isOpened +"', '"+address+"', '"+birthDate +"','"+sex+"','"+ disaRegion1 + "','" + disaRegion2 +"','" + cancel_yn_c + "', null )" ;
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+catCode +", "+catName +", "+title +", "+reason +", "+statusName +", "+receivePathName +", "+regDateTime +", "+isOpened +", "+address+", "+birthDate +","+sex+",'"+ disaRegion1 + "','" + disaRegion2 +"'," + cancel_yn_c + ", null )" ;
					}else if (typeString.equals("Receipt") && serviceNm.equals("EPOUMB")) {
						sql = " values ('" + DQ_ID +"', '"+petiNo+"', '"+statusName+"', '"+planEndDateTime+"', '"+ancRegDateTime+"', '"+firstEndDateTime+"', '"+doResultDateTime+"', "+getDate(ancRegDateTime, "year")+", "+getDate(ancRegDateTime, "month")+", "+getDate(ancRegDateTime, "yearMonth")+", "+getDate(ancRegDateTime, "week")+", "+getDate(ancRegDateTime, "day")+", "+getDate(ancRegDateTime, "hour")+")";
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+statusName+"	, "+planEndDateTime+", "+ancRegDateTime+", "+firstEndDateTime+", "+doResultDateTime+", "+getDate(ancRegDateTime, "year")+", "+getDate(ancRegDateTime, "month")+", "+getDate(ancRegDateTime, "yearMonth")+", "+getDate(ancRegDateTime, "week")+", "+getDate(ancRegDateTime, "day")+", "+getDate(ancRegDateTime, "hour")+")" ;
					}else if (typeString.equals("Process") && serviceNm.equals("EPOUMB")) {
						sql = " values ('" + DQ_ID +"', '"+petiNo+"', '"+content.replaceAll("\\p{Punct}", " ") +"', '"+statusName+"', '"+deptCode+"', '"+deptName+"', '"+regDateTime+"', '"+doDateTime+"')" ;
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+content+", "+statusName+", "+deptCode+", "+deptName+", "+regDateTime+", "+doDateTime+")";
					}else if (typeString.equals("Petition") && serviceNm.equals("EPOUPO")) {
						disaRegion1 = "";
						disaRegion2 = "";
						if(address != null && !address.equals("")) setDisa(address,disa);
						sql = " values ('" + DQ_ID +"', '"+petiNo+"', '"+title+"', '"+reason.replaceAll("\\p{Punct}", " ") +"', '"+receivePathName+"', '"+regDateTime+"', '"+statusName+"', '"+isOpened+"', '"+address+"', '"+birthDate+"', '"+sex+"', null, null, null)";
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+title+", "+reason+", "+receivePathName+", "+regDateTime+", "+statusName+", "+isOpened+", "+address+", "+birthDate+", "+sex+",'"+ disaRegion1 + "','" + disaRegion2 +"', null)";
					}else if (typeString.equals("Receipt") && serviceNm.equals("EPOUPO")) {
						sql = " values ('" + DQ_ID +"', '"+petiNo+"', '"+statusName+"', '"+planEndDateTime+"', '"+regDateTime+"', "+getDate(regDateTime, "year")+", "+getDate(regDateTime, "month")+", "+getDate(regDateTime, "yearMonth")+", "+getDate(regDateTime, "week")+", "+getDate(regDateTime, "day")+", "+getDate(regDateTime, "hour")+")" ;
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+statusName+", "+planEndDateTime+", "+regDateTime+", "+getDate(regDateTime, "year")+", "+getDate(regDateTime, "month")+", "+getDate(regDateTime, "yearMonth")+", "+getDate(regDateTime, "week")+", "+getDate(regDateTime, "day")+", "+getDate(regDateTime, "hour")+")" ;
					}else if (typeString.equals("Answer") && serviceNm.equals("EPOUPO")) {
						sql = " values ('" + DQ_ID +"', '"+petiNo+"', '"+content.replaceAll("\\p{Punct}", " ") +"', '"+regDateTime+"')" ;
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+content+", "+regDateTime+")" ;
					}else if (typeString.equals("Petition") && serviceNm.equals("EPOUGN")) { // 테스트 필요
						sql = " values ('" + DQ_ID +"', '"+petiNo+"','"+title+"', '"+abstract1.replaceAll("\\p{Punct}", " ") +"', '"+regDateTime+"', '"+planEndDateTime+"', '"+updateDateTime+"', '"+statusName+"', null)" ;
					//	System.out.println("sql1111111111>>>>"+sql);
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+title+", "+abstract1+", "+regDateTime+", "+planEndDateTime+", "+updateDateTime+", "+statusName+", null)" ;
					}else if (typeString.equals("Petitioner") && serviceNm.equals("EPOUGN")) { // 테스트 필요
						sql = " values ('" + DQ_ID +"', '"+petiNo+"', '"+deptName+"','"+statusName+"')";
					//	System.out.println("sql222222222>>>>"+sql);
						//sql = " values ('" + DQ_ID +"', "+petiNo+", "+deptName+")" ;
					}
					

					if(!sql.equals("") && !opType.equals("D")) {
						String[] isCheck = selectDB(typeString, serviceNm, opType, petiNo);
						String DB_STATE = isCheck[0];	// DB_상태
						String DB_NO = isCheck[1];		// DB_접수번호
						String DB_YN = isCheck[2];		// DB_유무
						
						if(DB_YN.equals("N")) {
							//System.out.println("INSERT_[1] 시작");
							insertDB(typeString, serviceNm, sql, opType, petiNo);																					
						}else {
							if(!"완료".equals(DB_STATE) &&DB_NO.equals(petiNo.toLowerCase())) {
							//System.out.println("INSERT_[2] 시작");
								insertDB(typeString, serviceNm, sql, opType, petiNo);								
							}
						}
					}
//					TimeUnit.MILLISECONDS.sleep(100);
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				// DBClose 클래스 안쓰고 만들기 ( Statement일때 )
				if (stmt != null) { // 값이 들어가 있음
					stmt.close(); // statement 닫음
				}
				if (conn != null) { // 디비 연결되어 있음
					conn.close(); // connection닫아
				}
			} catch (SQLException e) {
				e.printStackTrace();
			}
			
		}
		
	//	System.out.println("[=====================] total xmlRowCount =" + xmlRowCount  );
	}
	
	private static String getTagValue(String sTag, Element element) {
		try {
			String result = element.getElementsByTagName(sTag).item(0).getTextContent();
			return result;
		} catch (NullPointerException e) {
			return "";
		} catch (Exception e) {
			return "";
		}
	}
		
	private static void insertDB(String typeString, String serviceNm, String sql, String opType, String petiNo) {
		// Process 테이블 상태만 STATE2 
		sql = "insert  into RFC_CHUNGNAM_EPEOPLE_"+serviceNm+"_INFO_"+typeString+sql;
		sql = sql.toLowerCase();
		//System.out.println("[INSERT sql ] " + sql);
		try {
			stmt.executeUpdate(sql);	
			//System.out.println("stmt<<<>>>>>>>>>>>>>>>>>>"+stmt);
			xmlRowCount++;
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("["+e.getErrorCode()+"] " + e); 
		} 
	}
	
	private static String[] selectDB(String typeString, String serviceNm, String opType, String petiNo) {
		
		String selectSql = "select * from RFC_CHUNGNAM_EPEOPLE_" + serviceNm +"_INFO_" + typeString + " where No = '" +petiNo + "'" ;
		selectSql = selectSql.toLowerCase();
//		System.out.println("[selectSql]");
//		System.out.println("selectSql >>> "+selectSql);
		String DB_STATE = null;
		String DB_IDX = null;
		String DB_NO = null;
		String isCheck = "N";
		try {
			stmt = conn.createStatement();   // 현재 연결부분에 대한 상태를 생성
			rs = stmt.executeQuery(selectSql);
			 if(rs.next()) {
				 isCheck = "Y";
				 DB_IDX = rs.getString("IDX");
				 DB_NO = rs.getString("NO");
				if(DB_IDX.contains("_i_")) {
					
					deleteDB(typeString, serviceNm, petiNo);
				}else {					
					if(DB_IDX.contains("_u_") && typeString.equals("Answer")) {
						DB_STATE = null;
					}else if(DB_IDX.contains("_u_") && !typeString.equals("Process")) {
						DB_STATE = rs.getString("STATE");
					}else if(DB_IDX.contains("_u_") && typeString.equals("Process")){ 
						DB_STATE = rs.getString("STATE2");
					}
					
					if(DB_IDX.contains("_u_") && opType.equals("U") && !DB_STATE.equals("완료")) {
						deleteDB(typeString,serviceNm, petiNo);
					}
				}
			 }
			 
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("[SELECT Error]" + e);
		} 
		String[] retrunSelect = {DB_STATE, DB_NO, isCheck};
		return retrunSelect;
	}
	
	private static void deleteDB(String typeString, String serviceNm,   String petiNo) {
		
		String deleteSql = "delete from RFC_CHUNGNAM_EPEOPLE_" + serviceNm +"_INFO_" + typeString;
		if(!petiNo.equals(""))deleteSql += " where NO= '" +petiNo+"'";
		deleteSql = deleteSql.toLowerCase();
	//	System.out.println("[DELETE sql]"+deleteSql); 
		try {
			int r = stmt.executeUpdate(deleteSql);
	//		System.out.println("[DELETE Count] " + r);
			
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("[DELETE Error]" + e);
		} 
	}
	
	
	
	/**
	 * 
	 * @param strDate 문자형 날짜
	 * @param type	  return 반을 날짜 Type 
	 * @return		  String date
	 */
	private static String getDate(String strDate, String type) {
		strDate = strDate.replaceAll("'","");
		if(!strDate.equals("") && strDate != null) {
			try {
				SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
				Date date = formatter.parse(strDate);		
				
				date = new Date(date.getTime() + (1000 * 60 * 60 * 24 - 1)); 
				Calendar cal = Calendar.getInstance();
				cal.setTime(date); 
				
				if(type.equals("year")) {
					strDate = "'" + Integer.toString(cal.get(Calendar.YEAR)) + "'";
				}else if(type.equals("month")) {
					strDate = "'" + Integer.toString(cal.get(Calendar.MONTH)+1) + "'";
				}else if(type.equals("yearMonth")) {
					strDate = "'" + Integer.toString(cal.get(Calendar.YEAR)) + Integer.toString(cal.get(Calendar.MONTH)+1) + "'";
				}else if(type.equals("week")) {
					strDate = "'" + Integer.toString(cal.get(Calendar.WEEK_OF_MONTH))+ "'";
				}else if(type.equals("day")) {
					strDate = "'" + Integer.toString(cal.get(Calendar.DATE)-1)+ "'";
				}else if(type.equals("hour")) {
					strDate = "'" + Integer.toString(cal.get(Calendar.HOUR))+ "'";					
				}				

			} catch (ParseException e) {
			}
		
		}else { 
			strDate = null;			
		}
		
		return strDate;
	}//getDate()
	
	
	/**
	 * DISA  
	 * @param address 
	 */
//	private static void setDisa(String address) {
//		
//		List<DisaSenResult> disaResult = disa.analyze(address.toCharArray());
//		int insertCnt = 0;
//		
//		DisaRelation disaRelation;
//		DisaEntity disaEntity;
//		for(DisaSenResult dsr : disaResult){
//			for(int i = 0; i < dsr.relations.length; i++){
//				disaRelation = dsr.relations[i];
//				for(int j = 0; j < disaRelation.size(); j++){
//					disaEntity = disaRelation.getEntity(j);
//					
//					if(insertCnt == 0) disaRegion1 = address.substring(disaEntity.start, disaEntity.end);
//					if(insertCnt == 1) disaRegion2 = address.substring(disaEntity.start, disaEntity.end);
//
//					++insertCnt;
//				}
//			}
//		}
//	}	
	/**
	 * DISA  
	 * @param address 
	 */
	private static String[] setDisa(String address, DISA disa) {
		
		String[] regionArr = new String[2];
		String disaRegion = "";
		
		try {
			List<DisaSenResult> disaResult = disa.analyze(address.toCharArray());
		//	System.out.println("확인>>>>>1111");
			if(disaResult != null) {
				DisaRelation disaRelation;
				DisaEntity disaEntity;
				for(DisaSenResult dsr : disaResult){
					for(int i = 0; i < dsr.relations.length; i++){
						disaRelation = dsr.relations[i];
						if(disaRelation.size()==2) {
							for(int j = 0; j < disaRelation.size(); j++){
								disaEntity = disaRelation.getEntity(j);
								disaRegion = address.substring(disaEntity.start, disaEntity.end);
								if(j < 2) {
									regionArr[j] = disaRegion;
								}
								
							}
						}		
					}
				}
			}
			
		
		}catch (Exception e) {
			// TODO: handle exception
			System.out.println("지역>>>>>>>>>>>>>>>>>>> " + address);
			e.printStackTrace();
		}
		
		return regionArr;
	}	
	
	
}
