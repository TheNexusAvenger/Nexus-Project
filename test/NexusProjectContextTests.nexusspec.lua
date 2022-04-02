--[[
TheNexusAvenger

Tests the NexusProjectContext class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusProject"))



--[[
Creates the component under testing and sub-instances.
--]]
local function Setup()
	--Create the folders and a ModuleScript.
	local Folder1 = Instance.new("Folder")
	Folder1.Name = "Folder1"
	
	local ModuleScript1A = Instance.new("ModuleScript")
	ModuleScript1A.Name = "ModuleScript1A"
	ModuleScript1A.Source = "return \"Test 1\""
	ModuleScript1A.Parent = Folder1
	
	local Folder1A = Instance.new("Folder")
	Folder1A.Name = "Folder1A"
	Folder1A.Parent = Folder1
	
	local Folder1B = Instance.new("Folder")
	Folder1B.Name = "Folder1B"
	Folder1B.Parent = Folder1A
	
	local ModuleScript1B = Instance.new("ModuleScript")
	ModuleScript1B.Name = "ModuleScript1B"
	ModuleScript1B.Source = "return \"Test 2\""
	ModuleScript1B.Parent = Folder1B
	
	local Folder2 = Instance.new("Folder")
	Folder2.Name = "Folder2"
	
	local ModuleScript2A = Instance.new("ModuleScript")
	ModuleScript2A.Name = "ModuleScript2A"
	ModuleScript2A.Source = "return \"Test 3\""
	ModuleScript2A.Parent = Folder2
	
	local Folder3 = Instance.new("Folder")
	Folder3.Name = "Folder3"
	
	local Folder3A = Instance.new("Folder")
	Folder3A.Name = "Folder3A"
	Folder3A.Parent = Folder3
	
	local ModuleScript3A = Instance.new("ModuleScript")
	ModuleScript3A.Name = "ModuleScript3A"
	ModuleScript3A.Source = "return \"Test 4\""
	ModuleScript3A.Parent = Folder3A
	
	local ModuleScript3B = Instance.new("ModuleScript")
	ModuleScript3B.Name = "ModuleScript3B"
	ModuleScript3B.Source = "wait(0.1) return \"Test 5\""
	ModuleScript3B.Parent = Folder3A
	
	--Create the component under testing.
	local CuT = NexusProject.new(Folder1)
	CuT:CreatePathLink("Test1",Folder2)
	CuT:CreatePathLink("Test2",Folder3)
	
	--Return the CuT and folders.
	return CuT:GetContext(ModuleScript1A),Folder1,Folder2,Folder3
end

--[[
Tests the IsLoading method.
--]]
NexusUnitTesting:RegisterUnitTest("IsLoading",function(UnitTest)
	--Create the component under testing.
	local CuT,Folder1,Folder2,Folder3 = Setup()
	
	--Load the resouce in a co-routine.
	coroutine.wrap(function()
		CuT:GetResource("Test2.Folder3A.ModuleScript3B")
	end)()
	
	--Run the assertions.
	wait()
	UnitTest:AssertTrue(CuT:IsLoading("Test2.Folder3A.ModuleScript3B"),"Resource is loaded.")
	wait(0.1)
	UnitTest:AssertFalse(CuT:IsLoading("Test2.Folder3A.ModuleScript3B"),"Resource is not loaded.")
	UnitTest:AssertEquals(CuT:GetResource("Test2.Folder3A.ModuleScript3B"),"Test 5","Resource is incorrect.")
end)

--[[
Tests the IsInstanceInPath method.
--]]
NexusUnitTesting:RegisterUnitTest("IsInstanceInPath",function(UnitTest)
	--Create the component under testing.
	local CuT,Folder1,Folder2,Folder3 = Setup()
	
	--Run the assertions for valid instances.
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder1))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder1.ModuleScript1A))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder1.Folder1A))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder1.Folder1A.Folder1B))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder1.Folder1A.Folder1B.ModuleScript1B))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder2))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder2.ModuleScript2A))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder3))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder3.Folder3A))
	UnitTest:AssertTrue(CuT:IsInstanceInPath(Folder3.Folder3A.ModuleScript3A))
	UnitTest:AssertFalse(CuT:IsInstanceInPath(game:GetService("Workspace")))
