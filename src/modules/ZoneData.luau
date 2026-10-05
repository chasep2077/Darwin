local ZoneData = {}

ZoneData.States = {
	Open = "Open",
	Closed = "Closed",
}

ZoneData.Ids = {
	NW = "NW",
	NE = "NE",
	W = "W",
	C = "C",
	E = "E",
	SW = "SW",
	SE = "SE",
}

ZoneData.Definitions = {
	[ZoneData.Ids.NW] = {
		Connections = {
			ZoneData.Ids.NE,
			ZoneData.Ids.W,
			ZoneData.Ids.C,
		},
	},

	[ZoneData.Ids.NE] = {
		Connections = {
			ZoneData.Ids.NW,
			ZoneData.Ids.C,
			ZoneData.Ids.E,
		},
	},

	[ZoneData.Ids.W] = {
		Connections = {
			ZoneData.Ids.NW,
			ZoneData.Ids.C,
			ZoneData.Ids.SW,
		},
	},

	[ZoneData.Ids.C] = {
		Connections = {
			ZoneData.Ids.NW,
			ZoneData.Ids.NE,
			ZoneData.Ids.W,
			ZoneData.Ids.E,
			ZoneData.Ids.SW,
			ZoneData.Ids.SE,
		},
	},

	[ZoneData.Ids.E] = {
		Connections = {
			ZoneData.Ids.NE,
			ZoneData.Ids.C,
			ZoneData.Ids.SE,
		},
	},

	[ZoneData.Ids.SW] = {
		Connections = {
			ZoneData.Ids.W,
			ZoneData.Ids.C,
			ZoneData.Ids.SE,
		},
	},

	[ZoneData.Ids.SE] = {
		Connections = {
			ZoneData.Ids.C,
			ZoneData.Ids.E,
			ZoneData.Ids.SW,
		},
	},
}

function ZoneData.Validate(): (boolean, string?)
	for zoneId, definition in pairs(ZoneData.Definitions) do
		if type(zoneId) ~= "string" or zoneId == "" then
			return false, "Invalid zone id."
		end

		local connections = {}

		for _, connectedZoneId in ipairs(definition.Connections) do
			if connectedZoneId == zoneId then
				return false, `Zone {zoneId} cannot connect to itself.`
			end

			local connectedZone = ZoneData.Definitions[connectedZoneId]

			if not connectedZone then
				return false, `Zone {zoneId} connects to nonexistent zone {connectedZoneId}.`
			end

			if connections[connectedZoneId] then
				return false, `Zone {zoneId} contains duplicate connection {connectedZoneId}.`
			end

			connections[connectedZoneId] = true

			local reverseConnectionFound = false

			for _, reverseId in ipairs(connectedZone.Connections) do
				if reverseId == zoneId then
					reverseConnectionFound = true
					break
				end
			end

			if not reverseConnectionFound then
				return false, `Connection between {zoneId} and {connectedZoneId} is not bidirectional.`
			end
		end
	end

	return true
end

return ZoneData
