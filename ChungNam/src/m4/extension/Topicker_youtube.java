package m4.extension;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.diquest.disa.DISA;
import com.diquest.disa.result.DisaSenResult;
import com.diquest.disa.result.NeEntity;
import com.diquest.ir.dbwatcher.DbWatcher;
import com.diquest.ir.dbwatcher.DbWatcherExtension;
import com.diquest.ir.dbwatcher.dbcolumn.DbColumnValue;
import com.diquest.ir.dbwatcher.mapper.FieldMapper;
import com.diquest.jiana.morph.CottonBuffer;
import com.diquest.jiana.morph.JianaConst;
import com.diquest.jiana.morph.JianaCotton;
import com.diquest.topicker.preprocessing.TPbasicSentExtractor;
import com.diquest.topicker.preprocessing.TPbasicTermExtractorComp;
import com.diquest.topicker.topicker.TopicAnalyzer;

public class Topicker_youtube implements DbWatcherExtension {
	private String jianaHome = "/data/diquest/mariner4/resources/korean";
//	private String jianaHome = "/home/chungnam/mariner4/resources/korean";
	private TPbasicSentExtractor se = new TPbasicSentExtractor();
	private TPbasicTermExtractorComp te=new TPbasicTermExtractorComp(jianaHome);
	private TopicAnalyzer ta = new TopicAnalyzer();
	private String INITIAL_KEYWORD;
	private String INITIAL_KEYWORD2;
	private String INITIAL_KEYWORD3;

	 //문장 추출
	
	// DB에서 정보를 가져 오기 위한 JDBC Object
	private DbWatcher watcher;
	private Connection con;

	private static Set<String> trStopWordSet;
	private static String GET_STOP_QUERY = "SELECT keyword FROM diquest.IR_RECOMMEND where COLLECTION_ID=?";
	
	/* DISA 관련 경로 */
	private static final String dicHome = "/data/diquest/disa/resources/"; // 실서버 $DISA_HOME/
	private static final String JIANA_DCD_DIR = dicHome + "jiana/dic/korean/dcd";
	private static final String PLOT_DCD_DIR = dicHome + "plot/dic/korean/dcd";
	private static final String DISA_DCD_DIR = dicHome + "disa/dic/korean/dcd";
	private static final String DISA_CATEGORY	= "CHUNGNAM_PV";
	private static DISA disa;
	private static JianaCotton cotton;
	private static CottonBuffer cb;
	
	/* DISA 관련 변수 */
	private String emotionType;										// 감정 분석 결과타입  
	
	/* extension 변수 설정 */
	private StringBuffer KEYWORS_NEG		= new StringBuffer();
	private StringBuffer KEYWORD_POS		= new StringBuffer();
	private StringBuffer DISA_INPUT 		= new StringBuffer();
	
	/* 식별자 */
	private String currentId	= "";
	private String hasId		= "";
	
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	@Override
	public FieldMapper getMapper(String topicTemp, DbColumnValue[] columnValue) throws SQLException {
		
		return new exTractorTopicker(topicTemp,columnValue);
	}

