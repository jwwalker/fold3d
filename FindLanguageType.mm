/*
 *  FindLanguageType.mm
 *  Fold3D
 *
 *  Created by James Walker on 11/25/06.
 *  Copyright 2006 James W. Walker. All rights reserved.
 *
 */
/*
	Copyright (c) 2018 James W. Walker

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

#import "FindLanguageType.h"

#import "BBLMTextIterator.h"


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
	#if DEBUG
	else
	{
		DEBUG_LOG(@"Fo3D: language not identified");
	}
	#endif
	
	return theType;
}
