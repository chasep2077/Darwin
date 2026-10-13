local Players = game:GetService("Players")

local InventoryServiceServer = {}

local InventoriesByPlayer = {}
local IsInitialized = false

-- Creates a fresh inventory for one player
local function CreateInventory()
	return {
		Resources = {
			Wood = 0,
			Leather = 0,
			Electronics = 0,
		},

		Consumables = {
			FirstAidKits = 0,
			SpeedDrinks = 0,
			WarmCoffees = 0,
		},

		Arrows = {
			Type = nil,
			Amount = 0,
		},

		Tools = {
			Slot1 = {
				Type = nil,
				Amount = 0,
			},

			Slot2 = {
				Type = nil,
				Amount = 0,
			},

			Slot3 = {
				Type = nil,
				Amount = 0,
			},
		},

		Powers = {
			Slot1 = {
				Type = nil,
				Unlocked = false,
			},

			Slot2 = {
				Type = nil,
				Unlocked = false,
			},

			Slot3 = {
				Type = nil,
				Unlocked = false,
			},
		},

		Upgrades = {
			Axe = {
				Type = nil,
				Level = 0,
			},

			Cloak = {
				Type = nil,
				Level = 0,
			},

			Boots = {
				Type = nil,
				Level = 0,
			},
		},
	}
end

-- Returns an independent copy, including nested tables
local function CopyTable(original)
	local copy = {}

	for key, value in pairs(original) do
		if type(value) == "table" then
			copy[key] = CopyTable(value)
		else
			copy[key] = value
		end
	end

	return copy
end

-- Retrieves a player's inventory or an error message
local function GetPlayerInventory(player: Player)
	local inventory = InventoriesByPlayer[player]

	if not inventory then
		return nil, `Player {player.Name} has no inventory.`
	end

	return inventory
end

-- Checks whether an amount is a positive integer
local function IsValidAmount(amount: number): boolean
	return typeof(amount) == "number" and amount >= 1 and amount % 1 == 0
end

-- Finds a slot containing the requested type
local function FindSlot(inventory, category: string, name: string)
	local slots = inventory[category]

	if not slots then
		return nil
	end

	for _, slot in pairs(slots) do
		if slot.Type == name then
			return slot
		end
	end

	return nil
end

-- Creates an inventory when a player joins
local function AddPlayer(player: Player)
	if InventoriesByPlayer[player] then
		return
	end

	InventoriesByPlayer[player] = CreateInventory()
end

local function ModifyResource(player: Player, resourceName: string, amount: number): (boolean, string?)
	local inventory, reason = GetPlayerInventory(player)

	if not inventory then
		return false, reason
	end

	local resource = inventory.Resources[resourceName]

	if not resource then
		return false, `Resource {resourceName} is not a valid resource.`
	end

	local newAmount = resource + amount

	if newAmount < 0 then
		return false, `Not enough {resourceName}: have {resource}, need {math.abs(amount)}.`
	end

	inventory.Resources[resourceName] = newAmount

	return true
end

local function ModifyConsumable(player: Player, consumableName: string, amount: number): (boolean, string?)
	local inventory, reason = GetPlayerInventory(player)

	if not inventory then
		return false, reason
	end

	local consumable = inventory.Consumables[consumableName]

	if not consumable then
		return false, `Consumable {consumableName} is not a valid consumable.`
	end

	local newAmount = consumable + amount

	if newAmount < 0 then
		return false, `Not enough {consumableName}: have {consumable}, need {math.abs(amount)}.`
	end

	inventory.Consumables[consumableName] = newAmount

	return true
end

local function ModifyArrow(player: Player, amount: number): (boolean, string?)
	local inventory, reason = GetPlayerInventory(player)

	if not inventory then
		return false, reason
	end

	local currentAmount = inventory.Arrows.Amount
	local newAmount = currentAmount + amount

	if newAmount < 0 then
		return false, `Not enough Arrows: have {currentAmount}, need {math.abs(amount)}.`
	end

	inventory.Arrows.Amount = newAmount

	return true
end

