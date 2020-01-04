--[[
TheNexusAvenger

Allows tracking of dependencies in a project.
--]]

local NexusObject = require(script.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))

local NexusProjectContext = NexusObject:Extend()
NexusProjectContext:SetClassName("NexusProjectContext")



--[[
Creates a Nexus Project Context object.
--]]
function NexusProjectContext:__new(RequiringScript,Project)
	self:InitializeSuper()
	self.__RequiringScript = RequiringScript
	self.__Project = Project
end

--[[
Returns if a resource loading.
--]]
function NexusProjectContext:IsLoading(Path)
	return self.__Project:IsLoading(Path)
end

--[[
Returns if an instance is part of the project.
--]]
function NexusProjectContext:IsInstanceInPath(Ins)
	return self.__Project:IsInstanceInPath(Ins)
end

--[[
Returns if a dependent eventually has itself
as a dependent.
--]]
function NexusProjectContext:IsResourceCyclic(Path)
	return self.__Project:IsResourceCyclic(Path)
end

--[[
Returns the object reference for the given string.
--]]
function NexusProjectContext:GetObjectReference(Path)
	return self.__Project:GetObjectReference(Path)
end

--[[
Returns the project path for the given instance. Throws
an error if the instance isn't part of the project.
--]]
function NexusProjectContext:GetPathFromInstance(Ins)
	return self.__Project:GetPathFromInstance(Ins)
end

--[[
Returns a table of the path from a dependent to a sub-dependent.
Returns nil if the dependent doesn't have the dependency.
--]]
function NexusProjectContext:GetDependencyPath(Dependent,Dependency,VisitiedDependents)
	return self.__Project:GetDependencyPath(Dependent,Dependency,VisitiedDependents)
end

--[[
Returns a context for getting resources. The first
parameter should be the "script" property. This is
used for detecting and warning cyclic dependencies
(A requires B, B requires A).
--]]
function NexusProjectContext:GetContext(ScriptReference)
	return self.__Project:GetContext(ScriptReference)
end

--[[
Returns the resource for the given path. If it is a
ModuleScript, it is required and returned.
--]]
function NexusProjectContext:GetResource(Path)
	self.__Project:__AddDependency(self.__RequiringScript,Path)
	return self.__Project:GetResource(Path)
end

--[[
Creates a link between a string and a game
reference. Note that it will only be valid for the
first word (ex: "game" in "game.Workspace") and
the given string should NOT have a period. Also
note that links are case sensitive.
--]]
function NexusProjectContext:CreatePathLink(Reference,Object)
	self.__Project:CreatePathLink(Reference,Object)
end

--[[
Registers a resource with a given path. If GetResource
is called, it will use what is registered.
--]]
function NexusProjectContext:SetResource(Path,Resource)
	self.__Project:SetResource(Path,Resource)
end

--[[
Sets the resource for the given context.
--]]
function NexusProjectContext:SetContextResource(Resource)
	local Path = self:GetPathFromInstance(self.__RequiringScript)
	self.__Project:SetResource(Path,Resource)
end



return NexusProjectContext