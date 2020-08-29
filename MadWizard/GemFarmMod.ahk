#NoEnv
SystemRoot := A_WinDir
SetWorkingDir, %A_ScriptDir%
SetDefaultMouseSpeed, 10
SetMouseDelay, 10
SetKeyDelay, 15
CoordMode, Pixel, Screen
CoordMode, ToolTip, Screen

;VARIABLES BASED NEEDED TO BE CHANGED
	;AREAS FOR RESETING
Global StackArea := 326 ;z26 to z29 has portals, z41 & z16 has a portal also
Global ResetArea := 330 ;what you set Modron to reset at

	;FROMATION SAVES
Global BrivStacking := "w" ;"w" is formation 2
Global RuningForm := "e" ;"e" is formation 3

	;LEVELING VARIABLES
;have noticed Fkey leveling is generally faster
Global FamiliarOrFkey := False ;true for Familiar, false for FKey
	;change the following two vars to seats you want
		;broken up for slighly better timing
;only want one Fkey2 active
Global Fkey1 := "{F3}{F4}{F5}{F6}{F12}" ;Binwin, Sentry, Briv, Shandie, Melf
Global Fkey2 := "{F1}{F2}{F8}{F10}" ;Deekin, Celeste, Hitch, Havilar
;mirt
;Fkey2 := "{F2}{F7}{F8}{F10}" ;Celeste, Farideh, Hitch, Havilar
;vajra
;Fkey2 := "{F1}{F7}{F8}{F11}" ;Deekin, Farideh, Delina, Nova

Global Havilar := True ;this does not Mater to much, but is if using Havilar
;change next var based on what you see happen, it is in milliseconds 1000ms = 1sec
Global SleepBeforeLeveling := 3000

Global BrivExist := True ;Briv stack time
	;BRIV BUILD TIME: Seconds - should be rouhgly what the calc says, but test a few times
Global BrivTime := 230 ;235 norm ;155 speed pots in modron

Global TimeBetweenResets := 8 ;in hours

;VARIABLES TO CHANGE IF YOU ARE HAVING MAJOR TIMING ISSUES
Global ScriptSpeed := 2, DefaultSleep := 50

;VARIABLES NOT NEEDED TO BE CHANGED
;   If you make no major changes to the script
Global RunCount := 0, Crashes := 0, AreaStarted := 0, Bosses := 0, BossesPerHour := 0
Global dtStartTime := "00:00:00", dtFirstResetTime := "00:00:00"
Global toolTipToggle := true
Global timeSinceLastRestart := A_TickCount

LoadTooltip()

;start the Mad Wizard gem runs
$F2::
    Menu, Tray, Icon, %SystemRoot%\System32\setupapi.dll, 10
	InputBox, areaStart, Area Started, Does not mater just enter current area
	AreaStarted := areaStart
    dtStartTime := A_Now
	dtFirstResetTime := A_Now
	WaitForResults()
return

$F5::
    ToggleToolTip()
return

;Reload the script
$F9::
    if RunCount > 0
        DataOut()
    Reload
return

;kills the script
$F10::
	if RunCount > 0
        DataOut()
ExitApp

