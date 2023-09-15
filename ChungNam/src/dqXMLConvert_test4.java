
import java.io.FileOutputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
 
public class dqXMLConvert_test4 {
 
    public static void main(String[] args) {
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        
        Connection con = null;
        PreparedStatement stmt = null;
        ResultSet rs = null; //select 의 결과를 저장
        
        try {
            con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl",
                    "c##ksu","1234");
            //test1 테이블의 모든 데이터 읽어오는 sql
            stmt = con.prepareStatement("select * from test001");
            rs = stmt.executeQuery();
            
            if(rs.next()){
                do{
                    String filename = rs.getString("filename");
                    System.out.println(filename);
                    
                    InputStream is = rs.getBinaryStream("blob");
                    FileOutputStream fos = new FileOutputStream("../" +filename);
                    
                    byte[] buf = new byte[512];
                    int len;
                    while(true){
                        //is에서 buf 만큼 읽어서 buf에 저장하고
                        //읽은 갯수를 len에 저장
                        //읽지 못하면 -1을 저장
                        len = is.read(buf);
                        //읽은 데이터가 없으면 읽기 종료
                        
                        if(len<=0)
                            break;
                        //읽은 데이터가 있으면 buf에서 0부터 len만큼 fos에 저장
                        
                        fos.write(buf,0,len);
                    }
                    
                }while(rs.next());
            }
            else{//없을때
                System.out.println("데이터가 없습니당");
            }
            
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
        finally {
                //사용한 객체 close
                try {
                    if(rs != null) rs.close();
                    if(con != null) con.close();
                    if(stmt != null) stmt.close();
                    
                } catch (Exception e) {
                    
                }
            
        }
        
    }
 
}