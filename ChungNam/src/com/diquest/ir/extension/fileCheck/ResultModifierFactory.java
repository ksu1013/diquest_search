package com.diquest.ir.extension.fileCheck;

import com.diquest.ir.common.exception.IRException;
import com.diquest.ir.server.extension.IResultModifier;
import com.diquest.ir.server.extension.IResultModifierFactory;

public class ResultModifierFactory implements IResultModifierFactory{

	@Override
	public IResultModifier create() throws IRException {
		// TODO Auto-generated method stub
		
		return new FileCheckResultModifier();
	}
}
