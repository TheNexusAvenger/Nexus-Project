--[[
TheNexusAvenger

Simplifies manages resources in large scale projects.
--]]

local CYCLIC_WARNING_TIME_REQUIREMENT = 5



local NexusObject = require(script:WaitForChild("NexusInstance"):WaitForChild("NexusObject"))
local NexusProjectContext = require(script:WaitForChild("NexusProjectContext"))

local NexusProject = NexusObject:Extend()
NexusProject:SetClassName("NexusProject")



--[[
Creates an instance of Nexus Project.
--]]
function NexusProject:__new(ReferenceInstance,SuppressCyclicWarnings)
	self:InitializeSuper()
	self.__BaseReference = ReferenceInstance
	self.__SuppressCyclicWarnings = SuppressCyclicWarnings == true
	
	self.__Links = {}
	self.__CachedResources = {}
	self.__LoadingResources = {}
	self.__InternalDependencies = {}
	self.__ExternalDependencies = {}
end

--[[
Adds an internal dependency reference.
--]]
function NexusProject:__AddInternalDependency(DependentPath,DependencyPath)
	--Add the table if it doesn't exist.
	if not self.__InternalDependencies[DependentPath] then
		self.__InternalDependencies[DependentPath] = {}
	end
	
	--Return if the reference exists.
	local Dependencies = self.__InternalDependencies[DependentPath]
	for _,Dependency in pairs(Dependencies) do
		if Dependency == DependencyPath then
			return
		end
	end
	
	--Add the dependency.
	table.insert(Dependencies,DependencyPath)
end

--[[
Adds an external dependency reference.
--]]
function NexusProject:__AddExternalDependency(DependentInstance,DependencyPath)
	--Add the table if it doesn't exist.
	if not self.__ExternalDependencies[DependentInstance] then
		self.__ExternalDependencies[DependentInstance] = {}
	end
	
	--Return if the reference exists.
	local Dependencies = self.__ExternalDependencies[DependentInstance]
	for _,Dependency in pairs(Dependencies) do
		if Dependency == DependencyPath then
			return
		end
	end
	
	--Add the dependency.
	table.insert(Dependencies,DependencyPath)
end

--[[
Adds a dependency reference.
--]]
function NexusProject:__AddDependency(DependentInstance,DependencyPath)
	if self:IsInstanceInPath(DependentInstance) then
		self:__AddInternalDependency(self:GetPathFromInstance(DependentInstance),DependencyPath)
	else
		self:__AddExternalDependency(DependentInstance,DependencyPath)
	end
end

--[[
Returns if a resource loading.
--]]
function NexusProject:IsLoading(Path)
	return self.__LoadingResources[Path] == true
end

--[[
Returns if an instance is part of the project.
--]]
function NexusProject:IsInstanceInPath(Ins)
	--Return true if it is or is under the base reference.
	if Ins == self.__BaseReference or self.__BaseReference:IsAncestorOf(Ins) then
		return true
	end
	
	--Return true if it is equal to or under a linked reference.
	for _,Reference in pairs(self.__Links) do
		if Ins == Reference or Reference:IsAncestorOf(Ins) then
			return true
		end
	end
	
	--Return false (not part of the project).
	return false
end

--[[
Returns if a dependent eventually has itself
as a dependent.
--]]
function NexusProject:IsResourceCyclic(Path)
	return self:GetDependencyPath(Path,Path) ~= nil
end

--[[
Returns the object reference for the given string.
--]]
function NexusProject:GetObjectReference(Path)
	--Split the path.
	local SplitPath = string.split(Path,".")
	if Path == "" then
		SplitPath = {}
	end
	
	--Get the base instance.
	local Base = self.__BaseReference
	for FirstItem,Reference in pairs(self.__Links) do
		if SplitPath[1] == FirstItem then
			table.remove(SplitPath,1)
			Base = Reference
			break
		end
	end
	
	--Get the reference.
	local Reference = Base
	for _,PathPart in pairs(SplitPath) do
		if Reference == nil then
			break
		end
		
		Reference = Reference:WaitForChild(PathPart)
	end
	
	--Retrun the reference.
	return Reference
end

