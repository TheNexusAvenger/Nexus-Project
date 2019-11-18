# Intended Setup
For creating a library, it is not intended to
require Nexus Project and set up the project
for each use. The intended use is to have the
root of a library set up the project and to
require it externally. For example, a root
`ModuleScript` for Nexus Git could look like this:

```lua
--[[
TheNexusAvenger

Root project for Nexus Git.
--]]

--Create the project.
local NexusProject = require(script:WaitForChild("NexusProject"))
local NexusGit = NexusProject.new(script)

--Add some constants.
NexusGit:SetResource("Constants.NexusGit.Version","1.0.0")
NexusGit:SetResource("Constants.NexusGit.DisplayName","Nexus Git")

--Add a custom method.
function NexusGit:PrintVersion()
    print("Nexus Git 1.0.0")
end

--Return the project.
return NexusGit
```

A script using the project can use the project
like the following:
```lua
--[[
TheNexusAvenger
Class that invokes actions.
--]]

local NexusGit = require(script.Parent.Parent.Parent.Parent)
local NexusWrappedInstance = NexusGit:GetResource("NexusPluginFramework.Base.NexusWrappedInstance")
local NexusCollapsableListFrame = NexusGit:GetResource("NexusPluginFramework.UI.CollapsableList.NexusCollapsableListFrame")
local ActionIcon = NexusGit:GetResource("UI.Frame.Action.ActionIcon")

...
```