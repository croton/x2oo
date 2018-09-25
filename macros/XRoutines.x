::routine msgBox public
parse arg title, msg, datasrc
'EXTRACT /ESCAPE/'
CR=ESCAPE.1||'N'
-- trace 'i'
if msg='' then do
  if datasrc='' then return .false
  else do
    -- Show content in a message box
    msg='' -- 'datasource='datasrc
    res=cmdOutput(datasrc)
    do val over res
      msg=msg val||CR
    end
    'MESSAGEBOX' title||CR||msg
  end
end
else do
  -- Content of message is literal text
  ctxt=copies('-', length(msg))
  ctxt2='---------|---------|---------|---------|'
  'MESSAGEBOX' title||CR||ctxt||CR||msg
end
return result

/* -----------------------------------------------------------------------------
   A message box which provides a Yes/No prompt. Returns boolean value.
   -----------------------------------------------------------------------------
*/
::routine msgYNBox public
parse arg msg, title
'EXTRACT /ESCAPE/'
CR=ESCAPE.1||'N'
if msg='' then msg='Continue?'
maxwidth=max(length(msg), length(title))+5
divline=copies('-', maxwidth)
choices=centre('(Y)es | (N)o', maxwidth)
info=' 'msg -- ~centre(maxwidth)
if title='' then
  'MESSAGEBOX' info||CR choices
else
  'MESSAGEBOX' title||CR divline||CR info||CR choices
if result='ENTER' then return 1
else if abbrev(translate(result), 'Y') then return 1
return 0

::routine ask public
parse arg promptTxt
'PROMPT' promptTxt
if rc=0 then
  if result<>'' then return result
return .nil

::routine showHelp public
parse arg params, helpMsg, noblank
if noblank=.true then do
  if params='-?' | translate(params)='-H' | params='' then do
    'MSG' helpMsg
    return .true
  end
end
if params='-?' | translate(params)='-H' then do
  'MSG' helpMsg
  return .true
end
return .false

/* Pass a given command to the external environment and return results as array */
::routine cmdOutput public
  parse arg command
  if arg(1,'O') then return .nil
  myresults=.Array~new
  ADDRESS CMD command '| RXQUEUE'
  do while queued()<>0
    parse pull entry
    if entry='' then iterate
    myresults~append(entry)
  end
  return myresults

/* -----------------------------------------------------------------------------
   Pass a given command to the external environment and return first line of
   output as a string.
   -----------------------------------------------------------------------------
*/
::routine cmdOutputLine public
  parse arg command
  if arg(1,'O') then return ''
  output=cmdOutput(command)
  if output=.NIL then return ''
  return output[1]

-- Replace a string containing embedded placeholders with specified values.
::routine mergevalues public
  use arg str, values, PH
  if arg(3,'O') then PH='?'
  posPH=str~pos(PH)
  if posPH=0 then return str
  newstr=''
  do item over values until posPH=0
    parse var str before (PH) str
    newstr=newstr||before||item
    posPH=str~pos(PH)
    if posPH=0 then newstr=newstr||str
  end
  return newstr

-- Alternate pattern .. replace ?1,?2,?n with space delimited string
::routine merge public
  parse arg str, values
  newstr=str
  do w=1 to values~words
    PH='?'w
    newstr=newstr~changestr('?'w,values~word(w))
  end w
  return newstr

::routine hasmark public
  'EXTRACT /MARK/'
  'EXTRACT /FLSCREEN/'
  select
    when MARK.0=0 then return 0                                -- Nothing marked
    when (MARK.2>FLSCREEN.2 | MARK.3<FLSCREEN.1) then return 0 -- Mark exists off screen
    when MARK.6=0 then return 0                                -- Mark exists in another file mark.1
    otherwise nop
  end
  return 1

::routine hasblockmark public
  'EXTRACT /MARK/'
  'EXTRACT /FLSCREEN/'
  rc=0
  select
    when MARK.0=0 then return rc                                -- Nothing marked
    when (MARK.2>FLSCREEN.2 | MARK.3<FLSCREEN.1) then return rc -- Mark exists off screen
    when MARK.6=0 then return rc                                -- Mark exists in another file mark.1
    when MARK.4=0 then return rc                                -- Line mark NOT OK
    otherwise rc=1
  end
  return rc

::routine log public
  parse arg message
  logf=value('X2HOME',,'ENVIRONMENT')||'\x2debug.log'
  -- 'echo' date() time() message '>>' logf
  outp=.stream~new(logf)
  outp~lineout(date() time() message)
  outp~close
  return

/* Present dialog of currently open files */
::routine filering public
  parse arg title, option
  'EXTRACT /RING/'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2

  displaytext.=getDisplayNames(RING., option)
  mxIW=maxItemInStem(displaytext.)
  winwidth=min(maxcols-2, max(maxItemInStem(displaytext.), maxcols%2))
  call log 'MxDW='maxcols-2 'MedDW='maxcols%2 'TW='length(title)+15 'MxIW='mxIW 'winW='winwidth 'opt='option
  'WINDOW' min(maxrows%2,RING.0) winwidth RING.0 title
  do i=1 to RING.0
    'WINLINE' displaytext.i '\n SETRESULT' RING.i
  end i
  'WINWAIT'
  -- Return blank string if user cancels choice
  if symbol('RESULT')='LIT' then return ''
  return result

::routine getDisplayNames private
  use arg srclist., option
  if abbrev('FILENAME', option) then do i=1 to srclist.0
    newlist.i=filespec('N', srclist.i)
  end i
  else do
    'EXTRACT /CD/'
    do i=1 to srclist.0
      newlist.i=abbrevPath(srclist.i, CD.1)
    end i
  end
  newlist.0=srclist.0
  return newlist.

/* Shorten a full path if it is in the current working directory */
::routine abbrevPath private
  parse arg fullpath, currdir
  if abbrev(fullpath, currdir) then partial='.'substr(fullpath,length(currdir))
  else                              partial=fullpath
  return translate(partial, '/', '\')

::routine maxItemInStem private
  use arg srclist.
  maxlen=0
  do i=1 to srclist.0
    if length(srclist.i)>maxlen then maxlen=length(srclist.i)
  end i
  return maxlen

