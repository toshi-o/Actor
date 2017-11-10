﻿MsgBox, 36, Actor v1.0.2, ACTは%A_ScriptDir%\ACTにインストールされます。`nインストールを開始しますか？
IfMsgBox, No
    Exit

Progress, 0 A M T, 準備中, Actor v1.0.2, Actor - ACT One-click Ready
GetAPI(URL)
{
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", URL, true)
    whr.Send()
    whr.WaitForResponse()
    Return whr.ResponseText
}

#Include JSON.ahk
#Include zip.ahk


SetWorkingDir,%A_ScriptDir% 
ACT_URL = http://advancedcombattracker.com/includes/page-download.php?id=57
FFXIV_ACT_Plugin_URL = https://api.github.com/repos/ravahn/FFXIV_ACT_Plugin/releases/latest
Hojoring_URL = https://api.github.com/repos/anoyetta/ACT.Hojoring/releases/latest
OverlayPlugin_URL = https://api.github.com/repos/hibiyasleep/OverlayPlugin/releases/latest


FileRemoveDir % A_ScriptDir . "\actor_download", 1
FileCreateDir % A_ScriptDir . "\actor_download"


Progress, 10, ACTをダウンロード
URLDownloadToFile % ACT_URL, % A_ScriptDir . "\actor_download\ACT.zip"
Progress, 15, ACTを展開
Unz(A_ScriptDir . "\actor_download\ACT.zip", A_ScriptDir . "\actor_download\ACT\")

Progress, 20, FFXIV_ACTプラグインをダウンロード
FFXIV_ACT_Plugin_JSON := GetAPI(FFXIV_ACT_Plugin_URL)
FFXIV_ACT_Plugin_Parsed := JSON.Load(FFXIV_ACT_Plugin_JSON)
URLDownloadToFile % FFXIV_ACT_Plugin_Parsed.assets.1.browser_download_url, % A_ScriptDir . "\actor_download\" . FFXIV_ACT_Plugin_Parsed.assets.1.name
Progress, 25, FFXIV_ACTプラグインを展開
Unz(A_ScriptDir . "\actor_download\" . FFXIV_ACT_Plugin_Parsed.assets.1.name, A_ScriptDir . "\actor_download\FFXIV_ACT_Plugin")

Progress, 30, Hojoringプラグインをダウンロード
Hojoring_JSON := GetAPI(Hojoring_URL)
Hojoring_Parsed := JSON.Load(Hojoring_JSON)
URLDownloadToFile % Hojoring_Parsed.assets.1.browser_download_url, % A_ScriptDir . "\actor_download\" . Hojoring_Parsed.assets.1.name
Progress, 35, Hojoringプラグインを展開
RunWait, 7za.exe x .\actor_download\ACT.Hojoring*.7z -o.\actor_download\Hojoring

Progress, 40, Overlayプラグインをダウンロード
sleep 100
OverlayPlugin_JSON := GetAPI(OverlayPlugin_URL)
OverlayPlugin_Parsed := JSON.Load(OverlayPlugin_JSON)

If (A_Is64bitOS)
{ ; 64bit
    Progress, 50, Overlayプラグイン(64bit)をダウンロード
    OverlayPlugin_Download_URL := OverlayPlugin_Parsed.assets.1.browser_download_url
    OverlayPlugin_name := OverlayPlugin_Parsed.assets.1.name
}
Else If (!OverlayPlugin_Parsed.assets.3.name)
{ ; 32bit no Patch release
    Progress, 50, Overlayプラグイン(32bit)をダウンロード
    OverlayPlugin_Download_URL := OverlayPlugin_Parsed.assets.2.browser_download_url
    OverlayPlugin_name := OverlayPlugin_Parsed.assets.2.name
}
Else
{ ; 32bit with Patch release
    Progress, 50, Overlayプラグイン(32bit)をダウンロード
    OverlayPlugin_Download_URL := OverlayPlugin_Parsed.assets.3.browser_download_url
    OverlayPlugin_name := OverlayPlugin_Parsed.assets.3.name
}

URLDownloadToFile % OverlayPlugin_Download_URL, % A_ScriptDir . "\actor_download\" . OverlayPlugin_name
Progress, 55, Overlayプラグインを展開
Unz(A_ScriptDir . "\actor_download\" . OverlayPlugin_Parsed.assets.1.name, A_ScriptDir . "\actor_download\OverlayPlugin")


Progress, 60, プラグインをインストール
FileCopyDir % A_ScriptDir . "\actor_download\FFXIV_ACT_Plugin", % A_ScriptDir . "\actor_download\ACT\plugin\FFXIV_ACT_Plugin", 1
FileCopyDir % A_ScriptDir . "\actor_download\OverlayPlugin", % A_ScriptDir . "\actor_download\ACT\plugin\OverlayPlugin", 1
FileCopyDir % A_ScriptDir . "\actor_download\Hojoring", % A_ScriptDir . "\actor_download\ACT\plugin\Hojoring", 1

FileCopyDir % A_ScriptDir . "\actor_download\ACT", % A_ScriptDir . "\ACT", 1

MsgBox, 36, Actor, コンフィグをインストールしますか?`n既存のコンフィグは削除されます。
IfMsgBox, Yes
    FileRemoveDir, % A_AppData . "\Advanced Combat Tracker\Config", 1
    Progress, 70, コンフィグをインストール
    FileRead, ACTconfig, % A_ScriptDir . "\config\Advanced Combat Tracker.config.xml"
    StringReplace, ACTconfig, ACTconfig, ACTPATH, % A_ScriptDir . "\ACT", All
    FileCreateDir % A_AppData . "\Advanced Combat Tracker\Config"
    FileAppend , %ACTconfig%, % A_AppData . "\Advanced Combat Tracker\Config\Advanced Combat Tracker.config.xml"
    FileCopy % A_ScriptDir . "\config\FFXIV_ACT_Plugin.config.xml", % A_AppData . "\Advanced Combat Tracker\Config\", 1


MsgBox, 36, Actor, デスクトップにショートカットを作成しますか?
IfMsgBox, Yes
    If (A_Is64bitOS)
    {
      FileCreateShortcut, % A_ScriptDir . "\ACT\Advanced Combat Tracker.exe", % A_Desktop . "\Advanced Combat Tracker.lnk"
    }
    Else
    {
      FileCreateShortcut, % A_ScriptDir . "\ACT\ACTx86.exe", % A_Desktop . "\Advanced Combat Tracker(x86).lnk"
    }

MsgBox, 64, Actor, すべての処理が完了しました