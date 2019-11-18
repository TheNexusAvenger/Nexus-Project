# Why Nexus Project

## Simplified Requires
The primary goal of Nexus Project is to reduce
the complexity of requiring `ModuleScripts`.
Using a `Folder` in `ReplicatedStorage` with a
set of `ModuleScripts` and other instances would
look like this:

```lua
--[[
Without Nexus Project.
--]]
local ClientModules = game:GetService("ReplicatedStorage"):WaitForChild("ClientModules")
local UICreator = require(Project:WaitForChild("UICreator"))
local ColorUtil = require(Project:WaitForChild("Util"):WaitForChild("ColorUtil"))
local TweenUtil = require(Project:WaitForChild("Util"):WaitForChild("TweenUtil"))
local DefaultColors = require(Project:WaitForChild("Data"):WaitForChild("UI"):WaitForChild("DefaultColors"))

--[[
With Nexus Project.
--]]
--Create the base project.
local NexusProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusProject"))
local Project = NexusProject.new(game:GetService("ReplicatedStorage"):WaitForChild("ClientModules"))

--Require several modules.
local UICreator = Project:GetResource("UICreator")
local ColorUtil = Project:GetResource("Util.ColorUtil")
local TweenUtil = Project:GetResource("Util.TweenUtil")
local DefaultColors = Project:GetResource("Data.UI.DefaultColors")
```

## Non-Module Resources
Along with `ModuleScripts`, other data can be
retrieved or stored. This is useful for other
Roblox instances, as well as configurable items
or constants.

```lua
--Create the base project.
local NexusProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusProject"))
local Project = NexusProject.new(game:GetService("ReplicatedStorage"):WaitForChild("ClientModules"))

--Store some values.
Project:SetResource("Constants.ConfirmColor",Color3.new(0,1,0))
Project:SetResource("Constants.CancelColor",Color3.new(1,0,0))

--Get the values.
local BaseButtonObject = Project:GetResource("Base.UI.Buttton")
local ConfirmColor = Project:GetResource("Constants.ConfirmColor")
local CancelColor = Project:GetResource("Constants.CancelColor")
local ConfirmButtonBase,CancelButtonBase = BaseButtonObject:Clone(),BaseButtonObject:Clone()
ConfirmButtonBase.BackgroundColor3,CancelButtonBase.BackgroundColor3 = ConfirmColor,CancelColor
```

## Custom Base Paths
A project may store objects in different places.
All of these can be combined into a single project.

```lua
--Create the base project.
local NexusProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusProject"))
local Project = NexusProject.new(game:GetService("ReplicatedStorage"):WaitForChild("ClientModules"))

--Add external path bases.
Project:CreatePathLink("Workspace",game:GetService("Workspace"))
Project:CreatePathLink("Common",game:GetService("ReplicatedStorage"):WaitForChild("CommonModules"))

--Get several resources.
local Baseplate = Project:GetResource("Workspace.Baseplate")
local Terrain = Project:GetResource("Workspace.Terrain")
local CFrameTweenUtil = Project:GetResource("Common.Util.CFrameTweenUtil")
```

## Path Redirecting
For public libraries, modules may need to be moved to
make it more clear, or to refactor code.

```lua
--Create the base project.
local NexusProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusProject"))
local Project = NexusProject.new(game:GetService("ReplicatedStorage"):WaitForChild("ClientModules"))

--Redirect resources.
Project:SetResource("ColorUtil",Project:GetResource("Util.ColorUtil"))
Project:SetResource("TweenUtil",Project:GetResource("Util.TweenUtil"))
```