local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local MapServiceServer = {}

local TILE_SIDE_LENGTH = 500

local Tiles = ServerStorage.Tiles

local TileWidth
local TileHorizontalSpacing
local TileVerticalSpacing

local ZonePositions = {}

function MapServiceServer.init(_self: MapServiceServer)
	TileWidth = math.sqrt(3) * TILE_SIDE_LENGTH

	TileHorizontalSpacing = TileWidth
	TileVerticalSpacing = 1.5 * TILE_SIDE_LENGTH

	ZonePositions = {
		C = Vector3.new(0, 0, 0),

		NW = Vector3.new(-TileHorizontalSpacing / 2, 0, -TileVerticalSpacing),

		NE = Vector3.new(TileHorizontalSpacing / 2, 0, -TileVerticalSpacing),

		W = Vector3.new(-TileHorizontalSpacing, 0, 0),

		E = Vector3.new(TileHorizontalSpacing, 0, 0),

		SW = Vector3.new(-TileHorizontalSpacing / 2, 0, TileVerticalSpacing),

		SE = Vector3.new(TileHorizontalSpacing / 2, 0, TileVerticalSpacing),
	}
end

function MapServiceServer.Generate()
	local Zones = Instance.new("Folder")
	Zones.Name = "Zones"
	Zones.Parent = Workspace

	local availableTiles = Tiles:GetChildren()

	for zoneId, zonePosition in pairs(ZonePositions) do
		local index = math.random(#availableTiles)
		local tileTemplate = table.remove(availableTiles, index)

		local tile: Model = tileTemplate:Clone()

		local rotation = math.random(0, 5) * 60

		tile:PivotTo(CFrame.new(zonePosition) * CFrame.Angles(0, math.rad(rotation), 0))

		tile.Name = `{zoneId}_Tile_{tile.Name}`
		tile.Parent = Zones
	end

	print(`Generated Map: {Zones:GetChildren()}`)
end

export type MapServiceServer = typeof(MapServiceServer)
return MapServiceServer
