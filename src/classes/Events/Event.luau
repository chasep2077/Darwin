local Event = {}

Event.__index = Event

function Event.new(id: string, eventType: string, target: any, duration: number)
	local self = setmetatable({}, Event)

	self.Id = id
	self.Type = eventType
	self.Target = target
	self.Duration = duration
	self.ElapsedTime = 0

	return self
end

function Event:Start() end

function Event:Update(deltaTime: number)
	self.ElapsedTime += deltaTime
end

function Event:Complete() end

export type Event = typeof(Event) & {}
return Event
