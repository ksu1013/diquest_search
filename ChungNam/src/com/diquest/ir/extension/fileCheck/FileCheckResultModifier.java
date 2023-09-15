package com.diquest.ir.extension.fileCheck;


import com.diquest.ir.common.exception.IRException;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.result.Result;
import com.diquest.ir.server.extension.IResultModifier;

/**
 * @Desc : 하나의 게시물에 여러개의 첨부파일이 있을 경우, 첨부파일 본문에 검색어가 있는 첨부파일명만 화면에 보이도록
 * @Method : modify
 * @Date : 2020.02.20
 * @Author : yds
 * @param : Query, Result
 * @return : 
 * @throws IRException 
 */
public class FileCheckResultModifier implements IResultModifier{
	
	@Override
	public void modify(Query query, Result result) throws IRException {
	
		/** 커스터마이징 영역 **/
		/** 첨부파일 내용 구분자 **/	
	
		//System.out.println("highlightWord>>>>>"+highlightWord);
		
		/** 첨부파일 내용 필드명 **/	
		final String file_filter = query.getValue("selectNumber");
		/** 첨부파일이 여러개일 때 구분하는 구분자 **/	
		final String splitGubunja = ",";
		/** 첨부파일 내용에 검색어를 찾기 위한 SelectSet 필드명 및 위치 **/
		
			
		/** 고정 영역 **/
		/** DQDOC 문서순서 **/
		int row = 0;
		/** DQDOC 문서 내 필드순서 **/
		int column = 0;
		
		String[] filterArr = file_filter.split(",");
		
		System.out.println("file_filter"+ file_filter + "/" + filterArr.length );
		char[][][] summaryInfoResult = result.getResults();
		
		for(row = 0; row < result.getRealSize(); row++) {
			
		
			for(column = 0 ; column < filterArr.length; column++) {
				int number = Integer.parseInt(filterArr[column]);
				System.out.println("number" +number);
				/** 검색결과 필드명 **/
				String field = new String(query.getSelectFields()[number].getField());
				/** 검색결과 값 **/
				String value = new String(result.getResult(row, number));
				//System.out.println("value>>>>"+value);

				String aa = "N";
				if(value.contains(new String (query.getHighLightEndTag()))){
					aa = "Y";
				}
				summaryInfoResult[row][number] = aa.toCharArray();
			//	System.out.println("summaryInfoResult[row][column]>>>"+summaryInfoResult[row][number]);
			
				
			
			}
		}
		
	}
}