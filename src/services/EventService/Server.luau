local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local EventClasses = ServerScriptService.Classes.Events

local ZoneServiceServer = require(ServerScriptService.Services.ZoneService.ZoneServiceServer)
local EventData = require(ReplicatedStorage.Shared.Modules.EventData)

local EventServiceServer = {}

local Events = {}

local ActiveEvents = {}

local function validateTarget(targetType: string, target: any): (boolean, string?)
	if targetType == EventData.TargetTypes.Zone then
		if type(target) ~= "string" then
			return false, "Zone events require a zone Id."
		end

		if not ZoneServiceServer.GetZone(target) then
			return false, `Zone {target} does not exist.`
		end
	elseif targetType == EventData.TargetTypes.Player then
		if type(target) ~= "number" then
			return false, "Player events require a UserId."
		end

		if not Players:GetPlayerByUserId(target) then
			return false, `Player {target} does not exist.`
		end
	elseif targetType == EventData.TargetTypes.Map then
		if target ~= "Map" then
			return false, "Map events require the target to be Map."
		end
	end

	return true
end

-- Checks whether an active event already occupies the target.
local function hasConflictingEvent(targetType: string, target: any): boolean
	for _, event in pairs(ActiveEvents) do
		local eventDefinition = EventData.Definitions[event.Type]

		-- Only one map-wide event can be active at a time.
		if targetType == EventData.TargetTypes.Map then
			if eventDefinition.TargetType == EventData.TargetTypes.Map then
				return true
			end
		-- Events targeting the same type cannot share a target.
		elseif eventDefinition.TargetType == targetType then
			if event.Target == target then
				return true
			end
		end
	end

	return false
end

-- Initializes the server's runtime events from the events classes.
function EventServiceServer.init(_self: EventServiceServer)
	local isValid, errorMessage = EventData.Validate()
	assert(isValid, errorMessage)

	Events = {
		-- Map Events
		[EventData.Types.LowGravity] = require(EventClasses.LowGravity),
		-- Player Events
		[EventData.Types.Manhunt] = require(EventClasses.Manhunt),
		-- Zone Events
		[EventData.Types.CloseZone] = require(EventClasses.CloseZone),
		[EventData.Types.OpenZone] = require(EventClasses.OpenZone),
	}
end

-- Determines whether an event can be created with the given target.
function EventServiceServer.CanCreateEvent(eventType: string, target: any): (boolean, string?)
	local definition = EventData.Definitions[eventType]

	if not definition then
		return false, `Event type {eventType} does not exist.`
	end

	if not Events[eventType] then
		return false, `Event type {eventType} has no event class.`
	end

	local validTarget, targetError = validateTarget(definition.TargetType, target)

	if not validTarget then
		return false, targetError
	end

	if hasConflictingEvent(definition.TargetType, target) then
		if definition.TargetType == EventData.TargetTypes.Map then
			return false, "There is already an active map event."
		end

		return false, `Target {target} already has an event.`
	end

	return true
end

-- Creates and starts an event after validating the event type and target.
function EventServiceServer.CreateEvent(eventType: string, target: any): (any, string?)
	local canCreate, reason = EventServiceServer.CanCreateEvent(eventType, target)

	if not canCreate then
		return nil, reason
	end

	local definition = EventData.Definitions[eventType]
	local eventClass = Events[eventType]

	local eventId = HttpService:GenerateGUID(false)

	local event = eventClass.new(eventId, target, definition.Duration)

	ActiveEvents[event.Id] = event

	event:Start()

	return event
end

-- Returns a copy of the active event registry.
function EventServiceServer.GetEvents()
	return table.clone(ActiveEvents)
end

-- Updates active events and removes them when their duration expires.
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
