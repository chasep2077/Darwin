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
	print(`Zone Event: Opening Zone [STARTED] in the {self.Target} zone`)
end

function OpenZone:Update(deltaTime: number)
	Event.Update(self, deltaTime)
end

function OpenZone:Complete()
	print(`Zone Event: Opening Zone [ENDED] in the {self.Target} zone\nZONE OPENED`)

	ZoneServiceServer.OpenZone(self.Target)
end

return OpenZone
