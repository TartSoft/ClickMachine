#RequireAdmin
#Region
    #AutoIt3Wrapper_Icon=Icon.ico
    #AutoIt3Wrapper_Res_Fileversion=1.7.1.1
    #AutoIt3Wrapper_Res_ProductVersion=1.7.1.1
    #AutoIt3Wrapper_Outfile=ClickMachine.exe
    #AutoIt3Wrapper_Res_Field=Productname|ClickMachine By duongletrieu
    #AutoIt3Wrapper_Res_Description=Created By duongletrieu
    #AutoIt3Wrapper_Res_LegalCopyright=©2022 duongletrieu
    #AutoIt3Wrapper_Res_Field=Email|theblackvaultufofootage@gmail.com
    #AutoIt3Wrapper_Res_Field=CompanyName|TartSoft
    #AutoIt3Wrapper_Res_Language=1066
    #AutoIt3Wrapper_Res_Field=Compile Date|%date% %time%
    #AutoIt3Wrapper_Compression=4
    #AutoIt3Wrapper_UseUpx=y
    #AutoIt3Wrapper_UseX64=n
    #AutoIt3Wrapper_Run_Obfuscator=y
#EndRegion
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <GuiStatusBar.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <array.au3>
If _singleton(@ScriptName&"_Setup", 1) = 0 Then Exit MsgBox(0,"Error", "Program is running",1)
Func _singleton($soccurencename, $iflag = 0)
    Local Const $error_already_exists = 183
    Local Const $security_descriptor_revision = 1
    Local $tsecurityattributes = 0
    If BitAND($iflag, 2) Then
        Local $tsecuritydescriptor = DllStructCreate("byte;byte;word;ptr[4]")
        Local $aret = DllCall("advapi32.dll", "bool", "InitializeSecurityDescriptor", "struct*", $tsecuritydescriptor, "dword", $security_descriptor_revision)
        If @error Then Return SetError(@error, @extended, 0)
        If $aret[0] Then
            $aret = DllCall("advapi32.dll", "bool", "SetSecurityDescriptorDacl", "struct*", $tsecuritydescriptor, "bool", 1, "ptr", 0, "bool", 0)
            If @error Then Return SetError(@error, @extended, 0)
            If $aret[0] Then
                $tsecurityattributes = DllStructCreate($tagsecurity_attributes)
                DllStructSetData($tsecurityattributes, 1, DllStructGetSize($tsecurityattributes))
                DllStructSetData($tsecurityattributes, 2, DllStructGetPtr($tsecuritydescriptor))
                DllStructSetData($tsecurityattributes, 3, 0)
            EndIf
        EndIf
    EndIf
    Local $handle = DllCall("kernel32.dll", "handle", "CreateMutexW", "struct*", $tsecurityattributes, "bool", 1, "wstr", $soccurencename)
    If @error Then Return SetError(@error, @extended, 0)
    Local $lasterror = DllCall("kernel32.dll", "dword", "GetLastError")
    If @error Then Return SetError(@error, @extended, 0)
    If $lasterror[0] = $error_already_exists Then
        If BitAND($iflag, 1) Then
            Return SetError($lasterror[0], $lasterror[0], 0)
        Else
            Exit -1
        EndIf
    EndIf
    Return $handle[0]
EndFunc
 
Func _WinAPI_DrawAnimatedRects($hwnd, $ianim, $prectfrom, $prectto)
    Local $aresult = DllCall("user32.dll", "int", "DrawAnimatedRects", "hwnd", $hwnd, "int", $ianim, "ptr", $prectfrom, "ptr", $prectto)
    If @error Then Return SetError(1, 0, 0)
    Return $aresult[0]
EndFunc   ;==>_winapi_drawanimatedrects
 
