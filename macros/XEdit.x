-- X2 basic editing functions, ver. 0.01
::routine wordAtCursor public
  'EXTRACT /CURLINE/'
  'EXTRACT /CURSOR/'
  return word(substr(CURLINE.1, CURSOR.2),1)

::routine wordAtCursor2 public
  parse arg currline, colno
  return word(substr(currline, colno),1)

::routine leadblanks public
  parse arg str
  return max(verify(str, ' ')-1,0)

::routine getindent public
  'EXTRACT /CURLINE/'
  blanks=max(verify(CURLINE.1, ' ')-1,0)
  return copies(' ', blanks)

