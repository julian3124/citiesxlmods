-- It uses delayedtasks to force the control over blueprints in another way... (GlobexCo)

function BluePrintBase:ValidateBPPlacement ()
	Interface:DoActionScript("CONSTRUCTIONMENU2","Project.Validate")
	Interface:DoActionScript("CONSTRUCTIONMENU2","ClearPhotos")
	Interface:DoActionScript("CONSTRUCTIONMENU2","ClearMain")
	DelayedTasks:AddtaskForce("TRADING:CheckGpProgress", {}, 2)
end

function TradingLogic:RequestGPProgess()
		if (cnx) and (TradingLogic:OfflineMode() == false) then 
			TRADING:GetGpProgress()


		end	
end

function TradingLogic:RequestBPUpdates()
	
	if (TradingLogic:OfflineMode()) then 
		TRADING:CheckGpProgress()
		return
	end
	
	if (cnx and next(TRADING.BpDesc) == nil) then 
		cnx:Trading():InitBlueprints()
	end
	
	TRADING.CityGp  = TRADING.CityGp or {}
	TRADING.CityGp[ TradingLogic:GetCurrentCityId()]  = {}
	
	TRADING:GetPlayerBlueprints()
	TRADING:GetGpProgress()
	 
end

function TradingLogic:GPProgressArrived()

	local _CityID = TradingLogic:GetCurrentCityId()
	
	if (TRADING.CityGp == nil or TRADING.CityGp[_CityID] == nil ) then 
		LOG_WARNING("TRADING.CityGp is nil, cannot resolve message")
		return 
	end

	if (next (TRADING.CityGp[_CityID]) == nil) then 
		LOG_INFO("Player does not hasve any GP in progress")
	end	
	
	
	for _GPId,_GDProgressDesc in pairs(TRADING.CityGp[_CityID]) do 
	
		local Name
		local iBpDesc = TRADING.BpDesc[_GDProgressDesc.m_iBpType]
		if (iBpDesc ~= nil) then 
			Name = iBpDesc.m_strAlias
		end	
			
		if (Name ~= nil) then 
			-- LOG_INFO("Blueprint : "..Name.." in city ".._GDProgressDesc.m_iCityId.." with ID ".._GDProgressDesc.m_iGpCityId.." has progress = ".. _GDProgressDesc.m_iProgress.." and stage ".._GDProgressDesc.m_iCurPhase)			
		else
			LOG_WARNING("Unknown BP type : ".._GDProgressDesc.m_iBpType) 
			Name = "Unknown-".._GDProgressDesc.m_iBpType
		end
	
		TradingData.GPByCity[_GDProgressDesc.m_iCityId] = TradingData.GPByCity[_GDProgressDesc.m_iCityId] or {}
			
		TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId] = {}
			
		TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId].GpCityId = _GDProgressDesc.m_iGpCityId
		TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId].BpType  = _GDProgressDesc.m_iBpType 
		TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId].Name = Name; 
		TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId].CityID = _GDProgressDesc.m_iGpCityId
		TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId].Progress = _GDProgressDesc.m_iProgress
		TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId].CurrentPhase = _GDProgressDesc.m_iCurPhase
			
		for k,v in pairs (_GDProgressDesc.m_vTokenProgress) do 
			TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId]["Token"..k.."Needed"] = v.m_iNeeded
			TradingData.GPByCity[_GDProgressDesc.m_iCityId][_GDProgressDesc.m_iGpCityId]["Token"..k.."Sent"] = v.m_iAlreadySent
		end
	
		if (_GDProgressDesc.m_iCityId == _CityID) then 
			local nxtStep = _GDProgressDesc.m_iCurPhase
			
			if iBpDesc ~= nil and iBpDesc.m_vPhases[nxtStep] ~= nil then
				local BpTrigger = true
				--LOG_ERROR("nxtStep : " .. tostring(nxtStep))
					
				for tId,tV in pairs(iBpDesc.m_vPhases[nxtStep]) do
					--LOG_ERROR("tok : " .. tostring(tV.m_iTokenId) .. " :: " .. tostring(tV.m_iTotalAmount) .. " vs " .. tostring( _GDProgressDesc.m_vTokenProgress[tV.m_iTokenId].m_iAlreadySent))
					if tV.m_iTotalAmount > 0 and tV.m_iTotalAmount > _GDProgressDesc.m_vTokenProgress[tV.m_iTokenId].m_iAlreadySent then
						BpTrigger = false
						break
					end
				end
				
				if BpTrigger == true then
					local Thumb, SimName = TradingLogic:GetImageFromSimID(Name)
					
					if nxtStep < 3 and iBpDesc.m_vPhases[nxtStep + 1] == nil then
						nxtStep = 3
					end
				
					MESSAGEBOX:DoNewMessageBox(7, SimName, "&ThisProjectHasReachedTheNextStage", "MESSAGEBOX:NoAction", "", "MESSAGEBOX:NoAction", "","&Ok", "&Close")
					MESSAGEBOX:HideNo()

					Command:Post("BLUEPRINT","BIGPROJECTIDSTEP", _GDProgressDesc.m_iGpCityId.." "..Name.." "..nxtStep)
					DelayedTasks:AddtaskForce("TRADING:CheckGpProgress", {}, 2)
					--TRADING:CheckGpProgress()
				end

			end			


		end	
	end

