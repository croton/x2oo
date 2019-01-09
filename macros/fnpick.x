/* fnpick -- Pull up a dialog from which to select functions.
   The first argument, if provided, is the filestem of the text file and
   will be searched in two places - the current directory and
   in X2HOME\lists. If not provided, the X2 variable CODE_TYPE
   will be retrieved and a filename <code_type>.xfn will be searched.
*/
parse arg codeType template
if codeType='-?' then do; 'MSG fnpick [filename]'; exit; end

if codeType='' then do
  'EXTRACT /CODE_TYPE/'
  codeType=CODE_TYPE.1
end
call insertFn codeType, template
exit

/* Load items from specified file and keyin the selected one within a template.*/
insertFn: procedure
  parse arg filestem, tmpl
  fnfile=getFunctionFile(filestem)
  if fnfile='' then 'MSG Function file not found:' filestem
  else do
    ans=getFileChoice(fnfile, filestem)
    if ans='' then
      'MSG Selection cancelled'
    else do
      if tmpl='' then 'KEYIN' ans
      else            'KEYIN' changestr('@', tmpl, ans)
    end
  end
  return

/* Choose from values in specified file (non-OO) */
getchoice: procedure
  parse arg fnfile, filestem
  'MACRO chooser --f' fnfile '--t' filestem '--q'
  entry=''
  if queued()>0 then parse pull entry
  return entry

getFileChoice: procedure
  parse arg fnfile, filestem
  return pickFromFile(fnfile, filestem)

/* Search for a matching file given a filespec */
getFunctionFile: procedure
  parse arg filestem
  fnfile=filestem'.xfn'
  x2home=value('X2HOME',,'ENVIRONMENT')
  filepaths='.\'fnfile x2home'\lists\'fnfile
  do w=1 to words(filepaths)
    fn=word(filepaths,w)
    if stream(fn,'c','query exists')<>'' then return fn
  end w
  return ''

::requires 'XRoutines.x'