	@Override
	public void start(DbWatcher watcher) throws SQLException {
		// TODO Auto-generated method stub
		try {
			con = watcher.createConnection();
		
		} catch (SQLException e) {
			try {	
				if (con != null) {
					watcher.releaseConnection(con);
					con = null;
				}
			} catch (SQLException e2) { }
			throw e;
		}		
		String collectionId = "CHUNGNAM_YOUTUBE";
		try {
			getStopWordCheck(collectionId);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		/* DISA init */
		disa = new DISA();
		disa.init(DISA_DCD_DIR, PLOT_DCD_DIR, JIANA_DCD_DIR, DISA_CATEGORY);
		
		//cotton 객체생성
		cotton = new JianaCotton();
		//사전 resource initialize
		cotton.init2(JIANA_DCD_DIR,(byte)JianaConst.CN_FLAG);
		
		cb = new CottonBuffer();

	}

	@Override
	public void stop() throws SQLException {
		/* DISA 종료 */		
		disa.fine();
		pstmt.close();
		rs.close();
		con.close();
	}
	
	private static String getValueByFieldName(String name, DbColumnValue[] columnValues) throws SQLException {
		for(int i = 0; i < columnValues.length; i++) {
			if(!name.equals(columnValues[i].getName())) {
				continue;
			}
			return columnValues[i].getString();
		}
		throw new SQLException("DBWatcherExtension : " + name + " 컬럼이 SELECT 되지 않았습니다. " );
	}
	
	private void getStopWordCheck(String collectionId) throws Exception {
		trStopWordSet = new HashSet<String>();
		 
		pstmt = con.prepareStatement(GET_STOP_QUERY);
		pstmt.setString(1, collectionId);
		rs = pstmt.executeQuery();
		
		while (rs.next() == true) {
			trStopWordSet.add(rs.getString(1).replaceAll("_", " "));
		}

	}
	
	
	public class exTractorTopicker extends FieldMapper {
		//private int DOCID;
		private String fieldName;
		
		

		public exTractorTopicker(String fieldName,DbColumnValue[] columnValue) throws SQLException  {
			super(fieldName);
			//DOCID = getIndexOf("CONTS_CONTS", columnValue); // 디비의 로우 이름을 설정.
	        this.fieldName = fieldName;// 필드명 세팅
		}

		@Override
		public String mapping(DbColumnValue[] columnValue) throws SQLException {
			currentId = getValueByFieldName("CONTS_SEQ", columnValue);
			StringBuilder data_fkey = null;
			StringBuilder data_fkey2 = null;
			
			if(!currentId.equals(hasId)) {
				INITIAL_KEYWORD = columnValue[getIndexOf("YOUTUBE_CONTENT", columnValue)].getString();// DQ_DOC의 ID값에 해당하는 value값.
				INITIAL_KEYWORD2 = columnValue[getIndexOf("YOUTUBE_VIDEO_TITLE", columnValue)].getString();// DQ_DOC의 ID값에 해당하는 value값.
				INITIAL_KEYWORD3 = columnValue[getIndexOf("YOUTUBE_TAGS", columnValue)].getString();// DQ_DOC의 ID값에 해당하는 value값.
				data_fkey = new StringBuilder();// 최종적인 결과물을 담아내서 return 하기위한 최종 결과물역할 변수.
				data_fkey2 = new StringBuilder();// 최종적인 결과물을 담아내서 return 하기위한 최종 결과물역할 변수.
				
				String kkkk="";
				kkkk = exTractorTopicker(INITIAL_KEYWORD);
				if(!kkkk.equals(""))kkkk= kkkk+";"+exTractorTopicker(INITIAL_KEYWORD2)+";"+exTractorTopicker(INITIAL_KEYWORD3);
				else kkkk = exTractorTopicker(INITIAL_KEYWORD2)+";"+exTractorTopicker(INITIAL_KEYWORD3);
				
				if (fieldName.equals("MAIN_KEYWORD")) { 
					// 만든 조건문.
					data_fkey.append(kkkk);
				}
				if(fieldName.equals("MAIN_KEYWORD2")) {
					data_fkey2.append(exTractorTopicker(INITIAL_KEYWORD3));
				}
				
				/* DISA */
	    		KEYWORS_NEG.delete(0, KEYWORS_NEG.length());
	    		KEYWORD_POS.delete(0, KEYWORD_POS.length());
	    		DISA_INPUT.delete(0,  DISA_INPUT.length());

	    		DISA_INPUT.append(getValueByFieldName("YOUTUBE_VIDEO_TITLE", columnValue) + " " + getValueByFieldName("YOUTUBE_CONTENT", columnValue));
	    		//setDisaResul(DISA_INPUT.toString());
	    	

			}
			
			if(fieldName.equals("KEYWORS_NEG"))					return KEYWORS_NEG.toString();
	    	if(fieldName.equals("KEYWORD_POS"))					return KEYWORD_POS.toString();
	    	if(fieldName.equals("EPOTION_TYPE"))				return emotionType;
		    if(fieldName.equals("MAIN_KEYWORD"))				return data_fkey.toString();
		    if(fieldName.equals("MAIN_KEYWORD2"))				return data_fkey2.toString();
	        
		   return null;
		}

	}
	
	
	public String exTractorTopicker(String topicTemp) {
		
		
	    int j = 0;
	    String topicker = "";
	    topicTemp = topicTemp == null ? "" :topicTemp;
	    Set<String> bufSet = new HashSet<String>();
	    try {

		
	    if(!topicTemp.equals("")) {
	    	
		    if (ta.doAnalysis(topicTemp, se, te)) {
		    	for (Map.Entry<String, Double> localEntry : ta.getKWordRankMap("80%").entrySet()) {	
		    		String keyword = (String)localEntry.getKey();
		    		if (j > 11) break;
		    		if(trStopWordSet.contains(keyword) ) {
					  continue;
		    		}
		            bufSet.add((String)localEntry.getKey());
		          //System.out.println("(String)localEntry.getKey()>>>>>>>>>>>"+(String)localEntry.getKey());
		            j++;
		    	}
		    }
	    }
	    
	    } catch (Exception e) {
			// TODO: handle exception
	    	e.printStackTrace();
		}
	    topicker = toString(bufSet, ";");
	    return topicker;
		
	}
	public String toString(Set<String> set, String delim) {
		StringBuilder b = new StringBuilder();
		int j = 0;
		for(String s : set) {
			if(j > 0)
				b.append(delim);
			b.append(s);
			j++;
		}
		return b.toString();
	}
	
	
	private static int getIndexOf(String name, DbColumnValue[] columnValue) throws SQLException {
	    for (int i = 0; i < columnValue.length; i++) {
	        if (name.equals(columnValue[i].getName()))
	            return i;
	    }
	    throw new SQLException("DBWatcherExtension : " + name + " 컬럼이 SELECT 되지 않았습니다.");
	    // 밑의 NameMapperField가쪽에서 에러가 날 경우 select가 되지 않았다는 오류가 이 부분에서 표출되게 끔 생성함.
	}	
	
	
//	public void setDisaResul(String input){
//		
//		int negativeCount = 0;
//		int positiveCount = 0;
//		
//		
//		
//		NeEntity entity = null; 
//		String key = null;
//		String type = null;
//		
//		List<DisaSenResult> disaResult = disa.analyze(input.toCharArray()); 
//
//		for(DisaS enResult dsr : disaResult){
//			
//			for(int i = 0; i < dsr.getEntitySize(); i++){
//				String splitUnit = "" ;
//				
//				entity = dsr.getEntity(i);
//				key = entity.lexical;
//				type = entity.type;
//				
//								
//				if(type!=null && !type.equals("")) {
//					if(type.equals("$EMOTION_NEG")) {
//						if(KEYWORS_NEG.length() > 0) {
//							splitUnit = ",";
//						}
//						++negativeCount;						
//						String postStr = cottonExtract(key);
//						KEYWORS_NEG.append(splitUnit + postStr);
//					}
//					if(type.equals("$EMOTION_POS")) {
//						if(KEYWORD_POS.length() > 0) {
//							splitUnit = ",";
//						}
//						++positiveCount;
//
//						String postStr = cottonExtract(key);
//						KEYWORD_POS.append(splitUnit + postStr);
//					}
//					
//				}
//
//			}
//
//		}
//		
//		if(positiveCount == negativeCount) {
//			emotionType = "중립";
//		}else if(positiveCount > negativeCount) {
//			emotionType = "긍정";
//		}else {
//			emotionType = "부정";
//		}
//		
		
//	}
	
	public static String cottonExtract(String inputStr){
		String jianaStr = "";
		cb.init(inputStr.toCharArray());
		//cotton 분석
		cotton.analyze(cb); 
				
		//형태소 결과 출력
		for (int i = 0; i < cb.nTerm; i++){
			// character[]의 start와 length를 이용하여 출력, 태그번호 출력
			//System.out.println(new String(cb.input, cb.termStart[i], cb.termLength[i]) + " " + cb.termTag[i]);
			String term = new String(cb.input, cb.termStart[i], cb.termLength[i]);
			//System.out.println("term>>>>>>"+term);
			if(cb.termTag[i] == 1) {    //명사
				jianaStr = term;
			}else if(cb.termTag[i] == 3) {   //
				jianaStr = term + "다";
			}
		}
	
		return jianaStr;
	}

}
