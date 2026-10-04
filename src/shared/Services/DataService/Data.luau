local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
local Template = require(script.Parent.Template)

local ProfileStoreIndex = "Live"
if RunService:IsStudio() then
	ProfileStoreIndex = "Studio"
end

return DataServiceTyped({
	template = Template,
	profileStoreIndex = ProfileStoreIndex,
})
