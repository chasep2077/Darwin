local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataServiceTyped = require(ReplicatedStorage.Packages.DataServiceTyped)
local Template = require(script.Parent.Template)

return DataServiceTyped({
	template = Template,
})
