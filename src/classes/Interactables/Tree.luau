local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Interactable = require(script.Parent.Interactable)
local InventoryServiceServer = require(ServerScriptService.Services.InventoryService.InventoryServiceServer)

local AnimationsFolder = ServerStorage:WaitForChild("Animations"):WaitForChild("Interactions")
local ModelsFolder = ServerStorage:WaitForChild("Models"):WaitForChild("Interactables")

local Contents = {
	ResourceName = "Wood",
	Amount = 1,
}

local Tree = {}
Tree.__index = Tree

setmetatable(Tree, Interactable)

Tree.Animation = AnimationsFolder:WaitForChild("HarvestTree") :: Animation
Tree.HarvestedModel = ModelsFolder:WaitForChild("TreeHarvested") :: Model

function Tree.new(model: Model)
	local self = Interactable.new(model, Tree.Animation)

	setmetatable(self, Tree)

	return self
end

function Tree:GetContents(_player: Player)
	if self.IsHarvested then
		return {}
	end

	return table.clone(Contents)
end

function Tree:OnCompleted(player: Player): (boolean, string?)
	if self.IsHarvested then
		return false, "Already Harvested"
	end

	local model = self.Model :: Model

	if not model:IsDescendantOf(Workspace) or not model.Parent then
		return false, "Object Unavailable"
	end

	-- Add the contents of the tree to the player
	InventoryServiceServer.AddResource(player, Contents.ResourceName, Contents.Amount)

	-- Remember the tree's location and its parent container
	local originalParent = model.Parent
	local origianlPivot = model:GetPivot()

	-- Prepare the replacement at the same position and orientation
	local harvestedModel = Tree.HarvestedModel:Clone()
	harvestedModel:PivotTo(origianlPivot)

	-- Mark the tree harvested before replacing the original model
	self.IsHarvested = true
	self.Model = harvestedModel

	model:Destroy()
	harvestedModel.Parent = originalParent

	return true
end

export type Tree = typeof(Tree)

return Tree
