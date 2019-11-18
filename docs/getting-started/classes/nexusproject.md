# NexusProject
(Extends `NexusObject`)

`NexusProject` is the root class for projects. When
setting up a project, `NexusProject`'s constructor
should be called like the other examples.

### `static NexusProject.new(ReferenceInstance,SuppressCyclicWarnings)`
Creates an instance of Nexus Project. The
`ReferenceInstance` is the root object of
the project. `SuppressCyclicWarnings` can
be sent to `true` to disable warnings about
cyclic loading (ex: Script1 requires Script2,
Script2 requires Script1).

### `NexusProject:GetResource(Path)`
Returns the resource for the given path. If it is a
ModuleScript, it is required and returned.

### `NexusProject:SetResource(Path,Resource)`
Registers a resource with a given path. If GetResource
is called, it will use what is registered.

### `NexusProject:CreatePathLink(Reference,Object)`
Creates a link between a string and a game
reference. Note that it will only be valid for the
first word (ex: `game` in `game.Workspace`) and
the given string should NOT have a period. Also
note that links are case sensitive.

### `NexusProject:IsLoading(Path)`
Returns if a resource loading.

### `NexusProject:GetContext(ScriptReference)`
Returns a [NexusProjectContext](nexusprojectcontext.md)
for getting resources. The first parameter should be the
`script` property. This is used for detecting and warning
cyclic dependencies (A requires B, B requires A).

### `NexusProject:IsInstanceInPath(Ins)`
Returns if an instance is part of the project.

### `NexusProject:IsResourceCyclic(Path)`
Returns if a dependent eventually has itself
as a dependent.

### `NexusProject:GetObjectReference(Path)`
Returns the object reference for the given string.

### `NexusProject:GetPathFromInstance(Ins)`
Returns the project path for the given instance. Throws
an error if the instance isn't part of the project.

### `NexusProject:GetDependencyPath(Dependent,Dependency,VisitiedDependents)`
Returns a table of the path from a dependent to a sub-dependent.
Returns nil if the dependent doesn't have the dependency.