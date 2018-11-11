/*
 *  FindLanguageType.h
 *  Fold3D
 *
 *  Created by James Walker on 11/25/06.
 *  Copyright 2006 James W. Walker. All rights reserved.
 *
 */
#include <Carbon/Carbon.h>
#include "BBLMInterface.h"


const UInt32	kLanguageType3DMF	= '3DMF';
const UInt32	kLanguageTypeVRML	= 'Vrml';


UInt32	GetLanguageType( BBLMParamBlock &params );
