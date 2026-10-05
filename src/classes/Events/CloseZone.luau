local Event = require(script.Parent.Event)

local CloseZone = {}
CloseZone.__index = CloseZone

setmetatable(CloseZone, Event)

function CloseZone.new(id: string, target: string, duration: number)
	local self = Event.new(id, "CloseZone", target, duration)

	setmetatable(self, CloseZone)

	return self
end

function CloseZone:Start()
	print(`Starting CloseZone event for zone {self.Target}`)
end

function CloseZone:Update(deltaTime: number)
	Event.Update(self, deltaTime)
end

function CloseZone:Complete()
	print(`Completing CloseZone event for zone {self.Target}`)
end

return CloseZone
