/* linecolor -- Set the color for the current line. */
parse arg fg bg
if showHelp(fg, 'linecolor [fg bg]') then exit

'EXTRACT /CURLINE/'
linelen=length(CURLINE.1)
fgDef='blue'
bgDef='white'
if fg='' then do
  'LINECOLOUR 1' linelen '/DATA'  -- reset to normal
  'MSG Line color has been reset'
end
else
  'LINECOLOUR 1' linelen translate(fg, ' ', '_') 'on' translate(bg, ' ', '_')
exit

::requires 'XRoutines.x'
