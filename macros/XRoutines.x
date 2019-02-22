-- X2 Routines Library, ver. 0.13
::routine msgBox public
  parse arg title, msg
  'EXTRACT /ESCAPE/'
  NL=ESCAPE.1||'N'
  -- ruleline=copies('-', length(title))
  ruleline=copies('-', 35)
  'MESSAGEBOX' title||NL ruleline||NL||msg
  return result

::routine msgBoxFromStem public
  use arg title, textlines.
  'EXTRACT /SCREEN/'
  'EXTRACT /ESCAPE/'
  NL=ESCAPE.1||'N'
  maxlines=SCREEN.1-5
  msg=''
  do i=1 to textlines.0-1 while i<maxlines
    msg=msg textlines.i||NL
  end i
  msg=msg textlines.i
  if i>=maxlines then msg=msg '...'
  call msgBox title, msg
  return

/* -----------------------------------------------------------------------------
   A message box which provides a Yes/No prompt. Returns boolean value.
   -----------------------------------------------------------------------------
*/
::routine msgYNBox public
  parse arg msg, title
  'EXTRACT /ESCAPE/'
  NL=ESCAPE.1||'N'
  if msg='' then msg='Continue?'
  maxwidth=max(length(msg), length(title))+5
  divline=copies('-', maxwidth)
  choices=centre('(Y)es | (N)o', maxwidth)
  info=' 'msg
  if title='' then
    'MESSAGEBOX' info||NL choices
  else
    'MESSAGEBOX' title||NL divline||NL info||NL choices
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

/* Prompt for single choice among items in a stem. */
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

/* Prompt for multiple choices among items in a stem. */
::routine pickmany public
  use arg srclist., title
  if title='' then title='Make a selection'
  'EXTRACT /ESCAPE/'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  totalitems=srclist.0
  'WINDOW' min(maxrows%2,totalitems) calcMinDialogWidth(maxItemInStem(srclist.), maxcols) totalitems title
  do i=1 to totalitems
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
  do w=1 to totalitems
    if picked.w then do
      ctr=ctr+1
      picks.ctr=srclist.w
    end
  end w
  picks.0=ctr
  return picks.

/* Prompt for single choice among items in an array. */
::routine pickFromArray public
  use arg srclist, title
  if title='' then title='Make a selection'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  mxlen=maxItemInArray(srclist)
  if mxlen=0 then mxlen=maxcols%2
  winwidth=min(maxcols-2, max(mxlen, maxcols%3))
  -- winwidth=calcMinDialogWidth(mxlen, maxcols)
  return getDialogAChoice(srclist, maxrows, winwidth, title)

/* Prompt for single choice among items in a map or directory. */
::routine pickfrom public
  use arg map, title
  if title='' then title='Make a selection'
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  'WINDOW' min(maxrows%2,map~items) calcMinDialogWidth(maxItemInDirectory(map), maxcols) map~items title
  do i over map
    'WINLINE' map[i] '\n SETRESULT' i
  end i
  'WINWAIT'
  -- Return blank string if user cancels choice
  if symbol('RESULT')='LIT' then return ''
  return result

/* Prompt for multiple choices among items in an array. */
::routine pickManyFromArray public
  use arg srclist, title
  'EXTRACT /SCREEN/'
  return getDialogAChoices(srclist, SCREEN.1, calcMinDialogWidth(maxItemInArray(srclist), SCREEN.2), title)

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

/* Prompt for single choice among lines in a given file. */
::routine pickFromFile public
  parse arg filename, title
  if \SysFileExists(filename) then return ''
  ifile=.Stream~new(filename)
  contents=ifile~arrayin
  ifile~close
  return pickFromArray(contents, title)

/* Prompt for multiple choices among lines in a given file. */
::routine pickManyFromFile public
  parse arg filename, title
  if \SysFileExists(filename) then return ''
  ifile=.Stream~new(filename)
  contents=ifile~arrayin
  ifile~close
  return pickManyFromArray(contents, title)

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
  totalItems=returnValues.0
  'WINDOW' min(maxrows%2, totalItems) winWidth totalItems title
  if datatype(displayValues.0,'W') then do i=1 to totalItems
    'WINLINE' displayValues.i '\n SETRESULT' returnValues.i
  end i
  else do i=1 to totalItems
    'WINLINE' returnValues.i '\n SETRESULT' returnValues.i
  end i
  'WINWAIT'
  if symbol('RESULT')='LIT' then return ''
  return result

/* Display a dialog and return a selection, using arrays */
::routine getDialogAChoice private
  use arg returnValues, maxrows, winWidth, title
  totalItems=returnValues~items
  'WINDOW' min(maxrows%2, totalItems) winWidth totalItems title
  do i=1 to totalItems
    'WINLINE' returnValues[i] '\n SETRESULT' returnValues[i]
  end i
  'WINWAIT'
  if symbol('RESULT')='LIT' then return ''
  return result

/* Display a dialog and return one or more selections, using arrays */
::routine getDialogAChoices private
  use arg returnValues, maxrows, winWidth, title
  totalItems=returnValues~items
  'WINDOW' min(maxrows%2, totalItems) winWidth totalItems title
  do i=1 to totalItems
    'WINLINE' returnValues[i] '\n SETRESULT' i   -- returnValues[i]
  end i
  pmsg=''            -- keep a running list of picked items as feedback
  picked.=0          -- set all indexes as NOT picked
  do forever
    'WINWAIT GETKEY'
    select
      when rc<>0 then leave
      when wordpos(winwait.1, 'UP DOWN LEFT RIGHT')>0 then 'WINSCROLL' winwait.1
      -- ESC = exit and ignore any selections
      when winwait.1='ESCAPE' then do; picked.=0; leave; end
      -- F2 = select all
      when winwait.1='F2' then do; picked.=1; leave; end
      -- F3 = exit and maintain any selections
      when winwait.1='F3' then leave
      -- ENTER = pick current and exit
      when winwait.1='ENTER' then do; idx=winwait.2; picked.idx=1; leave; end
      -- SPACE = toggle current
      when winwait.1='SPACE' then do
        idx=winwait.2
        picked.idx=\picked.idx
        pmsg=''
        do w=1 to totalItems       -- update picked items list
          if picked.w then pmsg=pmsg left(returnValues[w],3)
        end w
      end
      otherwise nop
    end -- process key stroke
    'MSG' pmsg
  end
  'WINCLEAR'
  picks=.Array~new
  do w=1 to totalItems
    if picked.w then picks~append(returnValues[w])
  end w
  return picks

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
::routine abbrevPath public
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

::routine maxItemInArray private
  use arg srclist
  maxlen=0
  loop item over srclist
    if length(item)>maxlen then maxlen=length(item)
  end
  return maxlen

::routine maxItemInDirectory private
  use arg map
  maxlen=0
  do i over map
    if length(map[i])>maxlen then maxlen=length(map[i])
  end i
  return maxlen

