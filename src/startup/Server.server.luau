local ServerScriptService = game:GetService("ServerScriptService")

local ExampleServiceServer = require(ServerScriptService.Services.ExampleService.ExampleServiceServer)
local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)

ExampleServiceServer:init()
ZoneServiceServer:init()
