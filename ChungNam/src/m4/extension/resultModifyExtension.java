package m4.extension;


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.diquest.ir.dbwatcher.DbWatcher;
import com.diquest.ir.dbwatcher.DbWatcherExtension;
import com.diquest.ir.dbwatcher.dbcolumn.DbColumnValue;
import com.diquest.ir.dbwatcher.mapper.FieldMapper;

public class resultModifyExtension implements DbWatcherExtension {

	/** 현재 자료관리 문서 아이디 **/
	private String nowID = "";		
	/**이전 자료관리 문서 아이디 **/
	private String preID = "";		
	
	/** 현재 처리하고 있는 row의 attach 데이터 **/
	private String file_title, file_path, file_filter, file_extension;	
	
	private String filterGubunja = "◎.¤";

	/** DB에서 정보를 가져 오기 위한 JDBC Object **/
	private DbWatcher watcher;
	private Connection con;
	private PreparedStatement pstmt;
	
	/** 첨부파일 가져오는 쿼리(SELECT 앞에 꼭 공백 넣어주기) **/
	private String query = " SELECT TITLE, PATH, CONCAT('sftp://133.186.171.33:22/',PATH) AS FILTER, EXTENSION FROM ATTACH WHERE BOARD_ID=?";
	
	@Override
	public void start(DbWatcher watcher) throws SQLException {

		SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		System.out.println("start time [" + format.format(new Date()) + "]");
		System.out.println("query [" + query + "]");
		
		this.watcher = watcher;
		this.con = null;
		this.pstmt = null;	

		try {
			con = watcher.createConnection();
			pstmt = con.prepareStatement(query);
			System.out.println(pstmt);
			
		} catch(SQLException e) {
			try {
				if(pstmt != null) pstmt.close();
				if(con != null) {
					watcher.releaseConnection(con);
					con = null;
				}
			} catch(SQLException e2) { }
			throw e;
		}
	}
	
	private static int getIndexOf(String name, DbColumnValue[] columnValue) throws SQLException {
		for(int i = 0; i < columnValue.length; i++) {
			if(name.equals(columnValue[i].getName())){
				return i;
			}
		}	
		throw new SQLException("DBWatcherExtension : " + name + " 컬럼이 SELECT되지 않았습니다.");
	}
	
	@Override
	public FieldMapper getMapper(String fieldName, DbColumnValue[] dbColumnVlue) throws SQLException {
		SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		System.out.println("[" + format.format(new Date()) + "] " + fieldName);
		
		return new NameMapperField(dbColumnVlue, pstmt, fieldName);
	}

	private class NameMapperField extends FieldMapper {
		private int id;		
		private String fieldName;

		public NameMapperField(DbColumnValue[] columnValue,PreparedStatement pstmt, String fieldName) throws SQLException {
			super(fieldName);
			id = getIndexOf("ID", columnValue);	
			this.fieldName = fieldName;
		}

		public String mapping(DbColumnValue[] dbColumnValue) throws SQLException {
				
				/** 현재와 이전을 비교하는 자료관리 문서 아이디 **/
				nowID = dbColumnValue[id].getString();

				if(!nowID.equals(preID)) {

				file_title = "";
				file_path = "";
				file_filter = ""; 
				file_extension = "";
				
				ResultSet rs = null;
				StringBuffer total_file_title = new StringBuffer();
				StringBuffer total_file_path = new StringBuffer();
				StringBuffer total_file_filter = new StringBuffer();
				StringBuffer total_file_extension = new StringBuffer();

				try {
					pstmt.setString(1, dbColumnValue[id].getString());
					rs = pstmt.executeQuery();
	
					while(rs.next()) {
						total_file_title.append(rs.getString(1)+",");		
						total_file_path.append(rs.getString(2)+",");		
						total_file_filter.append(rs.getString(3)+"\n"+filterGubunja+"\n");		
						total_file_extension.append(rs.getString(4)+",");		
					}
	
					file_title = total_file_title.toString().trim();
					file_path = total_file_path.toString().trim();
					file_filter = total_file_filter.toString().trim();
					file_extension = total_file_extension.toString().trim();

				} finally {
					try {	
						if(rs != null) rs.close();
					} catch (SQLException e) {
						
					}
				}
			}
			preID = nowID;

		if(fieldName.equals("FILE_TITLE")) {				
			return file_title;							
		
		} else if(fieldName.equals("FILE_PATH")) {		
			return file_path;							
			
		} else if(fieldName.equals("FILE_FILTER")) {		
			return file_filter;	
																
		} else if(fieldName.equals("FILE_EXTENSION")) {		
			return file_extension;			
		} 
		return null;
		}
	}

	@Override
	public void stop() throws SQLException {
		SimpleDateFormat format = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		System.out.println("end time [" + format.format(new Date()) + "]");
		if(pstmt != null) pstmt.close();
		if(con != null) {
			watcher.releaseConnection(con);
			con = null;
		}
	}
}