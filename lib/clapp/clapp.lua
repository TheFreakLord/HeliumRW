--#TODO:0 Add functionality to CLApp @CLApp +CLApp

--[[

local function expectTable(check,base)
  for k,v in pairs(base) do
    if(not check[k]) then return error("Key ["..k.."] not present") end
    if(type(check[k]) ~= v) then return error("Key ["..k.."] has the wrong value. Expected "..v..", got "..type(check[k])) end
  end
end

]]