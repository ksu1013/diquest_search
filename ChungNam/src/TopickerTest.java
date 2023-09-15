

import java.util.Map;

import com.diquest.topicker.preprocessing.TPbasicSentExtractor;
import com.diquest.topicker.preprocessing.TPbasicTermExtractor;
import com.diquest.topicker.topicker.TopicAnalyzer;

public class TopickerTest {
	
	public static void main(String[] args)  {
		//raw document
		String rawDoc="한류,넷플릭스 K드라마,일본반응,블랙핑크,손흥민,외계+인,한산 해외반응,헤어질결심,마녀2,손흥민 해외반응,마녀2 해외반응,환혼,붉은단심,파친코,브로커 해외반응,외계+인 해외반응,파친코 해외반응,나의해방일지 해외반응,우리들의블루스 해외반응,BLACKPINK reaction,KPOP reaction,BTS 해외방송,NetflixKRAMA,누리호 해외번응,Broker,HUNT,스위트홈 해외반응,BTS외신반응,해외반응,K-POP,한류반응,환혼 해외반응,한류드라마,블랙핑크 일본반응,블랙핑크 해외반응,나의아저씨,응답하라1988,무빙 해외반응,범죄도시2,한산 예고편,외계인 해외반응,왜오수재인가?,범죄도시2 해외반응,브로커 칸,사내맞선일본반응,내일,드라마 내일,왜오수재인가? 해외반응,나의해방일지,헌트,헌트해외반응,한산예고편해외반응,한산리액션,누리호일본반응,누리호중국반응,이상한변호사우영우,이상한변호사우영우해외반응";
		String jianaHome = System.getenv("IR4_HOME") + "/resources/korean/data";
		
		TPbasicSentExtractor se = new TPbasicSentExtractor();
		TPbasicTermExtractor te = new TPbasicTermExtractor(jianaHome);
		
		TopicAnalyzer ta = new TopicAnalyzer();
		//TopicAnalyzer ta = new TopicAnalyzer("./data/tr_stopword.UTF8");
	
		if(ta.doAnalysis(rawDoc,se,te)) {
			//문서내 주요 단어
			System.out.println("------------k words------------");			
			for(Map.Entry<String,Double> item: ta.getKWordRankMap("80%").entrySet()) {
				System.out.println(item.getValue() + " " + item.getKey());
			}
			
			//문서내 주요 문장 (원래문장 순서대로 정렬)				
			System.out.println("\n------------k-sentences with original order------------");			
			for(Map.Entry<String,Double> item: ta.getKSentRankMap("4", true).entrySet()) {
				System.out.println(item.getValue() + " " + item.getKey());
			}
			
			//문서내 주요 문장  (score순 정렬)
			System.out.println("\n------------k-sentences with socore order------------");			
			for(Map.Entry<String,Double> item: ta.getKSentRankMap("4", false).entrySet()) {
				System.out.println(item.getValue() + " " + item.getKey());
			}
		}
	}
}