local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneData = require(ReplicatedStorage.Shared.Modules.ZoneData)

local ZoneServiceUtils = {}

function ZoneServiceUtils.GetOpenZones(zones: { [string]: any }): { [string]: any }
	local openZones = {}

	for zoneId, zone in pairs(zones) do
		if zone.State == ZoneData.States.Open then
			openZones[zoneId] = zone
		end
	end

	return openZones
end

function ZoneServiceUtils.HasOpenNeighbor(zones: { [string]: any }, zoneId: string): boolean
	local zone = zones[zoneId]

	if not zone then
		return false
	end

	for _, connectedZoneId in ipairs(zone.Connections) do
		local connectedZone = zones[connectedZoneId]

		if connectedZone and connectedZone.State == ZoneData.States.Open then
			return true
		end
	end

	return false
end

function ZoneServiceUtils.AreOpenZonesConnected(zones: { [string]: any }): boolean
	local openZones = ZoneServiceUtils.GetOpenZones(zones)

	local openZoneCount = 0
	local visitedZoneCount = 0

	local startZoneId = nil

	for zoneId in pairs(openZones) do
		openZoneCount += 1

		if not startZoneId then
			startZoneId = zoneId
		end
	end

	if openZoneCount == 0 then
		return false
	end

	local visited = {}
	local queue = { startZoneId }

	visited[startZoneId] = true
	visitedZoneCount += 1

	while #queue > 0 do
		local currentZoneId = table.remove(queue, 1)
		local currentZone = zones[currentZoneId]

		for _, connectedZoneId in ipairs(currentZone.Connections) do
			local connectedZone = zones[connectedZoneId]

			if connectedZone and connectedZone.State == ZoneData.States.Open and not visited[connectedZoneId] then
				visited[connectedZoneId] = true
				visitedZoneCount += 1
				queue[#queue + 1] = connectedZoneId
			end
		end
	end

	return visitedZoneCount == openZoneCount
end

export type ZoneServiceUtils = typeof(ZoneServiceUtils) & {}
return ZoneServiceUtils
