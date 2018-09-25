/* togglefile - Choose a pair of files between which to toggle */
arg doPick
if doPick=1 then call linkPair filering('Choose a file to toggle')
else             call jump2previous
exit

linkPair: procedure
  parse arg newfilename
  'EXTRACT /FILENAME/'
  push FILENAME.1
  'EDIT' newfilename
  'REFRESH'
  'MSG Jump to' filespec('N', newfilename) 'from' filespec('N', FILENAME.1)
  return

jump2previous: procedure
  if queued()=0 then
    'MSG No previous file specified.'
  else do
    parse pull prevfile
    'EXTRACT /FILENAME/'
    push FILENAME.1
    'EDIT' prevfile
    'MSG Jump to' filespec('N', prevfile) 'from' filespec('N', FILENAME.1)
  end
  return

::requires 'XRoutines.x'
