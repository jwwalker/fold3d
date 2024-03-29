VRML+3DMF Language Module
=========================

VRML+3DMF is a BBEdit language module for the VRML and 3DMF (text variant) file formats for 3D models.  It provides folding of data blocks, and basic syntax coloring of keywords, comments, and quoted strings.  It is written in Objective-C++.  To build it, you will need the [BBEdit Language Module SDK][1].  If you want to notarize the product, you will need to modify `Notarize.sh` to specify your own credentials.

To install the compiled `VRML+3DMF.bblm` bundle, place it in the folder `~/Library/Application Support/BBEdit/Language Modules`.

The code is provided under the zlib/libpng public license:

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

 [1]: https://github.com/siegel/LanguageModuleSDK