$`::Pause

#c::
    WinGetPos, X, Y, Width, Height, A
    WinMove, A,, (Max(Min(Floor((X + (Width / 2)) / A_ScreenWidth), 1), 0) * A_ScreenWidth) + ((A_ScreenWidth - Width) / 2), (A_ScreenHeight - Height) / 2
return

SafetyCheck(Skip := False) {
    while(Not WinExist("ahk_exe IdleDragons.exe")) {
        Run, "C:\Program Files (x86)\Steam\steamapps\common\IdleChampions\IdleDragons.exe"
        Sleep, 30000
        Crashes++
		timeSinceLastRestart := A_TickCount
		DirectedInput("2345678", 5000)
		DirectedInput("2345678")
    }
    if Skip
        WinActivate, ahk_exe IdleDragons.exe
}

CloseAndReopen() {
	PostMessage, 0x112, 0xF060,,, ahk_exe IdleDragons.exe
	Sleep, 20000
	Run, "C:\Program Files (x86)\Steam\steamapps\common\IdleChampions\IdleDragons.exe"
	Sleep, 10000
	timeSinceLastRestart := A_TickCount
	Sleep, 10000
	DirectedInput("2345678", 5000)
	DirectedInput("2345678")
}

DirectedInput(s, timeToWait := 0) {
	SafetyCheck()
	ControlFocus,, ahk_exe IdleDragons.exe
	ControlSend, ahk_parent, {Blind}%s%, ahk_exe IdleDragons.exe
	timeToWait += ScriptSpeed
	Sleep, %timeToWait%
}

FindInterfaceCue(filename, ByRef i, ByRef j, time = 0) {
	SafetyCheck()
	WinGetPos, x, y, width, height, ahk_exe IdleDragons.exe
	start := A_TickCount
	Loop {
		ImageSearch, outx, outy, x, y, % x + width, % y + height, *15 *Trans0x00FF00 %filename%
		If (ErrorLevel = 0) {
			i := outx - x, j := outy - y
			Return True
		}
		If ((A_TickCount - start)/1000 >= time)
			Return False
		Sleep, %ScriptSpeed%
	}
}

FindAndClick(filename, k, l, timeToRun := 0) {
    If FindInterfaceCue(filename, i, j, timeToRun) {
		SafetyCheck(true)
		FindInterfaceCue(filename, x, y, timeToRun)
		MouseClick, L, x+k, y+l, 2
		Sleep, 10
	}
}

CalcBossesPerHour() {
	if (RunCount) > 0 {
		Bosses := round((RunCount - 1) * ResetArea / 5, 0)
		Bosses += ceil((ResetArea - AreaStarted) / 5)
	} else
		Bosses := 0
	BossesPerHour := round(Bosses / (MinuteTimeDiff(dtStartTime, A_Now) / 60), 0)
}

FamiliarLeveling() {
	Sleep, 5000
	DirectedInput("23456", 5000)
	DirectedInput("23456", 16000)
	DirectedInput(RuningForm, 10)
	DirectedInput(RuningForm, 10)
	DirectedInput(RuningForm)
}

FkeyLeveling() {
	Sleep, SleepBeforeLeveling
	DirectedInput(RuningForm, 20)
	DirectedInput(RuningForm, 10)
	if Havilar {
		Loop, 4
			DirectedInput("{F10}", 5) ;Level up Havilar
		Sleep, 1000
		DirectedInput("123", 5000) ;Spawn Dembo
		DirectedInput("123", 10)
	}
	Loop, 35 {  ;Loop for Champion Spam
		DirectedInput(Fkey1, 5)
		DirectedInput(Fkey2, 5)
	}
	DirectedInput(RuningForm, 300)
	DirectedInput(RuningForm, 10)
	DirectedInput(RuningForm, 10)
	DirectedInput(RuningForm)
}

WaitForResults() {  
    workingArea := "areas\" . StackArea . "working.PNG" ;meant to stop on areaNum
    completeArea := "areas\" . StackArea . "complete.PNG" ;meant if skip areaNum
	dtLastRunTime := A_Now
	brivStacked := false
	firstRun := false, secondRun := false
	num := 255
	TimeBetweenResets := TimeBetweenResets * 60 * 60 * 1000
	timeSinceLastRestart := A_TickCount
    loop {
        if FindInterfaceCue("areas\1start.png", i, j) {
			dtLastRunTime := A_Now
			brivStacked := false
			if firstRun {
				RunCount += 1
				CalcBossesPerHour()
			}
			if FamiliarOrFkey {
				FamiliarLeveling()
			}
			else {
				FkeyLeveling()
			}
			Sleep, 10000
			firstRun := true
			if (TimeBetweenResets > 0 and (A_TickCount - timeSinceLastRestart) > TimeBetweenResets) {
				CloseAndReopen()
			}
        }
		
		if (FindInterfaceCue(workingArea, i, j) Or FindInterfaceCue(completeArea, i, j)) {
			if BrivExist {
				if (not brivStacked) {
					BuildBrivStacks()
					brivStacked := true
				} else if (mod(num, 2) = 1) {
					DirectedInput(RuningForm, 10)
				}
			}
			firstRun := true
		}
		
		num++
		if (mod(num, 3) = 1) {
			DirectedInput("{right}")
		}
		if (mod(num, 4) = 1) {
			FindAndClick("runAdventure\offlineOkay.png", 5, 5)
		} else if (mod(num, 4) = 2) and FindInterfaceCue("runAdventure\progress.png", i, j) {
			DirectedInput("g")
		} else if ((mod(num, 4) = 3) and (FindInterfaceCue("runAdventure\cancel.png", i, j) or FindInterfaceCue("runAdventure\onOtherTeam.png", i, j))) {
			DirectedInput("{ESC}")
		}
		if toolTipToggle and (mod(num, 30) = 1) {
			LoopedTooltip(round(MinuteTimeDiff(dtLastRunTime, A_Now), 2))
		}
		if (num > 240) {
			num := 0
		}
    }
}

BuildBrivStacks() {
    DirectedInput(BrivStacking)
    DirectedInput("g", 5)
    DirectedInput(BrivStacking, 5)
    DirectedInput(BrivStacking)
    Sleep % BrivTime * 1000 * 1.05
	DirectedInput(RuningForm, 10)
    DirectedInput("g", 10)
	DirectedInput(RuningForm, 6000)
    DirectedInput(RuningForm)
}

DataOut() {
    FormatTime, currentDateTime,, MM/dd/yyyy HH:mm:ss
	totTime := DateTimeDiff(dtStartTime, A_Now)
    currentPatron := "Modron" ;not really a Patron any more
	InputBox, areaStopped, Area Stopped, Generaly stop on areas ending in`nz1 thru z4`nz6 thru z9
    ;meant for Google Sheets/Excel/Open Office
    FileAppend,%currentDateTime%`t%currentPatron%`t%ResetArea%`t%totTime%`t%RunCount%`t%AreaStarted%`t%areaStopped%`t%Crashes%`n, MadWizard-BossesMod.txt
}

{ ;time HELPERS
    ;return String HH:mm:ss of the timespan
    DateTimeDiff(dtStart, dtEnd) {
        dtResult := dtEnd
        EnvSub, dtResult, dtStart, Seconds
        return TimeResult(dtResult)
    }
    
    ;might use later
    TimeSpanAverage(ts1, nCount) {
        time_parts1 := StrSplit(ts1, ":")
        t1_seconds := (((time_parts1[1] * 60) + time_parts1[2]) * 60) + time_parts1[3]
        if (!nCount) {
            return "00:00:00"
        }
        return TimeResult(t1_seconds / nCount)
    }
    
    TimeResult(dtResult) {
        nSeconds := Floor(Mod(dtResult, 60))
        nMinutes := Floor(dtResult / 60)
        nHours := Floor(nMinutes / 60)
        nMinutes := Mod(nMinutes, 60)
        
        sResult := (StrLen(nHours) = 1 ? "0" : "") nHours ":" (StrLen(nMinutes) = 1 ? "0" : "") nMinutes ":" (StrLen(nSeconds) = 1 ? "0" : "") nSeconds
        
        return sResult
    }
    
    MinuteTimeDiff(dtStart, dtEnd) {
        dtResult := dtEnd
        EnvSub, dtResult, dtStart, Seconds
        nSeconds := Floor(Mod(dtResult, 60))
        nMinutes := Floor(dtResult / 60)
        nHours := Floor(nMinutes / 60)
        nMinutes := Mod(nMinutes, 60)
        
        return (nMinutes + (nHours * 60) + (nSeconds / 60))
    }
}

{ ;tooltips
    LoadTooltip() {
		WinGetPos, x, y, width, height, ahk_exe IdleDragons.exe
        ToolTip, % "Shortcuts`nF2: Run MW`nF9: Reload`nF10: Kill the script`nThere are others", % x + (width / 3.5), % y + (height / 16), 1
        SetTimer, RemoveToolTip, -5000
        return
    }
    LoopedTooltip(currentRunTime) {
        WinGetPos, x, y, width, height, ahk_exe IdleDragons.exe
        ToolTip, % "Resets: " RunCount "`nCrashes: " Crashes "`nMins since start: " currentRunTime "`nBosses: " Bosses "`nBosses per hour: " BossesPerHour, % x + (width / 3.5), % y + (height / 16), 2
        SetTimer, RemoveToolTip, -1000
        return
    }
	ToggleToolTip() {
		ToolTip,,,,2
        toolTipToggle := Not toolTipToggle
    }
    RemoveToolTip:
        ToolTip,,,,
    return
}