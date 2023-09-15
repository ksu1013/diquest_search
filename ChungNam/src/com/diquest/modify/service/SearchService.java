package com.diquest.modify.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.simple.parser.ParseException;

import com.diquest.ir.client.command.CommandSearchRequest;
import com.diquest.ir.common.exception.IRException;
import com.diquest.ir.common.msg.protocol.Protocol;
import com.diquest.ir.common.msg.protocol.query.Query;
import com.diquest.ir.common.msg.protocol.query.QueryParser;
import com.diquest.ir.common.msg.protocol.query.QuerySet;
import com.diquest.ir.common.msg.protocol.query.SelectSet;
import com.diquest.ir.common.msg.protocol.query.WhereSet;
import com.diquest.ir.common.msg.protocol.result.Result;
import com.diquest.ir.common.msg.protocol.result.ResultSet;

public class SearchService {
	
	public static void main(String[] args) throws IRException, ParseException {
		Map<String, Object> searchParam = new HashMap<String, Object>();
		
		searchParam.put("adminIp","127.0.0.1"); //검색엔진 설치 된 IP
		searchParam.put("adminPort",5555); // 검색엔진 포트
		searchParam.put("searchTerm","최초 작성");  // 검색키워드
		//searchParam.put("searchType","all");  // 검색종류    1. 통합  -> all  2. 계약  -> contract 3. 자문 -> jamoon  4. 소송  -> sosong
		//searchParam.put("page",1); //현재 페이지
		
		//System.out.println(search(searchParam));
		search(searchParam);
		
	}
	/**
	 * @Desc : 검색결과
	 * @Method : getSearch
	 * @Date : 2020.01.03
	 * @Author : DIQUEST
	 * @param : SearchVO
	 * @return : Map<String, Object>
	 * @throws IRException 
	 */
	public static List<HashMap<String, Object>> search(Map<String, Object> searchParam) throws IRException{
    	
		/** 검색어 **/
		String searchWord = (String) searchParam.get("searchTerm");			
		String searchIP = (String) searchParam.get("adminIp");			
		int searchPORT = (int) searchParam.get("adminPort");			

		
		/** 검색엔진 쿼리셋 **/
		QuerySet querySet = null;	
		/** 검색엔진 필드 **/
		SelectSet[] selectSet = null;
		/** 검색엔진 조건 **/
		WhereSet[] whereSet = null;	
		/** 검색 결과 **/
		Result result = null;									
		/** 검색 결과 리스트 **/
		Result[] resultList = null;			
		/** 검색요청 **/
		CommandSearchRequest command = null;			
		/** 전송코드 **/
		int returnCode = 0;						
		/** 해당 주소와 포트로 검색준비 **/
		command = new CommandSearchRequest(searchIP, searchPORT);	
		/** 쿼리셋 생성 **/
		querySet = new QuerySet(1);
		/** 하이라이트 **/
		char[] startTag = "<strong>".toCharArray();
		char[] endTag = "</strong>".toCharArray();	
		/** 컬렉션명 **/
		String collection = "TEST002";
		
		/** SelectSet **/
		selectSet = new SelectSet[] {	
				/** cjaqnvfd */
			new SelectSet("ATTACH_CON_1", (byte)Protocol.SelectSet.HIGHLIGHT),
			new SelectSet("FILR_NM_1"),	
			new SelectSet("FILE_PT_1"),	
			new SelectSet("ATTACH_CON_2", (byte)Protocol.SelectSet.HIGHLIGHT),
			new SelectSet("FILR_NM_2"),	
			new SelectSet("FILE_PT_2"),	
			new SelectSet("ATTACH_CON_3", (byte)Protocol.SelectSet.HIGHLIGHT),
			new SelectSet("FILR_NM_3"),	
			new SelectSet("FILE_PT_3"),	
			new SelectSet("ATTACH_CON_4", (byte)Protocol.SelectSet.HIGHLIGHT),
			new SelectSet("FILR_NM_4"),	
			new SelectSet("FILE_PT_4"),	

			new SelectSet("PK"),													
			//new SelectSet("NAME"),	

		};	
		
		/** WhereSet **/
		whereSet = new WhereSet[] {		
				
				
			new WhereSet("IDX_ATTACH_CON_1", Protocol.WhereSet.OP_HASALL, searchWord, 1),
			new WhereSet(Protocol.WhereSet.OP_OR),
			new WhereSet("IDX_ATTACH_CON_2", Protocol.WhereSet.OP_HASALL, searchWord, 1),
			new WhereSet(Protocol.WhereSet.OP_OR),
			new WhereSet("IDX_ATTACH_CON_3", Protocol.WhereSet.OP_HASALL, searchWord, 1),
			new WhereSet(Protocol.WhereSet.OP_OR),
			new WhereSet("IDX_ATTACH_CON_4", Protocol.WhereSet.OP_HASALL, searchWord, 1)
		};	
		
		Query query = new Query(startTag, endTag);	
		query.setSelect(selectSet);
		query.setWhere(whereSet);
		query.setFrom(collection);
		query.setResult(0, 9);
		/** ResultModifier **/
		query.setResultModifier("fileCheck");
		/** ResultModifier Parameter **/ 
		query.setValue("searchWord", searchWord);
		query.setValue("selectNumber", "0,3,6,9");
		query.setDebug(true);
		query.setPrintQuery(false);
		query.setLoggable(true);
		querySet.addQuery(query);
		QueryParser  queryParser = new QueryParser();
		System.out.println(queryParser.queryToString(query));
		
		/** 검색요청 **/
		returnCode = command.request(querySet);
																	

		/** 검색결과 리스트 **/
		List<HashMap<String, Object>> resultMapList = null;
		/** 검색결과 **/
		HashMap<String, Object> resultMap = null;

		/** 검색이 성공 시 **/
		if(returnCode > 0) {		
			/** ResultSet 가져오기 **/
			ResultSet results = command.getResultSet();			
			/** ResultSet에서 모든 쿼리 결과 가져오기 **/
			resultList = results.getResultList();
			
			/** 검색결과가 있을 때 **/
			if(resultList.length > 0) {
				for(int i = 0; i < resultList.length; i++) {
					result = resultList[i];	
					System.out.println("Total>>>>>>"+result.getTotalSize());
					
					/** 검색결과 리스트 **/
					resultMapList = new ArrayList<HashMap<String, Object>>();
					for(int row = 0; row < result.getRealSize(); row++) {
						/** 검색결과 **/
						resultMap = new HashMap<String, Object>();
						for(int column = 0 ; column < result.getNumField() ; column++) {
							resultMap.put(new String(querySet.getQuery(i).getSelectFields()[column].getField()), new String(result.getResult(row, column)));
							System.out.println("resultMap>>>>>>"+resultMap);
							
						}
						resultMapList.add(resultMap);
					}
				}
			}
		/** 검색 실패 **/	
		} else {
			resultList = new Result[1];
			resultList[0] = new Result();
		}		
		//System.out.println("resultMapList>?>>>>>>>>>"+resultMapList);
		return resultMapList;
    }
}