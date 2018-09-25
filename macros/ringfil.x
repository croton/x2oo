/* ringfil - Display the file ring */
arg options -- Display (f)ilenames only or include a 'partial path'?
fn=filering('Open files', options)
'REFRESH'
if filename<>'' then 'EDIT' filename
exit

::requires 'XRoutines.x'
