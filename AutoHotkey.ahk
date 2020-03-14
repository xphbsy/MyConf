#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; 因任务计划程序无法创建任务计划，通过此方法重启OneQuick
Sleep, 10000
Run, D:\任务计划备份\发送重启OneQuick快捷键.vbs

; 因TIM启动后容易卡死，延迟启动TIM
Sleep, 60000
Run, C:\Program Files (x86)\Tencent\TIM\Bin\QQScLauncher.exe

; 为自动将输入法切换成英文状态，延迟启动XYplorer
Run, D:\软件\XYPlorer-亚信\XYplorer.exe

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;分组配置;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;编辑器分组
GroupAdd, Editor, ahk_class Notepad  ;记事本
GroupAdd, Editor, ahk_class WizNoteMainFrame  ;为知笔记
GroupAdd, Editor, ahk_group ModernEditor
GroupAdd, Editor, ahk_group IDEEditor
GroupAdd, Editor, ahk_exe Xshell.exe  ;Xshell 5
GroupAdd, Editor, ahk_exe hh.exe  ;chm
GroupAdd, Editor, ahk_exe Listary.exe  ;Listary
GroupAdd, Editor, ahk_exe Wox.exe  ;Wox
GroupAdd, Editor, ahk_class TXGuiFoundation  ;QQ和TIM
GroupAdd, Editor, ahk_exe WeChat.exe  ;微信
GroupAdd, Editor, ahk_exe Foxmail.exe  ;Foxmail

GroupAdd, ModernEditor, ahk_class PX_WINDOW_CLASS  ;Sublime Text
GroupAdd, ModernEditor, ahk_exe Code.exe  ;Visual Studio Code

GroupAdd, IDEEditor, ahk_exe eclipse.exe  ;Eclipse
GroupAdd, IDEEditor, ahk_group JetBrainsEditor

GroupAdd, JetBrainsEditor, ahk_exe idea.exe  ;IntelliJ IDEA
GroupAdd, JetBrainsEditor, ahk_exe idea64.exe  ;IntelliJ IDEA
GroupAdd, JetBrainsEditor, ahk_exe pycharm64.exe  ;PyCharm

;浏览器分组
GroupAdd, Browser, ahk_exe 360se.exe  ;360安全浏览器
GroupAdd, Browser, ahk_exe chrome.exe  ;谷歌浏览器
GroupAdd, Browser, ahk_exe 360chrome.exe  ;360极速浏览器

;可使用Alt+q关闭窗口的软件分组（AltQAvailableSoftware）
GroupAdd, AQAS, ahk_class TXGuiFoundation  ;TIM和QQ
GroupAdd, AQAS, ahk_exe WeChat.exe  ;微信
GroupAdd, AQAS, ahk_class Photo_Lightweight_Viewer  ;Windows 照片查看器
GroupAdd, AQAS, ahk_exe Foxmail.exe  ;Foxmail
GroupAdd, AQAS, ahk_exe Wiz.exe  ;为知笔记

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Editor>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Editor结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<ModernEditor>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive,ahk_group ModernEditor
!z::Send ^z
$!w::Send !w    ;覆盖通用映射，使用自己的，$用于发送键自己
$!q::Send !q
^!j::Send ^{down}
^!k::Send ^{up}
^!h::Send ^{left}
^!l::Send ^{right}
!+h::Send +{left}
!+l::Send +{right}
!+j::Send +{down}
!+k::Send +{up}
#!h::Send ^+{left}
#!l::Send ^+{right}
^!y::Send ^{Home}
^!o::Send ^{End}
!+y::Send +{Home}
!+o::Send +{End}
#!y::Send ^+{Home}
#!o::Send ^+{End}
;上页翻页键映射
!u::Send {PgUp}
!i::Send {PgDn}
^!u::Send ^{PgUp}
^!i::Send ^{PgDn}
^h::Send ^{PgUp}
^l::Send ^{PgDn}
#!u::Send ^+{PgUp}
#!i::Send ^+{PgDn}

; 查找并粘贴
#v::
Send ^f
Send ^v
return

#IfWinActive
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<ModernEditor结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<IDEEditor>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive,ahk_group IDEEditor
;上页翻页键映射
!u::Send {PgUp}
!i::Send {PgDn}
return

; 查找并粘贴
#v::
Send ^f
Send ^v
return

; 下一次出现
^.::
SetKeyDelay, 10, 10
ControlSend, , ^{.}, ahk_group IDEEditor
return

#IfWinActive
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<IDEEditor结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<JetBrainsEditor>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive,ahk_group JetBrainsEditor
$!q::Send !q    ;覆盖通用映射，使用自己的
!w::Send ^{F4}

^Space::
SetKeyDelay, 10, 10
ControlSend, , ^{Space}, ahk_group JetBrainsEditor
return

;复制整行（不含换行符）
!c::
Send {End}
Send +{Home}
Send ^c
return

#IfWinActive
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<JetBrainsEditor结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Browser>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive,ahk_group Browser
!j::Send {down}
!k::Send {up}
!h::Send {left}
!l::Send {right}
return

; 查找选中内容
^;::
^q::
^s::
^!f::
Send ^c
Send ^f
Sleep, 200
Send ^v
return

^Space::
Send, m
Sleep 500
Send, c
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Browser结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<AQAS>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive,ahk_group AQAS
!q::!F4
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<AQAS结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
