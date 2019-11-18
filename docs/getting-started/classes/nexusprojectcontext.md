# NexusProjectContext
(Extends `NexusObject`)
(Uses implemention of `[NexusProject](nexusproject.md)`)

`NexusProjectContext` is created by `NexusProject::GetContext`
for warning about cyclic dependencies. All of the API except
for the constructor is caried over from `[NexusProject](nexusproject.md)`.

### `static NexusProjectContext.new(RequiringScript,Project)`
Creates a Nexus Project Context object. Not intended
to be used outside of `NexusProject::GetContext`.

### `NexusProjectContext:SetContextResource(Resource)`
Sets the resource for the given context.