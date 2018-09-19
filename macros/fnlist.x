/* fnlist -- Display a popup from which to select functions. Function lists are
   defined in space-delimited text files within X2HOME\lists in the format
   <category> <function name> or simply
   <function name>
*/
parse arg fnsfile noDrillDown
if showHelp(fnsfile, 'fnlist fnfilename',1) then exit

fp=.FunctionPicker~new(fnsfile)
if noDrillDown='' then
  fnc=fp~choose
else
  fnc=fp~choose(1)
if fnc='' then do
  'MSG Selection cancelled'
  return
end

if fnc~pos('(')=0 then
  'KEYIN' fnc
else do
  'KEYIN' fnc
  'LOCATE /(/-'  -- search backwards for open parens
  'CURSOR +0 +1' -- move cursor forward
end
exit

::requires 'FunctionPicker.cls'
