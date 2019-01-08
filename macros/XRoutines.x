-- X2 Routines Library, ver. 0.11
::routine msgBox public
  parse arg title, msg, xcmd
  'EXTRACT /ESCAPE/'
  CR=ESCAPE.1||'N'
  -- trace 'i'
  if msg='' then do
    if xcmd='' then return 1
    else do
      -- Show content in a message box
      msg='' -- 'datasource='xcmd
      res=cmdOutput(xcmd)
      do val over res
        msg=msg val||CR
      end
      'MESSAGEBOX' title||CR||msg
    end
  end
  else do
    -- Content of message is literal text
    ctxt=copies('-', length(title))
    ctxt2='---------|---------|---------|---------|'
    'MESSAGEBOX' title||CR ctxt||CR msg
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
  info=' 'msg
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

::routine searchfile public
  parse arg searchString
  'EXTRACT /SCREEN/'
  'EXTRACT /WRAP/'
  'EXTRACT /CURSOR/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  ctr=0
  found.0=0
  'TOP'
  'WRAP OFF'
  'LOCATE /'searchString'/'
  do until ctr=maxrows
    if rc<>0 then leave
    'EXTRACT /CURLINE/'
    ctr=ctr+1
    found.ctr=CURLINE.1
    'FIND REPEAT'
  end
  found.0=ctr
  'FIND RESTORE'
  'WRAP' WRAP.1
  'CURSOR' CURSOR.1 CURSOR.2
  return found.

/* Pass a given command to the external environment and return results as array */
::routine cmdOutput public
  parse arg command
  if arg(1,'O') then return .nil
  myresults=.Array~new
  ADDRESS CMD command '|RXQUEUE'
  do while queued()<>0
    parse pull entry
    if entry='' then iterate
    myresults~append(entry)
  end
  return myresults

/* Pass a given command to the environment and return results as stem */
::routine cmdOutputStem public
  parse arg command
  myresults.0=0
  if arg(1,'O') then return myresults.
  ctr=0
  ADDRESS CMD command '|RXQUEUE'
  do while queued()<>0
    parse pull entry
    if entry='' then iterate
    ctr=ctr+1
    myresults.ctr=entry
  end
  myresults.0=ctr
  return myresults.

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

::routine xsay public
  parse arg message
  'REFRESH'
  'MSG' message
  return

::routine pickfrom public
/* Present a listbox containing items in a directory. */
  use arg map, title
  if title='' then title='Make a selection'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  mxlen=maxItemInDirectory(map)
  if mxlen=0 then mxlen=maxcols%2
  winwidth=min(maxcols-2, max(mxlen, maxcols%3))

  'WINDOW' min(maxrows%2,map~items) winwidth map~items title
  do i over map
    'WINLINE' map[i] '\n SETRESULT' i
  end i
  'WINWAIT'
  -- Return blank string if user cancels choice
  if symbol('RESULT')='LIT' then return ''
  return result

/* Prompt for single choice among items in compound variable. */
::routine pick public
  use arg srclist., title
  if title='' then title='Make a selection'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  mxlen=maxItemInStem(srclist.)
  if mxlen=0 then mxlen=maxcols%2
  winwidth=min(maxcols-2, max(mxlen, maxcols%3))
  return getDialogChoice(srclist., maxrows, winwidth, title)

/* Prompt for single choice among items in a file listing. */
::routine pickFile public
  use arg srclist., title
  if title='' then title='Pick a file'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  displaytext.=getDisplayNames(srclist., 'P')
  mxlen=maxItemInStem(displaytext.)
  if mxlen=0 then mxlen=maxcols%2
  winwidth=calcMinDialogWidth(mxlen, maxcols)
  return getDialogChoice(srclist., maxrows, winwidth, title, displaytext.)

::routine pickmany public
  use arg srclist., title
  if title='' then title='Make a selection'
  'EXTRACT /ESCAPE/'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  mxlen=maxItemInStem(srclist.)
  if mxlen=0 then mxlen=maxcols%2
  winwidth=min(maxcols-2, max(mxlen, maxcols%3))

  'WINDOW' min(maxrows%2,srclist.0) winwidth srclist.0 title
  do i=1 to srclist.0
    'WINLINE' srclist.i '\nSETRESULT' i
  end i
  pmsg=''            -- keep a running list of picked items as feedback
  picked.=0          -- set all indexes as NOT picked
  do forever
    'WINWAIT GETKEY'
    select
      when rc<>0 then leave
      when wordpos(winwait.1, 'UP DOWN LEFT RIGHT')>0 then 'WINSCROLL' winwait.1
      when winwait.1='ESCAPE' then do; picked.=0; leave; end
      when winwait.1='F2' then do; picked.=1; leave; end     -- select all
      when winwait.1='F3' then leave     -- exit, making no changes to selection
      when winwait.1='ENTER' then do; idx=winwait.2; picked.idx=1; leave; end
      when winwait.1='SPACE' then do
        idx=winwait.2
        picked.idx=\picked.idx -- toggle selection state
        pmsg=''
        do w=1 to srclist.0       -- update picked items list
          if picked.w then pmsg=pmsg left(srclist.w,3)
        end w
      end
      otherwise nop
    end -- process key stroke
    'MSG' pmsg
  end
  'WINCLEAR'
  ctr=0
  do w=1 to srclist.0
    if picked.w then do
      ctr=ctr+1
      picks.ctr=srclist.w
    end
  end w
  picks.0=ctr
  return picks.

/* Show open files in a dialog, displaying [F]ilename only (default) or [P]artial path */
::routine filering public
  parse arg title, option
  'EXTRACT /RING/'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  displaytext.=getDisplayNames(RING., option)
  mxIW=maxItemInStem(displaytext.)
  winwidth=calcMinDialogWidth(mxIW, maxcols)
  -- call log 'MxDW='maxcols-2 'MedDW='maxcols%2 'TW='length(title)+15 'MxIW='mxIW 'winW='winwidth 'opt='option
  return getDialogChoice(RING., maxrows, winwidth, title, displaytext.)

/* Display a dialog and return selection */
::routine getDialogChoice private
  use arg returnValues., maxrows, winWidth, title, displayValues.
  'WINDOW' min(maxrows%2, returnValues.0) winWidth returnValues.0 title
  if datatype(displayValues.0,'W') then do i=1 to returnValues.0
    'WINLINE' displayValues.i '\n SETRESULT' returnValues.i
  end i
  else do i=1 to returnValues.0
    'WINLINE' returnValues.i '\n SETRESULT' returnValues.i
  end i
  'WINWAIT'
  if symbol('RESULT')='LIT' then return ''
  return result

::routine calcMinDialogWidth private
  arg mxItemInList, maxcols
  return min(maxcols-2, max(mxItemInList, maxcols%2))

/* Transform a file listing to show either name-only or partial path */
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

::routine maxItemInDirectory private
  use arg map
  maxlen=0
  do i over map
    if length(map[i])>maxlen then maxlen=length(map[i])
  end i
  return maxlen

