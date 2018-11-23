/*
 *  ScanForFolds.mm
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

#import "ScanForFolds.h"

#import "BBLMTextIterator.h"
#import "FindLanguageType.h"

#import <vector>
#import <cstdio>
#import <cctype>

enum EState
{
	kState_Normal,
	kState_InString,
	kState_inComment
};

enum class FoldKind
{
	none,
	paren,			// '(', ')' in 3DMF
	bracket,		// '[', ']' in VRML
	brace,			// '{', '}' in VRML
	group			// BeginGroup, EndGroup in 3DMF
};

class FoldScanner
{
public:
								FoldScanner( BBLMParamBlock &params,
									const BBLMCallbackBlock &bblmCallbacks );
	
	void						Scan();
	
private:
	FoldKind					GetFoldKind( UniChar inChar, UniChar inPrevChar );
	bool						IsFoldEnd( UniChar inChar, UniChar inPrevChar );
	
	BBLMParamBlock&				mParams;
	const BBLMCallbackBlock&	mLMCallbacks;
	BBLMTextIterator			mIter;
	
	// Scanning state
	EState						mState;
	int32_t						mLineStart;
	std::vector<int32_t>		mFoldStartOffset;
	std::vector<FoldKind>		mFoldKinds;
};

FoldScanner::FoldScanner( BBLMParamBlock &params,
						const BBLMCallbackBlock &bblmCallbacks )
	: mParams( params )
	, mLMCallbacks( bblmCallbacks )
	, mIter( params )
	, mState( kState_Normal )
	, mLineStart( 0 )
{
}

FoldKind	FoldScanner::GetFoldKind( UniChar inChar, UniChar inPrevChar )
{
	FoldKind result = FoldKind::none;
	switch (mParams.fLanguage)
	{
		case kLanguageType3DMF:
			if (inChar == '(')
			{
				result = FoldKind::paren;
				if ( (not mFoldKinds.empty()) and
					(mFoldKinds[ mFoldKinds.size() - 1 ] == FoldKind::group) and
					(mLineStart < mFoldStartOffset[ mFoldKinds.size() - 1 ] ) )
				{
					// This means that we are seeing something like "BeginGroup (".
					// If two folds start on the same line, then only the first
					// will be useable, so see if we can advance this one to
					// the next line.
					if ( (mIter[0] == '\r') or (mIter[0] == '\n') )
					{
						mIter++;
						if ( (mIter[0] == '\r') or (mIter[0] == '\n') )
						{
							mIter++;
						}
						mLineStart = mIter.Offset();
					}
				}
			}
			else if ( (inChar == 'B') and std::isspace( inPrevChar ) )
			{
				if ( (mIter[0] == 'e') and
					 (mIter[1] == 'g') and
					 (mIter[2] == 'i') and
					 (mIter[3] == 'n') and
					 (mIter[4] == 'G') and
			 		 (mIter[5] == 'r') and
					 (mIter[6] == 'o') and
					 (mIter[7] == 'u') and
					 (mIter[8] == 'p') and
					 (mIter[9] == ' ') )
				{
					result = FoldKind::group;
					mIter += 9;
				}
			}
			break;
		
		case kLanguageTypeVRML:
			if (inChar == '{')
			{
				result = FoldKind::brace;
			}
			else if (inChar == '[')
			{
				result = FoldKind::bracket;
			}
			break;
	}
	
	return result;
}


bool	FoldScanner::IsFoldEnd( UniChar inChar, UniChar inPrevChar )
{
	bool isEnd = false;
	if (not mFoldKinds.empty())
	{
		switch (mFoldKinds.back())
		{
			case FoldKind::none: // this can't happen
				break;
				
			case FoldKind::paren:
				isEnd = (inChar == ')');
				break;

			case FoldKind::brace:
				isEnd = (inChar == '}');
				break;

			case FoldKind::bracket:
				isEnd = (inChar == ']');
				break;
			
			case FoldKind::group:
				if ( (inChar == 'E') and std::isspace( inPrevChar ) )
				{
					if ( (mIter[0] == 'n') and
						 (mIter[1] == 'd') and
						 (mIter[2] == 'G') and
						 (mIter[3] == 'r') and
						 (mIter[4] == 'o') and
						 (mIter[5] == 'u') and
						 (mIter[6] == 'p') and
						 (mIter[7] == ' ') )
					{
						isEnd = true;
					}
				}
				break;
		}
	}
	
	return isEnd;
}

void	FoldScanner::Scan()
{
	UniChar	theChar;
	UniChar prevChar = ' ';
	FoldKind foldKind;
	
	while ( (theChar = mIter.GetNextChar()) != 0 )
	{
		switch (mState)
		{
			case kState_Normal:
				if (theChar == '#')
				{
					mState = kState_inComment;
				}
				else if (theChar == '"')
				{
					mState = kState_InString;
				}
				else if (theChar == 0x0D)
				{
					if (*mIter == 0x0A)
					{
						mIter++;
					}
					mLineStart = mIter.Offset();
				}
				else if (theChar == 0x0A)
				{
					mLineStart = mIter.Offset();
				}
				else if ( (foldKind = GetFoldKind( theChar, prevChar)) != FoldKind::none)
				{
					mFoldStartOffset.push_back( mIter.Offset() );
					mFoldKinds.push_back( foldKind );
				}
				else if ( IsFoldEnd( theChar, prevChar ) )
				{
					int32_t	startOff = mFoldStartOffset.back();
					foldKind = mFoldKinds.back();
					mFoldStartOffset.pop_back();
					mFoldKinds.pop_back();
					if (startOff < mLineStart)
					{
						bblmAddFoldRange( &mLMCallbacks, startOff,
							mIter.Offset() - 1 - startOff,
							(foldKind == FoldKind::group)? kBBLMClassAutoFold :
							kBBLMDataAutoFold );
					}
				}
				break;
				
			case kState_InString:
				if (theChar == '\\')
				{
					// Within a string, skip over any character after a
					// backslash, including another backslash.
					mIter++;
				}
				else if (theChar == '"')
				{
					// end of string
					mState = kState_Normal;
				}
				break;
				
			case kState_inComment:
				if (theChar == 0x0D)
				{
					if (*mIter == 0x0A)
					{
						mIter++;
					}
					mState = kState_Normal;
					mLineStart = mIter.Offset();
				}
				else if (theChar == 0x0A)
				{
					mState = kState_Normal;
					mLineStart = mIter.Offset();
				}
				break;
		} // end switch
		prevChar = theChar;
	} // end loop
}

#pragma mark -

void ScanForFolds( BBLMParamBlock &params,
			const BBLMCallbackBlock &bblmCallbacks )
{
	try
	{
		FoldScanner	scanner( params, bblmCallbacks );
		scanner.Scan();
	}
	catch (...)
	{
	}
}