Global $htray = ControlGetHandle("[CLASS:Shell_TrayWnd]", "", "TrayNotifyWnd1")
Global $Struct = DllStructCreate($tagPoint)
Global $idani_caption = 3, $hien=True,$chay=False,$fminimized = False
Global $button, $tpoint, $x, $y, $hwnd
Global $Struct = DllStructCreate($tagPoint), $y_ctrl[0], $x_ctrl[0], $ctrl_hwnd[0]
Opt("TrayOnEventMode", 1)
TraySetIcon("Shell32.dll", 29)
TraySetOnEvent(-13, "_Restore")
TraySetClick(16)
_GUI()
Func _GUI()
    Global $Form1 = GUICreate("* AutoClick Don't Accounted Mouse Beta 1", 293, 226, 525, 185, 0x2200)
    Global $Group1 = GUICtrlCreateGroup("  *Coordinates*  ", 8, 8, 97, 161)
    Global $List = GUICtrlCreateList("", 16, 80, 81, 84)
    Global $Label1 = GUICtrlCreateLabel("X:", 16, 24, 66, 17)
    Global $Label2 = GUICtrlCreateLabel("Y:", 16, 40, 66, 17)
    Global $Label3 = GUICtrlCreateLabel("Total:", 16, 56, 55, 17)
    Global $Clear = GUICtrlCreateButton("X", 77, 55, 20, 20)
    Global $Group2 = GUICtrlCreateGroup("AutoClick Options", 120, 8, 161, 129)
    Global $Group3 = GUICtrlCreateGroup("Click Point", 128, 24, 73, 57)
    Global $Radio1 = GUICtrlCreateRadio("Multi", 136, 39, 57, 17)
    Global $Radio2 = GUICtrlCreateRadio("Single", 136, 59, 57, 17)
    GUICtrlSetState(-1, $GUI_CHECKED)
    Global $Group4 = GUICtrlCreateGroup("Time", 208, 24, 65, 57)
    GUICtrlCreateLabel("s", 220, 38, 14, 17)
    Global $Input1 = GUICtrlCreateInput("1", 215, 55, 20, 21)
    GUICtrlCreateLabel("ms", 245, 38, 25, 17)
    Global $Input2 = GUICtrlCreateInput("000", 237, 55, 30, 21)
    Global $Group5 = GUICtrlCreateGroup("Mouse Click Options", 128, 88, 145, 41)
    Global $Combo = GUICtrlCreateCombo("Left Click", 136, 104, 129, 25, 3)
    GUICtrlSetData(-1, "Left Double Click|Middle Click|Middle Double Click|Right Click|Right Double Click")
    Global $Button1 = GUICtrlCreateButton("Start", 120, 144, 49, 25)
    Global $Button2 = GUICtrlCreateButton("Hide", 176, 144, 51, 25)
    Global $Button3 = GUICtrlCreateButton("Exit", 232, 144, 49, 25)
    GUICtrlSetTip($Clear,"Reset Coordinates")
    GUICtrlSetTip($Radio1,"Single Point Click")
    GUICtrlSetTip($Radio2,"Multi Point Click")
    GUICtrlSetTip($Button1,"F3 To Start And Hide")
    GUICtrlSetTip($Button2,"Hide To Taskbar")
    GUICtrlSetTip($Button3,"F4 or ESC TO Exit Program")
    GUICtrlSetTip($Label1,"Width")
    GUICtrlSetTip($Label2,"Height")
    GUICtrlSetTip($Label3,"Total Coordinates Selected - F6 For More Details")
    Global $StatusBar = _GUICtrlStatusBar_Create($Form1)
    _GUICtrlStatusBar_SetSimple($StatusBar)
    _GUICtrlStatusBar_SetText($StatusBar, "F1: Goto Help File")
    Local $f1 = HotKeySet("{F1}", "_help")
    Local $f2 = HotKeySet("{F2}", "_getpos")
    Local $f3 = HotKeySet("{F3}", "_Run")
    Local $f4 = HotKeySet("{F4}", "_Exit")
    Local $f6 = HotKeySet("{F6}", "_views")
    Local $f7 = HotKeySet("{F7}", "_clear")
    Local $f8 = HotKeySet("{F8}", "_Restore")
    Local $es = HotKeySet("{ESC}", "_Exit")
    SplashTextOn("", "move the mouse into the window, then click F2 để lấy cửa sổ và điểm AutoClick. - F3 to start and hide the program", "800", "18", "-1", "10", 33, "Tahoma", "10", "700")
    GUISetState(@SW_SHOW)
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $Clear
                _clear()
            Case $Button3
                Exit
            Case $Button2
                _minimize()
            Case $Button1
                _Start()
        EndSwitch
    WEnd
EndFunc
 
