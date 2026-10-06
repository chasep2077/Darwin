local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Event = require(ServerScriptService.Classes.Events.Event)

local LowGravity = {}
LowGravity.__index = LowGravity

setmetatable(LowGravity, Event)

-- The higher the number the larger the jump and slower the fall
local LOW_GRAVITY_MULTIPLIER = 5

function LowGravity.new(id: string, target: string, duration: number)
	local self = Event.new(id, "LowGravity", target, duration)

	setmetatable(self, LowGravity)

	self.AffectedPlayers = {}
	self.CharacterAddedConnections = {}
	self.PlayerAddedConnection = nil
	self.DefaultGravity = nil

	return self
end

function LowGravity:ApplyToPlayer(player)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	self.AffectedPlayers[player.UserId] = {
		Player = player,
		JumpHeight = humanoid.JumpHeight,
	}

	humanoid.JumpHeight *= LOW_GRAVITY_MULTIPLIER

	self.CharacterAddedConnections[player.UserId] = player.CharacterAdded:Connect(function(addedCharacter)
		local addedHumanoid = addedCharacter:WaitForChild("Humanoid")

		if self.AffectedPlayers[player.UserId] then
			addedHumanoid.JumpHeight *= LOW_GRAVITY_MULTIPLIER
		end
	end)
end

function LowGravity:Start()
	self.DefaultGravity = Workspace.Gravity
	Workspace.Gravity = self.DefaultGravity / LOW_GRAVITY_MULTIPLIER

	self.PlayerAddedConnection = Players.PlayerAdded:Connect(function(player)
		self:ApplyToPlayer(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:ApplyToPlayer(player)
	end

	print("Map Event: Low-Gravity [STARTED]")
end

function LowGravity:Update(deltaTime: number)
	Event.Update(self, deltaTime)
end

function LowGravity:Complete()
	Workspace.Gravity = self.DefaultGravity

	for userId, data in pairs(self.AffectedPlayers) do
		local player = data.Player
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			humanoid.JumpHeight = data.JumpHeight
		end

		local connection = self.CharacterAddedConnections[userId]

		if connection then
			connection:Disconnect()
		end
	end

	if self.PlayerAddedConnection then
		self.PlayerAddedConnection:Disconnect()
	end

	print("Map Event: Low-Gravity [ENDED]")
end

return LowGravity
