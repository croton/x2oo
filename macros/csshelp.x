/* csshelp - Get help on CSS attributes. */
arg option
if option='-?' then do; 'MSG csshelp [C]'; exit; end

if abbrev('COLOR', option, 1) then
  call pickColor
else
  call lookupAttrib
exit

pickColor: procedure
  parse arg format
  colors=.environment['colors']
  if colors=.nil then call xsay 'No colors list available'
  else do
    dir=.Directory~new
    do key over colors
      dir~put(key colors[key], key)
    end
    choice=pickfrom(dir, 'Colors')
    if choice='' then call xsay 'No choice made'
    else              'KEYIN' choice
  end
  return

lookupAttrib: procedure
  'EXTRACT /CURLINE/'
  name=getAttrib(CURLINE.1)
  if name='' then
    'MSG No attribute on current line!'
  else do
    atbs=.environment['cssattribs']
    if atbs=.nil then call xsay 'No css attributes list available'
    else do
      if atbs[name]=.NIL then call xsay 'Unrecognized css attribute:' name
      else do
        choice=popup(name, atbs[name])
        if choice='' then call xsay 'No choice made'
        else              'KEYIN' choice
      end
    end
  end
  return

getAttrib: procedure
  parse arg text
  if pos(':', text)=0 then return ''
  parse var text attrib ':' .
  return strip(attrib)

popup: procedure
  parse arg name, values
  choices.0=0
  if values='' then list='initial;inherit'
  else              list=values';initial;inherit'
  do i=1 until list=''
    parse var list item ';' list
    choices.i=item
  end i
  choices.0=i
  return pick(choices., name)

::requires 'XRoutines.x'
