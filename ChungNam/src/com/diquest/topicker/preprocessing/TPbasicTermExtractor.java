package com.diquest.topicker.preprocessing;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.diquest.jiana.morph.CottonBuffer;
import com.diquest.jiana.morph.JianaConst;
import com.diquest.jiana.morph.JianaCotton;
import com.diquest.topicker.topicker.TopicAnalyzer;




public class TPbasicTermExtractor implements TPtermExtractor{
	
	private String jianaHome = "C:\\mariner4\\resources\\korean\\data";
	
	private JianaCotton jianacotton;

	public String getJianaHome() {return jianaHome;}
	public void setJianaHome(String jianaHome) {this.jianaHome = jianaHome;}

	//initializer
	@Override
	public void init() {
		this.jianacotton = new JianaCotton();
		this.jianacotton.init2(this.jianaHome, (byte)(JianaConst.CN_FLAG));
		//System.out.println("jianaHome>>>>>>>>>>"+jianaHome);
		System.out.println("BasicTermExtractor initialized....))))))))))))");
	}
	
	//constructor
	public TPbasicTermExtractor() {
		if(!this.jianaHome.isEmpty())
			init();
	}

	public TPbasicTermExtractor(String jianaHome) {
		this.jianaHome = jianaHome;
		init();
	}
	
	@Override
	public void beforeExtract() {}

	@Override
	public void afterExtract() {
		this.jianacotton.fine();
	}

	//term maker
	public List<String> makeTermList(String sentence){
		List<String> ExtractedTermList = new ArrayList<String>();
		CottonBuffer cb = new CottonBuffer();
		cb.init(sentence.toCharArray());
		this.jianacotton.analyze(cb);	
		for(int j=0; j<cb.nTerm; j++) {
			String eachWord = new String(cb.input, cb.termStart[j],cb.termLength[j]);
			//명사이고, 단어길이가 2이상이며, 숫자가 아닌 term만 추출
			if (cb.termTag[j]==1 && eachWord.length()>1 &&(!eachWord.matches("[-+]?\\d*\\.?\\d+"))) 
				ExtractedTermList.add(eachWord);
		}
		cb=null;
		//System.out.println("ExtractedTermList?>>?>?>?>?>?"+ExtractedTermList);
		return ExtractedTermList;
	}
	
	
	
	public static String toString(Set<String> set, String delim) {
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
	
}