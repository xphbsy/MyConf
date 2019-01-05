;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; AHK版本：		1.1.23.01
; 语言：		中文
; 作者：		lspcieee <lspcieee@gmail.com>
; 网站：		http://www.lspcieee.com/
; 脚本功能：	自动切换输入法
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;=====分组配置
;新开窗口时，切换到微软拼音输入法的分组
GroupAdd,idea,ahk_exe idea.exe  ;IntelliJ IDEA
GroupAdd,idea,ahk_class SunAwtFrame  ;IntelliJ IDEA
GroupAdd,idea,ahk_class SunAwtDialog  ;IntelliJ IDEA
; GroupAdd,idea,ahk_class Notepad

;窗口切换时，切换到微软拼音输入法的分组
; GroupAdd,idea32772,ahk_exe idea.exe  ;IntelliJ IDEA

;新开窗口时，切换到英文输入法的分组
GroupAdd,en,ahk_exe explorer.exe
GroupAdd,en,ahk_class Windows.UI.Core.CoreWindow
GroupAdd,en,ahk_exe Xshell.exe

;窗口切换时，切换到英文输入法
GroupAdd,en32772,ahk_class Listary_WidgetWin_0
; GroupAdd,en32772,ahk_exe Xshell.exe

setMSPinyin(){
	;发送中文输入法切换快捷键，请根据实际情况设置。
	; ToolTip, mspinyin
	Send ^+{F11}
	Sleep, 500
	Send #{Space}
}
setEnglishLayout(){
	;发送英文输入法切换快捷键，请根据实际情况设置。
  Send {Shift}
}

;监控消息回调ShellMessage，并自动设置输入法
Gui +LastFound
hWnd := WinExist()
DllCall( "RegisterShellHookWindow", UInt,hWnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage")

ShellMessage( wParam,lParam ) {

;1 顶级窗体被创建
;2 顶级窗体即将被关闭
;3 SHELL 的主窗体将被激活
;4 顶级窗体被激活
;5 顶级窗体被最大化或最小化
;6 Windows 任务栏被刷新，也可以理解成标题变更
;7 任务列表的内容被选中
;8 中英文切换或输入法切换
;9 显示系统菜单
;10 顶级窗体被强制关闭
;11
;12 没有被程序处理的APPCOMMAND。见WM_APPCOMMAND
;13 wParam=被替换的顶级窗口的hWnd
;14 wParam=替换顶级窗口的窗口hWnd
;&H8000& 掩码
;53 全屏
;54 退出全屏
;32772 窗口切换
	If ( wParam = 1 )
	{
		;WinGetclass, WinClass, ahk_id %lParam%
		;MsgBox,%Winclass%
		Sleep, 1000
		;WinActivate,ahk_class %Winclass%
		;WinGetActiveTitle, Title
		;MsgBox, The active window is "%Title%".
		IfWinActive,ahk_group idea
		{
			setMSPinyin()
			TrayTip,AHK, 已自动切换到微软拼音输入法
			return
		}
		IfWinActive,ahk_group en
		{
			setEnglishLayout()
			TrayTip,AHK, 已自动切换到英文输入法
			return
		}
	}
	If ( wParam = 32772 )
	{
		IfWinActive,ahk_group en32772
		{
			setEnglishLayout()
			TrayTip,AHK, 已自动切换到英文输入法
			return
		}
		; IfWinActive,ahk_group idea32772
		; {
		; 	setMSPinyin()
		; 	TrayTip,AHK, 已自动切换到微软拼音输入法
		; 	return
		; }
	}
}
