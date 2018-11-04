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
	bool						IsGroupStart( UniChar inChar );
	bool						IsGroupEnd( UniChar inChar );
	
	BBLMParamBlock&				mParams;
	const BBLMCallbackBlock&	mLMCallbacks;
	
	// Language-specific settings
	bool						mAllowDoubleSlashComment;
	bool						mPairParentheses;
	bool						mPairBraces;
	bool						mPairBrackets;
	
	// Scanning state
	EState						mState;
	int32_t						mLineStart;
	std::vector<int32_t>		mGroupStarts;
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

bool	FoldScanner::IsGroupStart( UniChar inChar )
{
	return (mPairParentheses and (inChar == '(')) or
		(mPairBraces and (inChar == '{')) or
		(mPairBrackets and (inChar == '['));
}

bool	FoldScanner::IsGroupEnd( UniChar inChar )
{
	return (mPairParentheses and (inChar == ')')) or
		(mPairBraces and (inChar == '}')) or
		(mPairBrackets and (inChar == ']'));
}

void	FoldScanner::Scan()
{
	BBLMTextIterator	iter( mParams );
	UniChar	theChar;
	
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
						int32_t	startOff = mGroupStarts.back();
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