--[[
Returns the project path for the given instance. Throws
an error if the instance isn't part of the project.
--]]
function NexusProject:GetPathFromInstance(Ins)
	local Path = ""
	local CurrentReference = Ins
	
	--Move up the path until nil is reached.
	while CurrentReference ~= nil do
		--Break the loop if the root of the project was reached.
		local ParentReached = false
		if CurrentReference == self.__BaseReference then
			break
		end
		for PathPart,Reference in pairs(self.__Links) do
			if Reference == CurrentReference then
				Path = PathPart.."."..Path
				ParentReached = true
				break
			end
		end
		if ParentReached then break end
		
		--Add to the path and move up.
		Path = CurrentReference.Name.."."..Path
		CurrentReference = CurrentReference.Parent
	end
	
	--If the current reference is nil, throw an error.
	if CurrentReference == nil then
		error("Instance isn't part of the project: "..tostring(Ins:GetFullName()))
	end
	
	--Return the path.
	return string.sub(Path,1,#Path - 1)
end

--[[
Returns a table of the path from a dependent to a sub-dependent.
Returns nil if the dependent doesn't have the dependency.
--]]
function NexusProject:GetDependencyPath(Dependent,Dependency,VisitiedDependents)
	VisitiedDependents = VisitiedDependents or {}
	VisitiedDependents[Dependent] = true
	local Dependencies = self.__InternalDependencies[Dependent]
	
	--Return nil if dependencies don't exists.
	if not Dependencies then
		return nil
	end
	
	--Return if the dependent has the given dependency.
	for _,OtherDependency in pairs(Dependencies) do
		if Dependency == OtherDependency then
			return {Dependent,Dependency}
		end
	end
	
	--Return if a dependency has the given dependency.
	for _,OtherDependency in pairs(Dependencies) do
		if not VisitiedDependents[OtherDependency] then
			local DependencyList =  self:GetDependencyPath(OtherDependency,Dependency,VisitiedDependents)
			if DependencyList then
				table.insert(DependencyList,1,Dependent)
				return DependencyList
			end
		end
	end
	
	--Return nil (not a dependency).
	return nil
end

--[[
Returns a context for getting resources. The first
parameter should be the "script" property. This is
used for detecting and warning cyclic dependencies
(A requires B, B requires A).
--]]
function NexusProject:GetContext(ScriptReference)
	return NexusProjectContext.new(ScriptReference,self)
end

--[[
Returns the resource for the given path. If it is a
ModuleScript, it is required and returned.
--]]
function NexusProject:GetResource(Path)
	--Return a cached resource if it exists.
	local CachedResource = self.__CachedResources[Path]
	if CachedResource then
		return CachedResource
	end
	
	--Get the resource and require it if it is a ModuleScript.
	self.__LoadingResources[Path] = true
	coroutine.wrap(function()
		local Resource = self:GetObjectReference(Path)
		if typeof(Resource) == "Instance" and Resource.IsA and Resource:IsA("ModuleScript") then
			Resource = require(Resource)
		end
		
		--Cache the resource.
		if not self.__CachedResources[Path] then
			self.__CachedResources[Path] = Resource
		end
		
		--Register the resource as loaded.
		self.__LoadingResources[Path] = nil
	end)()
	
	--Start a loop and wait for the instance.
	local StartTime = tick()
	local WarningDisplayed = false
	local Resource
	while Resource == nil and self.__LoadingResources[Path] do
		Resource = self.__CachedResources[Path]
		
		--Break if the resource exists.
		if Resource ~= nil then
			return Resource
		end
	
		--Display a warning if it is cyclic.
		if WarningDisplayed == false and self.__SuppressCyclicWarnings ~= true and tick() - StartTime > CYCLIC_WARNING_TIME_REQUIREMENT then
			local DependencyPath = self:GetDependencyPath(Path,Path)
			if DependencyPath then
				WarningDisplayed = true
				warn("A dependency loop exists:")
				for _,Path in pairs(DependencyPath) do
					warn("\t"..Path)
				end 
				warn("Use NexusProject::SetResource or NexusProjectContext::SetContextResource to allow the loop to end without having to load the resources.")
			end
		end
		wait()
	end
	
	--Return the resource.
	return self.__CachedResources[Path]
end

--[[
Creates a link between a string and a game
reference. Note that it will only be valid for the
first word (ex: "game" in "game.Workspace") and
the given string should NOT have a period. Also
note that links are case sensitive.
--]]
function NexusProject:CreatePathLink(Reference,Object)
	self.__Links[Reference] = Object
end

--[[
Registers a resource with a given path. If GetResource
is called, it will use what is registered.
--]]
function NexusProject:SetResource(Path,Resource)
	self.__CachedResources[Path] = Resource
end



return NexusProject