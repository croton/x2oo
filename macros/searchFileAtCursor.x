/* Highlight word at cursor -- to be a filename or part of filename
   to be used as filespec for a file lookup.
*/
parse arg searchPrefix
if searchPrefix='' then searchPrefix='c:\path\to\app\'

'CURSOR DATA'
'INSMODE ON'
'MARK WORD'
'MSG marked='extractAlphaFromMark()
-- call searchForMark
'MARK CLEAR'
exit

restrictMark: procedure
  'LOCATE /,/m'
  myInfo='RC='rc
  if rc=0 then do
    'MSG exclude comma'
    'MARK EXTEND LEFT'
  end
  else 'msg' myInfo
  return

extractAlphaFromMark: procedure
  'EXTRACT /MARKTEXT/'
  marked=MARKTEXT.1
  lastpos=length(marked)
  npos=0
  do i=1 to lastpos
    chr=substr(MARKTEXT.1, i, 1)
    if \datatype(chr,'A') then do
      npos=i-1
      leave i
    end
  end i
  if npos=0 then return marked
  return left(marked, npos)

searchForMark: procedure expose searchPrefix
  fspec='*'||extractAlphaFromMark()||'*'
  'MACRO cmdout projfiles.txt dir' searchPrefix||fspec '/s /b'
  return
