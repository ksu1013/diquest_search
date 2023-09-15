package m4.extension;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import com.diquest.ir.dbwatcher.DbWatcher;
import com.diquest.ir.dbwatcher.DbWatcherExtension;
import com.diquest.ir.dbwatcher.dbcolumn.DbColumnValue;
import com.diquest.ir.dbwatcher.mapper.FieldMapper;
import com.diquest.topicker.preprocessing.TPbasicSentExtractor;
import com.diquest.topicker.preprocessing.TPbasicTermExtractorComp;
import com.diquest.topicker.topicker.TopicAnalyzer;

public class Topicker_gugminNP implements DbWatcherExtension {
	private String jianaHome = "/data/diquest/mariner4/resources/korean";
//	private String jianaHome = "/home/chungnam/mariner4/resources/korean";
	private TPbasicSentExtractor se = new TPbasicSentExtractor();
	private TPbasicTermExtractorComp te=new TPbasicTermExtractorComp(jianaHome);
	private TopicAnalyzer ta = new TopicAnalyzer();
	private String INITIAL_KEYWORD;
	private String INITIAL_KEYWORD2;

	 //문장 추출
	
	// DB에서 정보를 가져 오기 위한 JDBC Object
	private DbWatcher watcher;
	private Connection con;

	private static Set<String> trStopWordSet;
	private static String GET_STOP_QUERY = "SELECT keyword FROM diquest.IR_RECOMMEND where COLLECTION_ID=?";
	
	
	
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
		
		String collectionId = "EPEOPLE";
		try {
			getStopWordCheck(collectionId);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}

	@Override
	public void stop() throws SQLException {
		// TODO Auto-generated method stub
		
	}
	
	private void getStopWordCheck(String collectionId) throws Exception {
		trStopWordSet = new HashSet<String>();
		 
		PreparedStatement pstmt = con.prepareStatement(GET_STOP_QUERY);
		ResultSet rs = null;
		
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
			INITIAL_KEYWORD = columnValue[getIndexOf("CONTENTS", columnValue)].getString();// DQ_DOC의 ID값에 해당하는 value값.
			INITIAL_KEYWORD2 = columnValue[getIndexOf("TITLE", columnValue)].getString();// DQ_DOC의 ID값에 해당하는 value값.
	        StringBuilder data_fkey = new StringBuilder();// 최종적인 결과물을 담아내서 return 하기위한 최종 결과물역할 변수.
	        String kkkk="";
	        kkkk = exTractorTopicker(INITIAL_KEYWORD);
	        if(!kkkk.equals(""))kkkk= kkkk+";"+exTractorTopicker(INITIAL_KEYWORD2);
	        else kkkk = exTractorTopicker(INITIAL_KEYWORD2);
		    	if (fieldName.equals("MAIN_KEYWORD")) { 
                    // 만든 조건문.
		    		data_fkey.append(kkkk);
		    	}

		        

	        return data_fkey.toString();
		   
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
	
	
	

}
