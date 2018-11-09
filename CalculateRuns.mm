//
//  CalculateRuns.mm
//  Fold3D
//
//  Created by James Walker on 11/4/18.
//
#import <Cocoa/Cocoa.h>

#import "CalculateRuns.h"

#import "BBLMTextIterator.h"
#import "BBLMTextUtils.h"

enum class RunKind
{
	normal,
	quoted,
	comment
};


void CalculateRuns( BBLMParamBlock &params,
			const BBLMCallbackBlock &bblmCallbacks )
{
	BBLMTextIterator p( params );
	p.SetOffset( params.fCalcRunParams.fStartOffset );
	int32_t start = p.Offset();
	int32_t end = start;
	RunKind runKind = RunKind::normal;
	bool prevWasBackslash = false;
	NSLog(@"CalculateRuns starting at %d, current run count %d", start,
		bblmRunCount( &bblmCallbacks ));
	
	while (p.InBounds())
	{
		UniChar c = p.GetNextChar();
		
		switch (runKind)
		{
			case RunKind::normal:
				if (c == '\"')
				{
					end = p.Offset() - 1;
					if (end > start)
					{
						NSLog(@"Code run %d to %d", (int)start, (int)end );
						if (not bblmAddRun( &bblmCallbacks, params.fLanguage,
							kBBLMCodeRunKind, start, end - start ))
						{
							return;
						}
					}
					start = end;
					runKind = RunKind::quoted;
					prevWasBackslash = false;
				}
				else if (c == '#')
				{
					end = p.Offset() - 1;
					if (end > start)
					{
						NSLog(@"Code run %d to %d", (int)start, (int)end );
						if (not bblmAddRun( &bblmCallbacks, params.fLanguage,
							kBBLMCodeRunKind, start, end - start ))
						{
							return;
						}
					}
					start = end;
					runKind = RunKind::comment;
				}
				break;
			
			case RunKind::quoted:
				if (c == '\\')
				{
					if (prevWasBackslash)
					{
						prevWasBackslash = false;
					}
					else
					{
						prevWasBackslash = true;
					}
				}
				else if (c == '\"')
				{
					if (prevWasBackslash)
					{
						prevWasBackslash = false;
					}
					else
					{
						end = p.Offset();
						if (not bblmAddRun( &bblmCallbacks, params.fLanguage,
							kBBLMDoubleQuotedStringRunKind, start, end - start ) )
						{
							return;
						}
						NSLog(@"Quoted string run %d to %d", (int)start, (int)end );
						start = end;
						runKind = RunKind::normal;
					}
				}
				else
				{
					prevWasBackslash = false;
				}
				break;
			
			case RunKind::comment:
				if ( (c == '\n') or (c == '\r') )
				{
					end = p.Offset();
					if (not bblmAddRun( &bblmCallbacks, params.fLanguage,
						kBBLMCommentRunKind, start, end - start ) )
					{
						return;
					}
					NSLog(@"Comment string run %d to %d", (int)start, (int)end );
					start = end;
					runKind = RunKind::normal;
				}
				break;
		}
	}
	
	end = p.Offset();
	if (end > start)
	{
		NSString* lastRunKind = kBBLMCodeRunKind;
		switch (runKind)
		{
			case RunKind::normal:
				lastRunKind = kBBLMCodeRunKind;
				NSLog(@"Final code run %d to %d", (int)start, (int)end );
				break;
				
			case RunKind::quoted:
				lastRunKind = kBBLMDoubleQuotedStringRunKind;
				NSLog(@"Final quoted string run %d to %d", (int)start, (int)end );
				break;
			
			case RunKind::comment:
				lastRunKind = kBBLMCommentRunKind;
				NSLog(@"Final comment run %d to %d", (int)start, (int)end );
				break;
		}
		bblmAddRun( &bblmCallbacks, params.fLanguage,
						lastRunKind, start, end - start );
	}
}