local function ModifyTool(player: Player, toolName: string, amount: number): (boolean, string?)
	local inventory, reason = GetPlayerInventory(player)

	if not inventory then
		return false, reason
	end

	local toolSlot = FindSlot(inventory, "Tools", toolName)

	if not toolSlot then
		return false, `Tool {toolName} is not selected in any slot.`
	end

	local currentAmount = toolSlot.Amount
	local newAmount = currentAmount + amount

	if newAmount < 0 then
		return false, `Not enough {toolName}: have {toolSlot.Amount}, need {math.abs(amount)}.`
	end

	toolSlot.Amount = newAmount

	return true
end

local function ModifyPower(player: Player, powerName: string, unlocked: boolean): (boolean, string?)
	local inventory, reason = GetPlayerInventory(player)

	if not inventory then
		return false, reason
	end

	local powerSlot = FindSlot(inventory, "Powers", powerName)

	if not powerSlot then
		return false, `Power {powerName} is not selected in any slot.`
	end

	if powerSlot.Unlocked == unlocked then
		if unlocked then
			return false, `Power {powerName} is already unlocked.`
		else
			return false, `Power {powerName} is not unlocked.`
		end
	end

	powerSlot.Unlocked = unlocked

	return true
end

local function ModifyUpgrade(player: Player, upgradeName: string, amount: number): (boolean, string?)
	local inventory, reason = GetPlayerInventory(player)

	if not inventory then
		return false, reason
	end

	local upgrade = inventory.Upgrades[upgradeName]

	if not upgrade then
		return false, `Upgrade {upgradeName} is not a valid upgrade.`
	end

	if not upgrade.Type then
		return false, `No upgrade selected for {upgradeName}.`
	end

	local newLevel = upgrade.Level + amount

	if newLevel < 0 then
		return false, "Cannot remove more levels than the upgrade has."
	elseif newLevel > 5 then
		return false, "Upgrade is already at or would exceed maximum level."
	end

	upgrade.Level = newLevel

	return true
end

function InventoryServiceServer.init(_self: InventoryServiceServer)
	if IsInitialized then
		return
	end

	IsInitialized = true

	Players.PlayerAdded:Connect(AddPlayer)

	Players.PlayerRemoving:Connect(function(player)
		InventoriesByPlayer[player] = nil
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		AddPlayer(player)
	end
end

function InventoryServiceServer.GetInventory(player: Player)
	local inventory = InventoriesByPlayer[player]

	if not inventory then
		return nil
	end

	return CopyTable(inventory)
end

function InventoryServiceServer.AddResource(player: Player, resourceName: string, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyResource(player, resourceName, amount)
end

function InventoryServiceServer.RemoveResource(player: Player, resourceName: string, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyResource(player, resourceName, -amount)
end

function InventoryServiceServer.AddConsumable(
	player: Player,
	consumableName: string,
	amount: number
): (boolean, string?)
	if IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyConsumable(player, consumableName, amount)
end

function InventoryServiceServer.RemoveConsumable(
	player: Player,
	consumableName: string,
	amount: number
): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyConsumable(player, consumableName, -amount)
end

function InventoryServiceServer.AddArrow(player: Player, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyArrow(player, amount)
end

function InventoryServiceServer.RemoveArrow(player: Player, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyArrow(player, -amount)
end

function InventoryServiceServer.AddTool(player: Player, toolName: string, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyTool(player, toolName, amount)
end

function InventoryServiceServer.RemoveTool(player: Player, toolName: string, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyTool(player, toolName, -amount)
end

function InventoryServiceServer.AddPower(player: Player, powerName: string): (boolean, string?)
	return ModifyPower(player, powerName, true)
end

function InventoryServiceServer.RemovePower(player: Player, powerName: string): (boolean, string?)
	return ModifyPower(player, powerName, false)
end

function InventoryServiceServer.AddUpgrade(player: Player, upgradeName: string, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyUpgrade(player, upgradeName, amount)
end

function InventoryServiceServer.RemoveUpgrade(player: Player, upgradeName: string, amount: number): (boolean, string?)
	if not IsValidAmount(amount) then
		return false, "Amount must be a positive integer."
	end

	return ModifyUpgrade(player, upgradeName, -amount)
end

export type InventoryServiceServer = typeof(InventoryServiceServer)
return InventoryServiceServer
