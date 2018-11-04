/*
 *  ScanForFolds.mm
 *  Fold3D
 *
 *  Created by James Walker on 11/25/06.
 *  Copyright 2006 James W. Walker. All rights reserved.
 *
 */

#include "ScanForFolds.h"

#import <Cocoa/Cocoa.h>

#include "BBLMTextIterator.h"
#include "FindLanguageType.h"

#include <vector>
#include <cstdio>

enum EState
{
	kState_Normal,
	kState_InString,
	kState_inComment
};

class FoldScanner
{
public:
								FoldScanner( BBLMParamBlock &params,
									const BBLMCallbackBlock &bblmCallbacks );
	
	void						Scan();
	
private:
	void						CheckLanguage();
	bool						IsGroupStart( UInt16 inChar );
	bool						IsGroupEnd( UInt16 inChar );
	
	BBLMParamBlock&				mParams;
	const BBLMCallbackBlock&	mLMCallbacks;
	
	// Language-specific settings
	bool						mAllowDoubleSlashComment;
	bool						mPairParentheses;
	bool						mPairBraces;
	bool						mPairBrackets;
	
	// Scanning state
	EState						mState;
	SInt32						mLineStart;
	std::vector<SInt32>			mGroupStarts;
};

FoldScanner::FoldScanner( BBLMParamBlock &params,
						const BBLMCallbackBlock &bblmCallbacks )
	: mParams( params )
	, mLMCallbacks( bblmCallbacks )
	, mState( kState_Normal )
	, mLineStart( 0 )
{
	CheckLanguage();
}

bool	FoldScanner::IsGroupStart( UInt16 inChar )
{
	return (mPairParentheses and (inChar == '(')) or
		(mPairBraces and (inChar == '{')) or
		(mPairBrackets and (inChar == '['));
}

bool	FoldScanner::IsGroupEnd( UInt16 inChar )
{
	return (mPairParentheses and (inChar == ')')) or
		(mPairBraces and (inChar == '}')) or
		(mPairBrackets and (inChar == ']'));
}

void	FoldScanner::Scan()
{
	BBLMTextIterator	iter( mParams );
	UInt16	theChar;
	
	while ( (theChar = iter.GetNextChar()) != 0 )
	{
		switch (mState)
		{
			case kState_Normal:
				if (theChar == '#')
				{
					mState = kState_inComment;
				}
				else if (mAllowDoubleSlashComment and (theChar == '/'))
				{
					if (*iter == '/')
					{
						mState = kState_inComment;
						iter++;
					}
				}
				else if (theChar == '"')
				{
					mState = kState_InString;
				}
				else if (theChar == 0x0D)
				{
					if (*iter == 0x0A)
					{
						iter++;
					}
					mLineStart = iter.Offset();
				}
				else if (theChar == 0x0A)
				{
					mLineStart = iter.Offset();
				}
				else if (IsGroupStart( theChar ))
				{
					mGroupStarts.push_back( iter.Offset() );
				}
				else if (IsGroupEnd( theChar ))
				{
					if (not mGroupStarts.empty())
					{
						SInt32	startOff = mGroupStarts.back();
						mGroupStarts.pop_back();
						if (startOff < mLineStart)
						{
							bblmAddFoldRange( &mLMCallbacks, startOff,
								iter.Offset() - 1 - startOff );
						}
					}
				}
				break;
				
			case kState_InString:
				if (theChar == '\\')
				{
					iter++;
				}
				else if (theChar == '"')
				{
					mState = kState_Normal;
				}
				break;
				
			case kState_inComment:
				if (theChar == 0x0D)
				{
					if (*iter == 0x0A)
					{
						iter++;
					}
					mState = kState_Normal;
					mLineStart = iter.Offset();
				}
				else if (theChar == 0x0A)
				{
					mState = kState_Normal;
					mLineStart = iter.Offset();
				}
				break;
		}
	}
}

void	FoldScanner::CheckLanguage()
{
	switch (mParams.fLanguage)
	{
		case kLanguageType3DMF:
			mPairParentheses = true;
			mPairBraces = false;
			mPairBrackets = false;
			mAllowDoubleSlashComment = false;
			break;
		
		case kLanguageTypeVRML:
			mPairParentheses = false;
			mPairBraces = true;
			mPairBrackets = true;
			mAllowDoubleSlashComment = false;
			break;

		case kLanguageTypeDirX:
			mPairParentheses = false;
			mPairBraces = true;
			mPairBrackets = false;
			mAllowDoubleSlashComment = true;
			break;
	
		default:
			mPairParentheses = true;
			mPairBraces = true;
			mPairBrackets = true;
			mAllowDoubleSlashComment = true;
			break;
	}
}

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

