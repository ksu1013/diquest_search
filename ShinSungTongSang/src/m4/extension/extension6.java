package m4.extension;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.diquest.ir.dbwatcher.DbWatcher;
import com.diquest.ir.dbwatcher.DbWatcherExtension;
import com.diquest.ir.dbwatcher.dbcolumn.DbColumnValue;
import com.diquest.ir.dbwatcher.mapper.FieldMapper;

//단위테스트용 ssts 스키마 사용
public class extension6 implements DbWatcherExtension {
	
	private String nowPkgPK = "";	
	
	private String prePkgPK = "";	
	
	private String BRND_ID;
	private String BRND_NM;
	private String BRND_IMG_FILE_NM;
	private String BRND_IMG_FILE_URL;
	private String BRND_IMG_ALTRTV_CONT;
	private String DSP_CTGRY_NO;
	private String CTGRY_OUTPT_TP_CD;
	private String OUTPT_SECT_CD;
	private String OUTPT_LINK_URL;
	private String DQ_BRAND;
	
	// DB에서 정보를 가져 오기 위한 JDBC Object
	private DbWatcher watcher;
	private Connection con;
	private PreparedStatement pstmt_con;
	private PreparedStatement pstmt_con2;
	
	private String pln_query ="SELECT \r\n"
			+ "     T3.BRND_ID                 /* 브랜드 ID */\r\n"
			+ "    ,T3.BRND_NM                 /* 브랜드명 */\r\n"
			+ "    ,T4.BRND_IMG_FILE_NM        /* 브랜드 이미지명 */    \r\n"
			+ "    ,T4.BRND_IMG_FILE_URL       /* 브랜드 이미지URL */\r\n"
			+ "    ,T4.BRND_IMG_ALTRTV_CONT    /* 브랜드 이미지 대체 내용 */    \r\n"
			+ "    ,T6.DSP_CTGRY_NO            /* 브랜드 카테고리 번호 */    \r\n"
			+ "    ,T6.CTGRY_OUTPT_TP_CD       /* 카테고리 출력 유형 코드 => TH_WIN : 본창 , NEW_WIN : 새창 , POPUP : 팝업 */    \r\n"
			+ "    ,T6.OUTPT_SECT_CD           /* 브랜드 카테고리 출력 구분 코드 => GNRL : 일반 , LINK : 링크 */\r\n"
			+ "    ,T6.OUTPT_LINK_URL          /* 브랜드 카테고리 출력 링크 URL */\r\n"
			+ "    ,T3.BRND_ID::TEXT || '^' || T3.BRND_NM::TEXT AS DQ_BRAND\r\n"
			+ "FROM PERM_SSTS.DSP_PROMT T1\r\n"
			+ "JOIN PERM_SSTS.DSP_PROMT_BRND T2 ON T1.PROMT_SN = T2.PROMT_SN\r\n"
			+ "JOIN PERM_SSTS.SYS_BRND T3 ON T2.BRND_ID = T3.BRND_ID\r\n"
			+ "LEFT OUTER JOIN PERM_SSTS.SYS_BRND_IMG T4 ON T3.BRND_ID = T4.BRND_ID AND T4.BRND_IMG_SECT_CD = 'BRND_LOGO_MO_IMG'\r\n"
			+ "LEFT OUTER JOIN PERM_SSTS.DSP_CTGRY T6 ON T3.BRND_ID = T6.DSP_BRND_ID\r\n"
			+ "WHERE 1 = 1\r\n"
			+ "AND T1.PROMT_SN = ?\r\n"
			+ "ORDER BY T3.SORT_SEQ, T3.BRND_NM\r\n"
			+ ";";
	
