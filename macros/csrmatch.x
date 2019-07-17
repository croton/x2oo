/* csrmatch - Mark text from cursor to the next instance of current character.*/
parse arg options
if options='-?' then do; 'MSG csrmatch options'; exit; end

'EXTRACT /CURLINE/'
'EXTRACT /CURSOR/'
delim=left(getword(CURLINE.1, CURSOR.2), 1)
next=pos(delim, CURLINE.1, CURSOR.2+1)
segmentLen=next-CURSOR.2
select
  when next=0 then msg='No delim found->' delim
  when segmentLen=0 then msg='Cursor ON the delim'
  otherwise
    -- selected=substr(CURLINE.1, CURSOR.2+1, segmentLen)
    msg='Next delim->' delim 'at' next
    'MARK BLOCK'
    'CURSOR +0 +'segmentLen
    'MARK BLOCK'
end
'MSG' msg
exit

::requires 'XEdit.x'
