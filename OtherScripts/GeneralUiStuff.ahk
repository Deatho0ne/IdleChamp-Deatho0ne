/*
By Deatho0ne
version 05.16.2020
*/

/*
Need to update this more often
*/
SetWorkingDir, %A_ScriptDir%
SetMouseDelay, 30

ShowHelpTip()

$F10::ExitApp

;Buy chest
$F1::
    BuyChests()
return

;open Multiple Silver Chest
$F2::
    ;can act a bit weird
    OpenChest("silverChest")
return

;open Multiple Gold Chest
$F3::
    ;can act a bit weird
    OpenChest("goldChest")
return

;use Multiple bountyContracts
$F4::
    BountyContracts()
return

;read comments below
$F6::
    ; Used for testing when needed
    ;CaptureResultsScreen()
return

;Reload the script
$F9::
    Reload
return

;do not feel this is need
;$`::Pause

#c::
    WinGetPos, X, Y, Width, Height, A
    WinMove, A,, (Max(Min(Floor((X + (Width / 2)) / A_ScreenWidth), 1), 0) * A_ScreenWidth) + ((A_ScreenWidth - Width) / 2), (A_ScreenHeight - Height) / 2
return

{ ;tooltips
    global gShowHelpTip := ""
    ShowHelpTip() {
        gShowHelpTip := !gShowHelpTip
        
        if (gShowHelpTip) {
            ToolTip, % "F1: Buy Chest`nF2: Open Silver Chest`nF3: Open Gold Chest`nF4: Use Bounty Contracts`nF9: Reload the Script`nF10: Exit the Script", 25, 325, 3
            SetTimer, ClearToolTip, -10000 
        }
        else {
            ToolTip, , , ,3
        }
    }

    ClearToolTip:
	{
		ToolTip, , , ,2
		ToolTip, , , ,3
		gToolTip		:= ""
		gShowHelpTip 	:= 0
		gShowStatTip 	:= 0
		return
	}
}

SafetyCheck(Skip := False) {
    if Not WinExist("ahk_exe IdleDragons.exe") {
        ExitApp
    }
    if Not Skip {
        WinActivate, ahk_exe IdleDragons.exe
    }
}

DirectedInput(s) {
    SafetyCheck(True)
    ControlFocus,, ahk_exe IdleDragons.exe
    ControlSend,, {Blind}%s%, ahk_exe IdleDragons.exe
    sleep, 100
}

FindInterfaceCue(filename, ByRef i, ByRef j, k = 360) {
    SafetyCheck()
    WinGetPos,,, width, height, A
    loop {
        sleep, 333
        ImageSearch, i, j, 0, 0, %width%, %height%, *10 *Trans0x00FF00 %filename%
        if (ErrorLevel = 0) {
            return True
        }
        if (A_Index >= k) {
            return False
        }
    }
}

ClickBasedFile(filename, x, y) {
    if FindInterfaceCue("" . filename . "", i, j, 1) {
        MouseClick, L, x+i, y+j, 1
        sleep, 100
        return True
    }
    return False
}

BuyChests() {
    if ClickBasedFile("uiWork\chestBuying\chestPrice.png", 60, 30) Or ClickBasedFile("chestBuying\chestPriceS.png", 60, 30) {
        sleep, 1
    }
    loop {
        if ClickBasedFile("uiWork\chestBuying\buyNow.png", 60, 30) Or ClickBasedFile("chestBuying\buyNowS.png", 60, 30) {
            sleep, 100
            MouseMove, 550, 550
        }
    }
    return
}

OpenChest(chestType) {
    chestToOpen := "uiWork\openingChest\" . chestType . ".png"
    loop {
        if ClickBasedFile(chestToOpen, 110, 15) {
            sleep, 100
            if ClickBasedFile("uiWork\rightArrow.png", -20, 15) {
                sleep, 100
                if ClickBasedFile("uiWork\openingChest\openMultipleChest.png", 20, 10) {
                    sleep, 3000
                    if FindInterfaceCue("uiWork\openingChest\card.png", 0, 0) {
                        loop, 7 {
                            DirectedInput("{Space}")
                            sleep, 100
                        }
                        sleep, 5000
                        DirectedInput("{Space}")
                        loop {
                            if FindInterfaceCue("uiWork\openingChest\closeAllLoot.png", i, j) {
                                DirectedInput("{Esc}")
                                break
                            }
                        }
                    }                    
                }
            }
        }
    }
    return
}

BountyContracts() {
    InputBox, contractType, Contract type, small: 1`nmedium: 2`nlarge: 3
    InputBox, contractCount, Contracts to use, Put the number you want to use in`nbut will floor the number put in by 10`nmax of 100000
    contract := (contractType = 1) ? "small" : contractType = 2 ? "medium" : contractType = 3 ? "large" : 0

    if (contract = 0) {
        MsgBox, Wrong`nContract Type`nUser Entered: %contractType%
        reload
    }
    else if (Not (contractCount > 0 and contractCount <= 100000)) {
        MsgBox, Wrong`nCountract Count`nUser Entered: %contractCount%
        reload
    }

    MsgBox, Contracts Type to use: %contracts%`nCountract Count User entered: %contractCount%`nHit F9 if this is higher wrong before hitting Enter or clicking OK

    contracts := "uiWork\bountyContracts\" . contract . ".png"
    contractCount := floor(contractCount / 10)
    
    loop, %contractCount% {
        ;MouseMove, i+20, j+15 ;more for future reference
        if ClickBasedFile("" . contracts . "", 25, 25) {
            sleep, 100
            if ClickBasedFile("uiWork\rightArrow.png", -20, 10) {
                sleep, 100
                if ClickBasedFile("uiWork\bountyContracts\useContracts.png", 20, 15) {
                    sleep, 1000
                }
            }
        }
    }
    return
}
