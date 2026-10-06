local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneData = require(ReplicatedStorage.Shared.Modules.ZoneData)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)

local ZoneServiceServer = {}

local Zones = {}

-- Creates a safe copy of a zone without exposing the internal state.
local function copyZone(zone)
	return {
		Id = zone.Id,
		State = zone.State,
		Connections = table.clone(zone.Connections),
	}
end

-- Initializes the server's runtime zone state from the zone definitions.
function ZoneServiceServer.init(_self: ZoneServiceServer)
	local isValid, errorMessage = ZoneData.Validate()
	assert(isValid, errorMessage)

	for zoneId, definition in pairs(ZoneData.Definitions) do
		Zones[zoneId] = {
			Id = zoneId,
			State = ZoneData.States.Open,
			Connections = table.clone(definition.Connections),
		}
	end
end

-- Returns a copy of a single zone so callers cannot modify internal states.
function ZoneServiceServer.GetZone(zoneId: string)
	local zone = Zones[zoneId]

	if not zone then
		return nil
	end

	return copyZone(zone)
end

-- Returns copies of all zones.
function ZoneServiceServer.GetZones()
	local zones = {}

	for zoneId, zone in pairs(Zones) do
		zones[zoneId] = copyZone(zone)
	end

	return zones
end

-- Determines whether a closed zone can be opened.
function ZoneServiceServer.CanOpenZone(zoneId: string): boolean
	local zone = Zones[zoneId]

	if not zone or zone.State == ZoneData.States.Open then
		return false
	end

	return ZoneServiceUtils.HasOpenNeighbor(Zones, zoneId)
end

-- Determines whether a closed zone can be closed without disconnecting the remaining open zones from one another.
function ZoneServiceServer.CanCloseZone(zoneId: string): boolean
	local zone = Zones[zoneId]

	if not zone or zone.State == ZoneData.States.Closed then
		return false
	end

	-- Test the closure on a copy so the real zone state is unchanged.
	local simulatedZones = {}

	for simulatedId, simulatedZone in pairs(Zones) do
		simulatedZones[simulatedId] = copyZone(simulatedZone)
	end

	simulatedZones[zoneId].State = ZoneData.States.Closed

	return ZoneServiceUtils.AreOpenZonesConnected(simulatedZones)
end

-- Changes a zone from closed to open if the transition is valid.
function ZoneServiceServer.OpenZone(zoneId: string): boolean
	if not ZoneServiceServer.CanOpenZone(zoneId) then
		return false
	end

	Zones[zoneId].State = ZoneData.States.Open
	return true
end

-- Changes a zone from open to closed if the transition is valid.
function ZoneServiceServer.CloseZone(zoneId: string): boolean
	if not ZoneServiceServer.CanCloseZone(zoneId) then
		return false
	end

	Zones[zoneId].State = ZoneData.States.Closed
	return true
end

export type ZoneServiceServer = typeof(ZoneServiceServer) & {}
return ZoneServiceServer
