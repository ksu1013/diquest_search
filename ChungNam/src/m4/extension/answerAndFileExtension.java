package m4.extension;



import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;

import com.diquest.ir.dbwatcher.DbWatcher;
import com.diquest.ir.dbwatcher.DbWatcherExtension;
import com.diquest.ir.dbwatcher.dbcolumn.DbColumnValue;
import com.diquest.ir.dbwatcher.mapper.FieldMapper;

// implements DBException interface
public class answerAndFileExtension implements DbWatcherExtension {
	private int recordNum = 0;
	private String prePkgPK = "";	// 이전PK
	private String nowPkgPK = "";	// 현재PK
	private String nowPkgPK2 = "";	// 현재PK

	// 현재 처리하고 있는 row의 attach 데이터
	private String nobd_ansr_cntn, file_nm, file_cntn;
	
	// DB에서 정보를 가져오기 위한 JDBC Object
	private DbWatcher watcher;
	private Connection conn;
	private PreparedStatement pstmt_pho1;
	private PreparedStatement pstmt_pho2;
	private PreparedStatement pstmt_pho3;
	
	// 
	private String getQuery1 = " select * from test001 where PK=? and PK2=?";		// 첨부파일
	//private String getQuery2 = "select * from test001_1 where PK2=?";		// 첨부파일
	//private String getQuery3 = "select * from test001_2 where PK2=?";		// 첨부파일
	
	public void start(DbWatcher watcher) throws SQLException {
		SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		this.watcher = watcher;
		this.conn = null;
		this.pstmt_pho1 = null;
		this.pstmt_pho2 = null;
		this.pstmt_pho3 = null;
		
		try {
			conn = watcher.createConnection();
			pstmt_pho1 = conn.prepareStatement(getQuery1);
			//pstmt_pho2 = conn.prepareStatement(getQuery2);
			//pstmt_pho3 = conn.prepareStatement(getQuery3);
		
		} catch(SQLException e) {
			try {
				if(pstmt_pho1 != null) pstmt_pho1.close();
				if(pstmt_pho2 != null) pstmt_pho2.close();
				if(pstmt_pho3 != null) pstmt_pho3.close();
				if(conn != null) {
					watcher.releaseConnection(conn);
					conn = null;
				}
			
			} catch(SQLException e2) {
				
			}
			
			throw e;
		}
	}
		
	public void stop() throws SQLException {
		SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		if(pstmt_pho1 != null) pstmt_pho1.close();
		//if(pstmt_pho2 != null) pstmt_pho2.close();
		//if(pstmt_pho3 != null) pstmt_pho3.close();
		if(conn != null) {
			watcher.releaseConnection(conn);
			conn = null;
		}
	}
	
	private static int getIndexOf(String name, DbColumnValue[] columnValue) throws SQLException {
		for(int i = 0; i < columnValue.length; i++) {
			if(name.equals(columnValue[i].getName())) {
				return i;
			}
		}
		
		throw new SQLException("DBWatcherExtension: " + name + "컬럼이 SELECT 되지 않았습니다.");
	}
	
	public FieldMapper getMapper(String fieldName, DbColumnValue[] columnValue) throws SQLException {
		return new NameMapperField(columnValue, pstmt_pho1, pstmt_pho2,pstmt_pho3, fieldName);
	}
	
	private class NameMapperField extends FieldMapper {
		private final int pk;		// DQID
		private final int pk2;		// DQID
		private final PreparedStatement pstmt_pho1;
		//private final PreparedStatement pstmt_pho2;
		//private final PreparedStatement pstmt_pho3;
		private final String fieldName;
		
		public NameMapperField(DbColumnValue[] columnValue, PreparedStatement pstmt_pho1, PreparedStatement pstmt_pho2,PreparedStatement pstmt_pho3, String fieldName) throws SQLException {
			super(fieldName);
			//DQ_ID = getIndexOf("NOBD_ID", columnValue);
			pk = getIndexOf("PK", columnValue);
			pk2 = getIndexOf("PK2", columnValue);
			
			//System.out.println("pk>>>>>>>"+pk);
			
			this.pstmt_pho1 = pstmt_pho1;
			//this.pstmt_pho2 = pstmt_pho2;
			//this.pstmt_pho3 = pstmt_pho3;
			this.fieldName = fieldName;
		}
		
		public String mapping(DbColumnValue[] value) throws SQLException {
			nowPkgPK = value[pk].getString();
			nowPkgPK2 = value[pk2].getString();
			
			if(!nowPkgPK.equals(prePkgPK)) {
				file_nm = "";
				file_cntn = "";
				
				PreparedStatement pstmt = null;
				ResultSet re = null;
				
				// 첨부파일 가져오는 쿼리(getQuery)가 2개 이상일 때 쓰임
				//for(int ii = 1; ii < 4; ii++) {
					StringBuffer buf01 = new StringBuffer();
					StringBuffer buf02 = new StringBuffer();
					
					try {
						//if(ii==1)
							pstmt = pstmt_pho1;
						//if(ii==2)pstmt = pstmt_pho2;
						//if(ii==3)pstmt = pstmt_pho3;
						
						pstmt.setString(1, value[pk].getString());
						re = pstmt.executeQuery();
						
						while(re.next() == true) {
							
							
								buf01.append(re.getString("FILENAME")).append(" ");
								String filePath = "C:\\mariner4\\fileDownlod\\" + re.getString("FILENAME");	// 경로에 파일 저장
								System.out.println("filePath>>>>>>"+filePath);
								Blob blob = re.getBlob("BLOB");
								InputStream inputStream = blob.getBinaryStream();
								OutputStream outputStream;
								try {
									outputStream = new FileOutputStream(filePath);
									StringBuffer sb = new StringBuffer();
									int bytesRead = -1;
									byte[] buffer = new byte[4096];
									while((bytesRead = inputStream.read(buffer)) != -1) {
										outputStream.write(buffer, 0, bytesRead);
										sb.append(new String(buffer, 0, bytesRead, "EUC-KR"));
									}
									
									inputStream.close();
									outputStream.close();
									System.out.println("FILE SAVE: [" + filePath + "]");
									
								} catch(Exception e) {
									e.printStackTrace();
									System.out.println("FILE SAVE FAIL: [" + filePath + "]");
								}
								
								buf02.append(filePath).append("\n");	// 수집 시 줄 바꿈
							
						}
						
					file_nm = buf01.toString();
					file_cntn = buf02.toString();
										
					} finally {
						try {
							if(re != null) re.close();
						} catch(SQLException e) {
							
						}
					}
				//}		// for문의 끝
			}
			
			prePkgPK = nowPkgPK;
			if(fieldName.equals("FILENAME")) {
				return file_nm;
			
			} else if(fieldName.equals("BLOB")) {
				return file_cntn;
			}
			
			return null;
		}
	}		
}