/*
 *  FindLanguageType.cpp
 *  Fold3D
 *
 *  Created by James Walker on 11/25/06.
 *  Copyright 2006 James W. Walker. All rights reserved.
 *
 */

#include "FindLanguageType.h"

#include "BBLMTextIterator.h"


UInt32	GetLanguageType( BBLMParamBlock &params )
{
	UInt32	theType = 0;
	
	BBLMTextIterator	iter( params );
	
	if (iter.strcmp("3DMetafile") == 0)
	{
		theType = kLanguageType3DMF;
		DEBUG_LOG(@"Fo3D: language identified as 3DMF");
	}
	else if ( (iter.strcmp("#VRML V1.0 ascii") == 0) or
		(iter.strcmp("#VRML V2.0 utf8") == 0) )
	{
		theType = kLanguageTypeVRML;
		DEBUG_LOG(@"Fo3D: language identified as VRML");
	}
	else if (iter.strcmp("xof ") == 0)
	{
		theType = kLanguageTypeDirX;
		DEBUG_LOG(@"Fo3D: language identified as DirectX");
	}
	#if DEBUG
	else
	{
		DEBUG_LOG(@"Fo3D: language not identified");
	}
	#endif
	
	return theType;
}