end)

--[[
Tests the IsResourceCyclic method.
--]]
NexusUnitTesting:RegisterUnitTest("IsResourceCyclic",function(UnitTest)
	--Create the component under testing.
	local CuT = NexusProject.new(script)
	CuT:__AddInternalDependency("Test1","Test2")
	CuT:__AddInternalDependency("Test1","Test3")
	CuT:__AddInternalDependency("Test2","Test4")
	CuT:__AddInternalDependency("Test3","Test2")
	CuT:__AddInternalDependency("Test4","Test5")
	CuT:__AddInternalDependency("Test5","Test1")
	CuT:__AddInternalDependency("Test5","Test6")
	
	--Run the assertions.
	UnitTest:AssertTrue(CuT:IsResourceCyclic("Test1"),"Test1 isn't cyclic.")
	UnitTest:AssertTrue(CuT:IsResourceCyclic("Test2"),"Test2 isn't cyclic.")
	UnitTest:AssertTrue(CuT:IsResourceCyclic("Test3"),"Test3 isn't cyclic.")
	UnitTest:AssertTrue(CuT:IsResourceCyclic("Test4"),"Test4 isn't cyclic.")
	UnitTest:AssertTrue(CuT:IsResourceCyclic("Test5"),"Test5 isn't cyclic.")
	UnitTest:AssertFalse(CuT:IsResourceCyclic("Test6"),"Test6 is cyclic.")
	UnitTest:AssertFalse(CuT:IsResourceCyclic("Test7"),"Test7 is cyclic.")
end)

--[[
Tests the GetPathFromInstance method.
--]]
NexusUnitTesting:RegisterUnitTest("GetPathFromInstance",function(UnitTest)
	--Create the component under testing.
	local CuT,Folder1,Folder2,Folder3 = Setup()
	
	--Run the assertions for valid paths.
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder1),"")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder1.ModuleScript1A),"ModuleScript1A")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder1.Folder1A),"Folder1A")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder1.Folder1A.Folder1B),"Folder1A.Folder1B")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder1.Folder1A.Folder1B.ModuleScript1B),"Folder1A.Folder1B.ModuleScript1B")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder2),"Test1")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder2.ModuleScript2A),"Test1.ModuleScript2A")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder3),"Test2")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder3.Folder3A),"Test2.Folder3A")
	UnitTest:AssertEquals(CuT:GetPathFromInstance(Folder3.Folder3A.ModuleScript3A),"Test2.Folder3A.ModuleScript3A")
	
	--Assert non-project paths error.
	UnitTest:AssertErrors(function()
		CuT:GetPathFromInstance(game:GetService("Workspace"))
	end)
end)

--[[
Tests the GetDependencyPath method.
--]]
NexusUnitTesting:RegisterUnitTest("GetDependencyPath",function(UnitTest)
	--Create the component under testing.
	local CuT = NexusProject.new(script)
	CuT:__AddInternalDependency("Test1","Test2")
	CuT:__AddInternalDependency("Test1","Test3")
	CuT:__AddInternalDependency("Test2","Test4")
	CuT:__AddInternalDependency("Test3","Test2")
	CuT:__AddInternalDependency("Test4","Test5")
	CuT:__AddInternalDependency("Test5","Test1")
	CuT:__AddInternalDependency("Test5","Test6")
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT:GetDependencyPath("Test1","Test3"),{"Test1","Test3"},"Path is incorrect.")
	UnitTest:AssertEquals(CuT:GetDependencyPath("Test1","Test1"),{"Test1","Test2","Test4","Test5","Test1"},"Path is incorrect.")
	UnitTest:AssertEquals(CuT:GetDependencyPath("Test2","Test2"),{"Test2","Test4","Test5","Test1","Test2"},"Path is incorrect.")
	UnitTest:AssertEquals(CuT:GetDependencyPath("Test3","Test3"),{"Test3","Test2","Test4","Test5","Test1","Test3"},"Path is incorrect.")
	UnitTest:AssertEquals(CuT:GetDependencyPath("Test4","Test4"),{"Test4","Test5","Test1","Test2","Test4"},"Path is incorrect.")
	UnitTest:AssertEquals(CuT:GetDependencyPath("Test5","Test5"),{"Test5","Test1","Test2","Test4","Test5"},"Path is incorrect.")
	UnitTest:AssertNil(CuT:GetDependencyPath("Test1","Test7"),"Path exists.")
	UnitTest:AssertNil(CuT:GetDependencyPath("Test6","Test6"),"Path exists.")
	UnitTest:AssertNil(CuT:GetDependencyPath("Test7","Test7"),"Path exists.")
