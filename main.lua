require('mobdebug').start()
require('string')

local debugFile = io.open("networking-debug.txt", "w")

local networking = RegisterMod("isaac-networking", 1)

local networkX = 0.0
local networkY = 0.0

local host, port = "127.0.0.1", 9999
local socket = require("socket")
local tcp = assert(socket.tcp())

-- https://github.com/excessive/cpml/blob/master/modules/utils.lua
local frexp = math.frexp or function(x)
  if x == 0 then
    return 0, 0
  end
  
  local e = math.floor(math.log(math.abs(x)) / math.log(2) + 1)
  return x / (2 ^ e), e
end

local ldexp = math.ldexp or function(m, n)
  return m * (2 ^ n)
end

-- http://stackoverflow.com/q/14416734
function PackNumber(number)
    if number == 0 then
        return string.char(0x00, 0x00, 0x00, 0x00)
    elseif number ~= number then
        return string.char(0xFF, 0xFF, 0xFF, 0xFF)
    else
        local sign = 0x00
        if number < 0 then
            sign = 0x80
            number = -number
        end
        local mantissa, exponent = frexp(number)
        exponent = exponent + 0x7F
        if exponent <= 0 then
            mantissa = ldexp(mantissa, exponent - 1)
            exponent = 0
        elseif exponent > 0 then
            if exponent >= 0xFF then
                return string.char(sign + 0x7F, 0x80, 0x00, 0x00)
            elseif exponent == 1 then
                exponent = 0
            else
                mantissa = mantissa * 2 - 1
                exponent = exponent - 1
            end
        end
        mantissa = math.floor(ldexp(mantissa, 23) + 0.5)
        return string.char(
                sign + math.floor(exponent / 2),
                (exponent % 2) * 0x80 + math.floor(mantissa / 0x10000),
                math.floor(mantissa / 0x100) % 0x100,
                mantissa % 0x100)
    end
end

-- http://stackoverflow.com/q/14416734
function UnpackNumber(packed)
    local b1, b2, b3, b4 = string.byte(packed, 1, 4)
    local exponent = (b1 % 0x80) * 0x02 + math.floor(b2 / 0x80)
    local mantissa = ldexp(((b2 % 0x80) * 0x100 + b3) * 0x100 + b4, -23)
    if exponent == 0xFF then
        if mantissa > 0 then
            return 0 / 0
        else
            mantissa = math.huge
            exponent = 0x7F
        end
    elseif exponent > 0 then
        mantissa = mantissa + 1
    else
        exponent = exponent + 1
    end
    if b1 >= 0x80 then
        mantissa = -mantissa
    end
    return ldexp(mantissa, exponent - 0x7F)
end

function networking:PlayerInit(aConstPlayer)
  if tcp ~= nil then
    tcp:connect(host, port)
  end
end

function networking:PostRender()
  Isaac.RenderText("Hello Network!", networkX, networkY, 1.0, 1.0, 1.0, 1.0)
end

function networking:PostUpdate()
  local player = Isaac.GetPlayer(0)
  
  if tcp ~= nil then
    tcp:send(PackNumber(player.Position.X) .. PackNumber(player.Position.Y))
    local data = tcp:receive(8)
    if data ~= nil then
      local xValue = UnpackNumber(string.sub(data, 1, 4))
      local yValue = UnpackNumber(string.sub(data, 5, 8))
      
      if xValue ~= nil and yValue ~= nil then
        networkX = xValue
        networkY = yValue
      end
    end
  end
end

networking:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, networking.PlayerInit)
networking:AddCallback(ModCallbacks.MC_POST_UPDATE, networking.PostUpdate)
networking:AddCallback(ModCallbacks.MC_POST_RENDER, networking.PostRender)
