local hello = require "utils.hello"

local _M = {}

function _M.greet(message)
  ngx.say(hello.helloMenu(), message)
end

return _M