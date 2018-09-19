::requires 'XList.cls'
::requires 'XRoutines.x'
::class FunctionPicker public

::method funcdir ATTRIBUTE
::method isSingleColumnList ATTRIBUTE
::method cmd_singleValue ATTRIBUTE
::method cmd_category ATTRIBUTE
::method cmd_subcategory ATTRIBUTE
::method cmd_hidecategory ATTRIBUTE
::method cmd_subcatoption ATTRIBUTE
::method cmd_oplist ATTRIBUTE

::method init
  expose dlg dlgtitle
  parse arg fnsfile, title, funcloc
  if funcloc='' then self~funcdir=value('x2home',,'ENVIRONMENT')||'\lists\'
  else               self~funcdir=funcloc'\'
  fnspath=self~funcdir||fnsfile
  if SysFileExists(fnspath) then ecmd='type' fnspath '|head -1'
  else                           ecmd='echo Invalid filepath:' fnspath
  dlg=.XList~new(ecmd)
  if title='' then parse var fnsfile title '.' .
  dlgtitle=title
  self~isSingleColumnList=(dlg~first~words=1)                   -- Is this a single column list?
  self~cmd_singleValue='type' fnspath'|sort'                    -- Get a single column
  self~cmd_category='type' fnspath'|col 1 |sort |uniq'          -- Get the first of two columns
  self~cmd_subcategory='type' fnspath'|grep -ie "^@" |col 2 |sort' -- Get items in a category
  self~cmd_hidecategory='type' fnspath'|col 2 |sort |uniq'      -- Get all subcategories
  self~cmd_subcatoption='type' fnspath'|col 2-'                -- Get all subcategories and options
  self~cmd_oplist='type' fnspath'|col 2- |grep -ie "^@"|col 2'  -- Get items in sub category

::method choose
  expose dlg dlgtitle
  arg noDrillDown
  if self~isSingleColumnList then return dlg~pickfromc(self~cmd_singleValue, dlgtitle)
  if arg(1,'E') then do
    -- Prompt with all sub-categories; no drill down
    return dlg~pickfromc(self~cmd_hidecategory, dlgtitle)
  end
  -- Prompt with category first
  ok=dlg~loadbycmd(self~cmd_category)
  if \ok then return 'No items to pick from' self~cmd_category
  choice=dlg~pick(dlgtitle)
  -- Drill down to sub category
  ecmd=self~cmd_subcategory~changestr('@',choice)
  ok=dlg~loadbycmd(ecmd)
  if ok then return dlg~pick(dlgtitle)
  return 'No items to pick from' ecmd

-- Choose from last column which is a delimited string to be parsed into a list
::method chooseOption
  expose dlg dlgtitle
  -- Prompt with sub category
  ok=dlg~loadbycmd(self~cmd_subcatoption,1)  -- arg 2 indicates listText<>value
  if \ok then return 'No items to pick from' self~cmd_subcatoption
  parse value dlg~pick(dlgtitle) with subcat options
  origops=options
  if options='' then return subcat
  -- Parse delimited string into stem variable
  items.=''
  do ctr=1 while options<>''
    parse var options items.ctr '|' options
  end
  items.0=ctr-1
  call log 'Parse' origops 'into' items.0 'items'
  return subcat':' dlg~pickfrom(items.,dlgtitle)

-- Choose category, do NOT drill down to subcategories
::method chooseCategory
  expose dlg dlgtitle
  return dlg~pickfromc(self~cmd_category, dlgtitle)

::method string
  return 'A FunctionPicker based in' self~funcdir