end

function TradingLogic:DoAssignation(_str) 

	-- InterfaceUtilities:LOG_CUSTOM1("Doing GP assignation _ str = ".._str) 

	local Tab = InterfaceUtilities:GetTableFromLongString(_str)
	
	if (TradingLogic:OfflineMode()) then 
		local CityId =  TradingLogic:GetCurrentCityId()
		
		TRADING:CheckGpProgress()
		
		--LOG_ERROR("TradingLogic:DoAssignation : CityId : " .. tostring(CityId) .. " Tab.ID : " .. tostring(Tab.ID) .. " ::: " .. tostring(TRADING.CityGp[CityId][Tab.ID]))
		
		--ME:Print_r(TRADING.CityGp, " :: ")
		
		Tab.ID = tonumber(Tab.ID)
		
		if TRADING.CityGp[CityId][Tab.ID] ~= nil and TRADING.CityGp[CityId][Tab.ID].m_iProgress < 100 then
			local TimersInfo = {}
			local Limit = TradingLogic:GetLimit()
		
			Time:GetAllTimersInfo( TimersInfo )
			local Timer = TimersInfo.Timers[TimersInfo.ActiveTimerIndex];
			local TimerNext = (Timer.Turn * 60) + Timer.Step + 60
			
			--LOG_ERROR("TimerNext : " .. tostring(TimerNext))
		
			for i = 1, Limit do
				local Name = TradingLogic:GetTokenName(i)
				local Nb = tonumber(Tab[Name] or 0)
				local OldNb = TRADING.CityGp[CityId][Tab.ID].m_vTokenProgress[i].m_iAlocated
				local UsedTimerNext = TRADING.CityGp[CityId][Tab.ID].m_vTokenProgress[i].m_iTimerNext
				
				--LOG_ERROR("TradingLogic:DoAssignation : TokName : " .. tostring(Name) .. " TokNb : " .. tostring(Nb))
			
				if Nb > 0 and Nb ~= OldNb then
					UsedTimerNext = TimerNext
				elseif Nb == 0 then
					UsedTimerNext = 0
				end
			
				TRADING.CityGp[CityId][Tab.ID].m_vTokenProgress[i].m_iAlocated = Nb
				TRADING.CityGp[CityId][Tab.ID].m_vTokenProgress[i].m_iTimerNext = UsedTimerNext
				TRADING.GpTokenAllocs[CityId][Tab.ID][i] = Nb
				TRADING.GpTokenAllocsByName[CityId][Tab.ID][Name] = Nb
			end
			
			TRADING:CheckGpProgressDelayed(TimerNext)

			TradingLogic:GPProgressArrived()
		end
		
		TradingLogic:ButtonPress("ManageMegastructures")
		
		return
	end

	local _Allocation = {}

	if (Tab.ID == nil) then 
	--	LOG_ERROR("Tab ID is nil, cannot proceed.")
		return 
	end

	_Allocation.m_iGpId = Tab.ID
	_Allocation.m_iCityId = TradingLogic:GetCurrentCityId()
	--LOG_ERROR("GP ID = "..tostring(_Allocation.m_iGpId))

	local Limit = TradingLogic:GetLimit()

	for i = 1, Limit do 
		local Name = TradingLogic:GetTokenName(i)
		local Nb = Tab[Name]
		_Allocation[i] = Tab[Name]
		if (Nb ~= nil) then 
			-- InterfaceUtilities:LOG_CUSTOM1("Assigning "..Nb.." tokens of "..i.." = "..Name)
		end
	end
	--ShowTableElementInLog( _Allocation, "_Allocation")
	TRADING:AllocateToken(_Allocation)

	TradingLogic:ButtonPress("ManageMegastructures")

	DelayedTasks:Addtask("TradingLogic:DelayedAllocUpdate", nil, 40)
end