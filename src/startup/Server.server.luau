local ServerScriptService = game:GetService("ServerScriptService")

local EventServiceServer = require(ServerScriptService.Services.EventService.EventServiceServer)
local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)

ZoneServiceServer:init()
EventServiceServer:init()

local e1, reason1 = EventServiceServer.CreateEvent("LowGravity", "Map")
if e1 == nil then
	print(reason1)
end
--[[
task.wait(5)

local e2, reason2 = EventServiceServer.CreateEvent("LowGravity", "Map")
if e2 == nil then
	print(reason2)
end

task.wait(10)

local e3, reason3 = EventServiceServer.CreateEvent("LowGravity", "Map")
if e3 == nil then
	print(reason3)
end
--]]
