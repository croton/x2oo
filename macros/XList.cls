/* -----------------------------------------------------------------------------
   XList -- X2 List dialog
   Prompts the user with options and returns choice(s).
   -----------------------------------------------------------------------------
*/
::class XList public

::method entries ATTRIBUTE
::method rtnvals ATTRIBUTE
::method dlgRows ATTRIBUTE
::method dlgCols ATTRIBUTE

::method init
  expose maxrows maxcols
  parse arg extcmd
  'EXTRACT /SCREEN/'
  maxrows=SCREEN.1
  maxcols=SCREEN.2
  self~entries=.array~new
  self~rtnvals=.array~new
  self~dlgRows=20
  self~dlgCols=25
  if extcmd<>'' then self~loadbycmd(extcmd)
  return

-- Load items from a stem collection
::method load
  use arg itemtext., itemval.
  if itemtext.=.NIL then return .false
  if self~entries~items>0 then do
    self~entries~empty
    self~rtnvals~empty
  end
  do key over itemtext.
    if key>0 then self~entries~append(itemtext.key)
  end
  if itemval.<>.NIL then do key over itemval.
    if key>0 then self~rtnvals~append(itemval.key)
  end
  return self~entries~items>0

-- Load items from an external command
::method loadbycmd
  parse arg extcmd, doparse
  if extcmd='' then return .false
  ADDRESS CMD extcmd '| RXQUEUE'
  if self~entries~items>0 then self~entries~empty
  if self~rtnvals~items>0 then self~rtnvals~empty
  if doparse=1 then do while queued()<>0
    parse pull item itemvalue
    if item<>'' then do
      self~entries~append(item)
      self~rtnvals~append(item itemvalue)
    end
  end
  else do while queued()<>0
    parse pull item
    if item<>'' then self~entries~append(item)
  end
  return self~entries~items>0

::method hasitems
  return self~entries~items>0

-- Create the editor pop-up and return a single choice
::method pick
  expose maxrows maxcols
  parse arg title, envkey
  if \self~hasitems then return 'No items to pick!'
  'WINDOW' min(self~dlgRows,maxrows) max(self~dlgCols,title~length+5) self~entries~items title
  if self~rtnvals~items>0 then do i=1 to self~entries~items
    txt=self~entries[i]
    val=self~rtnvals[i]
    if val=.NIL then val=txt
    'WINLINE' txt'\nSETRESULT' val
  end i
  else do val over self~entries
    'WINLINE' val'\nSETRESULT' val
  end
  'WINWAIT'
  -- Return blank string if user cancels choice
  if symbol('RESULT')='LIT' then return ''
  else choice=result
  -- Store choice under specified key to remember most recent selection
  if arg(2,'E') then .environment[envkey]=choice
  return choice

-- Create the editor pop-up and return an array of choices
::method picks
  expose maxrows
  parse arg title
  if title='' then title='Make one or more selections'
  'EXTRACT /ESCAPE/'
  'WINDOW' min(self~dlgRows,maxrows) max(self~dlgCols,title~length+5) self~entries~items title
  do i=1 to self~entries~items
    'WINLINE' self~entries[i] || '\nSETRESULT' i
  end i
  pmsg=''            -- keep a running list of picked items as feedback
  picked.=0          -- set all indexes as NOT picked
  do forever
    'WINWAIT GETKEY'
    select
      when rc<>0 then leave
      when wordpos(winwait.1, 'UP DOWN LEFT RIGHT')>0 then 'WINSCROLL' winwait.1
      when winwait.1='ESCAPE' then do; picked.=0; leave; end
      when winwait.1='F2' then do; picked.=1; leave; end -- select all
      when winwait.1='F3' then leave                     -- exit, making no changes
      when winwait.1='ENTER' then do; idx=winwait.2; picked.idx=1; leave; end
      when winwait.1='SPACE' then do
        idx=winwait.2
        picked.idx=\picked.idx             -- toggle selection state
        pmsg=''
        do w=1 to self~entries~items       -- update picked items list
          if picked.w then pmsg=pmsg left(self~entries[w],3)
        end w
      end
      otherwise nop
    end              -- process key stroke
    'MSG' pmsg
  end
  'WINCLEAR'
  -- Return user's choices in array
  choices=.Array~new
  do w=1 to self~entries~items
    if picked.w then choices~append(self~entries[w])
  end w
  return choices

-- Convenience method which loads data by external command AND prompts user
::method pickfromc
  parse arg extcmd, title, envkey
  if self~loadbycmd(extcmd) then return self~pick(title, envkey)
  return 'no_choice_'extcmd

-- Convenience method which loads data from a stem AND prompts user
::method pickfrom
  use arg itemtext., title, envkey, itemval.
  if itemval.=.NIL then ok=self~load(itemtext.)
  else                  ok=self~load(itemtext., itemval.)
  if ok then return self~pick(title, envkey)
  return 'no_choice_from_collection'

-- Convenience method like PICKFROMC but returns multiple choices
::method mpickfromc
  parse arg extcmd, title, width, height
  if self~loadbycmd(extcmd) then return self~picks(title, width, height)
  return .array~of('no_choice_'extcmd)

-- Convenience method like PICKFROM but returns multiple choices
::method mpickfrom
  use arg vals., title, width, height
  if self~load(vals.) then return self~picks(title, width, height)
  return .array~of('no_choice_from_collection')

::method first
  rc=self~entries[1]
  if rc=.NIL then return ''
  return rc

::method string
  expose extcmd
  return 'A List Box' self~dlgRows 'x' self~dlgCols
