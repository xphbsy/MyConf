
class User_LENOVO_PC
{
	Ini()
	{
    OneQuick.Editor := "C:\Program Files\Sublime Text 3\sublime_text.exe"
	}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;分组配置;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ;编辑器分组 无效，还不知道原因
; GroupAdd, Editor, ahk_class Notepad  ;记事本
; GroupAdd, Editor, ahk_class WizNoteMainFrame  ;为知笔记
; GroupAdd, Editor, ahk_class PX_WINDOW_CLASS  ;Sublime Text
; GroupAdd, Editor, ahk_class SWT_Window0  ;Eclipse

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;分组配置结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;输入法配置;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; http://ahk8.com/thread-3751.html
; http://www6.atwiki.jp/_pub/eamat/MyScript/Lib/IME20121110.zip
IME_GET(WinTitle="A")  {
    ControlGet,hwnd,HWND,,,%WinTitle%
    if  (WinActive(WinTitle))   {
        ptrSize := !A_PtrSize ? 4 : A_PtrSize
        VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
        NumPut(cbSize, stGTI,  0, "UInt")   ;   DWORD   cbSize;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CapsLock键配置;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 要先使用如KeyTweak等将CapsLock键改为左Ctrl键

; https://gist.github.com/kshenoy/6cce6537030f088dc95c
; This is a complete solution to map the CapsLock key to Control and Escape without losing the ability to toggle CapsLock
; We use two tools here - any remapping software to map CapsLock to LControl and AutoHotkey to execute the following script
; This has been tested with MapKeyboard (by Inchwest)

; This will allow you to
;  * Use CapsLock as Escape if it's the only key that is pressed and released within 300ms (this can be changed below)
;  * Use CapsLock as LControl when used in conjunction with some other key or if it's held longer than 300ms
;  * Toggle CapsLock by pressing LControl/CapsLock + RControl

~*LControl::
if !State {
  State := (GetKeyState("Alt", "P") || GetKeyState("Shift", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
  ; For some reason, this code block gets called repeatedly when LControl is kept pressed.
  ; Hence, we need a guard around StartTime to ensure that it doesn't keep getting reset.
  ; Upon startup, StartTime does not exist thus this if-condition is also satisfied when StartTime doesn't exist.
  if (StartTime = "") {
    StartTime := A_TickCount
  }
}
return

$~LControl Up::
elapsedTime := A_TickCount - StartTime
if (  !State
   && (A_PriorKey = "LControl")
   && (elapsedTime <= 300)) {
  Send {Esc}
}
State     := 0
; We can reset StartTime to 0. However, setting it to an empty string allows it to be used right after first run
StartTime := ""
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CapsLock键配置结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;实用功能;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;win键 + PrintScreen键关闭屏幕
#PrintScreen::
KeyWait PrintScreen
KeyWait LWin ;释放左Win键才激活下面的命令
SendMessage,0x112,0xF170,2,,Program Manager ;关闭显示器。0x112:WM_SYSCOMMAND，0xF170:SC_MONITORPOWER。2：关闭，-1：开启显示器
Return

; #o::  ; Win+O hotkey that turns off the monitor.
; Sleep 1000  ; Give user a chance to release keys (in case their release would wake up the monitor again).
; ; Turn Monitor Off:
; SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
; ; Note for the above: Use -1 in place of 2 to turn the monitor on.
; ; Use 1 in place of 2 to activate the monitor's low-power mode.
; return

; 显示Listary
LAlt & LWin::
; Send #;
Send #n
Return

; 用Listary在百度百科搜索指定词条
#^;::
#j::
; Send #;
Send #n
sendbyclip("b")
Send, {Space}
Return

; 用Listary打开选中文件（全局）
#w::
Send ^c
Sleep 100
; Send {Ctrl down}{Ctrl up}
; Sleep 100
; Send {Ctrl down}{Ctrl up}
Send #n
Sleep 100
Send ^v
return

; 使用Wox切换窗口
#'::
Send #!{Space}
state := IME_GET()
If (state="1") ;此时为中文
{
    Send {Shift}
}
Send ^a
Send, w
Send, {Space}
Return

; 用有道词典打开选中单词
<!x::
Send ^c
Sleep 100
Send ^!x
Sleep 1000
Send ^v
Sleep 700
Send {Enter}
return

; 打开有道词典
; #q::Send {F8}
; Return

; 全选并复制
#c::
Send, ^a
Send, ^c
return

RControl & \::AltTab  ; Hold down right-control then press \ repeatedly to move forward.
; LControl & Esc::AltTab  ; Hold down right-control then press \ repeatedly to move forward.
LWin & LAlt::AltTab  ; Hold down right-control then press \ repeatedly to move forward.
; RControl & Enter::ShiftAltTab  ; Without even having to release right-control, press Enter to reverse direction.
LAlt & `::ShiftAltTab
RAlt & `::ShiftAltTab
LWin & LControl::ShiftAltTab
RControl & BackSpace::ShiftAltTab  ; Hold down right-control then press \ repeatedly to move forward.
return

; 切换到任务栏中前一个已打开程序（依赖于7+ Taskbar Tweaker）
#h::
#Left::
Click 664, 747, 0
Click WheelUp
Return

; 切换到任务栏中后一个已打开程序（依赖于7+ Taskbar Tweaker）
#l::
#Right::
Click 664, 747, 0
Click WheelDown
Return

; ; 提高亮度
; #^-::
; Sys.Screen.Brightness(-10)
; Return

; ; 降低亮度
; #^=::
; Sys.Screen.Brightness(+10)
; Return

; 打开搜狗截图
#^j::
Send {Ctrl down}{Alt Down}w{Alt Up}{Ctrl up}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;实用功能(结束);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;快速命令;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
自己加的
*/
#!j::run D:\老毛桃U盘\文档\J2SE6.0_CN.chm
#!b::run C:\Users\鹏\AppData\Roaming\baidu\BaiduYunGuanjia\baidunetdisk.exe ;启动百度网盘
#!c::run *RunAs D:\Program Files\Microsoft VS Code\Code.exe ;启动Visual Studio Code
RAlt & Home::run D:\软件\AutoHotkey\脚本\SublimeBrightness.ahk ;启动自动亮度调节
#^a::
run C:\Program Files\AutoHotkey\AutoHotkey.chm
run D:\书\AutoHotkey.chm
Return

#F10::Run http://www.baidu.com

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;快速命令结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;通用键的映射;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;对windows下的一些常用键进行映射,与苹果下的一些习惯一样(苹果下的快捷键有些非常合理:)
!w::Send ^w
!q::!F4    ;退出
return

;选择一行
!a::
Send {Home}
Send +{End}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;通用键的映射结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;应用程序各自的映射;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<360se6>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe 360se.exe
;^/::
;Send ^c
;Send ^f
;Send ^v
;return

^h::
Send ^{PgUp}
return

^l::
Send ^{PgDn}
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

; 查找并粘贴
#v::
Send ^f
Send ^v
return

^!l::
Send ^{PgDn}
Send ^w
return

^!h::
Send ^{PgUp}
Send ^w
Send ^{PgDn}
return

^[::
Send {Esc}
return

; $!q::Send !q    ;覆盖通用映射，使用自己的
; return

!j::Send {down}
!k::Send {up}
!h::Send {left}
!l::Send {right}
return

^+f::
Send +{Enter}
return

;打开侧边栏收藏夹
!s::
Send {Click 19, 161}
Send {Click 79, 178}
return

;在侧边栏收藏夹中搜索当前网址
!v::
Send, yy
Send {Click 19, 161}
Send {Click 79, 178}
Send ^a
Send ^v
return

;关闭或打开侧边栏收藏夹
!q::
Send {Click 19, 161}
return

^Space::
Send, mc
return

;添加博客园网摘，要先选中标题
!+z::
Send yy
Sleep 200
Send ^c
Sleep 200
Run http://wz.cnblogs.com/create
Sleep 2000
Send gi
Send ^!2
Sleep 500
Send {Tab}
Send ^!1
; Send {Click 327, 276}
Send {Click 792, 270}
return

;爱奇艺关闭广告
>!Space::
Send {Click 956, 158}
Return
;爱奇艺最大化
!,::
Send {Home}
Sleep 500
Send {Click 954, 657}
return

;移动标签
^+PgUp::Send ^{Left}
^+PgDn::Send ^{Right}
return

;快速设置1分钟闹表
!^a::
Send {Click 582, 420}
Sleep 200
Send {Esc}
return

;快速设置5分钟闹表
!^s::
Send {Click 618, 420}
Sleep 200
Send {Esc}
return

;快速设置30分钟闹表
!^d::
Send {Click 654, 420}
Sleep 200
Send {Esc}
return

;快速关闭闹表
^+z::
Send {Click 832, 450}
Sleep 200
Send {Esc}
return

; 将光标移动到“停止”按钮
!^z::
Send, !d
Send, {Tab 13}
Return

;快速设置50分钟闹表
!^e::
Send {Click 654, 420, 2}
Send {Click 721, 420, 2}
Sleep, 200
Send, {Tab 2}
return

;快速设置10分钟闹表
!^q::
Send {Click 616, 420, 2}
Sleep, 200
Send, {Tab 5}
return

;一键加速
!.::
Send {Click 1086, 716}
Sleep 200
Send {Click 684, 244}
return

; 切换到第一个标签页并刷新
~^1::
Sleep, 200
Send, r
Sleep, 1500
Send, {Click 452, 407}
Return

; 打开百度
#IfWinActive ahk_class Chrome_WidgetWin_2
F10::Run http://www.baidu.com
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<360se6结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<谷歌浏览器>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe chrome.exe
^;::
^!f::
Send ^c
Send ^f
Send ^v
return

^!l::
Send ^{PgDn}
Send ^w
return

^!h::
Send ^{PgUp}
Send ^w
Send ^{PgDn}
return

^[::
Send {Esc}
return

$!q::Send !q    ;覆盖通用映射，使用自己的
return

!j::Send {down}
!k::Send {up}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<谷歌浏览器结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Sublime Text>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe sublime_text.exe
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
>!x::Send {Delete}
return

^[::Send {Esc}
^!]::Send ^[
; +Space::Send !/
return

;复制tab
!e::
Send !fe
return

; 用Listary打开选中文件
^+o::
Send ^c
Sleep 100
Send ^o
Sleep 1250
; Send {LWin Down}{Ctrl down}o{Ctrl up}{LWin Up}
; Send {Ctrl down}{Ctrl up}
; Sleep 100
; Send {Ctrl down}{Ctrl up}
Send #n
Sleep 750
Send ^v
return

; 用Listary打开文件
^o::
Send ^o
Sleep 1500
; Send {Ctrl down}{Ctrl up}
; Sleep 100
; Send {Ctrl down}{Ctrl up}
Send #n
return

; 跳到指定字符左边
^;::
Send ^+'
return

; ; 跳到指定字符右边
; ^;::
; Send !.
; Send ^+'
; return

; 选择到指定字符左边
^,::
Send !;
Send ^+'
return

^j::Send ^+c
return

F10::
Send {Click right 559, 184}
Sleep, 200
Send o
return

+F10::
Send {Click right 559, 184}
return

^Space::
SetKeyDelay, 10, 10
ControlSend, ahk_parent, ^{Space}, ahk_class PX_WINDOW_CLASS
return

^+1::
SetKeyDelay, 10, 10
ControlSend, ahk_parent, ^+1, ahk_class PX_WINDOW_CLASS
return

^+2::
SetKeyDelay, 10, 10
ControlSend, ahk_parent, ^+2, ahk_class PX_WINDOW_CLASS
return

; 打开Key Bindings并最大化
#k::
Send !nk
Sleep 700
Send #{up}
return

; 打开Settings并最大化
#s::
Send !ns{Enter}
Sleep 700
Send #{up}
return

; 新建窗口并最大化
~^+n::
Sleep 500
Send #{up}
return

; 查找并粘贴
#v::
Send ^f
Send ^v
return

![::
sendbyclip("【自注：】")
Send, {Left}
Return

^![::
sendbyclip("【自注（参考《》的）：】")
Send, {Left 5}
Return

;复制整行（不含换行符）
!c::
Send {Home 2}
Send +{End 2}
Send ^c
return

;剪切整行
<!x::
Send {Home 2}
Send +{End 2}
Send ^x
return

;选择一行
!a::
Send {Home 2}
Send +{End 2}
return

; 自动匹配中文单引号
~'::
state := IME_GET()
If (state="1") ;此时为中文
{
    Send, '
    Send, {Left}
}
return

; 自动匹配中文双引号
~"::
state := IME_GET()
If (state="1") ;此时为中文
{
    Send, "
    Send, {Left}
    state := IME_GET()
    If (state="0") ;此时为英文
    {
        Send {Shift}
    }
}
return

; 自动匹配中文括号
~(::
state := IME_GET()
If (state="1") ;此时为中文
{
    Send, )
    Send, {Left}
    state := IME_GET()
    If (state="0") ;此时为英文
    {
        Sleep 300
        Send {Shift}
    }
}
return

; 自动匹配中文书名号
~<::
state := IME_GET()
If (state="1") ;此时为中文
{
    Send, >
    Send, {Left}
    state := IME_GET()
    If (state="0") ;此时为英文
    {
        Send {Shift}
    }
}
return

; 复制当前标签页中的全部内容
#c::
Send, ^a
Send, ^c
Send, ^u
Send, ^u
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Sublime Text结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Visual Studio Code>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe Code.exe
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
#!u::Send ^+{PgUp}
#!i::Send ^+{PgDn}
return

^[::Send {Esc}

;打开选中文件
^+o::
Send ^c
Sleep 100
Send ^o
Sleep 500
Send {LWin Down}{Ctrl down}o{Ctrl up}{LWin Up}
Sleep 100
Send ^v
return

^o::
Send ^o
Sleep 500
Send {Ctrl down}{Ctrl up}
Sleep 100
Send {Ctrl down}{Ctrl up}
; Send {LWin Down}{Ctrl down}o{Ctrl up}{LWin Up}
return

^Space::
SetKeyDelay, 10, 10
ControlSend, Chrome_RenderWidgetHostHWND1, ^{Space}, ahk_exe Code.exe
return

+Space::
SetKeyDelay, 10, 10
ControlSend, Chrome_RenderWidgetHostHWND1, +{Space}, ahk_exe Code.exe
return

!+Space::
SetKeyDelay, 10, 10
ControlSend, Chrome_RenderWidgetHostHWND1, !+{Space}, ahk_exe Code.exe
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Visual Studio Code结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<记事本>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class Notepad
!w::
Send !{F4}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<MyEclipse>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class #32770    ;查找框
$!a::Send !a    ;覆盖通用映射，使用自己的
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Eclipse>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe eclipse.exe
;上页翻页键映射
!u::Send {PgUp}
!i::Send {PgDn}
return

; 查找并粘贴
^;::
Send ^f
Send ^v
return

; 自动完成
^Space::
Send !/
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Xshell 5>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe C:\Program Files (x86)\NetSarang\Xshell 5\Xshell.exe
; 查找上一个
+Enter::
Send !u
Send {Enter}
Return

; 彻底清屏
^!l::
Send ^!l
Send ^+l
Send {Enter}
return

; 用Listary打开选中文件
#w::
Send ^x
Sleep 100
; Send {Ctrl down}{Ctrl up}
; Sleep 100
; Send {Ctrl down}{Ctrl up}
Send #n
Sleep 100
Send ^v
return

>!x::Send {Delete}
return

; 增大字体
^=::
Send ^!+]
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Xshell 5结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<chm>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 同时关闭AutoHotkey的中英文帮助
#IfWinActive AutoHotkey Help ahk_class HH Parent
^w::
!w::
!q::
!F4::
Send !{F4}
IfWinExist AutoHotkey 中文帮助
{
    WinActivate
    Send !{F4}
}
return

#IfWinActive AutoHotkey 中文帮助 ahk_class HH Parent
^w::
!w::
!q::
!F4::
Send !{F4}
IfWinExist AutoHotkey Help
{
    WinActivate
    Send !{F4}
}
return

#IfWinActive ahk_exe hh.exe
^w::
!w::
!q::
!F4::
Send !{F4}
return

^j::Send !n
^k::Send !p
^l::Send !vl
+Enter::Send !p
^[::Send {Esc}
return

^+[:: ;将焦点切换到主区，只对Java文档有效
Send !ot
Send !ot
return

^;::
Send ^c
Send ^f
Sleep 100
Send ^a
Sleep 200
Send ^v
return

^a::
Send {Home}
Send +{End}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<chm结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<为知笔记>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class WizNoteMainFrame
^PgUp::Send ^+{Tab}
^PgDn::Send ^{Tab}
$!q::Send !q    ;覆盖通用映射，使用自己的
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
!u::Send {PgUp}
!i::Send {PgDn}
^!u::Send ^{PgUp}
^!i::Send ^{PgDn}
!x::Send {Delete}
!z::Send ^z
return

; 在下一行添加一行
+Enter::
Send {End}
Send {Enter}
return

; 在当前行添加一行
^+Enter::
Send {Home}
Send {Enter}
Send {up}
return

^;::
Send ^c
Send ^f
Send ^v
return

; 自动匹配中英文单引号
:*b0:'::'{left 1}
Return

; 自动匹配中英文双引号
:*b0:"::
Send, "
Send, {Left}
Return

; 自动匹配中英文括号
:*b0:(::){left 1}
state := IME_GET()
If (state="0") ;此时为英文
{
  Send {Shift}
}
Return

; 自动匹配中英文书名号
:*b0:<::>{left 1}
Return

;复制整行（不含换行符）
!c::
Send {Home}
Send +{End}
Send ^c
return

![::
sendbyclip("【自注：】")
Send, {Left}
Return

^![::
sendbyclip("【自注（参考《》的）：】")
Send, {Left 5}
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<为知笔记结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<资源管理器>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class CabinetWClass
;!q::Send {Alt Down}{F4}{Alt Up}    ;退出
^j::
!j::
Send {down}
Return

^k::
!k::
Send {up}
Return

!h::Send {left}
!l::Send {right}
Return

^h::
Send !{Left}
Return

^l::
Send !{Right}
Return

^[::Send {Esc}
return

~!c::
~!s::
~^!c::
Sleep 200
Send {Click 507, 441}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<资源管理器结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Listary>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe Listary.exe
^n::Send ^j
^p::Send ^k
return

^[::
!^z::
!Space::
!q::
!F4::
!w::
Send {Esc}
return

^h::
Send {left}
return

^l::
Send {right}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Listary结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Wox>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; #IfWinActive ahk_exe Wox.exe
; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<开始菜单>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class Windows.UI.Core.CoreWindow
^j::
!j::
Send {down}
return

^k::
!k::
Send {up}
return

^h::
!h::
Send {Left}
return

^l::
!l::
Send {Right}
return

+F10::
Send {Click right 225, 297}
Sleep 750
Send {Click 238, 317}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<XYplorer>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class ThunderRT6FormDC
^Left::Send ^{PgUp}
^Right::Send ^{PgDn}
$!q::Send !q    ;覆盖通用映射，使用自己的
!j::Send {down}
!k::Send {up}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Beyond Compare>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class TViewForm
^j::Send ^n
^k::Send ^p
^+j::Send ^+n
^+k::Send ^+p
$!q::Send !q    ;覆盖通用映射，使用自己的
return

; 前一个标签页
^PgUp::
Send ^+{Tab}
return

; 后一个标签页
^PgDn::
Send ^{Tab}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Bandizip>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class BandizipClass
^j::Send {down}
^k::Send {up}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<WPS 演示>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class PP11FrameClass
^f::
Send ^f
Send ^a
return

^PgUp::
^PgDn::
Send ^{Tab}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<番茄钟>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive 番茄钟 10
;开始计时
Space::
Send #{up}
Send {Click 707, 595}
Send #{down}
return

;暂停
z::
Send #{up}
Send {Click 1147, 704}
Send #{down}
return

;结束任务
x::
Send #{up}
Sleep 100
Send {Click 1217, 704}
Sleep 100
Send #{down}
return

;重置
c::
Send #{up}
Send {Click 1285, 704}
Send #{down}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<番茄钟结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<QQ和TIM>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class TXGuiFoundation
$!w::Send !w    ;覆盖通用映射，使用自己的，$用于发送键自己
return

; :*://::
; Send {Shift}
; Send /
; return

:*Zb0:/::
state := IME_GET()
If (state="1") ;此时为中文
{
    Send {bs 1}
    Send {Shift}
    Send /
}
return

; 自动匹配中英文双引号
:*b0:"::
Send, "
Send, {Left}
Return

; 自动匹配中英文单引号
:*b0:'::'{left 1}
Return

; 上一个聊天窗口
^k::
^PgUp::
Send ^+{Tab}
return

; 下一个聊天窗口
^j::
^PgDn::
Send ^{Tab}
return

>!x::Send {Delete}
return

;剪切整行
<!x::
Send {Home}
Send +{End}
Send ^x
return

; 在下一行添加一行
+Enter::
Send {End}
Send {Enter}
return

; 在当前行添加一行
^+Enter::
Send {Home}
Send {Enter}
Send {up}
return

; ; 常用表情
; :*:/tx::
; sendbyclip("/tx")
; ; Send tx
; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<QQ和TIM结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<微信>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe WeChat.exe
; 在下一行添加一行
+Enter::
Send {End}
Send {Enter}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<微信结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Foxmail>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe Foxmail.exe
; 增大字体
^=::
Send ^+.
return

; 减小字体
^-::
Send ^+,
return

; 打开选项菜单
; #IfWinActive ahk_class TFoxMainFrm.UnicodeClass
; Alt::
; Send {Click 1343, 43}
; return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Foxmail结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<有道词典mini窗口>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class YdMiniModeWndClassName
^[::
!w::
!Space::
<!x::
Send {Esc}
return

!j::
^j::
Send {down}
return

!k::
^k::
Send {up}
return

!h::
^h::
Send {left}
return

!l::
^l::
Send {right}
return

; 粘贴并回车
~^v::
Sleep 200
Send {Enter}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<有道词典mini窗口结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<金山词霸mini窗口>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_exe PowerWord.exe
^[::
!w::
^w::
!Space::
<!x::
Send ^!x
return

!j::
^j::
Send {down}
return

!k::
^k::
Send {up}
return

!h::
^h::
Send {left}
return

!l::
^l::
Send {right}
return

; 粘贴并回车
~^v::
Sleep 200
Send {Enter}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<金山词霸mini窗口结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<百度网盘>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class BaseGui
^w::
!w::
Send !{F4}
return

!F4::
Send #{up}
Send {Click 1255, 5}
Send {Click 1274, 272}
return

;前进
!Right::
Send #{up}
Sleep 200
Send {Click 62, 160}
Send #{down}
return

;后退
!Left::
Send #{up}
Sleep 200
Send {Click 28, 160}
Send #{down}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<百度网盘结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<SciTE4AutoHotkey>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class SciTEWindow
F8::
SetKeyDelay, 10, 10
ControlSend, Scintilla1, {F8}, ahk_class SciTEWindow
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<桌面>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 滑动关机，配合StrokeIt使用
#IfWinActive ahk_class WorkerW
#F4::run C:\Windows\System32\SlideToShutDown.exe
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Git Bash>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class mintty
^v::
Send +{Insert}
return

^x::
Send ^{Insert}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Windows 照片查看器>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class Photo_Lightweight_Viewer
^!0::
ControlSend, Photos_PhotoCanvas1, ^!0, ahk_class Photo_Lightweight_Viewer
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Ditto>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class QPasteClass
!j::
^j::
Send {down}
return

!k::
^k::
Send {up}
return

!h::
^h::
Send {left}
return

!l::
^l::
Send {right}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<Ditto结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<WPS文字>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class OpusApp
; 在下一行添加一行
^Enter::
Send {End}
Send {Enter}
return

; 在当前行添加一行
^+Enter::
Send {Home}
Send {Enter}
Send {up}
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<WPS文字结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<PotPlayer>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive ahk_class PotPlayer64
; 复制当前时间（分:秒）以做笔记
^c::
Send, g
Send, {Left 4}
Send +{Left 5}
Send ^c
Send {Esc}
Return

; 复制当前标题以做笔记
^+c::
Send ^e
Send ^c
Send {Esc}
Return

; 弹出书签快捷菜单并选中第一个书签
~h::
Send {Down 4}
Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<PotPlayer结束>;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;应用程序各自的映射结束;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
