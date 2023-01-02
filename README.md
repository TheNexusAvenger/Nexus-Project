**Nexus Project is no longer maintained because it prevents Luau typing from working properly.**

# Nexus-Project
Nexus Project simplifies requiring resources in Roblox Lua.
Using `require` in Roblox typically involves numerous `WaitForChild`
calls, such as:
```lua
local Script1 = require(game.Workspace:WaitForChild("Project"):WaitForChild("Script1"))
local Script2 = require(game.Workspace:WaitForChild("Project"):WaitForChild("Subfolder1"):WaitForChild("Script2"))
local Script3 = require(game.Workspace:WaitForChild("Project"):WaitForChild("Subfolder2"):WaitForChild("Script3"))
local Part1 = game.Workspace:WaitForChild("Project"):WaitForChild("Part")
...
```
Nexus Project is designed to simplify this, similar to imports.
```lua
local Project = NexusProject.new(game.Workspace:WaitForChild("Project"))
local Script1 = Project:GetResource("Script1")
local Script2 = Project:GetResource("Subfolder1.Script2")
local Script3 = Project:GetResource("Subfolder2.Script3")
local Part1 = Project:GetResource("Part1")
...
```

## Documentation
Documentation can be found
on the [GitHub pages](https://thenexusavenger.github.io/Nexus-Project)
for this project. The [docs folder](docs) can also be used since it has all
of the markdown files.

## Contributing
Both issues and pull requests are accepted for this project.
More information can be found [here](docs/contributing.md).

## License
Nexus Project is available under the terms of the MIT 
Licence. See [LICENSE](LICENSE) for details.
