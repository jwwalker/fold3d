/*
 *  LMMessageName.cpp
 *  Fold3D
 *
 *  Created by James Walker on 11/25/06.
 *  Copyright 2006 James W. Walker. All rights reserved.
 *
 */
#include <Carbon/Carbon.h>
#include "BBLMInterface.h"

#include "LMMessageName.h"


const char* LMMessageName( int inMessage )
{
	const char*	msgText = "Unknown";
	
	switch (inMessage)
	{
		case kBBLMInitMessage:
			msgText = "Init";
			break;
		
		case kBBLMDisposeMessage:
			msgText = "Dispose";
			break;

		case kBBLMScanForFunctionsMessage:
			msgText = "ScanForFunctions";
			break;

		case kBBLMAdjustRangeMessage:
			msgText = "AdjustRange";
			break;

		case kBBLMCalculateRunsMessage:
			msgText = "CalculateRuns";
			break;

		case kBBLMAdjustEndMessage:
			msgText = "AdjustEnd";
			break;

		case kBBLMMapColorCodeToColorMessage:
			msgText = "MapColorCodeToColor";
			break;

		case kBBLMMapRunKindToColorCodeMessage:
			msgText = "MapRunKindToColorCode";
			break;

		case kBBLMSetCategoriesMessage:
			msgText = "SetCategories";
			break;

		case kBBLMMatchKeywordMessage:
			msgText = "MatchKeyword";
			break;

		case kBBLMEscapeStringMessage:
			msgText = "EscapeString";
			break;

		case kBBLMGuessLanguageMessage:
			msgText = "GuessLanguage";
			break;

		case kBBLMWordLeftStringMessage:
			msgText = "WordLeftString";
			break;

		case kBBLMWordRightStringMessage:
			msgText = "WordRightString";
			break;

		case kBBLMScanForFoldRangesMessage:
			msgText = "ScanForFoldRanges";
			break;

		case kBBLMCanSpellCheckRunMessage:
			msgText = "CanSpellCheckRun";
			break;

		case kBBLMMatchKeywordWithCFStringMessage:
			msgText = "MatchKeywordWithCFString";
			break;

		case kBBLMScanSubrangeForFunctionsMessage:
			msgText = "ScanSubrangeForFunctions";
			break;
	}
	
	return msgText;
}
