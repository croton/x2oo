/* -----------------------------------------------------------------------------
   This will throw all combos of fore/background colors into the file
   by Gerry Janssen
   -----------------------------------------------------------------------------
*/
arg options
if showHelp(options, 'linecolors [ALL]') then exit
'extract /flscreen'
'extract /cursor'

palette.1='Black'
palette.2='Blue'
palette.3='Brown'
palette.4='Cyan'
palette.5='Dark Grey'
palette.6='Green'
palette.7='Light Blue'
palette.8='Light Cyan'
palette.9='Light Green'
palette.10='Light Grey'
palette.11='Light Magenta'
palette.12='Light Red'
palette.13='Magenta'
palette.14='Red'
palette.15='White'
palette.16='Yellow'
palette.0=16

if options='ALL' then call writeColors options
else                  call showProfileColors
exit

/* Write ALL color information to the current file. */
writeColors:
do b=1 to palette.0
  bg=palette.b
  'input' '-'~copies(80)
  do f=1 to palette.0
    fg=palette.f
    'input' ' ' fg 'on' bg
     'linecolour 1 80' fg 'ON' bg
     -- 'linecolour 1 20' fg 'ON' bg '21 80' palette.2 'on' palette.15
  end f
end b
'input' '='~copies(80)
'topline' flscreen.1
'cursor' cursor.1 cursor.2
return

showProfileColors: procedure
'EXTRACT /colours/'
'INPUT X2 Color Mapping'
'INPUT' '='~copies(80)
do c=1 to colours.0
  parse var colours.c xarea colorinfo
  'INPUT' c~right(2) xarea~left(30) colorinfo
  'LINECOLOUR 1 80' colorinfo
end c
return

::requires 'XRoutines.x'
