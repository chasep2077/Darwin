local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local INTERACTABLE_TAG = "Interactable"
local MOVEMENT_CANCEL_DISTANCE = 0.75

local InteractionServiceServer = {}

-- Registered interactable objects
local Interactables = {}

-- Currently active interactions
local ActiveInteractionsByObject = {}
local ActiveInteractionsByPlayer = {}

local function RegisterInteractable(interactable: Instance)
	if Interactables[interactable] then
		return
	end

	local prompt = interactable:FindFirstChildWhichIsA("ProximityPrompt", true)

	if not prompt then
		warn(`Interactable {interactable:GetFullName()} has no ProximityPrompt.`)
		return
	end

	local triggeredConnection = prompt.Triggered:Connect(function(player)
		InteractionServiceServer.StartInteraction(player, interactable)
	end)

	Interactables[interactable] = {
		Prompt = prompt,
		TriggeredConnection = triggeredConnection,
	}
end

local function CanStartInteraction(player: Player, interactable: Instance): (boolean, string?)
	if player.Parent ~= Players then
		return false, "Player is not connected"
	end

	local character = player.Character

	if not character then
		return false, "Player has no character"
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or humanoid.Health <= 0 then
		return false, "Player is not alive"
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")

	if not rootPart or rootPart:IsA("BasePart") then
		return false, "Character has no valid HumanoidRootPart"
	end

	local interactableData = Interactables[interactable]

	if not interactableData then
		return false, "Interactable is not registered"
	end

	if not interactable:IsDescendantOf(Workspace) then
		return false, "Interactable is not in Workspace"
	end

	local prompt = interactableData.Prompt

	if not prompt.Enabled or not prompt:IsDescendantOf(interactable) then
		return false, "Prompt is unavailable"
	end

	if ActiveInteractionsByObject[interactable] then
		return false, "Object is already being interacted with"
	end

	if ActiveInteractionsByPlayer[player] then
		return false, "Player is already interacting"
	end

	local promptParent = prompt.Parent

	if not promptParent then
		return false, "Prompt has no parent"
	end

	local promptPosition: Vector3

	if promptParent:IsA("Attachment") then
		promptPosition = promptParent.WorldPosition
	elseif promptParent:IsA("BasePart") then
		promptPosition = promptParent.Position
	elseif promptParent:IsA("Model") then
		promptPosition = promptParent:GetPivot().Position
	else
		return false, "Prompt has no valid position"
	end

	local distance = (rootPart.Position - promptPosition).Magnitude

	if distance > prompt.MaxActivationDistance then
		return false, "Player is too far away"
	end

	return true
end

function InteractionServiceServer.init(_self: InteractionServiceServer)
	-- Register interactables added later
	CollectionService:GetInstanceAddedSignal(INTERACTABLE_TAG):Connect(RegisterInteractable)

	-- Unregister interactables when their tag is removed
	CollectionService:GetInstanceRemovedSignal(INTERACTABLE_TAG):Connect(function(interactable)
		local data = Interactables[interactable]

		if not data then
			return
		end

		local interaction = ActiveInteractionsByObject[interactable]

		if interaction then
			InteractionServiceServer.CancelInteraction(interaction.Player, "InteractableRemoved")
		end

		data.TriggeredConnection:Disconnect()

		-- Disable the prompt if the object lost its interactable tag
		if not CollectionService:HasTag(interactable, INTERACTABLE_TAG) and data.Prompt.Parent then
			data.Prompt.Enabled = false
		end

		Interactables[interactable] = nil
	end)

	Players.PlayerRemoving:Connect(function(player)
		InteractionServiceServer.CancelInteraction(player, "PlayerRemoving")
	end)

	-- Register objects that already exist
	for _, interactable in ipairs(CollectionService:GetTagged(INTERACTABLE_TAG)) do
		RegisterInteractable(interactable)
	end
end

local function CleanupInteraction(interaction)
	-- Disconnect all temporary event connections
	for _, connection in ipairs(interaction.Connections) do
		connection:Disconnect()
	end

	table.clear(interaction.Connections)

	-- Release the object reservation
	if ActiveInteractionsByObject[interaction.Object] == interaction then
		ActiveInteractionsByObject[interaction.Object] = nil
	end

	-- Release the player reservation
	if ActiveInteractionsByPlayer[interaction.Player] == interaction then
		ActiveInteractionsByPlayer[interaction.Player] = nil
	end

	-- Restore the prompt if the interaction was canceled
	local interactableData = Interactables[interaction.Object]

	if
		(interaction.Status == "Canceled" or interaction.Status == "Failed")
		and interactableData
		and interactableData.Prompt == interaction.Prompt
		and interaction.Prompt.Parent
	then
		interaction.Prompt.Enabled = interaction.PromptWasEnabled
	end

	-- Release animation resources
	interaction.Animation:Destroy()
	interaction.AnimationTrack:Destroy()
