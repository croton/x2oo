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
  ctxt='-'~copies(msg~length)
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
maxwidth=max(msg~length, title~length)+5
divline='-'~copies(maxwidth)
choices='(Y)es | (N)o'~centre(maxwidth)
info=' 'msg -- ~centre(maxwidth)
if title='' then
  'MESSAGEBOX' info||CR choices
else
  'MESSAGEBOX' title||CR divline||CR info||CR choices
if result='ENTER' then return .true
else if result~translate~abbrev('Y') then return .true
return .false

::routine ask public
parse arg promptTxt
'PROMPT' promptTxt
if rc=0 then
  if result<>'' then return result
return .nil

::routine log public
parse arg message
logf=value('X2HOME',,'ENVIRONMENT')||'\x2debug.log'
outp=.stream~new(logf)
outp~lineout(date() time() message)
outp~close
return

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
  ADDRESS CMD command '| RXQUEUE'
  do while queued()<>0
    parse pull entry
    if entry='' then iterate
    return entry
  end
  return ''

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
 
