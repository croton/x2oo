/* initcss -- CSS profile startup macro. */
arg stage
select
  when stage='START' then call go
  when stage='END' then call stop
  otherwise
  'MESSAGEBOX Macro initcss initialized. Input=['stage']'
end
exit

/* Steps to perform BEFORE an edit session. */
go: procedure
parse arg options
colorsfile=value('X2HOME',,'ENVIRONMENT')'\lists\csscolors.xfn'
inp=.Stream~new(colorsfile)
colors=.Directory~new
do while inp~lines>0
  parse value inp~linein with name rgb
  colors~put(rgb, translate(name))
end
inp~close
call xsay 'Storing' colors~items 'css colors in X2 edit session'
.environment['csscolors']=colors
/*
'EDIT initcss_temp.txt'
'INPUT Environment at edit START'
loop i over .environment
  'INPUT' i '=' .environment[i]
end i
*/
return

/* Steps to perform AFTER an edit session. */
stop: procedure
parse arg options
colors=.environment['csscolors']
if colors<>.NIL then do
  drop colors
  .environment['csscolors']=.NIL
  'echo Clearing CSS color entries for X2 Editor!'
end
return

error:
dashes=copies('=', 40)
say dashes
say 'Error' rc 'at line' sigl
-- say 'Instruction:' sourceline(sigl)
say dashes
return

::requires 'XRoutines.x'