Func _help()
    SplashTextOn("", "ClickMachine Manual", "480", "18", "-1", "10", 33, "Tahoma", "10", "700")
    GUIDelete($Form1)
    Local $f1 = HotKeySet("{F1}")
    Local $f2 = HotKeySet("{F2}")
    Local $f3 = HotKeySet("{F3}")
    Local $f4 = HotKeySet("{F4}","_Exit")
    Local $f6 = HotKeySet("{F6}")
    Local $f7 = HotKeySet("{F7}")
    Local $f8 = HotKeySet("{F8}")
    Local $es = HotKeySet("{ESC}", "_Exit")
    $Form2 = GUICreate("*Help*", 270, 270, 530, 185, 0x2200)
    $Form2B = GUICtrlCreateButton("Close", 80, 200, 105, 33)
    GUICtrlCreateLabel("TrunghieuTH10@gmail.com", 70, 3, 137, 17)
    GUICtrlCreateLabel("F1: Help", 20, 24, 44, 17)
    GUICtrlCreateLabel("F2: Select Mouse Point In Windows", 20, 48, 173, 17)
    GUICtrlCreateLabel("F3: Start/Pause  (Miniminze In Taskbar)", 20, 72, 191, 17)
    GUICtrlCreateLabel("F4/ESC: Exit Program", 20, 96, 107, 17)
    GUICtrlCreateLabel("F6: Details Coordinates In Multi Point Click", 20, 120, 203, 17)
    GUICtrlCreateLabel("F7: Clear All Coordinates", 20, 144, 119, 17)
    GUICtrlCreateLabel("F8: Exit Minimize, Shows GUI Program", 20, 168, 184, 17)
    GUISetState(@SW_SHOW, $Form2)
    While 1
        $nMsg = GUIGetMsg()
        If $nmsg = $Form2B Then
            GUIDelete($Form2)
            _GUI()
            ExitLoop
        EndIf
    WEnd
EndFunc
 
Func _Run()
    _Start()
    _minimize()
EndFunc
 
Func _minimize()
    Local $trcfrom, $trcto
    If Not $fminimized Then
        $trcfrom = _WinAPI_GetWindowRect($form1)
        $trcto = _WinAPI_GetWindowRect($htray)
        _WinAPI_DrawAnimatedRects($form1, $idani_caption, DllStructGetPtr($trcfrom), DllStructGetPtr($trcto))
        GUISetState(@SW_HIDE)
        $fminimized = True
    EndIf
EndFunc   ;==>_minimize
 
Func _restore()
    If $fminimized Then
        $trcfrom = _WinAPI_GetWindowRect($htray)
        Local $trcto = _WinAPI_GetWindowRect($form1)
        _WinAPI_DrawAnimatedRects($form1, $idani_caption, DllStructGetPtr($trcfrom), DllStructGetPtr($trcto))
        GUISetState(@SW_SHOW)
        $fminimized = False
    EndIf
EndFunc   ;==>_restore
 
Func _Exit()
    ProcessClose(@ScriptFullPath)
    Exit
EndFunc   ;==>_Exit
 
Func _Start()
    If NOT $hwnd Then
        MsgBox(0,"Note:","Move the mouse into the window then click F2 to get the window and point ClickMachine")
        Return 0
    EndIf
    If GUICtrlRead($button1) = "Start" Then
        SplashTextOn("","",-1,0,-600,-600,1)
        GUICtrlSetData($button1, "Stop")
    Else
        SplashTextOn("", "Di chuột vào cửa sổ, chọn điểm cần click rồi bấm F2 để lấy cửa sổ và điểm AutoClick. - F3 để bắt đầu và ẩn chương trình", "800", "18", "-1", "10", 33, "Tahoma", "10", "700")
        GUICtrlSetData($button1, "Start")
    EndIf
    $chay = NOT $chay
    $button = GUICtrlRead($Combo)
    _autoclick($x, $y, $button)
    If $chay Then
        timer(1)
    Else
        timer(0)
    EndIf
EndFunc
 
Func timer($t)
    $time1=GUICtrlRead($Input1)
    $time2=GUICtrlRead($Input2)
    If $time1="" Then $time1=0
    If $time2="" Then $time2="000"
    $time=Int($time1&$time2)
    If $t=1 Then
        AdlibRegister("_click",$time)
    Else
        AdlibUnRegister("_click")
    EndIf
EndFunc
 
Func _click()
    _autoclick($x,$y,$button)
EndFunc
 
Func _autoclick($x=0,$y=0,$button='Left Click')
    Local $radio = GUICtrlRead($radio1)
    If $radio = 1 Then
        For $i = 0 To UBound($ctrl_hwnd) - 1
            Global $lParam = ($y_ctrl[$i] * 65536) + ($x_ctrl[$i])
            _button()
        Next
    Else
        Global $lparam = ($y * 65536) + ($x)
        _button()
    EndIf
EndFunc
 
