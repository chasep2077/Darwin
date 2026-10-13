local ServerScriptService = game:GetService("ServerScriptService")

local EventServiceServer = require(ServerScriptService.Services.EventService.EventServiceServer)
local InteractionServiceServer = require(ServerScriptService.Services.InteractionService.InteractionServiceServer)
local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)
local MapServiceServer = require(ServerScriptService.Services.MapService.MapServiceServer)
local InventoryServiceServer = require(ServerScriptService.Services.InventoryService.InventoryServiceServer)

ZoneServiceServer:init()
EventServiceServer:init()
MapServiceServer:init()
InteractionServiceServer:init()
InventoryServiceServer:init()

local e1, reason1 = EventServiceServer.CreateEvent("LowGravity", "Map")
if e1 == nil then
	print(reason1)
end

MapServiceServer.Generate()
