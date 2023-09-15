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

public class FileExtension implements DbWatcherExtension {
	
	private String nowPkgPK = "";	
	private String nowPkgPK2 = "";	
	
	private int recordNum = 0;
	private String prePkgPK = "";	
	private String prePkgPK2 = "";	
	
	private String FILE_NM_1,FILE_NM_2,FILE_NM_3,FILE_NM_4,FILE_NM_5,
	FILE_CONTENT_1,FILE_CONTENT_2,FILE_CONTENT_3,FILE_CONTENT_4,FILE_CONTENT_5,FILE_PT_1,FILE_PT_2,FILE_PT_3,FILE_PT_4;
	
	// DB에서 정보를 가져 오기 위한 JDBC Object
	private DbWatcher watcher;
	private Connection con;
	private PreparedStatement pstmt_con;
	
	 String get_query = " select * from TEST002 where PK2=?";
	
	
	@Override
	public void start(DbWatcher watcher) throws SQLException {
		// TODO Auto-generated method stub
		this.watcher = watcher;
		this.con = null;
		this.pstmt_con = null;

		try {
			con = watcher.createConnection();
			pstmt_con = con.prepareStatement(get_query);
			

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
		return new NameMapperField(columnValue, pstmt_con, fieldName);
	}

	private class NameMapperField extends FieldMapper {
		private final int BOARD_ID;
	//	private final int NTT_SN;

		private final PreparedStatement pstmt_con;
	
		private final String fieldName;
		
		public NameMapperField(DbColumnValue[] columnValue, PreparedStatement pstmt_con,  String fieldName) throws SQLException {
			super(fieldName);
			
			BOARD_ID = getIndexOf("PK2", columnValue);
			
			  // NTT_SN = getIndexOf("NTT_SN", columnValue); 
				System.out.println("PK2 = "+BOARD_ID);
			// System.out.println("NTT_SN = "+NTT_SN);
			 
			this.pstmt_con = pstmt_con;
			this.fieldName = fieldName;
		}
	
		public String mapping(DbColumnValue[] value) throws SQLException {
			
			
			 nowPkgPK = value[getIndexOf("PK2", value)].getString(); 
			 
			  
			 
			

			PreparedStatement pstmt = null;
			ResultSet re = null;
							
			

			
			
			if(!nowPkgPK.equals(prePkgPK)) {
				//recordNum++;
			//System.out.println("****************"+pstmt);
				for (int i = 0; i < 1; i++) {
					StringBuffer file_nm_1 = new StringBuffer();
					StringBuffer file_nm_2 = new StringBuffer();
					StringBuffer file_nm_3 = new StringBuffer();
					StringBuffer file_nm_4 = new StringBuffer();
					
					StringBuffer file_path_1 = new StringBuffer();
					StringBuffer file_path_2 = new StringBuffer();
					StringBuffer file_path_3 = new StringBuffer();
					StringBuffer file_path_4 = new StringBuffer();
					
					StringBuffer file_path_pt_1 = new StringBuffer();
					StringBuffer file_path_pt_2 = new StringBuffer();
					StringBuffer file_path_pt_3 = new StringBuffer();
					StringBuffer file_path_pt_4 = new StringBuffer();
					
					pstmt = pstmt_con;
					
					
					pstmt.setString(1, nowPkgPK); 
					 
					
					re = pstmt.executeQuery();
					
					int tempCnt =0;
					
					while(re.next() == true){
						
						//if(!nowPkgPK2.equals(prePkgPK2)) {
							if(tempCnt==0)  {
								//System.out.println("re.getString(\"PK\")1>>>>"+re.getString("PK"));
								if(re.getString("FILENAME")!=null) {
									file_nm_1.append(re.getString("FILENAME"));
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_1.append(re.getString("FILEPATH"));
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_pt_1.append(re.getString("FILEPATH"));
								}
							}else if(tempCnt==1){
								//System.out.println("re.getString(\"PK\")2>>>>>>"+re.getString("PK"));
								if(re.getString("FILENAME")!=null) {
									file_nm_2.append(re.getString("FILENAME"));
								//	System.out.println("file_nm_2>>>>>"+file_nm_2);
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_2.append(re.getString("FILEPATH"));
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_pt_2.append(re.getString("FILEPATH"));
								}
							}else if(tempCnt==2){
								//System.out.println("re.getString(\"PK\")3>>>>>>"+re.getString("PK"));
								if(re.getString("FILENAME")!=null) {
									file_nm_3.append(re.getString("FILENAME"));
								//	System.out.println("file_nm_3>>>>>"+file_nm_3);
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_3.append(re.getString("FILEPATH"));
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_pt_3.append(re.getString("FILEPATH"));
								}
							}else if(tempCnt==3){
								//System.out.println("re.getString(\"PK\")4>>>>>>>"+re.getString("PK"));
								if(re.getString("FILENAME")!=null) {
									file_nm_4.append(re.getString("FILENAME"));
								//	System.out.println("file_nm_4>>>>>"+file_nm_4);
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_4.append(re.getString("FILEPATH"));
								}
								if(re.getString("FILEPATH")!=null) {
									file_path_pt_4.append(re.getString("FILEPATH"));
								}
							}
						tempCnt++;
						//prePkgPK2 = nowPkgPK2;
						
						
					}	
					FILE_NM_1 = file_nm_1.toString();
					FILE_NM_2 = file_nm_2.toString();
					FILE_NM_3 = file_nm_3.toString();
					FILE_NM_4 = file_nm_4.toString();
					
					
					FILE_CONTENT_1 = file_path_1.toString();
					FILE_CONTENT_2 = file_path_2.toString();
					FILE_CONTENT_3 = file_path_3.toString();
					FILE_CONTENT_4 = file_path_4.toString();
					
					FILE_PT_1 = file_path_pt_1.toString();
					FILE_PT_2 = file_path_pt_2.toString();
					FILE_PT_3 = file_path_pt_3.toString();
					FILE_PT_4 = file_path_pt_4.toString();
					
					
					
					
				}
				 
			}
				prePkgPK = nowPkgPK;
				
	
				//해당 스키마(컬럼)일때 위에서 미리 저장해둔 값만 return
				if(fieldName.equals("FILR_NM_1")) {
					return FILE_NM_1.toString();
				}else if(fieldName.equals("FILR_NM_2")) {
					return FILE_NM_2.toString();
				}else if(fieldName.equals("FILR_NM_3")) {
					return FILE_NM_3.toString();
				}else if(fieldName.equals("FILR_NM_4")) {
					return FILE_NM_4.toString();
				}else if(fieldName.equals("ATTACH_CON_1")) {
					return FILE_CONTENT_1.toString();
				}else if(fieldName.equals("ATTACH_CON_2")) {
					return FILE_CONTENT_2.toString();
				}else if(fieldName.equals("ATTACH_CON_3")) {
					return FILE_CONTENT_3.toString();
				}else if(fieldName.equals("ATTACH_CON_4")) {
					return FILE_CONTENT_4.toString();
				}else if(fieldName.equals("FILE_PT_1")) {
					return FILE_PT_1.toString();
				}else if(fieldName.equals("FILE_PT_2")) {
					return FILE_PT_2.toString();
				}else if(fieldName.equals("FILE_PT_3")) {
					return FILE_PT_3.toString();
				}else if(fieldName.equals("FILE_PT_4")) {
					return FILE_PT_4.toString();
				}
				return null;
			
		}
	
	}
}





