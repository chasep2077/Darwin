local ServerScriptService = game:GetService("ServerScriptService")
local Event = require(script.Parent.Event)

local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)

local CloseZone = {}
CloseZone.__index = CloseZone

setmetatable(CloseZone, Event)

function CloseZone.new(id: string, target: string, duration: number)
	local self = Event.new(id, "CloseZone", target, duration)

	setmetatable(self, CloseZone)

	return self
end

function CloseZone:Start()
	print(`Zone Event: Closing Zone [STARTED] in the {self.Target} zone`)
end

function CloseZone:Update(deltaTime: number)
	Event.Update(self, deltaTime)
end

function CloseZone:Complete()
	print(`Zone Event: Closing Zone [ENDED] in the {self.Target} zone\nZONE CLOSED`)

	ZoneServiceServer.CloseZone(self.Target)
end

return CloseZone