	private String ent_query="SELECT \r\n"
			+ "     T3.BRND_ID                 /* 브랜드 ID */\r\n"
			+ "    ,T3.BRND_NM                 /* 브랜드명 */\r\n"
			+ "    ,T4.BRND_IMG_FILE_NM        /* 브랜드 이미지명 */    \r\n"
			+ "    ,T4.BRND_IMG_FILE_URL       /* 브랜드 이미지URL */\r\n"
			+ "    ,T4.BRND_IMG_ALTRTV_CONT    /* 브랜드 이미지 대체 내용 */    \r\n"
			+ "    ,T6.DSP_CTGRY_NO            /* 브랜드 카테고리 번호 */    \r\n"
			+ "    ,T6.CTGRY_OUTPT_TP_CD       /* 카테고리 출력 유형 코드 => TH_WIN : 본창 , NEW_WIN : 새창 , POPUP : 팝업 */    \r\n"
			+ "    ,T6.OUTPT_SECT_CD           /* 브랜드 카테고리 출력 구분 코드 => GNRL : 일반 , LINK : 링크 */\r\n"
			+ "    ,T6.OUTPT_LINK_URL          /* 브랜드 카테고리 출력 링크 URL */\r\n"
			+ "	   ,T3.BRND_ID::TEXT || '^' || T3.BRND_NM::TEXT AS DQ_BRAND\r\n"
			+ "FROM PERM_SSTS.EVT T1\r\n"
			+ "JOIN PERM_SSTS.EVT_BRND T2 ON T1.EVT_NO = T2.EVT_NO\r\n"
			+ "JOIN PERM_SSTS.SYS_BRND T3 ON T2.BRND_ID = T3.BRND_ID\r\n"
			+ "LEFT OUTER JOIN PERM_SSTS.SYS_BRND_IMG T4 ON T3.BRND_ID = T4.BRND_ID AND T4.BRND_IMG_SECT_CD = 'BRND_LOGO_MO_IMG'\r\n"
			+ "LEFT OUTER JOIN PERM_SSTS.DSP_CTGRY T6 ON T3.BRND_ID = T6.DSP_BRND_ID\r\n"
			+ "WHERE 1 = 1\r\n"
			+ "AND T1.EVT_NO = ?\r\n"
			+ "ORDER BY T3.SORT_SEQ, T3.BRND_NM\r\n"
			+ ";";
	@Override
	public void start(DbWatcher watcher) throws SQLException {
		// TODO Auto-generated method stub
		this.watcher = watcher;
		this.con = null;
		this.pstmt_con = null;
		this.pstmt_con2 = null;

		try {
			con = watcher.createConnection();
			pstmt_con = con.prepareStatement(pln_query);
			pstmt_con2 = con.prepareStatement(ent_query);
			

		} catch (SQLException e) {
			try {
				if (pstmt_con != null) pstmt_con.close();
				if (pstmt_con2 != null) pstmt_con2.close();

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
		if (pstmt_con2 != null) pstmt_con.close();

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
		return new NameMapperField(columnValue, pstmt_con,pstmt_con2, fieldName);
	}

	private class NameMapperField extends FieldMapper {
		private final int PROMT_SN_ID;
		
		private final PreparedStatement pstmt_con;
		private final PreparedStatement pstmt_con2;
	
		private final String fieldName;
		
		public NameMapperField(DbColumnValue[] columnValue, PreparedStatement pstmt_con, PreparedStatement pstmt_con2, String fieldName) throws SQLException {
			super(fieldName);

			PROMT_SN_ID = getIndexOf("PROMT_SN", columnValue);
			//System.out.println("[PROMT_SN_ID] : "+PROMT_SN_ID);
			
			this.pstmt_con = pstmt_con;
			this.pstmt_con2 = pstmt_con2;
			this.fieldName = fieldName;
		}
	
		public String mapping(DbColumnValue[] value) throws SQLException {
			String nowPkgPK3="";
			int nowPkgPK2=0;
			
			nowPkgPK = value[PROMT_SN_ID].getString();
			
			//System.out.println("[nowPkgPK] : "+nowPkgPK);
			
			
			if(nowPkgPK.contains("EV")) {
				nowPkgPK3=nowPkgPK;
			}else {
				nowPkgPK2=Integer.parseInt(nowPkgPK);
			}
			
			
			PreparedStatement pstmt = null;
			ResultSet re = null;
							
			if(!nowPkgPK.equals(prePkgPK)) {
				StringBuffer buf01 = new StringBuffer();
				StringBuffer buf02 = new StringBuffer();
				StringBuffer buf03 = new StringBuffer();
				StringBuffer buf04 = new StringBuffer();
				StringBuffer buf05 = new StringBuffer();
				StringBuffer buf06 = new StringBuffer();
				StringBuffer buf07 = new StringBuffer();
				StringBuffer buf08 = new StringBuffer();
				StringBuffer buf09 = new StringBuffer();
				StringBuffer buf10 = new StringBuffer();
				for (int i = 1; i < 3; i++) {
					if(i==1) {
						pstmt = pstmt_con;
						pstmt.setInt(1, nowPkgPK2);
					}else if(i==2) {
						pstmt = pstmt_con2;
						pstmt.setString(1, nowPkgPK3);
					}
					
					 
					re = pstmt.executeQuery();
					
					int reCnt = 0;
					
					while(re.next() == true){
							if(re.getString("brnd_id")!=null&&re.getString("brnd_id").length()!=0) {
								if(reCnt > 0) buf01.append("@");
								buf01.append(re.getString("brnd_id"));
							}else  {
								if(reCnt > 0) buf01.append("@");
								buf01.append("***");
							}
							if(re.getString("brnd_nm")!=null&&re.getString("brnd_nm").length()!=0) {
								if(reCnt > 0) buf02.append("@");
								buf02.append(re.getString("brnd_nm"));
							}else  {
								if(reCnt > 0) buf02.append("@");
								buf02.append("***");
							}
							if(re.getString("brnd_img_file_nm")!=null&&re.getString("brnd_img_file_nm").length()!=0) {
								if(reCnt > 0) buf03.append("@");
								buf03.append(re.getString("brnd_img_file_nm"));
							}else  {
								if(reCnt > 0) buf03.append("@");
								buf03.append("***");
							}
							if(re.getString("brnd_img_file_url")!=null&&re.getString("brnd_img_file_url").length()!=0) {
								if(reCnt > 0) buf04.append("@");
								buf04.append(re.getString("brnd_img_file_url"));
							}else  {
								if(reCnt > 0) buf04.append("@");
								buf04.append("***");
							}
							if(re.getString("brnd_img_altrtv_cont")!=null&&re.getString("brnd_img_altrtv_cont").length()!=0) {
								if(reCnt > 0) buf05.append("@");
								buf05.append(re.getString("brnd_img_altrtv_cont"));
							}else  {
								if(reCnt > 0) buf05.append("@");
								buf05.append("***");
							}
							if(re.getString("dsp_ctgry_no")!=null&&re.getString("dsp_ctgry_no").length()!=0) {
								if(reCnt > 0) buf06.append("@");
								buf06.append(re.getString("dsp_ctgry_no"));
							}else  {
								if(reCnt > 0) buf06.append("@");
								buf06.append("***");
							}
							if(re.getString("ctgry_outpt_tp_cd")!=null&&re.getString("ctgry_outpt_tp_cd").length()!=0) {
								if(reCnt > 0) buf07.append("@");
								buf07.append(re.getString("ctgry_outpt_tp_cd"));
							}else  {
								if(reCnt > 0) buf07.append("@");
								buf07.append("***");
							}
							if(re.getString("outpt_sect_cd")!=null&&re.getString("outpt_sect_cd").length()!=0) {
								if(reCnt > 0) buf08.append("@");
								buf08.append(re.getString("outpt_sect_cd"));
							}else  {
								if(reCnt > 0) buf08.append("@");
								buf08.append("***");
							}
							if(re.getString("outpt_link_url")!=null&&re.getString("outpt_link_url").length()!=0) {
								if(reCnt > 0) buf09.append("@");
								buf09.append(re.getString("outpt_link_url"));
							}else  {
								if(reCnt > 0) buf09.append("@");
								buf09.append("***");
							}
							if(re.getString("dq_brand")!=null&&re.getString("dq_brand").length()!=0) {
								if(reCnt > 0) buf10.append("@");
								buf10.append(re.getString("dq_brand"));
							}else  {
								if(reCnt > 0) buf10.append("@");
								buf10.append("***");
							}
							reCnt ++; 
					}	
						
						BRND_ID=buf01.toString();
						BRND_NM=buf02.toString();
						BRND_IMG_FILE_NM=buf03.toString();
						BRND_IMG_FILE_URL=buf04.toString();
						BRND_IMG_ALTRTV_CONT=buf05.toString();
						DSP_CTGRY_NO=buf06.toString();
						CTGRY_OUTPT_TP_CD=buf07.toString();
						OUTPT_SECT_CD=buf08.toString();
						OUTPT_LINK_URL=buf09.toString();
						DQ_BRAND=buf10.toString();
				}
				 
			}
			prePkgPK = nowPkgPK;
			
			//해당 스키마(컬럼)일때 위에서 미리 저장해둔 값만 return
			if(fieldName.equals("BRND_ID")) {
				return BRND_ID;
			}else if(fieldName.equals("BRND_NM")) {
				return BRND_NM;
			}else if(fieldName.equals("BRND_IMG_FILE_NM")) {
				return BRND_IMG_FILE_NM;
			}else if(fieldName.equals("BRND_IMG_FILE_URL")) {
				return BRND_IMG_FILE_URL;
			}else if(fieldName.equals("BRND_IMG_ALTRTV_CONT")) {
				return BRND_IMG_ALTRTV_CONT;
			}else if(fieldName.equals("DSP_CTGRY_NO")) {
				return DSP_CTGRY_NO;
			}else if(fieldName.equals("CTGRY_OUTPT_TP_CD")) {
				return CTGRY_OUTPT_TP_CD;
			}else if(fieldName.equals("OUTPT_SECT_CD")) {
				return OUTPT_SECT_CD;
			}else if(fieldName.equals("OUTPT_LINK_URL")) {
				return OUTPT_LINK_URL;
			}else if(fieldName.equals("DQ_BRAND")) {
				
				return DQ_BRAND;
			}
			return null;
			
		}
	
	}
}





