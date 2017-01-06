require('mobdebug').start()

local debugFile = io.open("networking-debug.txt", "w")

local networking = RegisterMod("isaac-networking", 1)

local host, port = "127.0.0.1", 9999
local socket = require("socket")
local tcp = assert(socket.tcp())

function networking:PlayerInit(aConstPlayer)
  if tcp ~= nil then
    tcp:connect(host, port)
  end
end

function networking:PostUpdate()
  local player = Isaac.GetPlayer(0)
  
  if tcp ~= nil then
    tcp:send("x:" .. tostring(player.Position.X) .. " y:" .. tostring(player.Position.Y))
  end
end

networking:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, networking.PlayerInit)
networking:AddCallback(ModCallbacks.MC_POST_UPDATE, networking.PostUpdate)
