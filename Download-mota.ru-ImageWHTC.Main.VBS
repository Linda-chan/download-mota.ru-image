Option Explicit

Const AppTitle = "AJPapps - Download mota.ru image WHT console ver."
Const AppCopyright = "Линда Кайе 2017-2018. Посвящается Ариэль"

Dim PageURL
Dim ProxyPageURL
Dim PictureURL
Dim PictureDescription
Dim PictureData
Dim UserAgent

'====================================================================
Public Sub Main()
  ' Заранее получаем юзерагент, чтобы он не менялся при запросах...
  UserAgent = GetUserAgent()
  
  PageURL = GetPageURLFromArgs(True)
  If PageURL = "" Then Exit Sub
  
  WScript.Echo "Загружается страница: " & PageURL
  
  ProxyPageURL = GetProxyPageURL(PageURL)
  If ProxyPageURL = "" Then Exit Sub
  
  WScript.Echo "Загружается промежуточная страница: " & ProxyPageURL
  
  PictureURL = GetPictureURL(ProxyPageURL, PageURL, PictureDescription)
  If PictureURL = "" Then Exit Sub
  
  WScript.Echo "Загружается картинка: " & PictureURL
  
  PictureData = GetJPGFile(PictureURL, ProxyPageURL)
  If VarType(PictureData) <> vbByte + vbArray And _
     VarType(PictureData) <> vbString Then Exit Sub
  WScript.Echo "Сохраняется картинка..."
  
  SaveJPGFile PageURL, PictureURL, PictureData, PictureDescription
End Sub

'====================================================================
Private Function GetProxyPageURL(ByVal URL)
  Dim WHT
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetProxyPageURL = ""
  
  Set WHT = CreateObject("WinHttp.WinHttpRequest.5.1")
  
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось получить страницу с mota.ru. " & _
                 "Не удаётся создать объект Microsoft WinHTTP Services."
    Exit Function
  End If
  
  ' ResolveTimeout As Long, ConnectTimeout As Long, 
  ' SendTimeout As Long, ReceiveTimeout As Long
  WHT.SetTimeouts 300 * 1000, 300 * 1000, 300 * 1000, 300 * 1000
  
  ' Устанавливаем системный прокси для соединения. Прокси 
  ' настраивается через Proxycfg.exe, а не через настойки Инета.
  ' Иначе будет напрямик...
  WHT.SetProxy HTTPREQUEST_PROXYSETTING_PRECONFIG, "", ""
  
  WHT.Open "GET", URL
  WHT.SetRequestHeader "User-Agent", UserAgent
  WHT.Send
  
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось получить страницу с mota.ru. " & vbCrLf & _
                 "Ошибка отправки HTTP запроса (не удалось подключиться к серверу)."
    Exit Function
  End If
  
  If WHT.Status <> 200 Then
    WScript.Echo "Не удалось получить страницу с mota.ru. " & _
                 "Сервер вернул: " & WHT.Status & " " & _
                 WHT.StatusText & "."
    Exit Function
  End If
  
  TXT = ParseHTMLAndGetProxyPageURL(GetWHTResponseText(WHT))
  If TXT = "" Then
    WScript.Echo "Не удалось найти ссылку на промежуточную страницу."
    Exit Function
  End If
  
  GetProxyPageURL = TXT
End Function

'====================================================================
Private Function GetPictureURL(ByVal URL, ByVal PageURL, _
                               ByRef PictureDescription)
  Dim WHT
  Dim TXT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetPictureURL = ""
  
  Set WHT = CreateObject("WinHttp.WinHttpRequest.5.1")
  
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось получить промежуточную страницу с mota.ru. " & _
                 "Не удаётся создать объект Microsoft WinHTTP Services."
    Exit Function
  End If
  
  ' ResolveTimeout As Long, ConnectTimeout As Long, 
  ' SendTimeout As Long, ReceiveTimeout As Long
  WHT.SetTimeouts 300 * 1000, 300 * 1000, 300 * 1000, 300 * 1000
  
  ' Устанавливаем системный прокси для соединения. Прокси 
  ' настраивается через Proxycfg.exe, а не через настойки Инета.
  ' Иначе будет напрямик...
  WHT.SetProxy HTTPREQUEST_PROXYSETTING_PRECONFIG, "", ""
  
  WHT.Open "GET", URL
  WHT.SetRequestHeader "User-Agent", UserAgent
  WHT.SetRequestHeader "Referer", PageURL
  WHT.Send
  
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось получить промежуточную страницу с mota.ru. " & vbCrLf & _
                 "Ошибка отправки HTTP запроса (не удалось подключиться к серверу)."
    Exit Function
  End If
  
  If WHT.Status <> 200 Then
    WScript.Echo "Не удалось получить промежуточную страницу с mota.ru. " & _
                 "Сервер вернул: " & WHT.Status & " " & _
                 WHT.StatusText & "."
    Exit Function
  End If
  
  TXT = ParseHTMLAndGetPictureURL(GetWHTResponseText(WHT), PictureDescription)
  If TXT = "" Then
    WScript.Echo "Не удалось найти ссылку на картинку."
    Exit Function
  End If
  
  GetPictureURL = TXT
End Function

'====================================================================
Private Function GetJPGFile(ByVal URL, ByVal PageURL)
  Dim WHT
  
  On Error Resume Next
  
  ' Значение по умолчанию...
  GetJPGFile = ""
  
  Set WHT = CreateObject("WinHttp.WinHttpRequest.5.1")
  
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось получить картинку с mota.ru. " & _
                 "Не удаётся создать объект Microsoft WinHTTP Services."
    Exit Function
  End If
  
  ' ResolveTimeout As Long, ConnectTimeout As Long, 
  ' SendTimeout As Long, ReceiveTimeout As Long
  WHT.SetTimeouts 300 * 1000, 300 * 1000, 300 * 1000, 300 * 1000
  
  ' Устанавливаем системный прокси для соединения. Прокси 
  ' настраивается через Proxycfg.exe, а не через настойки Инета.
  ' Иначе будет напрямик...
  WHT.SetProxy HTTPREQUEST_PROXYSETTING_PRECONFIG, "", ""
  
  WHT.Open "GET", URL
  WHT.SetRequestHeader "User-Agent", UserAgent
  WHT.SetRequestHeader "Referer", PageURL
  WHT.Send
  
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось получить картинку с mota.ru. " & vbCrLf & _
                 "Ошибка отправки HTTP запроса (не удалось подключиться к серверу)."
    Exit Function
  End If
  
  If WHT.Status <> 200 Then
    WScript.Echo "Не удалось получить картинку с mota.ru. " & _
                 "Сервер вернул: " & WHT.Status & " " & _
                 WHT.StatusText & "."
    Exit Function
  End If
  
  GetJPGFile = WHT.ResponseBody  ' Byte array
  'GetJPGFile = WHT.ResponseText  ' String
End Function

'====================================================================
Private Sub SaveJPGFile(ByVal PageURL, ByVal PictureURL, _
                        ByVal PictureData, ByVal PictureDescription)
  Dim FileNameJPG
  Dim TMP
  Dim TXT
  
  On Error Resume Next
  
  ' Сохраняем картинку...
  TMP = InStrRev(PictureURL, "/")
  FileNameJPG = Mid(PictureURL, TMP + 1)
  
  ' Сохраняем файл...
  PutFileB FileNameJPG, PictureData
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось сохранить файл: " & FileNameJPG
    Exit Sub
  End If
  
  ' Описание не сохраняем - лень писать велосипед...
End Sub
