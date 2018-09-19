/* simple -- For use with expansion macro */
parse arg indent argval
'INPUT -- Expansion macro arg::' argval 'Indent='indent
-- Triggered by !n>
-- prefix=subword(argval, 1,length(argval)-1)
prefix=left(argval,length(argval)-3)
newline=copies(' ',indent)||prefix' ng-click="">'
'INPUT' prefix 'ng-click="">'
-- 'CURSOR +0 +'(length(newline)-2)
exit
