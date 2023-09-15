

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
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
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.TimeUnit;
import java.util.regex.Matcher; 
import java.util.regex.Pattern;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;


import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.mysql.jdbc.Blob;

public class dqXMLConvert_test2 {
	static ArrayList<String> arr = null;
	static Connection conn = null;
	static Statement stmt = null;
	static PreparedStatement pstmt = null;
	static ResultSet rs = null;

	/* DB접속 */
//	static String inputDir = "C:\\Users\\Dell\\Desktop\\프로젝트\\삼성증권\\test\\";
//	static String db_url = "jdbc:mysql://127.0.0.1:3306/test001?useUnicode=true&amp;characterEncoding=euckr&amp;characterSetResults=euckr";
//	static String db_user = "root";
//	static String db_pw = "ksu1013";
//	static String db_driver = "org.gjt.mm.mysql.Driver";
	
	static String db_url = "jdbc:oracle:thin:@localhost:1521:orcl";
	static String db_user = "c##ksu";
	static String db_pw = "1234";
	static String db_driver = "oracle.jdbc.driver.OracleDriver";
	
	static String filename =null;
	static Blob blob =null;
	
	/* DISA */
	
	
	
	public static void main(String[] args) throws IOException {

	
		assignData();
		

	
	
	}
	
	public static byte[] assignData() throws IOException {
		
		//disa.init(DISA_DCD_DIR, PLOT_DCD_DIR, JIANA_DCD_DIR, category);
		byte[] returnValue =null;
		ByteArrayOutputStream baos=null;
		FileInputStream fis=null;
		//String inputDir = "C:\\Users\\Dell\\Desktop\\프로젝트\\삼성증권\\test\\test001.txt";
		
		try {
			Class.forName(db_driver);
			conn = DriverManager.getConnection(db_url, db_user, db_pw);
			conn.setAutoCommit(true);
			
		//	baos =new ByteArrayOutputStream();
			//fis = new FileInputStream(inputDir);
			
//			byte[] buf=new byte[1024];
//			int read =0;
//			while ((read=fis.read(buf, 0, buf.length)) != -1) {
//				baos.write(buf, 0, read);
//			}
//			returnValue = baos.toByteArray();
//		
			//String data = new String(returnValue);
			//System.out.println(data);
			
			//Blob blob = connection.createBlob();
			
			
//			Blob blob = (Blob) conn.createBlob();
//			
//			blob.setBytes(1, returnValue);
//			
			
			
			//System.out.println(blob);
			
			String[] filename= {"DB 정보 요청_미래엔아카이브_20220509.xls","미래엔_검색어 입력 UI.pptx","인기검색어 가이드.docx","초성_한영변환_오탈자 검색 가이드.docx"};
			
			for (int i = 0; i < filename.length; i++) {
				insertDB(i,filename[i]);	
			}
			
			
				
		} catch (Exception e) {
			System.out.println(e);
		} finally {
			try {
				// DBClose 클래스 안쓰고 만들기 ( Statement일때 )
				if (stmt != null) { // 값이 들어가 있음
					stmt.close(); // statement 닫음
				}
				if (conn != null) { // 디비 연결되어 있음
					conn.close(); // connection닫아
				}
				if (baos != null) { // 디비 연결되어 있음
					baos.close(); // connection닫아
				}
				if (fis != null) { // 디비 연결되어 있음
					fis.close(); // connection닫아
				}
				//disa.fine();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return null;
	}
	
	private static void insertDB(int i, String filename) throws FileNotFoundException {
		String inputDir = "C:\\Users\\Dell\\Desktop\\프로젝트\\삼성증권\\test\\";
		String kk=Integer.toString(i);
		
		try {
			pstmt = conn.prepareStatement("insert into test001_2 values('"+kk+"','"+filename+"',?,'aaa')");
			//File f = new File(inputDir);    
			
			File f = new File(inputDir+filename);    
            FileInputStream fis = new FileInputStream(f);
			pstmt.setBinaryStream(1, fis,(int)f.length());
			
	            int rownum = pstmt.executeUpdate();
	            
	            if(rownum >0){
	                System.out.println("삽입성공");
	            }else
	            {
	                System.out.println("실패");
	            }
	
		} catch (SQLException e) {
			e.printStackTrace();
			System.out.println("["+e.getErrorCode()+"] " + e); 
		} 
	}
//	private static void insertDB(String filename, byte[] returnValue) {
//		System.out.println("확인>>>>>>>>>>>");
//		// Process 테이블 상태만 STATE2 
//		//INSERT INTO chungnam.test001(pk, filename, `blob`)VALUES('', '', ?)
//		String sql = "insert into chungnam.test001 (pk,filename,'blob') VALUES ('1','"+filename+"',"+returnValue+")";
//		//sql = sql.toLowerCase();
//		//System.out.println("[INSERT sql ] " + sql);
//		try {
//			System.out.println("sql>>>>>>"+sql);
//			stmt = conn.createStatement();
//			stmt.executeUpdate(sql);
//			//xmlRowCount++;
//		} catch (SQLException e) {
//			e.printStackTrace();
//			System.out.println("["+e.getErrorCode()+"] " + e); 
//		} 
//	}
	
	
}