end

function InteractionServiceServer.StartInteraction(player: Player, interactable: Instance)
	-- Validate, reserve, and begin the interaction
	local canStart, reason = CanStartInteraction(player, interactable)

	if not canStart then
		warn(reason)
		return
	end

	local character = player.Character
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local interactableData = Interactables[interactable]

	-- Get the animation configured for this object.
	local animationId = interactable:GetAttribute("InteractionAnimationId")

	if typeof(animationId) ~= "string" or animationId == "" then
		warn(`Interactable {interactable:GetFullName()} has no InteractionAnimationId`)
		return
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		warn(`Character for {player.Name} has no Animator.`)
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId

	local loaded, result = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if not loaded then
		animation:Destroy()
		warn(`Failed to load interaction animation: {result}`)
		return
	end

	local animationTrack = result :: AnimationTrack
	animationTrack.Priority = Enum.AnimationPriority.Action
	animationTrack.Looped = false

	-- Create the interaction record
	local interaction = {
		Player = player,
		Object = interactable,
		Prompt = interactableData.Prompt,
		PromptWasEnabled = interactableData.Prompt.Enabled,

		Status = "Active",

		Character = character,
		Humanoid = humanoid,
		RootPart = rootPart,
		StartPosition = rootPart.Position,

		Animation = animation,
		AnimationTrack = animationTrack,
		Connections = {},
	}

	ActiveInteractionsByObject[interactable] = interaction
	ActiveInteractionsByPlayer[player] = interaction

	-- Hids the prompt while the object is reserved
	interaction.Prompt.Enabled = false

	-- Complete the interaction when the animation naturally ends
	table.insert(
		interaction.Connections,
		animationTrack.Ended:Connect(function()
			if ActiveInteractionsByPlayer[player] ~= interaction then
				return
			end

			if interaction.Status ~= "Active" then
				return
			end

			InteractionServiceServer.CompleteInteraction(player)
		end)
	)

	-- Cancel if the player dies
	table.insert(
		interaction.Connections,
		humanoid.Died:Connect(function()
			InteractionServiceServer.CancelInteraction(player, "Died")
		end)
	)

	-- Cancel if the character is removed
	table.insert(
		interaction.Connections,
		player.CharacterRemoving:Connect(function(removingCharacter)
			if removingCharacter == character then
				InteractionServiceServer.CancelInteraction(player, "CharacterRemoving")
			end
		end)
	)

	-- Cancel if the character moves away from its starting position
	table.insert(
		interaction.Connections,
		RunService.Heartbeat:Connect(function()
			if (rootPart.Position - interaction.StartPosition).Magnitude >= MOVEMENT_CANCEL_DISTANCE then
				InteractionServiceServer.CancelInteraction(player, "Moved")
			end
		end)
	)

	-- Begin playing only after the interaction is registered
	animationTrack:Play()
end

function InteractionServiceServer.CancelInteraction(player: Player, reason: string)
	-- Stop the interaction and release reservations.
	local interaction = ActiveInteractionsByPlayer[player]

	-- There is no active interaction to cancel
	if not interaction or interaction.Status ~= "Active" then
		return
	end

	-- Mark it canceled before stopping the animation
	interaction.Status = "Canceled"
	interaction.CancelReason = reason

	-- Stop the animation if it is stil playing
	if interaction.AnimationTrack.IsPlaying then
		interaction.AnimationTrack:Stop(0)
	end

	-- Release reservations and clean up connections
	CleanupInteraction(interaction)
end

function InteractionServiceServer.CompleteInteraction(player)
	-- Complete the interaction and invoke the object's behavior.
	local interaction = ActiveInteractionsByPlayer[player]

	if not interaction or interaction.Status ~= "Active" then
		return
	end

	-- Verify that this interaction still owns the object reservation
	if ActiveInteractionsByObject[interaction.Object] ~= interaction then
		return
	end

	local interactableData = Interactables[interaction.Object]

	-- The object must still exist and be registered
	if not interactableData or not interaction.Object:IsDescendantOf(Workspace) then
		InteractionServiceServer.CancelInteraction(player, "ObjectUnavailable")
		return
	end

	local handler = interactableData.Handler

	if not handler then
		InteractionServiceServer.CancelInteraction(player, "MissingHandler")
		return
	end

	interaction.Status = "Completing"

	local success, completed, reason = pcall(function()
		return handler:Complete(player)
	end)

	if not success or completed ~= true then
		interaction.Status = "Failed"
		interaction.CancelReason = if success then reason or "CompletionFailed" else "HandlerError"

		if not success then
			warn(`Interaction completion failed: {completed}`)
		end

		CleanupInteraction(interaction)
		return
	end

	interaction.Status = "Completed"

	CleanupInteraction(interaction)
end

export type InteractionServiceServer = typeof(InteractionServiceServer)
return InteractionServiceServer
