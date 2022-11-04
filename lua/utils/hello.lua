

local function helloMenu()
  local curDate = os.date("*t")
  return string.format([[
  ================================
  Welcome to LUA API
  ================================
  Minh Nguyen - Copyright (C) %s
  ]], curDate.year)
end

return {
  helloMenu = helloMenu
}