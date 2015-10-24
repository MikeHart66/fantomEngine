#rem
	Title:        fantomEngine
	Description:  A 2D game framework for the Monkey programming language
	
	Author:       Michael Hartlef
	Contact:      michaelhartlef@gmail.com
	
	Website:      http://www.fantomgl.com
	
	License:      MIT
#End


'nav:<blockquote><nav><b>fantomEngine documentation</b> | <a href="index.html">Home</a> | <a href="classes.html">Classes</a> | <a href="3rdpartytools.html">3rd party tools</a> | <a href="examples.html">Examples</a> | <a href="changes.html">Changes</a></nav></blockquote>


Import fantomEngine
'#DOCON#
'***************************************
'summery:The class [b]ftSound[/b] is an object to play sounds easily.
Class ftSound
'#DOCOFF#
	Field sound:Sound
	Field name:String
	Field engine:ftEngine
	Field channel:Int=0
	Field loop:Bool=False
	Field volume:Float = 1.0
	Field pan:Float = 0.0
	Field rate:Float = 1.0
	Field isMusic:Bool = False
	Field isPaused:Bool = False
	Field soundNode:list.Node<ftSound> = Null 
'#DOCON#
	'------------------------------------------
'summery:Returns a free sound channel index.
	Method GetFreeSoundChannel:Int()
		Local msc:Int = engine.maxSoundChannel
		Local fsc:Int = engine.firstSoundChannel
		For Local i:Int = fsc To (msc-1)
			If ChannelState(i)=0 Then
				Return i
			End
		End
		' If no sound channel is free, or the app is running on Android/Flash...
		engine.nextSoundChannel += 1
		If engine.nextSoundChannel >= msc Then engine.nextSoundChannel = fsc
		Return engine.nextSoundChannel
	End
	'------------------------------------------
'summery:Returns the pan value of a sound.
'seeAlso:SetPan
	Method GetPan:Float()
		Return Self.pan
	End
	'------------------------------------------
'summery:Returns the pitch rate of a sound.
'seeAlso:SetPitchRate
	Method GetPitchRate:Float()
		Return Self.rate
	End
	'------------------------------------------
'summery:Returns the flag of a sound.
'seeAlso:SetPaused
	Method GetPaused:Bool()
		Return Self.isPaused
	End
	'------------------------------------------
'summery:Returns the volume of a sound. Ranges from 0.0 to 1.0.
'seeAlso:SetVolume
	Method GetVolume:Float()
		Return Self.volume
	End
	'------------------------------------------
'summery:Pause/resume a sound or a music.
'seeAlso:GetPaused
	Method SetPaused:Void(pauseFlag:Bool)
		If Self.isMusic = False Then
			If pauseFlag = False
				ResumeChannel(Self.channel)
			Else
				PauseChannel(Self.channel)
			Endif
		Else
			If pauseFlag = False
				ResumeMusic()
			Else
				PauseMusic()
			Endif
		Endif
		Self.isPaused = pauseFlag
	End
	'------------------------------------------
'summery:Plays a sound. If no channel is provided, fantomEngine will determine the channel automatically.
'seeAlso:Stop
	Method Play:Int(c:Int = -1)
		If Self.isMusic = False Then
			If c = -1 Then c = GetFreeSoundChannel()
			channel = c
			If sound <> Null Then 
				If engine.hasSound  = True Then
					PlaySound(sound, c, loop)
					SetChannelVolume( channel, Self.volume * engine.volumeSFX )
					SetChannelPan( channel, Self.pan )
					SetChannelRate( channel, Self.rate )
				Endif
			Endif
		Else
			If engine.hasMusic = True Then
				PlayMusic( name, loop )
				SetMusicVolume(volume * engine.volumeMUS) 
			Endif
		Endif
		Self.isPaused = False
		Return channel
	End
	'------------------------------------------
#Rem
'summery:Set the pan value of a sound. Ranges from -1.0 to 1.0. 
A value of -1.0 is on the left side, a value of 1.0 represents the right side.
#End
'seeAlso:GetPan
	Method SetPan:Void(channelPan:Float = 0.0)
		Self.pan = channelPan
		If Self.isMusic = False Then
			SetChannelPan( channel, Self.pan)
		Endif
	End
	'------------------------------------------
#Rem
'summery:Set the rate of a sound. 
The default base note (1.0) is 'A4'. You can use the GetPitchRate("C3") function to determine the rate from a given note.
#End
'seeAlso:GetPitchRate
	Method SetPitchRate:Void(channelRate:Float = 1.0)
		Self.rate = channelRate
		If Self.isMusic = False Then
			SetChannelRate( channel, Self.rate)
		Endif
	End
	'------------------------------------------
'summery:Set the volume of a sound. Ranges from 0.0 to 1.0.
'seeAlso:GetVolume
	Method SetVolume:Void(vol:Float = 1.0)
		Self.volume = vol
		'If Self.loop = True Or ChannelState(channel) = 0 Then
		If Self.isMusic = False Then
			If Self.loop = True Then
				SetChannelVolume( channel, volume * engine.volumeSFX)
			Endif
		Else
			SetMusicVolume(volume * engine.volumeMUS) 
		Endif
	End
	'------------------------------------------
'summery:Stop playing the sound. If a channel is given, it will stop that specific sound channel.
'seeAlso:Play
	Method Stop:Void(c:Int=-1)
		If c = -1 Then c = channel
		If Self.isMusic = False Then
			StopChannel(c)
		Else
			StopMusic()
		Endif
		Self.isPaused = False
	End
	'------------------------------------------
'#DOCOFF#
	Method Remove:Void()
		If Self.isMusic = False Then
			'StopChannel(channel)
		Else
			StopMusic()
		Endif
		Self.soundNode.Remove()
		Self.engine = Null
	End
'#DOCON#
End

#rem
footer:This fantomEngine framework is released under the MIT license:
[quote]Copyright (c) 2011-2016 Michael Hartlef

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, and to permit persons to whom the software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
[/quote]
#end