# Nexus-Project
Nexus Project simplifies requiring resources in Roblox Lua.
Using `require` in Roblox typically involves numerous `WaitForChild`
calls, such as:
```
local Script1 = require(game.Workspace:WaitForChild("Project"):WaitForChild("Script1"))
local Script2 = require(game.Workspace:WaitForChild("Project"):WaitForChild("Subfolder1"):WaitForChild("Script2"))
local Script3 = require(game.Workspace:WaitForChild("Project"):WaitForChild("Subfolder2"):WaitForChild("Script3"))
local Part1 = game.Workspace:WaitForChild("Project"):WaitForChild("Part")
...
```
Nexus Project is designed to simplify this, similar to imports.
```
local Project = NexusProject.new(game.Workspace:WaitForChild("Project"))
local Script1 = Project:GetResource("Script1")
local Script2 = Project:GetResource("Subfolder1.Script2")
local Script3 = Project:GetResource("Subfolder2.Script3")
local Part1 = Project:GetResource("Part1")
...
```