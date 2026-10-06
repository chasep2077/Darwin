local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneData = require(ReplicatedStorage.Shared.Modules.ZoneData)

local ZoneServiceUtils = {}

-- Returns all zones that are currently open
function ZoneServiceUtils.GetOpenZones(zones: { [string]: any }): { [string]: any }
	local openZones = {}

	for zoneId, zone in pairs(zones) do
		if zone.State == ZoneData.States.Open then
			openZones[zoneId] = zone
		end
	end

	return openZones
end

-- Checks whether a zone has at least one connected open neighbor.
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

-- Checks whether every open zone can be reached from every other open zone.
function ZoneServiceUtils.AreOpenZonesConnected(zones: { [string]: any }): boolean
	local openZones = ZoneServiceUtils.GetOpenZones(zones)

	local openZoneCount = 0
	local startZoneId = nil

	for zoneId in pairs(openZones) do
		openZoneCount += 1
		startZoneId = startZoneId or zoneId
	end

	-- There must be at least one open zone to form a connected network.
	if not startZoneId then
		return false
	end

	if openZoneCount == 0 then
		return false
	end

	local visited = { startZoneId = true }
	local visitedZoneCount = 1

	local queue = { startZoneId }
	local queueIndex = 1

	-- Traverse all rechable open zones using breadth-first search.
	while queueIndex <= #queue do
		local currentZoneId = queue[queueIndex]
		queueIndex += 1

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
