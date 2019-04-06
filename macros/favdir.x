/* favdir - Show contents of a directory among a stored list */
arg options
select
  when options='-?' then do; 'MSG favdir [E]'; exit; end
  otherwise
    ans=pickFromFile(getFavorites(), 'Quick Directories')
    if ans='' then 'MSG Selection cancelled'
    else do
      if options='E' then 'CMDTEXT dir' ans
      else                'MACRO dir' ans
    end
end
exit

getFavorites: procedure
  return value('X2HOME',,'ENVIRONMENT')||'\lists\favdir.xfn'

::requires 'XRoutines.x'
