local Event = require(script.Parent.Event)

local Manhunt = {}
Manhunt.__index = Manhunt

setmetatable(Manhunt, Event)

function Manhunt.new(id: string, target: number, duration: number)
	local self = Event.new(id, "Manhunt", target, duration)

	setmetatable(self, Manhunt)

	return self
end

function Manhunt:Start()
	print(`Player Event: Manhunt [STARTED] on {self.Target}`)
end

function Manhunt:Update(deltaTime: number)
	Event.Update(self, deltaTime)
end

function Manhunt:Complete()
	print(`Player Event: Manhunt [ENDED] on {self.Target}`)
end

return Manhunt
