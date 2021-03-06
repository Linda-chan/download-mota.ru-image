Option Explicit

Const HTTPREQUEST_PROXYSETTING_DEFAULT = 0
Const HTTPREQUEST_PROXYSETTING_PRECONFIG = 0
Const HTTPREQUEST_PROXYSETTING_DIRECT = 1
Const HTTPREQUEST_PROXYSETTING_PROXY = 2

'====================================================================
' Byte ==> String
'====================================================================
Public Function ByteArrayToUtf8String(ByRef Data)
  Dim TMP
  Dim Stream
  
  If VarType(Data) <> vbByte + vbArray Then
    ByteArrayToUtf8String = ""
  Else
    Set Stream = CreateObject("ADODB.Stream")
    
    Stream.Mode = adModeReadWrite
    Stream.Open
    
    Stream.Type = adTypeBinary
    Stream.Write Data
    
    Stream.Position = 0
    
    Stream.Type = adTypeText
    Stream.Charset = "utf-8"
    ByteArrayToUtf8String = Stream.ReadText
  End If
End Function

'====================================================================
Public Function GetWHTResponseText(ByRef WHT)
  On Error Resume Next
  
  GetWHTResponseText = WHT.ResponseText
  If Err.Number <> 0 Then
    ' Символ Юникода не имеет сопоставления в конечной многобайтовой кодовой странице.
    Err.Clear
    GetWHTResponseText = ByteArrayToUtf8String(WHT.ResponseBody)
    If Err.Number <> 0 Then
      Err.Clear
      GetWHTResponseText = ""
    End If
  End If
End Function

'====================================================================
Public Sub PutFile(ByVal FileName, ByVal Text, ByVal Unicode)
  Dim FSO
  Dim File
  
  Set FSO = CreateObject("Scripting.FileSystemObject")
  Set File = FSO.CreateTextFile(FileName, True, Unicode)
  
  File.Write Text
  File.Close
End Sub

Private Sub PutFileB(ByVal FileName, ByVal Text)
  Dim oStream
  
  Const adTypeBinary = 1
  Const adSaveCreateOverWrite = 2
  
  Set oStream = CreateObject("ADODB.Stream")
  
  oStream.Open
  oStream.Type = adTypeBinary
  oStream.Write Text
  oStream.SaveToFile FileName, adSaveCreateOverWrite
  oStream.Close
End Sub
