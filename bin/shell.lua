term.clear()
term.setCursorPos(1,1)

local new = false

local conf = Config:new("shell", function() new = true end)
local currentDir = "/"
local path = "/bin"

local commands = {}
local running = true

_G.shell = {}

function shell.getPath()
  return path
end

function shell.setPath(pat)
  path = pat
end

function shell.getCurrentDir()
  return currentDir
end

function shell.setCurrentDir(newDir)
  currentDir = newDir
end

local function split(str,pat)
  local fields = {}
  local pat = pat or "%s"
  str:gsub("[^"..pat.."]+", function(c) fields[#fields+1] = c end)
  return fields
end

if(new) then
  conf:set("useColors",true)
  conf:set("colors.arrow", colors.orange)
  conf:set("colors.user", colors.green)
  conf:set("colors.text", colors.white)
  conf:set("colors.error", colors.red)
  conf:set("colors.hostname.color", colors.lime)
  conf:set("colors.hostname.divider.char", "@")
  conf:set("colors.hostname.divider.color", colors.lightGray)
  conf:save()
end

if(not fs.exists("lang")) then fs.makeDir("lang") end
if(not fs.exists("lang/en.lua")) then
  local handle = fs.open("lang/en.lua","w")
  handle.write("return ")
  handle.write[[
  { en = {
    shell = {
        welcome = "Welcome to %{name}",
        error   = {
          command_not_found = "Command not found!"
        }
      }
    }
  }
  ]]
  handle.close()
end

i18n.loadFile "lang/en.lua"

term.setTextColor(colors.gray)
print(i18n("shell.welcome", {name = os.getFullName()}))

local function checkFile(name)

  local cur = fs.combine(currentDir,name)
  if(fs.exists(cur) and (not fs.isDir(cur))) then
    return cur
  end

  local entries = split(path,";")
  for _,folder in pairs(entries) do
    local list = fs.list(folder)
    for k,v in pairs(list) do
      if(v == name) then
        return fs.combine(folder,v)
      end
    end
  end
  return nil
end


local function shell()
  while running do
    term.setTextColor(conf:get "colors.user")
    term.write "root"
    term.setTextColor(conf:get "colors.hostname.divider.color")
    term.write(conf:get "colors.hostname.divider.char")
    term.setTextColor(conf:get "colors.hostname.color")
    term.write("host")
    term.setTextColor(conf:get "colors.arrow")
    term.write((currentDir == "/" and "" or " "..currentDir))
    term.write ">"
    term.setTextColor(conf:get "colors.text")
    local content = read()

    term.setTextColor(colors.lightGray)

    local command = split(content," \t")

    local file = checkFile(command[1])

    if(not file) then
      term.setTextColor(conf:get "colors.error")
      print(i18n "shell.error.command_not_found" )
      return
    end

    local handle = fs.open(file,"r")
    local cont = handle.readAll()
    handle.close()
    local ok, err = load(cont,"",nil,getfenv())
    ok(select(2,unpack(command)))
  end
end

parallel.waitForAny(shell)
