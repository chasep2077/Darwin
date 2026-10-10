local Workspace = game:GetService("Workspace")
local Interactable = {}

Interactable.__index = Interactable

function Interactable.new(model: Model, animation: Animation)
	assert(model:IsA("Model"), "Interactable requires a Model")
	assert(animation:IsA("Animation"), "Interactable requires an Animation")

	local self = setmetatable({}, Interactable)

	-- The specific world object this handler manages
	self.Model = model
	-- The animation used when interacting with this object
	self.Animation = animation
	-- Whether this object has already been consumed
	self.IsHarvested = false

	return self
end

function Interactable:CanInteract(_player: Player): (boolean, string?)
	if self.IsHarvested then
		return false, "Already Harvested"
	end

	if not self.Model:IsDescendantOf(Workspace) then
		return false, "Object Unavailable"
	end

	return true
end

function Interactable:GetContents(_player: Player)
	error("GetContents() must be implemented by an interactable subclass", 2)
end

function Interactable:OnCompleted(_player: Player)
	error("OnCompleted() must be implemented by an interactable subclass", 2)
end

return Interactable
