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
public class extension7 implements DbWatcherExtension {
	
	private String nowPkgPK = "";	
	
	
	private String prePkgPK = "";	
	
	
	private String CTGRYNOS;
	private String CTGRYNMS;
	private String DQ_CATEGORY;
	private String DQ_CATEGORY02;
	private String DQ_CATEGORY03;
	private String DQ_CATEGORY04;
	private String DQ_CATEGORY_CD;
	private String DQ_CATEGORY_NM;
	private String DQ_CATEGORY02_CD;
	private String DQ_CATEGORY02_NM;
	private String DQ_CATEGORY03_CD;
	private String DQ_CATEGORY03_NM;
	private String DQ_CATEGORY04_CD;
	private String DQ_CATEGORY04_NM;
	private String DQ_CATEGORY05_NM;
	private String DQ_CATEGORY05_CD;
	private String DQ_CATEGORY05;
	private String ITM_NO;
	private String STD_SIZE_SECT_CD;
	private String STD_SIZE_SECT_NM;
	private String STD_SIZE_CD;
	private String STD_SIZE_NM;
	private String DQ_SIZE;
	
	// DB에서 정보를 가져 오기 위한 JDBC Object
	private DbWatcher watcher;
	private Connection con;
	private PreparedStatement pstmt_con;
	private PreparedStatement pstmt_con2;
	
	private String category_query ="WITH RECURSIVE RS AS (\r\n"
			+ "    SELECT \r\n"
			+ "         DCCG.GOD_NO\r\n"
			+ "        ,DCCG.DSP_CTGRY_NO\r\n"
			+ "        ,DC.UPPER_DSP_CTGRY_NO\r\n"
			+ "        ,DC.LEAF_CTGRY_YN\r\n"
			+ "        ,DC.CTGRY_DPTH_CD\r\n"
			+ "        ,DC.DSP_CTGRY_NO::TEXT AS CTGRY_NO\r\n"
			+ "        ,DC.DSP_CTGRY_NM::TEXT AS CTGRY_NM\r\n"
			+ "        ,DC.CTGRY_SECT_CD\r\n"
			+ "    FROM PRD_SSTS.DSP_CTGRY_CNNC_GOD DCCG\r\n"
			+ "    JOIN PRD_SSTS.DSP_CTGRY DC ON DCCG.DSP_CTGRY_NO = DC.DSP_CTGRY_NO\r\n"
			+ "    JOIN PRD_SSTS.DSP_CTGRY_DSP_APL DCDA ON DC.DSP_CTGRY_NO = DCDA.DSP_CTGRY_NO AND LANG_CD = 'KOR' AND DSP_MBR_SECT_CD = 'GNRL'\r\n"
			+ "    WHERE 1 = 1    \r\n"
			+ "    AND DC.LEAF_CTGRY_YN = 'Y'\r\n"
			+ "    AND DC.DELETE_YN = 'N'\r\n"
			+ "    AND DC.DSP_YN = 'Y'\r\n"
			+ "    AND DC.APL_MALL_ID = 'SSM'\r\n"
			+ "    AND DCCG.GOD_NO = ?\r\n"
			+ "    AND DCCG.DSP_YN = 'Y'\r\n"
			+ "    AND DCCG.DELETE_YN = 'N'\r\n"
			+ "    AND DCDA.DSP_YN = 'Y'\r\n"
			+ "    UNION ALL\r\n"
			+ "    SELECT R.GOD_NO\r\n"
			+ "      ,CTG.DSP_CTGRY_NO\r\n"
			+ "      ,CTG.UPPER_DSP_CTGRY_NO\r\n"
			+ "      ,CTG.LEAF_CTGRY_YN\r\n"
			+ "      ,CTG.CTGRY_DPTH_CD\r\n"
			+ "      ,CTG.DSP_CTGRY_NO::TEXT||'%%'||R.CTGRY_NO::TEXT AS CTGRY_NO\r\n"
			+ "      ,CTG.DSP_CTGRY_NM::TEXT||'%%'||R.CTGRY_NM::TEXT AS CTGRY_NM\r\n"
			+ "      ,CTG.CTGRY_SECT_CD\r\n"
			+ "    FROM PRD_SSTS.DSP_CTGRY CTG\r\n"
			+ "          JOIN RS R ON (R.UPPER_DSP_CTGRY_NO = CTG.DSP_CTGRY_NO)\r\n"
			+ "    WHERE 1 = 1\r\n"
			+ "    AND CTG.DSP_CTGRY_NO LIKE 'SSM%'\r\n"
			+ "    AND CTG.SPCIFY_URL_DSP_YN = 'N'\r\n"
			+ "    AND CTG.APL_MALL_ID = 'SSM'\r\n"
			+ "    AND CTG.DELETE_YN = 'N'\r\n"
			+ "    AND CTG.DSP_YN = 'Y'\r\n"
			+ ")\r\n"
			+ "SELECT \r\n"
			+ "     CTGRY_NO AS CTGRYNOS       /* 카테고리번호 목록 */   \r\n"
			+ "    ,CTGRY_NM AS CTGRYNMS       /* 카테고리명 목록 */   \r\n"
			+ "    ,GOD_NO AS GOD_NO           /* 상품번호 목록 */  \r\n"
			+ "    ,CTGRY_SECT_CD              /* 카테고리 구분 => GNRL_CTGRY : 일반 카테고리, STRTGY_CTGRY : 전략 카테고리(2023-03-31) */\r\n"
			+ "FROM RS\r\n"
			+ "WHERE CTGRY_DPTH_CD = '1'\r\n"
			+ ";";
	
