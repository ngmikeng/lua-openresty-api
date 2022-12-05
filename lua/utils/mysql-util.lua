local mysql_c = require("resty.mysql")
local env = require("config.env")
local json = require("cjson.safe")

local _M = {}

local mt = { __index = _M }

--[[ 
  First get a connection from the connection pool, if not then establish a connection.
  return:
  - false, error message.
  - true, database connection
--]]
function _M.get_connect(self)

  if self.client then
    return true, self.client
  end

  local client, errmsg = mysql_c:new()
  if not client then
    return false, "mysql.socket_failed: " .. (errmsg or "nil")
  end

  client:set_timeout(self.db_timeout)

  local options = {
    host = self.db_host,
    port = self.db_port,
    user = self.db_user,
    password = self.db_password,
    database = self.db_name
  }
  local result, errmsg, errno, sqlstate = client:connect(options)

  if not result then
    return false, errmsg
  end

  local query = "SET NAMES " .. self.db_charset
  local result, errmsg, errno, sqlstate = client:query(query)
  if not result then
    return false, errmsg
  end
  self.client = client
  return true, client
end

--[[
    Return the connection to the connection pool. Using set_keepalive instead of close() will enable the connection pool feature,
    and you can specify the maximum idle time of the connection and the maximum number of connections in the connection pool for each nginx worker process
--]]
function _M.close(self)
  --self.client:close()
  if self.client then
    self.client:set_keepalive(10000, 100)
  end
end

--[[ 
  When the query has a result data set, return the result data set
  Return query affects return when there is no data dataset:
  - false, error message, sqlstate structure.
  - true, result set, sqlstate structure.
--]]
function _M.mysql_query(self, sql)
  local result, errmsg = self.client:query(sql)

  if errmsg then
    return false, errmsg
  end

  return true, result
end

function _M.query(self, sql)

  local ret, res, _ = self:mysql_query(sql)
  if not ret then
    self:close()
    error("sql query error:" .. res)
  end

  return setmetatable(res, json.empty_array_mt)
end

function _M.execute(self, sql)

  local ret, res, sqlstate = self:mysql_query(sql)
  if not ret then
    self:close()
    error("mysql.execute_failed. res: " .. (res or 'nil') .. ",sql_state: " .. (sqlstate or 'nil'))
  end

  return res.affected_rows
end

-- Open transaction
function _M.transactionOn(self)
  self:mysql_query([[begin]])
end

-- Commit transaction
function _M.commit(self)
  self:mysql_query([[commit]])
end

-- Rollback transaction
function _M.rollback(self)
  self:mysql_query([[rollback]])
end

function _M.new(opts)
  opts = opts or {}
  local db_host = opts.host or env.mysql_host
  local db_port = opts.port or env.mysql_port
  local db_user = opts.user or env.mysql_username
  local db_password = opts.password or env.mysql_password
  local db_name = opts.db_name or env.mysql_database
  local db_timeout = opts.db_timeout or 10000
  local db_charset = opts.charset or 'utf8'

  local newMysql = setmetatable({
    db_host = db_host,
    db_port = db_port,
    db_user = db_user,
    db_password = db_password,
    db_name = db_name,
    db_timeout = db_timeout,
    db_charset = db_charset
  }, mt)

  -- Connect to mysql when creating to ensure that all methods in an object use the same connection
  local ret, client = newMysql:get_connect()
  if not ret then
    ngx.log(ngx.ERR, client)
    return false, client, nil
  end

  return newMysql
end

return _M
