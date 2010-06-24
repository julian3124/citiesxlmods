-- root.patch uses this file to control the placement of blueprints (GlobexCo)

DelayedTasks = DelayedTasks or {}
DelayedTasks.List = DelayedTasks.List  or {}
DelayedTasks.GlobalParamTable = DelayedTasks.GlobalParamTable or {}


function DelayedTasks:ClearTaskList(_functionname)
	DelayedTasks.List = nil
	DelayedTasks.List = {}
end


function DelayedTasks:DoesTaskAlreadyExist(_functionname)

	for k,v in ipairs (DelayedTasks.List) do

			if (_functionname == v.Command) then 
				--LOG_ERROR(" trying to add a task that already exists : ".._functionname)
				return true
			end	
	end
	
	return false
	
end

function DelayedTasks:AddtaskForce(_functionname, _paramtable, _steps)
	
	local Task = {
			Command = _functionname,
			Parameters = _paramtable,
			Steps = _steps
		}

	table.insert (DelayedTasks.List,Task)


end

function DelayedTasks:Addtask(_functionname, _paramtable, _steps)

	if (DelayedTasks:DoesTaskAlreadyExist(_functionname)) then 
		
		return 
	end
	
	local Task = {
			Command = _functionname,
			Parameters = _paramtable,
			Steps = _steps
		}

	table.insert (DelayedTasks.List,Task)


end


function DelayedTasks:PrintTable()
	
	LOG_ERROR(" Printing delayed task list")
		
	for k,v in ipairs (DelayedTasks.List) do
		LOG_ERROR(" Task : "..k.." is "..v.Command.." and will be executed in "..v.Steps)
	end
end

function DelayedTasks:Update()


	for k,v in ipairs (DelayedTasks.List) do

		v.Steps = v.Steps -1
		if (v.Steps <= 0) then
			local functionName = v.Command
			DelayedTasks.GlobalParamTable = v.Parameters or {}
			--InterfaceUtilities:LOG_ERROR(" Doing Task : "..functionName)
			table.remove(DelayedTasks.List,k)
			local f = loadstring(functionName.."(DelayedTasks.GlobalParamTable)")
			f()
			--InterfaceUtilities:LOG_ERROR(" Task steps : "..v.Steps)
		else
			--InterfaceUtilities:LOG_ERROR(" Task steps : "..v.Steps)
		end

	end

end


function DelayedTasks:TestDelayedTask()
	DelayedTasks:Addtask("DelayedTasks:DummyTaskForTest", {}, 100)
end


function DelayedTasks:DummyTaskForTest()
	LOG_ERROR("Dummy task called")
end


function DelayedTasks:GotoScreen(Tab)
	if (Tab.Screen ~= nil) then 
		InterfaceMgr:GotoScreen(Tab.Screen)
	end	
end


function DelayedTasks:Quit(Tab)
		Main:RequestExitApp(0)
end