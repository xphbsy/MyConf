#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; 因任务计划程序无法创建任务计划，通过此方法重启OneQuick
Sleep, 10000
Run, D:\任务计划备份\发送重启OneQuick快捷键.vbs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;分组配置;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;编辑器分组
GroupAdd, Editor, ahk_class Notepad  ;记事本
GroupAdd, Editor, ahk_class WizNoteMainFrame  ;为知笔记
GroupAdd, Editor, ahk_class PX_WINDOW_CLASS  ;Sublime Text
GroupAdd, Editor, ahk_exe Code.exe  ;Visual Studio Code
GroupAdd, Editor, ahk_class SWT_Window0  ;Eclipse
GroupAdd, Editor, ahk_exe idea.exe  ;IntelliJ IDEA
GroupAdd, Editor, ahk_exe Xshell.exe  ;Xshell 5
GroupAdd, Editor, ahk_exe hh.exe  ;chm
GroupAdd, Editor, ahk_exe Listary.exe  ;Listary
GroupAdd, Editor, ahk_exe Wox.exe  ;Wox
GroupAdd, Editor, ahk_class TXGuiFoundation  ;QQ和TIM
GroupAdd, Editor, ahk_exe WeChat.exe  ;微信
GroupAdd, Editor, ahk_exe Foxmail.exe  ;Foxmail

;函数
;通过剪贴板粘贴的方法，将要输出的内容粘贴到光标处
sendbyclip(var_string)
{
    ClipboardOld = %ClipboardAll%
    Clipboard =%var_string%
    sleep 100
    send ^v
    sleep 100
    Clipboard = %ClipboardOld%  ; Restore previous contents of clipboard.
}

; ;发送英文输入法切换快捷键，请根据实际情况设置。
; setEnglishLayout(){
;   send #{Space}
; }

;在所有编辑器中自动转换
#IfWinActive,ahk_group Editor
; :*:///::
; sendbyclip("//")
; return

:*Zb0://::
state := IME_GET()
If (state="1") ;此时为中文
{
    Send {bs 2}
    sendbyclip("//")
}
return

;Alt + hjkl 实现对方向键的映射,写代码的时候灰常有用
!j::Send {down}
!k::Send {up}
!h::Send {left}
!l::Send {right}
;HOME END键映射
!y::Send {Home}
!o::Send {End}

#IfWinActive
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;分组配置结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;#j::run D:\老毛桃U盘\文档\J2SE6.0_CN.chm
;Return
;
;#IfWinActive ahk_class Notepad
;^!a::MsgBox You pressed Ctrl-Alt-A while Notepad is active.

; http://www.jianshu.com/p/32d6452b1280
;---- 本脚本开关、快速编辑和重启 -------------------

RCtrl & End:: 
    suspend ; AutoHotKey 挂起/激活双向开关 
    traytip,AutoHotKey,热键状态已切换
    ;msgbox,64,激活 VS 挂起,^-^ AutoHotKey 挂起/激活双向开关 ^-^,0.2 
return
#^e::
Edit   ; Edit the script by Alt+Ctrl+E.
return
#^r::
Reload  ; Reload the script by Alt+Ctrl+R.
TrayTip,AutoHotKey, 脚本已重启
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;输入法配置;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; http://ahk8.com/thread-3751.html
; http://www6.atwiki.jp/_pub/eamat/MyScript/Lib/IME20121110.zip
IME_GET(WinTitle="A")  {
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
	    VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
	    NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
	             ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}

    return DllCall("SendMessage"
          , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
          , UInt, 0x0283  ;Message : WM_IME_CONTROL
          ,  Int, 0x0005  ;wParam  : IMC_GETOPENSTATUS
          ,  Int, 0)      ;lParam  : 0
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;输入法配置结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; #v::
; state := IME_GET()
; ; Sleep, 500
; MsgBox 当前中英文状态为：%state%
; return