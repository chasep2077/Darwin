local ServerScriptService = game:GetService("ServerScriptService")
local Event = require(script.Parent.Event)

local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)

local OpenZone = {}
OpenZone.__index = OpenZone

setmetatable(OpenZone, Event)

function OpenZone.new(id: string, target: string, duration: number)
	local self = Event.new(id, "OpenZone", target, duration)

	setmetatable(self, OpenZone)

	return self
end

function OpenZone:Start()
	print(`Starting OpenZone event for zone {self.Target}`)
end

function OpenZone:Update(deltaTime: number)
	Event.Update(self, deltaTime)
end

function OpenZone:Complete()
	print(`Completing OpenZone event for zone {self.Target}`)

	ZoneServiceServer.OpenZone(self.Target)
end

return OpenZone