	private String size_query="SELECT\r\n"
			+ "     T.ITM_NO                       /* 단품번호 */\r\n"
			+ "    ,T.GOD_NO                       /* 상품번호 */    \r\n"
			+ "    ,T.STD_SIZE_SECT_CD             /* 표준 사이즈 구분 코드 */\r\n"
			+ "    ,T.STD_SIZE_SECT_NM             /* 표준 사이즈 구분 명 */\r\n"
			+ "    ,T.STD_SIZE_CD                  /* 표준 사이즈 코드 */\r\n"
			+ "    ,T.STD_SIZE_NM                  /* 표준 사이즈 코드 명 */    \r\n"
			+ "    ,T.SORT_SEQ1::TEXT||'^'||T.SORT_SEQ2::TEXT||'^'||T.STD_SIZE_SECT_CD::TEXT||'^'||T.STD_SIZE_SECT_NM::TEXT||'^'||T.STD_SIZE_CD::TEXT||'^'||T.STD_SIZE_NM::TEXT AS DQ_SIZE\r\n"
			+ "    ,T.SORT_SEQ1                    /* 그룹 정렬 */    \r\n"
			+ "    ,T.SORT_SEQ2                    /* 정렬 */    \r\n"
			+ "FROM (\r\n"
			+ "    SELECT \r\n"
			+ "         GI.ITM_NO                       \r\n"
			+ "        ,GI.GOD_NO                       \r\n"
			+ "        ,SG.CD AS STD_SIZE_SECT_CD    \r\n"
			+ "        ,SG.CD_NM AS STD_SIZE_SECT_NM     \r\n"
			+ "        ,SI.CD AS STD_SIZE_CD     \r\n"
			+ "        ,SI.CD_NM AS STD_SIZE_NM             \r\n"
			+ "        ,SG.SORT_SEQ AS SORT_SEQ1              \r\n"
			+ "        ,(1000+SI.SORT_SEQ) AS SORT_SEQ2                 \r\n"
			+ "    FROM prd_ssts.GOD_ITM GI\r\n"
			+ "    INNER JOIN prd_ssts.GOD G ON GI.GOD_NO = G.GOD_NO\r\n"
			+ "    INNER JOIN prd_ssts.MV_SYS_CD SG ON SG.CD = GI.STD_SIZE_SECT_CD\r\n"
			+ "    INNER JOIN prd_ssts.MV_SYS_CD SI ON SI.CD = GI.STD_SIZE_CD\r\n"
			+ "    WHERE 1 = 1\r\n"
			+ "        AND GI.ITM_STAT_CD IN ('SALE_PROGRS', 'SLDOUT','SALE_PROGRS_PKUP','TMPR_SLDOUT') \r\n"
			+ "        AND G.GOD_APRV_SECT_CD = 'APRV_COMPT'\r\n"
			+ "        AND G.DSP_YN = 'Y'\r\n"
			+ "        AND G.SPCIFY_URL_DSP_YN = 'N'\r\n"
			+ "        AND G.GOD_SALE_SECT_CD IN ('SALE_PROGRS', 'SLDOUT', 'TMPR_SLDOUT')\r\n"
			+ "        AND G.SALE_BEG_DATE <= TO_CHAR(NOW(), 'YYYYMMDD')\r\n"
			+ "        AND G.SALE_END_DATE >= TO_CHAR(NOW(), 'YYYYMMDD')\r\n"
			+ "        AND G.CVR_PRC <> 0              \r\n"
			+ "    UNION ALL\r\n"
			+ "    SELECT \r\n"
			+ "         GI.ITM_NO                          \r\n"
			+ "        ,GI.GOD_NO                          \r\n"
			+ "        ,SG.CD AS STD_SIZE_SECT_CD    \r\n"
			+ "        ,SG.CD_NM AS STD_SIZE_SECT_NM     \r\n"
			+ "        ,SI.ASSTN_CD_1 AS STD_SIZE_CD     \r\n"
			+ "        ,SI.CD_NM AS STD_SIZE_NM     \r\n"
			+ "        ,SG.SORT_SEQ AS SORT_SEQ1              \r\n"
			+ "        ,SI.SORT_SEQ AS SORT_SEQ2    \r\n"
			+ "    FROM prd_ssts.GOD_ITM GI\r\n"
			+ "    INNER JOIN prd_ssts.GOD G ON GI.GOD_NO = G.GOD_NO\r\n"
			+ "    INNER JOIN prd_ssts.MV_SYS_CD SG ON SG.CD = 'KIDS_SIZE'\r\n"
			+ "    INNER JOIN prd_ssts.MV_SYS_CD SI ON SI.UPPER_CD = 'KIDS_SIZE' AND SI.ASSTN_CD_1 = GI.OPT_VAL_CD_1  \r\n"
			+ "    WHERE 1 = 1\r\n"
			+ "        AND GI.ITM_STAT_CD IN ('SALE_PROGRS', 'SLDOUT','SALE_PROGRS_PKUP','TMPR_SLDOUT')   \r\n"
			+ "        AND GI.OPT_VAL_CD_1 IS NOT NULL \r\n"
			+ "        AND GI.OPT_VAL_CD_1 <> ''\r\n"
			+ "        AND G.STD_CTGRY_NO LIKE 'A02%'\r\n"
			+ "        AND G.GOD_APRV_SECT_CD = 'APRV_COMPT'\r\n"
			+ "        AND G.DSP_YN = 'Y'\r\n"
			+ "        AND G.SPCIFY_URL_DSP_YN = 'N'\r\n"
			+ "        AND G.GOD_SALE_SECT_CD IN ('SALE_PROGRS', 'SLDOUT', 'TMPR_SLDOUT')\r\n"
			+ "        AND G.SALE_BEG_DATE <= TO_CHAR(NOW(), 'YYYYMMDD')\r\n"
			+ "        AND G.SALE_END_DATE >= TO_CHAR(NOW(), 'YYYYMMDD')\r\n"
			+ "        AND G.CVR_PRC <> 0        \r\n"
			+ ") AS T\r\n"
			+ "WHERE 1 = 1\r\n"
			+ "AND GOD_NO = ?\r\n"
			+ "ORDER BY T.SORT_SEQ1, T.SORT_SEQ2\r\n"
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
			pstmt_con = con.prepareStatement(category_query);
			pstmt_con2 = con.prepareStatement(size_query);
			

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
		if (pstmt_con2 != null) pstmt_con2.close();

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
		private final int GOD_NO_ID;
		
