package com.diquest.topicker.preprocessing;

import java.util.List;

public interface TPtermExtractor {
	//initializer
	public void init();	
	
	//전/후처리 method
	public void beforeExtract();
	public void afterExtract();

	//term추출  method	
	public List<String> makeTermList(String sentence);
	//public String exTractorTopicker(String rawDoc);
	
	
}