end)

--[[
Tests the GetContext method.
--]]
NexusUnitTesting:RegisterUnitTest("GetContext",function(UnitTest)
	--Create the component under testing.
	local CuT,Folder1,Folder2,Folder3 = Setup()
	
	--Create the context and get some resources.
	local Context = CuT:GetContext(script)
	UnitTest:AssertEquals(Context:GetResource("Folder1A.Folder1B.ModuleScript1B"),"Test 2","Path returned incorrectly.")
	UnitTest:AssertEquals(Context:GetResource("Test2.Folder3A.ModuleScript3A"),"Test 4","Path returned incorrectly.")
	
	--Run the assertions.
	UnitTest:AssertEquals(Context.ClassName,"NexusProjectContext","Context class is incorrect.")
	UnitTest:AssertEquals(CuT.__Project.__ExternalDependencies[script],{"Folder1A.Folder1B.ModuleScript1B","Test2.Folder3A.ModuleScript3A"},"External dependencies is incorrect.")
end)

--[[
Tests the GetResource method.
--]]
NexusUnitTesting:RegisterUnitTest("GetResource",function(UnitTest)
	--Create the component under testing.
	local CuT,Folder1,Folder2,Folder3 = Setup()
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT:GetResource("Folder1A.Folder1B.ModuleScript1B"),"Test 2","Path returned incorrectly.")
	UnitTest:AssertEquals(CuT:GetResource("Test1.ModuleScript2A"),"Test 3","Path returned incorrectly.")
	UnitTest:AssertEquals(CuT:GetResource("Test2.Folder3A.ModuleScript3A"),"Test 4","Path returned incorrectly.")
	UnitTest:AssertEquals(CuT.__Project.__InternalDependencies["ModuleScript1A"],{"Folder1A.Folder1B.ModuleScript1B","Test1.ModuleScript2A","Test2.Folder3A.ModuleScript3A"},"Internal dependencies is incorrect.")
end)

--[[
Tests the SetResource method.
--]]
NexusUnitTesting:RegisterUnitTest("SetResource",function(UnitTest)
	--Create the component under testing.
	local CuT,Folder1,Folder2,Folder3 = Setup()
	
	--Set up the resources.
	CuT:SetResource("ModuleScript1A","Test 5")
	CuT:SetResource("Test3.Resource","Test 6")
	
	--Run the assertions.
	UnitTest:AssertEquals(CuT:GetResource("ModuleScript1A"),"Test 5","Resource is incorrect.")
	UnitTest:AssertEquals(CuT:GetResource("Test3.Resource"),"Test 6","Resource is incorrect.")
end)

--[[
Tests the SetContextResource method.
--]]
NexusUnitTesting:RegisterUnitTest("SetContextResource",function(UnitTest)
	--Create the component under testing.
	local CuT,Folder1,Folder2,Folder3 = Setup()
	
	--Set the resource.
	CuT:SetContextResource("Test A")
	
	--Run the assertion.
	UnitTest:AssertEquals(CuT:GetResource("ModuleScript1A"),"Test A","Resource is incorrect.")
end)



return true