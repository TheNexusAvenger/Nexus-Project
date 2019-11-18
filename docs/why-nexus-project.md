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

## Cyclic Dependency Detection and Correction
Cyclic dependency (A requires B, B requires A) happens a
lot and can be hard to detect. Using "contexts", detecting
them can be pretty easy. For example, assume there are the
following scripts:
```lua
--ReplicatedStorage/Client
local NexusProject = require(script:WaitForChild("NexusProject"))
local Client = NexusProject.new(script)

return Client
```

```lua
--ReplicatedStorage/Client/Util/ColorUtil
local Client = require(script.Parent.Parent):GetContext(script)
local TweenUtil = Client:GetResource("Util.TweenUtil")
local ColorUtil = {}

return ColorUtil
```

```lua
--ReplicatedStorage/Client/Util/TweenUtil
local Client = require(script.Parent.Parent):GetContext(script)
local TeleportUtil = Client:GetResource("Util.TeleportUtil")
local TweenUtil = {}

return TweenUtil
```

```lua
--ReplicatedStorage/Client/Util/TeleportUtil
local Client = require(script.Parent.Parent):GetContext(script)
local ColorUtil = Client:GetResource("Util.ColorUtil")
local TeleportUtil = {}

return TeleportUtil
```

Would result in the following warning:
```
A dependency loop exists:
Util.ColorUtil
Util.TweenUtil
Util.TeleportUtil
Util.ColorUtil
Use NexusProject::SetResource or NexusProjectContext::SetContextResource to allow the loop to end without having to load the resources.
```

The last line shows how it can be mitigated. All 3
modules end up in a deadlock since each need each
other to finish loading to continue. The quick way
to resolve this is to set one of the resources so
the others can finish loading.
```lua
--ReplicatedStorage/Client/Util/TweenUtil
local Client = require(script.Parent.Parent):GetContext(script)
local TweenUtil = {}
Client:SetContextResource(TweenUtil)
local TeleportUtil = Client:GetResource("Util.TeleportUtil")

return TweenUtil
```