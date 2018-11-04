#include <string.h>

#include <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

#include "BBLMInterface.h"
//#include "BBXTInterface.h"
#include "BBLMTextIterator.h"

#include "FindLanguageType.h"
#include "LMMessageName.h"
#include "ScanForFolds.h"

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
	
#if DEBUG
	std::printf("Fo3D: Does the text match the language %c%c%c%c? ",
		(char)(params.fLanguage >> 24),
		(char)(params.fLanguage >> 16),
		(char)(params.fLanguage >> 8),
		(char)(params.fLanguage) );
#endif

	if (theType == params.fLanguage)
	{
		params.fGuessLanguageParams.fGuessResult = kBBLMGuessDefiniteYes;
#if DEBUG
		std::printf("Yes\n");
#endif
	}
	else
	{
		params.fGuessLanguageParams.fGuessResult = kBBLMGuessDefiniteNo;
#if DEBUG
		std::printf("No\n");
#endif
	}
}

#pragma mark -

OSErr	FoldMain( BBLMParamBlock &params,
			const BBLMCallbackBlock &bblmCallbacks )
{
	OSErr	result = paramErr;
	
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
	std::printf("Fo3D: message %s for language %c%c%c%c\n",
		LMMessageName(params.fMessage),
		(char)(params.fLanguage >> 24),
		(char)(params.fLanguage >> 16),
		(char)(params.fLanguage >> 8),
		(char)(params.fLanguage) );
#endif
	
	switch (params.fMessage)
	{
		case kBBLMInitMessage:
		case kBBLMDisposeMessage:
			result = noErr;	// nothing to do
			break;
		
		case kBBLMScanForFoldRangesMessage:
			ScanForFolds( params, bblmCallbacks );
			result = noErr;
			break;
	
		case kBBLMGuessLanguageMessage:
			GuessLanguage( params );
			result = noErr;
			break;
			
		default:
			result = paramErr;
			break;
	}
#if DEBUG
	std::fflush(stdout);
#endif
	
	return result;
}

