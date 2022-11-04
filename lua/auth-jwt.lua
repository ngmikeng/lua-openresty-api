local jwt = require "lib.jwt.jwt"
local validators = require "lib.jwt.jwt-validators"

if ngx.var.request_method ~= "OPTIONS" and not string.match(ngx.var.uri, "login") then
  local headers = ngx.req.get_headers()
  local jwtToken = headers["Authorization"]
  if jwtToken == nil then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say("{\"error\": \"Forbidden\"}")
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end

  local claim_spec = {
    exp = validators.is_not_expired()
  }

  local jwt_obj = jwt:verify("secret", jwtToken, claim_spec)

  if not jwt_obj["verified"] then
    ngx.status = ngx.HTTP_UNAUTHORIZED
    ngx.header.content_type = "application/json; charset=utf-8"
    ngx.say("{\"error\": \"INVALID_JWT\"}")
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
  end
end