Func _button()
    Switch $button
        Case $button='Left Click'
            _WinAPI_PostMessage($hwnd, 0x201, 0x1,$lParam)
            _WinAPI_PostMessage($hwnd, 0x202, 0,$lParam)
        Case $button='Left Double Click'
            _WinAPI_PostMessage($hwnd, 0x201, 0x1,$lParam)
            _WinAPI_PostMessage($hwnd, 0x202, 0,$lParam)
            _WinAPI_PostMessage($hwnd, 0x203, 0x1,$lParam)
            _WinAPI_PostMessage($hwnd, 0x202, 0,$lParam)
        Case $button='Middle Click'
            _WinAPI_PostMessage($hwnd, 0x207, 0x10,$lParam)
            _WinAPI_PostMessage($hwnd, 0x208, 0,$lParam)
        Case $button='Middle Double Click'
            _WinAPI_PostMessage($hwnd, 0x207, 0x10,$lParam)
            _WinAPI_PostMessage($hwnd, 0x208, 0,$lParam)
            _WinAPI_PostMessage($hwnd, 0x209, 0x10,$lParam)
            _WinAPI_PostMessage($hwnd, 0x208, 0,$lParam)
        Case $button='Right Click'
            _WinAPI_PostMessage($hwnd, 0x204, 0x2,$lParam)
            _WinAPI_PostMessage($hwnd, 0x205, 0,$lParam)
        Case $button='Right Double Click'
            _WinAPI_PostMessage($hwnd, 0x204, 0x2,$lParam)
            _WinAPI_PostMessage($hwnd, 0x205, 0,$lParam)
            _WinAPI_PostMessage($hwnd, 0x206, 0x2,$lParam)
            _WinAPI_PostMessage($hwnd, 0x205, 0,$lParam)
    EndSwitch
EndFunc
 
Func _getpos()
    Local $radio = GUICtrlRead($Radio1)
    If $radio = 1 Then
        DllStructSetData($struct, "x", MouseGetPos(0))
        DllStructSetData($struct, "y", MouseGetPos(1))
        $hwnd = _winapi_windowfrompoint($struct)
        _winapi_screentoclient($hwnd, $struct)
        $x = DllStructGetData($struct, "x")
        $y = DllStructGetData($struct, "y")
        _ArrayAdd($x_ctrl, $x)
        _ArrayAdd($y_ctrl, $y)
        _ArrayAdd($ctrl_hwnd, $hwnd)
        For $i = 0 To UBound($ctrl_hwnd) - 1
            GUICtrlSetData($List, $x&" x "&$y)
            GUICtrlSetData($Label3,"Total: "&$i+1)
        Next
        GUICtrlSetData($Label1,"X: "&$x)
        GUICtrlSetData($Label2,"Y: "&$y)
    Else
        DllStructSetData($struct, "x", MouseGetPos(0))
        DllStructSetData($struct, "y", MouseGetPos(1))
        $hwnd = _winapi_windowfrompoint($struct)
        _winapi_screentoclient($hwnd, $struct)
        $x = DllStructGetData($struct, "x")
        $y = DllStructGetData($struct, "y")
        GUICtrlSetData($Label3,"Total: 1")
        GUICtrlSetData($Label1,"X: "&$x)
        GUICtrlSetData($Label2,"Y: "&$y)
    EndIf
EndFunc
 
Func _clear()
    If GUICtrlRead($button1) = "Stop" Then
        MsgBox(0,"Error -", "Program is runing. Please Click Stop Button And Try Again",5)
    Else
        SplashTextOn("", "Di chuột vào cửa sổ, chọn điểm cần click rồi bấm F2 để lấy cửa sổ và điểm AutoClick. - F3 để bắt đầu và ẩn chương trình", "800", "18", "-1", "10", 33, "Tahoma", "10", "700")
        $hwnd = 0
        GUICtrlSetData($button1, "Start")
        For $i = 0 To UBound($ctrl_hwnd) - 1
            _ArrayDelete($x_ctrl, UBound($ctrl_hwnd) - 1)
            _ArrayDelete($y_ctrl,UBound($ctrl_hwnd) - 1)
            _ArrayDelete($ctrl_hwnd,UBound($ctrl_hwnd) - 1)
        Next
        GUICtrlSetData($Label1,"X:")
        GUICtrlSetData($Label2,"Y:")
        GUICtrlSetData($Label3,"Total")
        GUICtrlSetData($List,"")
    EndIf
EndFunc
 
Func _views()
 _ArrayDisplay($x_ctrl, "x")
 _ArrayDisplay($y_ctrl, "y")
 _ArrayDisplay($ctrl_hwnd, "ctrl")
EndFunc   ;==>i
