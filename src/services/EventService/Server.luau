local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local EventData = require(ReplicatedStorage.Shared.Modules.EventData)

local EventServiceServer = {}

local Events = {
	[EventData.Types.CloseZone] = require(ServerScriptService.Classes.Events.CloseZone),
	[EventData.Types.OpenZone] = require(ServerScriptService.Classes.Events.OpenZone),
	[EventData.Types.Manhunt] = require(ServerScriptService.Classes.Events.Manhunt),
}

local ActiveEvents = {}

function EventServiceServer.CreateEvent(eventType: string, target: any)
	local definition = EventData.Definitions[eventType]

	if not definition then
		return nil, `Event type {eventType} does not exist.`
	end

	local eventClass = Events[eventType]

	if not eventClass then
		return nil, `Event type {eventType} has no event class.`
	end

	local eventId = HttpService:GenerateGUID(false)

	local event = eventClass.new(eventId, target, definition.Duration)

	event:Start()

	ActiveEvents[event.Id] = event

	return event
end

function EventServiceServer.GetEvents()
	return ActiveEvents
end

RunService.Heartbeat:Connect(function(deltaTime)
	for eventId, event in pairs(ActiveEvents) do
		event:Update(deltaTime)

		if event.ElapsedTime >= event.Duration then
			event:Complete()

			ActiveEvents[eventId] = nil
		end
	end
end)

export type EventServiceServer = typeof(EventServiceServer) & {}
return EventServiceServer
