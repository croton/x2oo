::requires 'XList.cls'
-- ::requires 'XRoutines.x'
::class FolderPicker public

::method origdir ATTRIBUTE
::method cmd_getdirs ATTRIBUTE

::method init
expose dlg
parse arg currdir
if currdir='' then do
  'EXTRACT /CD/'
  self~origdir=CD.1
end
else
  self~origdir=currdir
self~cmd_getdirs='dir @ /a:d /b'
dlg=.XList~new
return

::method pickdir
expose dlg
parse arg currdir
if currdir='' then currdir=self~origdir
ok=dlg~load(dlg~expandCmd(self~cmd_getdirs, currdir))
if ok then
  entries.=dlg~dsrc
else
  return 'No sub directories in' currdir

-- Build the listbox
dlgwidth=35
dlgheight=30
'WINDOW' dlgheight dlgwidth entries.0 currdir
do i=1 to entries.0
  'WINLINE' entries.i||'\nSETRESULT' entries.i
end i
dirpicked=''
do forever
  'WINWAIT GETKEY'
  select
    when rc<>0 then leave
    -- allow scrolling
    when wordpos(winwait.1, 'UP DOWN LEFT RIGHT')>0 then 'WINSCROLL' winwait.1
    -- no selection
    when winwait.1='ESCAPE' then leave
    -- dismiss dialog with current selection
    when winwait.1='ENTER' then do
      dirpicked=winwait.3
      leave
    end
    -- toggle selection of current item
    when winwait.1='BACKSPC' then do
      dirpicked=winwait.3
      leave
    end
    when winwait.1='SPACE' then do
      dirpicked=winwait.3
      leave
    end
    otherwise nop
  end
  'MSG' currdir dirpicked winwait.1
end
'WINCLEAR'
if winwait.1='SPACE' then do
  if currdir~right(1)='\' then dirpath=currdir||dirpicked
  else                         dirpath=currdir'\'dirpicked
  return self~pickdir(dirpath)
end
else if winwait.1='BACKSPC' then do
  parentdir=currdir~left(currdir~lastpos('\'))
  if parentdir='' then parentdir=self~origdir
  return self~pickdir(parentdir)
end
return dirpicked

::method string
return 'A FolderPicker'
