local env = _ENV or getfenv()

--I need an "easier" environment
_G["class"] = dofile "lib/class/middleclass.lua"
dofile "lib/easify.lua"

local function dcopy(t)
  local tt = {}
  if(type(t) ~= "table") then return t end
  for k,v in pairs(t) do
    tt[dcopy(k)] = dcopy(v)
  end
  setmetatable(tt,getmetatable(t))
  return tt
end

--And now I load all the good stuff



--Load all the i18n stuff
i18n = require "lib.i18n"
i18n.loadFile "config/i18n/lang/en.lua"

--Initialize the logging stuff
Log = require "lib.logging"
local TermLog = require "lib.logging.term"
local FileLog = require "lib.logging.file"
local MirrorLog = require "lib.logging.mirror"
local tl = TermLog:new()
local fl = FileLog:new(tostring(os.day()))
local ml = MirrorLog:new(tl,fl)

if(not fs.isDir("log")) then fs.makeDir("log") end

--Add a "divider" to the file log
fl:log("","",0)
fl:log("","STARTING OS",0)
fl:log("","",0)

--Everything this logger logs will be mirrored between the file and the terminal
local log = Log:new(ml)

--Beginning from here we start logging everything boot.lua does

local function loadLibraries(lib,en,reqenv)
  local en = en or env
  local reqenv = reqenv or _ENV
  for k,v in pairs(lib) do
    log:logify(v[1],function()
      en[v[1]] = require(v[2],reqenv)
    end)
  end
end

local libs = {
  {"semver", "lib.semver"},
  {"inspect", "lib.inspect"},
  {"JSON", "lib.json"},
  {"Config", "lib.config"},
  {"cron", "lib.cron"},
  {"SHA", "lib.sha"},
  {"switch", "lib.switch"},
  {"Sandbox", "lib.sandbox"}
}

loadLibraries(libs)

function os.getVersion()
  return semver "0.0.3-alpha"
end

function os.getName()
  return "Helium"
end

function os.getFullName()
  return os.getName() .. " " .. tostring(os.getVersion())
end

log:logify("Sandbox Shell",function()

  sandbox = Sandbox:new("shell",_ENV)
  sandbox:addImport("bin/sym","bin")
  sandbox:addLib("lib.i18n","i18n")
  sandbox:addLib("lib.config","Config")
  sandbox:addLib("lib.clapp.clapp", "CLApp")
  for k,v in pairs(libs) do sandbox:addLib(v[2],v[1]) end
  sandbox:run "bin/bootstrap.lua"

end)
