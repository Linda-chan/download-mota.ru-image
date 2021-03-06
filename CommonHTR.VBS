Option Explicit

Const fbAuto = 0
Const fbNoBOM = 1
Const fbBOM = 2

Const feAuto = 0
Const feANSI = 1
Const feUTF8 = 2
Const feUTF16 = 3

Const ibAuto = 0
Const ibDontInvertBytes = 1
Const ibInvertBytes = 2

'====================================================================
' Этот велосипед необходим, поскольку функция библиотеки ждёт Long 
' и работать с вариантом не будет =_=
'====================================================================
Public Function CrackURL(ByVal URL, ByRef Protocol, ByRef Host, _
                         ByRef Port, ByRef SearchObject)
  Dim RE
  Dim MC
  
  On Error Resume Next
  
  Set RE = New RegExp
  RE.Global = True
  RE.IgnoreCase = True
  RE.MultiLine = True
  
  RE.Pattern = "(.*?)://(.*?)(:(.*?))?(/.*)"
  
  Set MC = RE.Execute(URL)
  Protocol = MC(0).SubMatches(0)
  Host = MC(0).SubMatches(1)
  Port = MC(0).SubMatches(3)
  If Port = "" Then Port = 80 Else Port = CLng(Port)
  SearchObject = MC(0).SubMatches(4)
  
  CrackURL = CBool(Host <> "")
End Function
