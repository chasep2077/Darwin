local EventData = {}

EventData.Types = {
	CloseZone = "CloseZone",
	OpenZone = "OpenZone",
	Manhunt = "Manhunt",
}

EventData.TargetTypes = {
	Zone = "Zone",
	Player = "Player",
	Map = "Map",
}

EventData.Definitions = {
	[EventData.Types.CloseZone] = {
		TargetType = EventData.TargetTypes.Zone,
		Duration = 60,
	},
	[EventData.Types.OpenZone] = {
		TargetType = EventData.TargetTypes.Zone,
		Duration = 60,
	},
	[EventData.Types.Manhunt] = {
		TargetType = EventData.TargetTypes.Player,
		Duration = 60,
	},
}

-- Validates the static event definitions before they are used by the service.
function EventData.Validate(): (boolean, string?)
	for eventType, definition in pairs(EventData.Definitions) do
		if type(eventType) ~= "string" or eventType == "" then
			return false, "Invalid event type."
		end

		if type(definition) ~= "table" then
			return false, `Event {eventType} has an invalid definition.`
		end

		if type(definition.TargetType) ~= "string" then
			return false, `Event {eventType} has an invalid target type.`
		end

		-- Checks that the target type is one of the supported types.
		local validTargetType = false

		for _, targetType in pairs(EventData.TargetTypes) do
			if definition.TargetType == targetType then
				validTargetType = true
				break
			end
		end

		if not validTargetType then
			return false, `Event {eventType} has an invalid target type {definition.TargetType}.`
		end

		if type(definition.Duration) ~= "number" or definition.Duration <= 0 then
			return false, `Event {eventType} has an invalid duration.`
		end
	end

	return true
end

return EventData
