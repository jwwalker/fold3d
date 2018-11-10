#include <string.h>

#include <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

#include "BBLMInterface.h"
#include "BBLMTextIterator.h"

#include "FindLanguageType.h"
#include "LMMessageName.h"
#include "ScanForFolds.h"
#import "CalculateRuns.h"

#include <cstdio>

extern "C"
{
__attribute__((visibility("default")))
	OSErr	FoldMain( BBLMParamBlock &params,
				const BBLMCallbackBlock &bblmCallbacks);
}



#pragma mark -


static void	GuessLanguage( BBLMParamBlock &params )
{
	UInt32	theType = GetLanguageType( params );
	
	DEBUG_LOG(@"Fo3D: Does the text match the language %c%c%c%c? ",
		(char)(params.fLanguage >> 24),
		(char)(params.fLanguage >> 16),
		(char)(params.fLanguage >> 8),
		(char)(params.fLanguage) );

	if (theType == params.fLanguage)
	{
		params.fGuessLanguageParams.fGuessResult = kBBLMGuessDefiniteYes;
		DEBUG_LOG(@"Yes");
	}
	else
	{
		params.fGuessLanguageParams.fGuessResult = kBBLMGuessDefiniteNo;
		DEBUG_LOG(@"No");
	}
}

#pragma mark -

OSErr	FoldMain( BBLMParamBlock &params,
			const BBLMCallbackBlock &bblmCallbacks )
{
	OSErr	result = noErr;
	
	//
	//	a language module must always make sure that the parameter block
	//	is valid by checking the signature, version number, and size
	//	of the parameter block. Note also that version 2 is the first
	//	usable version of the parameter block; anything older should
	//	be rejected.
	//
	
	//
	//	RMS 010925 the check for params.fVersion > kBBLMParamBlockVersion
	//	is overly strict, since there are no structural changes that would
	//	break backward compatibility; only new members are added.
	//

	if ((params.fSignature != kBBLMParamBlockSignature) ||
		(params.fVersion == 0) ||
		(params.fVersion < 2) ||
		(params.fLength < sizeof(BBLMParamBlock)))
	{
		return paramErr;
	}
	
#if DEBUG
	if (params.fMessage != kBBLMRunKindForWordMessage)
	{
		DEBUG_LOG(@"Fold3D: message %s for language %c%c%c%c, length %d",
			LMMessageName(params.fMessage),
			(char)(params.fLanguage >> 24),
			(char)(params.fLanguage >> 16),
			(char)(params.fLanguage >> 8),
			(char)(params.fLanguage),
			(int)params.fTextLength );
	}
#endif
	
	switch (params.fMessage)
	{
		case kBBLMInitMessage:
		case kBBLMDisposeMessage:
			break;
		
		case kBBLMScanForFoldRangesMessage:
			ScanForFolds( params, bblmCallbacks );
			break;
	
		case kBBLMGuessLanguageMessage:
			GuessLanguage( params );
			break;
		
		case kBBLMCalculateRunsMessage:
			CalculateRuns( params, bblmCallbacks );
			break;
		
		case kBBLMAdjustRangeMessage:
			DEBUG_LOG(@"Adjust range (%d, %d) origStart %d, kind %@",
				(int)params.fAdjustRangeParams.fStartIndex,
				(int)params.fAdjustRangeParams.fEndIndex,
				(int)params.fAdjustRangeParams.fOrigStartIndex,
				params.fAdjustRangeParams.fOrigStartRun.runKind );
			break;
		
		case kBBLMAdjustEndMessage:
			DEBUG_LOG(@"Adjust end %d", (int)params.fAdjustEndParams.fEndOffset );
			break;
			
		default:
			result = userCanceledErr;
			break;
	}
	
	return result;
}

