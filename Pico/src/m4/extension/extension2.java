package m4.extension;

import java.sql.Array;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.diquest.ir.dbwatcher.DbWatcher;
import com.diquest.ir.dbwatcher.DbWatcherExtension;
import com.diquest.ir.dbwatcher.dbcolumn.DbColumnValue;
import com.diquest.ir.dbwatcher.mapper.FieldMapper;



//단위테스트용 ssts 스키마 사용
public class extension2 implements DbWatcherExtension {
	
	private String nowPkgPK = "";	
	private String nowPkgPK_DNO = "";	
	
	
	private String prePkgPK = "";	
	
	
	private String SIDO;
	private String SIGUNGU;
	private String EUPMYEONDONG;
	
	
	// DB에서 정보를 가져 오기 위한 JDBC Object
	private DbWatcher watcher;
	private Connection con;
	private PreparedStatement pstmt_con;
	
	private String sub_query ="WITH RECURSIVE dq as(SELECT USERNO AS DEALERNO\r\n"
			+ "		, '전국' AS SIDO\r\n"
			+ "		, '' AS SIGUNGU\r\n"
			+ "		, '' AS EUPMYEONDONG \r\n"
			+ "FROM PHARMUS_HOS.T_DEALER\r\n"
			+ "WHERE STATE = '100'\r\n"
			+ "	    AND ISNATIONALSALES = 'T'\r\n"
			+ "UNION ALL\r\n"
			+ "SELECT DSA.DEALERNO\r\n"
			+ "		, DSA.SIDO\r\n"
			+ "		, DSA.SIGUNGU\r\n"
			+ "		, DSA.EUPMYEONDONG\r\n"
			+ "FROM PHARMUS_HOS.T_DEALER D\r\n"
			+ "JOIN PHARMUS_HOS.T_DEALER_SELL_AREA DSA ON D.USERNO = DSA.DEALERNO \r\n"
			+ "    WHERE D.STATE = '100'\r\n"
			+ "	    AND D.ISNATIONALSALES = 'F'\r\n"
			+ "ORDER BY DEALERNO, SIDO, SIGUNGU, EUPMYEONDONG "
			+ "	   )\r\n"
			+ "	  select\r\n"
			+ "	  DEALERNO as dq_DEALERNO\r\n"
			+ "	  , SIDO as dq_sido\r\n"
			+ "	  , case when SIDO = '전국' then SIDO\r\n"
			+ "	        when nullif(SIGUNGU, '') is null then null\r\n"
			+ "	    	else SIDO||'@'||SIGUNGU\r\n"
			+ "	   	    end as dq_SIGUNGU\r\n"
			+ "	  , case when SIDO = '전국' then SIDO \r\n"
			+ "	         when nullif(EUPMYEONDONG, '') is null then null\r\n"
			+ "	    	 else SIDO||'@'||SIGUNGU||'@'||EUPMYEONDONG \r\n"
			+ "	    	 end as dq_EUPMYEONDONG\r\n"
			+ "	  from dq"
			+ "	 where cast (DEALERNO as text) = any (?::text[])"
			+ ";";
	
	
	@Override
	public void start(DbWatcher watcher) throws SQLException {
		// TODO Auto-generated method stub
		this.watcher = watcher;
		this.con = null;
		this.pstmt_con = null;

		try {
			con = watcher.createConnection();
			pstmt_con = con.prepareStatement(sub_query);
			

		} catch (SQLException e) {
			try {
				if (pstmt_con != null) pstmt_con.close();

				if (con != null) {
					watcher.releaseConnection(con);
					con = null;
				}
			} catch (SQLException e2) { }
			throw e;
		}
	}

	@Override
	public void stop() throws SQLException {
		// TODO Auto-generated method stub
		if (pstmt_con != null) pstmt_con.close();

		if (con != null) {
			watcher.releaseConnection(con);
			con = null;
		}
	}
	
	// 데이터베이스 value 개수
	private static int getIndexOf(String name, DbColumnValue[] columnValue) throws SQLException {
		for (int i=0; i < columnValue.length; i++) {
			if (name.equals(columnValue[i].getName()))
				return i;
		}
		throw new SQLException("DBWatcherExtension : " + name + " 컬럼이 SELECT 되지 않았습니다.");
	}
		
	@Override
	public FieldMapper getMapper(String fieldName, DbColumnValue[] columnValue) throws SQLException {
		// TODO Auto-generated method stub
		return new NameMapperField(columnValue, pstmt_con,fieldName);
	}

	private class NameMapperField extends FieldMapper {
		private final int DEALERNO;
		private final int GOODSMASTERNO;
		
		private final PreparedStatement pstmt_con;
	
		private final String fieldName;
		
		public NameMapperField(DbColumnValue[] columnValue, PreparedStatement pstmt_con,String fieldName) throws SQLException {
			super(fieldName);
			GOODSMASTERNO = getIndexOf("GOODSMASTERNO", columnValue);
			DEALERNO = getIndexOf("DEALERNOSTR", columnValue);
			
			this.pstmt_con = pstmt_con;
			this.fieldName = fieldName;
		}
	
		public String mapping(DbColumnValue[] value) throws SQLException {
			nowPkgPK = value[GOODSMASTERNO].getString();
			nowPkgPK_DNO = value[DEALERNO].getString();
			
			String[] check=nowPkgPK_DNO.replace("^", ",").split(",");
			
			String[] checkValue=new String[check.length];
			
			for (int i = 0; i < check.length; i++) {
				checkValue[i]=check[i];
			}
			
			PreparedStatement pstmt = null;
			ResultSet re = null;
			
			if(!nowPkgPK.equals(prePkgPK)) {
					StringBuffer buf01 = new StringBuffer();
					StringBuffer buf02 = new StringBuffer();
					StringBuffer buf03 = new StringBuffer();
					
					
					int reCnt=0;
				    pstmt = pstmt_con;
					pstmt.setArray(1, con.createArrayOf("text", checkValue)); 
					
					re = pstmt.executeQuery();
					
					while(re.next() == true){
						if(re.getString("DQ_SIDO")!=null&&!re.getString("DQ_SIDO").equals("")) {
							if(reCnt > 0&&buf01.length()>1) buf01.append("#");
								buf01.append(re.getString("DQ_SIDO"));
							
						}
						if(re.getString("DQ_SIGUNGU")!=null&&!re.getString("DQ_SIGUNGU").equals("")) {
							if(reCnt > 0&&buf02.length()>1) buf02.append("#");
							buf02.append(re.getString("DQ_SIGUNGU"));
						}
						if(re.getString("DQ_EUPMYEONDONG")!=null&&!re.getString("DQ_EUPMYEONDONG").equals("")) {
							if(reCnt > 0&&buf03.length()>1) buf03.append("#");
							buf03.append(re.getString("DQ_EUPMYEONDONG"));
						}
						reCnt ++;
						//sido =경기@서울@전국
					}
					
					SIDO=buf01.toString();
					SIGUNGU=buf02.toString();
					EUPMYEONDONG=buf03.toString();
					
				 
			}
			prePkgPK = nowPkgPK;

			//해당 스키마(컬럼)일때 위에서 미리 저장해둔 값만 return
			if(fieldName.equals("SIDO")) {
				return SIDO;
			}else if(fieldName.equals("SIGUNGU")) {
				return SIGUNGU;
			}else if(fieldName.equals("EUPMYEONDONG")) {
				return EUPMYEONDONG;
			}
			return null;
			
		}
	
	}
}





