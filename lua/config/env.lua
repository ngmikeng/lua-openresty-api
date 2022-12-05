
local _M = {}

local mt = { __index = _M }

_M.environment = os.getenv("ENV") or ""

ngx.log(ngx.INFO, "ENV: ", _M.environment)

-- MYSQL
_M.mysql_host = "mysql"
_M.mysql_port = 3306
_M.mysql_username = "admin"
_M.mysql_password = "mysql@123"
_M.mysql_database = "lua-openrestry-api"


return (_M.environment and _M.environment ~= "") and setmetatable(require("env-" .. _M.environment), mt) or _M

