//
//  CalculateRuns.mm
//  Fold3D
//
//  Created by James Walker on 11/4/18.
//
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
#import "CalculateRuns.h"

#import "BBLMTextIterator.h"

enum class RunKind
{
	normal,
	quoted,
	comment
};

class RunCalculator
{
public:
				RunCalculator( BBLMParamBlock &params,
							const BBLMCallbackBlock &bblmCallbacks );
	
	void		Calculate();

private:
	NSString*	KindName() const;
	bool		AddRun();

	BBLMParamBlock&					_params;
	const BBLMCallbackBlock&		_callbacks;
	BBLMTextIterator				_iter;
	int32_t							_start;
	int32_t							_end;
	RunKind							_runKind;
	bool							_prevWasBackslash;
};


RunCalculator::RunCalculator( BBLMParamBlock &params,
							const BBLMCallbackBlock &bblmCallbacks )
	: _params( params )
	, _callbacks( bblmCallbacks )
	, _iter( params )
	, _start( params.fCalcRunParams.fStartOffset )
	, _end( _start )
	, _runKind( RunKind::normal )
	, _prevWasBackslash( false )
{
	_iter.SetOffset( params.fCalcRunParams.fStartOffset );
	DEBUG_LOG(@"CalculateRuns starting at %d, current run count %d", _start,
		bblmRunCount( &bblmCallbacks ));
}

NSString*	RunCalculator::KindName() const
{
	NSString* runKindName = nil;
	switch (_runKind)
	{
		case RunKind::normal:
			runKindName = kBBLMCodeRunKind;
			break;
		
		case RunKind::comment:
			runKindName = kBBLMCommentRunKind;
			break;
		
		case RunKind::quoted:
			runKindName = kBBLMDoubleQuotedStringRunKind;
			break;
	}
	return runKindName;
}

bool	RunCalculator::AddRun()
{
	bool success = true;
	if (_end > _start)
	{
		success = bblmAddRun( &_callbacks, _params.fLanguage,
								KindName(), _start, _end - _start );
		DEBUG_LOG(@"Run of kind %@ from %d to %d", KindName(), (int)_start, (int)_end );
		_start = _end;
	}
	return success;
}

void	RunCalculator::Calculate()
{
	while (_iter.InBounds())
	{
		UniChar c = _iter.GetNextChar();
		
		switch (_runKind)
		{
			case RunKind::normal:
				if (c == '\"')
				{
					_end = _iter.Offset() - 1;
					if (not AddRun())
					{
						return;
					}
					_runKind = RunKind::quoted;
					_prevWasBackslash = false;
				}
				else if (c == '#')
				{
					_end = _iter.Offset() - 1;
					if (not AddRun())
					{
						return;
					}
					_runKind = RunKind::comment;
				}
				break;
			
			case RunKind::quoted:
				if (c == '\\')
				{
					_prevWasBackslash = not _prevWasBackslash;
				}
				else if (c == '\"')
				{
					if (_prevWasBackslash)
					{
						_prevWasBackslash = false;
					}
					else
					{
						_end = _iter.Offset();
						if (not AddRun())
						{
							return;
						}
						_runKind = RunKind::normal;
					}
				}
				else
				{
					_prevWasBackslash = false;
				}
				break;
			
			case RunKind::comment:
				if ( (c == '\n') or (c == '\r') )
				{
					_end = _iter.Offset();
					if (not AddRun())
					{
						return;
					}
					_runKind = RunKind::normal;
				}
				break;
		}
	}
	
	_end = _iter.Offset();
	AddRun();
}


void CalculateRuns( BBLMParamBlock &params,
			const BBLMCallbackBlock &bblmCallbacks )
{
	RunCalculator calculator( params, bblmCallbacks );
	
	calculator.Calculate();
}
