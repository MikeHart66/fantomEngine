#rem
	'Title:        fantomEngine
	'Description:  A 2D game framework for the Monkey programming language
	
	'Author:       Michael Hartlef
	'Contact:      michaelhartlef@gmail.com
	
	'Website:      http://www.fantomgl.com
	
	'Version:      1.57
	'License:      MIT
#End

#Rem
'header:The module [b]fantomEngine[/b] is a 2D game framework which supplies you with huge set of game object related functionalities. 
To use fantomEngine in your game, simply add "Import fantomEngine" at the top of your program.
#End


Import mojo
Import brl.pool

'If TARGET="html5"
Import "data/ftLoadingBar.png"
Import "data/ftOrientation_changeP.png"
Import "data/ftOrientation_changeL.png"
'End

'Import reflection
'#REFLECTION_FILTER+="|fantomEngine.cftLayer"
'#REFLECTION_FILTER+="|fantomEngine*"

Import fantomEngine.cftMisc
Import fantomEngine.cftFunctions
Import fantomEngine.cftImageMng
Import fantomEngine.cftObject
Import fantomEngine.cftObjAnimMng
Import fantomEngine.cftLayer
Import fantomEngine.cftEngine
Import fantomEngine.cftSound
Import fantomEngine.cftTimer
Import fantomEngine.cftFont
Import fantomEngine.cftTrans
Import fantomEngine.cftHighscore
Import fantomEngine.cftSwipe
Import fantomEngine.cftWaypoints
Import fantomEngine.cftAStar
Import fantomEngine.cftLocalization
Import fantomEngine.cftKeyMapping
Import fantomEngine.cftTileMap
Import fantomEngine.cftSpriteAtlas
Import fantomEngine.cftRGBA
Import fantomEngine.cftVec2D
Import fantomEngine.cftScene
Import fantomEngine.cftGui

#If TARGET="DocMonk"
Import fantomEngine.cftBox2D
#End

Import json

'-OUTPUTNAME#index.html
'#INCLFILE#docInclude/introduction.txt
'-INCLFILE#docInclude/classes.txt
'-INCLFILE#docInclude/3rdpartytools.txt
'-INCLFILE#docInclude/examples.txt
'-INCLFILE#docInclude/changes.txt
#rem
footer:This fantomEngine framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end