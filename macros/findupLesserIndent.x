/* findupLesserIndent- From current position, move cursor up until the parent node
    is found, that is, a line with less indentation.
*/
call findupLesserIndent
exit

moveToFirstChar: procedure
  'EXTRACT /CURLINE/'
  parse var CURLINE.1 firstword .
  firstCharPos=pos(left(firstword,1), CURLINE.1)
  if firstCharPos>1 then
    'CURSOR +0 'firstCharPos
  -- 'MSG First char at col' firstCharPos 'line len='length(CURLINE.1)
  return firstCharPos

findUpLesserIndent: procedure
  'EXTRACT /CURSOR/'
  row=CURSOR.1
  if row=1 then do
    'MSG Already at top line.'
    return
  end
  char1=moveToFirstChar()
  if char1=1 then do
    'MSG Already at top indent.'
    return
  end
  'CURSOR +0 -1' -- backup 1 column
  do while CURSOR.1>1
    'UP'
    'EXTRACT /CURLINE/'
    'EXTRACT /CURSOR/'
    blankAtCursor=(substr(CURLINE.1, CURSOR.2, 1)=' ')
    if blankAtCursor then do
      data2left=(strip(left(CURLINE.1, CURSOR.2-1))<>'')
      if data2left then do
        'MSG Found next indent from row' row
        call moveToFirstChar
        leave
      end
    end
    else do
      'MSG Found at line' CURSOR.1 'col' CURSOR.2
      leave
    end
  end
  return