		private final PreparedStatement pstmt_con;
		private final PreparedStatement pstmt_con2;
	
		private final String fieldName;
		
		public NameMapperField(DbColumnValue[] columnValue, PreparedStatement pstmt_con, PreparedStatement pstmt_con2,String fieldName) throws SQLException {
			super(fieldName);

			GOD_NO_ID = getIndexOf("GOD_NO", columnValue);
			
			this.pstmt_con = pstmt_con;
			this.pstmt_con2 = pstmt_con2;
			this.fieldName = fieldName;
		}
	
		public String mapping(DbColumnValue[] value) throws SQLException {
			nowPkgPK = value[GOD_NO_ID].getString();
			
			PreparedStatement pstmt = null;
			ResultSet re = null;
							
			if(!nowPkgPK.equals(prePkgPK)) {
				for (int i = 1; i < 3; i++) {
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
					StringBuffer buf11 = new StringBuffer();
					StringBuffer buf12 = new StringBuffer();
					StringBuffer buf13 = new StringBuffer();
					StringBuffer buf14 = new StringBuffer();
					StringBuffer buf15 = new StringBuffer();
					StringBuffer buf16 = new StringBuffer();
					StringBuffer buf17 = new StringBuffer();
					
					if(i==1) {
						pstmt = pstmt_con;
					}else if(i==2) {
						pstmt = pstmt_con2;
					}
					pstmt.setString(1, nowPkgPK); 
					re = pstmt.executeQuery();
					
					int reCnt = 0;
					while(re.next() == true){
						if(i==1) {
							String catStr="";
							String catStr_cd="";
							String catStr_nm="";
							String catStr02="";
							String catStr02_cd="";
							String catStr02_nm="";
							String catStr03="";
							String catStr03_cd="";
							String catStr03_nm="";
							String catStr04="";
							String catStr04_cd="";
							String catStr04_nm="";
							String catStr05="";
							String catStr05_cd="";
							String catStr05_nm="";
							
							String ctgry_sect_cd=re.getString("ctgry_sect_cd");
							
							String tmep="";
							
							String[] ctgrynos_tmp=re.getString("ctgrynos").split("%%");
							String[] ctgrynms_tmp=re.getString("ctgrynms").split("%%");
							
							
							
							for (int j = 0; j < ctgrynms_tmp.length; j++) {
								
								tmep=ctgrynos_tmp[j]+"^"+ctgrynms_tmp[j]+"^"+ctgry_sect_cd;
								
								if(j==0 )  {
									catStr = tmep;
									catStr_cd=ctgrynos_tmp[j];
									catStr_nm=ctgrynms_tmp[j];
									//SSMA01^여성^GNRL_CTGRY
									//SSMA01^여성$
								}
								if(j==1 ) {
									catStr02=catStr+"^"+tmep;
									catStr02_cd=ctgrynos_tmp[j];
									catStr02_nm=ctgrynms_tmp[j];
									
									//SSMA01^여성^GNRL_CTGRY$SSMA01A01^상의^GNRL_CTGRY
									//SSMA01^여성$SSMA01A01^상의$
								}
								if(j==2) {
									catStr03=catStr02+"^"+tmep;
									catStr03_cd=ctgrynos_tmp[j];
									catStr03_nm=ctgrynms_tmp[j];
									//SSMA01^여성$SSMA01A01^상의$SSMA01A01A01^티셔츠$
									//SSMA01^여성$SSMA01A01^상의$SSMA01A01A01^티셔츠$
								}
								if(j==3) {
									catStr04=catStr03+"^"+tmep;
									catStr04_cd=ctgrynos_tmp[j];
									catStr04_nm=ctgrynms_tmp[j];
									//SSMA01^여성^GNRL_CTGRYSSMA01A01^상의^GNRL_CTGRYSSMA01A01A01^티셔츠$SSMA01A01A01A02^브이넥$
									//SSMA01^여성$SSMA01A01^상의$SSMA01A01A01^티셔츠$SSMA01A01A01A02^브이넥$
								}
								if(j==4) {
									catStr05=catStr04+"^"+tmep;
									catStr05_cd=ctgrynos_tmp[j];
									catStr05_nm=ctgrynms_tmp[j];
									//SSMA01^여성^GNRL_CTGRYSSMA01A01^상의^GNRL_CTGRYSSMA01A01A01^티셔츠$SSMA01A01A01A02^브이넥$
									//SSMA01^여성$SSMA01A01^상의$SSMA01A01A01^티셔츠$SSMA01A01A01A02^브이넥$
								}
							}
							if(reCnt > 0) {
								if(buf01.toString().length()>1)buf01.append("@");
								if(buf02.toString().length()>1)buf02.append("@");
								if(buf03.toString().length()>1)buf03.append("@");
								if(buf04.toString().length()>1)buf04.append("@");
								if(buf07.toString().length()>1)buf07.append("@");
								if(buf08.toString().length()>1)buf08.append("@");
								if(buf09.toString().length()>1)buf09.append("@");
								if(buf10.toString().length()>1)buf10.append("@");
								if(buf11.toString().length()>1)buf11.append("@");
								if(buf12.toString().length()>1)buf12.append("@");
								if(buf13.toString().length()>1)buf13.append("@");
								if(buf14.toString().length()>1)buf14.append("@");
								if(buf15.toString().length()>1)buf15.append("@");
								if(buf16.toString().length()>1)buf16.append("@");
								if(buf17.toString().length()>1)buf17.append("@");
							}
							
							//SSMA01^여성$\nSSMA01^여성$
							//
//								if(catStr04.substring(0).equals("@"))catStr04 = catStr04.substring(1,catStr04.length());
//								if(catStr04_cd.substring(0).equals("@"))catStr04_cd = catStr04_cd.substring(1,catStr04_cd.length());
//								if(catStr04_nm.substring(0).equals("@"))catStr04_nm = catStr04_nm.substring(1,catStr04_nm.length());
							
								buf01.append(catStr);
								buf02.append(catStr02);
								buf03.append(catStr03);
								buf04.append(catStr04);
								buf07.append(catStr_cd);
								buf08.append(catStr_nm);
								buf09.append(catStr02_cd);
								buf10.append(catStr02_nm);
								buf11.append(catStr03_cd);
								buf12.append(catStr03_nm);
								buf13.append(catStr04_cd);
								buf14.append(catStr04_nm);
								buf15.append(catStr05);
								buf16.append(catStr05_cd);
								buf17.append(catStr05_nm);
							
							if(re.getString("ctgrynos")!=null) {
								if(reCnt > 0) buf05.append("@");
								buf05.append(re.getString("ctgrynos"));
							}
							if(re.getString("ctgrynms")!=null) {
								if(reCnt > 0) buf06.append("@");
								buf06.append(re.getString("ctgrynms"));
							}
							
							reCnt ++; 
				
						}else if(i==2) {
							
							if(re.getString("itm_no")!=null&&re.getString("itm_no").length()!=0) {
								if(reCnt > 0) buf01.append("@");
								buf01.append(re.getString("itm_no"));
							}
							if(re.getString("std_size_sect_cd")!=null&&re.getString("std_size_sect_cd").length()!=0) {
								if(reCnt > 0) buf02.append("@");
								buf02.append(re.getString("std_size_sect_cd"));
							}
							if(re.getString("std_size_sect_nm")!=null&&re.getString("std_size_sect_nm").length()!=0) {
								if(reCnt > 0) buf03.append("@");
								buf03.append(re.getString("std_size_sect_nm"));
							}
							if(re.getString("std_size_cd")!=null&&re.getString("std_size_cd").length()!=0) {
								if(reCnt > 0) buf04.append("@");
								buf04.append(re.getString("std_size_cd"));
							}
							if(re.getString("std_size_nm")!=null&&re.getString("std_size_nm").length()!=0) {
								if(reCnt > 0) buf05.append("@");
								buf05.append(re.getString("std_size_nm"));
							}
							if(re.getString("dq_size")!=null&&re.getString("dq_size").length()!=0) {
								if(reCnt > 0) buf06.append("@");
								buf06.append(re.getString("dq_size"));
							}
							reCnt ++;
						}
						
					}
					
					if(i==1) {
						DQ_CATEGORY=buf01.toString();
						DQ_CATEGORY02=buf02.toString();
						DQ_CATEGORY03=buf03.toString();
						DQ_CATEGORY04=buf04.toString();
						DQ_CATEGORY_CD=buf07.toString();
						DQ_CATEGORY_NM=buf08.toString();
						DQ_CATEGORY02_CD=buf09.toString();
						DQ_CATEGORY02_NM=buf10.toString();
						DQ_CATEGORY03_CD=buf11.toString();
						DQ_CATEGORY03_NM=buf12.toString();
						DQ_CATEGORY04_CD=buf13.toString();
						DQ_CATEGORY04_NM=buf14.toString();
						CTGRYNOS = buf05.toString();
						CTGRYNMS = buf06.toString();
						DQ_CATEGORY05=buf15.toString();
						DQ_CATEGORY05_CD=buf16.toString();
						DQ_CATEGORY05_NM=buf17.toString();
					}else if(i==2) {
						ITM_NO = buf01.toString();
						STD_SIZE_SECT_CD = buf02.toString();
						STD_SIZE_SECT_NM = buf03.toString();
						STD_SIZE_CD = buf04.toString();
						STD_SIZE_NM = buf05.toString();
						DQ_SIZE = buf06.toString();
					}
					
					
				}
				 
			}
			prePkgPK = nowPkgPK;
			

			//해당 스키마(컬럼)일때 위에서 미리 저장해둔 값만 return
			if(fieldName.equals("CTGRYNOS")) {
				return CTGRYNOS;
			}else if(fieldName.equals("CTGRYNMS")) {
				return CTGRYNMS;
			}else if(fieldName.equals("DQ_CATEGORY")) {
				return DQ_CATEGORY;
			}else if(fieldName.equals("DQ_CATEGORY02")) {
				return DQ_CATEGORY02;
			}else if(fieldName.equals("DQ_CATEGORY03")) {
				return DQ_CATEGORY03;
			}else if(fieldName.equals("DQ_CATEGORY04")) {
				return DQ_CATEGORY04;
			}else if(fieldName.equals("DQ_CATEGORY_CD")) {
				return DQ_CATEGORY_CD;
			}else if(fieldName.equals("DQ_CATEGORY_NM")) {
				return DQ_CATEGORY_NM;
			}else if(fieldName.equals("DQ_CATEGORY02_CD")) {
				return DQ_CATEGORY02_CD;
			}else if(fieldName.equals("DQ_CATEGORY02_NM")) {
				return DQ_CATEGORY02_NM;
			}else if(fieldName.equals("DQ_CATEGORY03_CD")) {
				return DQ_CATEGORY03_CD;
			}else if(fieldName.equals("DQ_CATEGORY03_NM")) {
				return DQ_CATEGORY03_NM;
			}else if(fieldName.equals("DQ_CATEGORY04_CD")) {
				return DQ_CATEGORY04_CD;
			}else if(fieldName.equals("DQ_CATEGORY04_NM")) {
				return DQ_CATEGORY04_NM;
			}else if(fieldName.equals("DQ_CATEGORY05")) {
				return DQ_CATEGORY05;
			}else if(fieldName.equals("DQ_CATEGORY05_CD")) {
				return DQ_CATEGORY05_CD;
			}else if(fieldName.equals("DQ_CATEGORY05_NM")) {
				return DQ_CATEGORY05_NM;
			}else if(fieldName.equals("ITM_NO")) {
				return ITM_NO;
			}else if(fieldName.equals("STD_SIZE_SECT_CD")) {
				return STD_SIZE_SECT_CD;
			}else if(fieldName.equals("STD_SIZE_SECT_NM")) {
				return STD_SIZE_SECT_NM;
			}else if(fieldName.equals("STD_SIZE_CD")) {
				return STD_SIZE_CD;
			}else if(fieldName.equals("STD_SIZE_NM")) {
				return STD_SIZE_NM;
			}else if(fieldName.equals("DQ_SIZE")) {
				return DQ_SIZE;
			}
			return null;
			
		}
	
	}
}





