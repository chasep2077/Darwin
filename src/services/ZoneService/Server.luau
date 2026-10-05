local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneData = require(ReplicatedStorage.Shared.Modules.ZoneData)
local ZoneServiceUtils = require(ReplicatedStorage.Shared.Services.ZoneService.ZoneServiceUtils)

local ZoneServiceServer = {}

local Zones = {}

function ZoneServiceServer.init(_self: ZoneServiceServer)
	local isValid, errorMessage = ZoneData.Validate()
	assert(isValid, errorMessage)

	for zoneId, definition in pairs(ZoneData.Definitions) do
		Zones[zoneId] = {
			Id = zoneId,
			State = ZoneData.States.Open,
			Event = nil, -- TEMPORARY INIT FOR EVENTS
			Connections = table.clone(definition.Connections),
		}
	end
end

function ZoneServiceServer.GetZone(zoneId: string)
	local zone = Zones[zoneId]

	if not zone then
		return nil
	end

	return {
		Id = zone.Id,
		State = zone.State,
		Event = zone.Event,
		Connections = table.clone(zone.Connections),
	}
end

function ZoneServiceServer.GetZones()
	local zones = {}

	for zoneId in pairs(Zones) do
		zones[zoneId] = ZoneServiceServer.GetZone(zoneId)
	end

	return zones
end

function ZoneServiceServer.OpenZone(zoneId: string): boolean
	local zone = Zones[zoneId]

	if not zone or zone.State == ZoneData.States.Open then
		return false
	end

	if not ZoneServiceUtils.HasOpenNeighbor(Zones, zoneId) then
		return false
	end

	zone.State = ZoneData.States.Open
	return true
end

function ZoneServiceServer.CloseZone(zoneId: string): boolean
	local zone = Zones[zoneId]

	if not zone or zone.State == ZoneData.States.Closed then
		return false
	end

	local simulatedZones = {}

	for simulatedId, data in pairs(Zones) do
		simulatedZones[simulatedId] = {
			Id = data.Id,
			State = data.State,
			Event = data.Event,
			Connections = table.clone(data.Connections),
		}
	end

	simulatedZones[zoneId].State = ZoneData.States.Closed

	if ZoneServiceUtils.AreOpenZonesConnected(simulatedZones) then
		zone.State = ZoneData.States.Closed
		return true
	end

	return false
end

function ZoneServiceServer.AddEvent(zoneId: string, event): boolean
	local zone = Zones[zoneId]

	if not zone or zone.Event ~= nil or zone.State ~= event.RequiredZoneState then
		return false
	end

	zone.Event = event

	return true
end

function ZoneServiceServer.RemoveEvent(zoneId: string): boolean
	local zone = Zones[zoneId]

	if not zone or zone.Event == nil then
		return false
	end

	zone.Event = nil

	return true
end

function ZoneServiceServer.GetEvent(zoneId: string)
	local zone = Zones[zoneId]

	if not zone then
		return nil
	end

	return zone.Event
end

export type ZoneServiceServer = typeof(ZoneServiceServer) & {}
return ZoneServiceServer
