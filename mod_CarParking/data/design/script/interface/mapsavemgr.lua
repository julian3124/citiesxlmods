--require "gd"

MapSaveMgr = MapSaveMgr or {}


MapSaveMgr.CurrentRegion = MapSaveMgr.CurrentRegion or 0
MapSaveMgr.CurrentMap = MapSaveMgr.CurrentMap or 0

MapSaveMgr.Directory = "live/solo"

MapSaveMgr.SaveFileName = "fn.dat"

MapSaveMgr.SaveFilePath = MapSaveMgr.Directory .. "/"..MapSaveMgr.SaveFileName 

MapSaveMgr.RegionStats =  MapSaveMgr.RegionStats or {}

MapSaveMgr.flagGotoPlanet = false
MapSaveMgr.flagQuit = false
MapSaveMgr.flagGotoRegion = false

MapSaveMgr.ShowPictures = true

MapSaveMgr.ContractsTable = MapSaveMgr.ContractsTable or {}

MapSaveMgr.IconIds = MapSaveMgr.IconIds or {}

MapSaveMgr.SaveNameTable = {}




MapSaveMgr.CurrentOnlineMap = ""

function MapSaveMgr:DoesCurrentMapAllowGemType(_Type)
	
	local MapName 
	MapName = MapSaveMgr.CurrentOnlineMap
	return  MapSaveMgr:DoesMapAllowGemType(MapName, _Type)
end

function MapSaveMgr:DoesMapAllowGemType(_mapName, _Type)

	if (_Type == "GemSki") or(_Type == "Ski") or (_Type == "SKI") then
		if (MapMgr.g_FullMapList[_mapName] ~= nil) and (MapMgr.g_FullMapList[_mapName].Flags ~= nil) then
			for k,v in pairs (MapMgr.g_FullMapList[_mapName].Flags) do 
				if (v == "SNOW_0") then 
					return true
				end	
			end	
		end	
		
		return false
	end
	
	if (_Type == "GemBeach") or(_Type == "Beach") or (_Type == "BEACH") then
		if (MapMgr.g_FullMapList[_mapName] ~= nil) and (MapMgr.g_FullMapList[_mapName].Flags ~= nil) then
			for k,v in pairs (MapMgr.g_FullMapList[_mapName].Flags) do 
				if (v == "BEAC_0") then 
					return true
				end	
			end	
		end	
		
		return false
	end
	

end


function MapSaveMgr:CreateScreenShot(FileName)
    Command:Post( "SCREENSHOT", FileName, "400x256" )
end



function MapSaveMgr:TreatScreenShot(Tab)
	--LOG_ERROR("now treating screenshot : "..Tab.FileName)
	
	-- should never be called ?
	do return end
	
	
end

	





function MapSaveMgr:InitRegion()


end


function MapSaveMgr:GetPlayable(RegionNb, MapNb) 
	
	local Playable = false 
	local NewMapName = MapSaveMgr.Regions["Region"..tostring(RegionNb)]["Map"..tostring(MapNb)][2]
	if MapMgr.g_FullMapList[NewMapName] ~= nil and MapMgr.g_FullMapList[NewMapName].Playable ~= nil and MapMgr.g_FullMapList[NewMapName].Playable == true then 
		 Playable = true 
	end	
	
	return (Playable and MapSaveMgr:IsLERA(RegionNb))
		
end




function MapSaveMgr:CreateLevelScreenShot()
		local MapName = MapSaveMgr.Regions["Region"..tostring(MapSaveMgr.CurrentRegion)]["Map"..tostring(MapSaveMgr.CurrentMap)][2]
		local FullScreenSaveFile = "../AssetSource/Interface/Flash/TGATexture_src/Maps/"..MapName.."_Full.dds"
		local SmallScreenSaveFile = "../AssetSource/Interface/Flash/TGATexture_src/Maps/"..MapName..".dds"

		Command:Post( "LEVELSCREENSHOT", SmallScreenSaveFile, "400x256x90" )
		
		local Tab = {}
		Tab["FileName"] = FullScreenSaveFile
		Tab["SmallFileName"] = SmallScreenSaveFile 
		Tab["Tries"]=0		
end


function MapSaveMgr:YesQuit(_Action)

	if (TutorialStatesMgr.TutorialActive) then 
		Main:RequestExitApp(0)
		return 
	end

	MapSaveMgr.flagGotoPlanet = false
	MapSaveMgr.flagQuit = true
	MapSaveMgr:Save()
end


function MapSaveMgr:QuitMessageBox()

	MESSAGEBOX:DoNewMessageBox(1, "&ReallyQuit", "&AreYouSureYouWantToQuit", "MapSaveMgr:YesQuit", "", "MESSAGEBOX:NoAction", "","&Yes", "No")
end


function MapSaveMgr:ClosePanel(Tab)
	if (Tab.Screen ~= nil) then 
		Interface:ClosePanel(Tab.Screen)
	end	
end

function MapSaveMgr:Quit(Tab)
		Main:RequestExitApp(0)
end


function MapSaveMgr:TaskSave(Tab)

end


function MapSaveMgr:SaveThenQuit()
	--LOG_ERROR("calling save then quit") 
	MapSaveMgr:QuitMessageBox()
end


function MapSaveMgr:SaveThenPlanet()
	--LOG_ERROR("calling save then planet") 
	MapSaveMgr.flagGotoPlanet = true
	MapSaveMgr.flagGotoRegion = false
	MapSaveMgr.flagQuit = false
	MapSaveMgr:Save()
end


function MapSaveMgr:SaveThenRegion()
	--LOG_ERROR("calling save then planet") 
	MapSaveMgr.flagGotoPlanet = false
	MapSaveMgr.flagGotoRegion = true
	MapSaveMgr.flagQuit = false
	MapSaveMgr:Save()
end


function MapSaveMgr:Save()
	if (INGAME.VisitMode) then 
		return 
	end	

	if (InterfaceMgr.SoloMode) then

	end
end


function MapSaveMgr:DoSave()

	if (InterfaceMgr.SoloMode) then
	
	end

end


function MapSaveMgr:DefineCityFullName(Region, Map, _NewCityName)

	

end


function MapSaveMgr:DefineCityName(_NewCityName)
	MapSaveMgr:DefineCityFullName(MapSaveMgr.CurrentRegion, MapSaveMgr.CurrentMap, _NewCityName)
end


function MapSaveMgr:Entry (b)

end


function MapSaveMgr:CalculateStatsByRegion()


end


function MapSaveMgr:Serialize(o,file)

	InterfaceUtilities:Serialize(o,file)
end


function MapSaveMgr:SerializeSaveNameTable()

	
end

function MapSaveMgr:LoadCityNames()
    --LOG_INFO("Loading city names")

end


function MapSaveMgr:NoDeleteSolo()

	

end


function MapSaveMgr:YesDeleteSolo(MapNb)

	
end


function MapSaveMgr:RequestDeletion(MapNb) 
	
	local FileName = MapSaveMgr:getFileName(MapSaveMgr.CurrentRegion, tonumber(MapNb))
	--local CityName = MapSaveMgr.SaveNameTable[FileName].CityName
	LocVarMgr:SetValue("CityName", MapSaveMgr.SaveNameTable[FileName].CityName)
	MESSAGEBOX:DoNewMessageBox(3, "&ReallyDeleteCity", "&AreYouSureYouWantToDeleteThisCitySolo", "MapSaveMgr:YesDeleteSolo", tostring(MapNb), "MapSaveMgr:NoDeleteSolo", "","&Yes", "&No")
	
end


--[[//////////////////////////////////////////////////////////////////////////////////////////////

FALLBACK TRADING LOGIC TO BE ABLE TO TEST WHILE THE NETWORK SERVICE IS SPOTTY 

//////////////////////////////////////////////////////////////////////////////////////////////]]

function MapSaveMgr:CreateOmnicorpContracts(MyCityID, _Exchange, _EndDate)	-- now the fun starts

	
	local _table = {}
	
	_table.m_iSourceCityId = MyCityID
	
	if (MyCityID == nil) then 
		LOG_ERROR("MyCityID is nil, cannot do Omnicorp solo contract")
		return 
	end
	_table.m_ExchangeList = _Exchange
	_table.m_EndDate = _EndDate
		
	table.insert( MapSaveMgr.ContractsTable, _table) 
	
	MapSaveMgr:SerializeSaveNameTable()
	
	MapSaveMgr:ResolveContracts() -- needs to include impacts - does it ? 
	
end

function MapSaveMgr:RemoveOmnicorpContracts(MyCityID)

	for k,_table in ipairs (MapSaveMgr.ContractsTable) do 
	
		if (_table.m_iSourceCityId == MyCityID) then 
			table.remove (MapSaveMgr.ContractsTable, k)
			MapSaveMgr:RemoveOmnicorpContracts(MyCityID)
			return
		end
	end

end


function MapSaveMgr:CreateContracts(MyCityID, HisCityID, _Exchange, _EndDate)	-- now the fun starts

	if (true) then 
		return 
	end
	
	local _table = {}
	
	_table.m_iSourceCityId = MyCityID
	
	if (MyCityID == nil) then 
		LOG_ERROR("MyCityID is nil")
	end
	
	if (HisCityID == nil) then 
		LOG_ERROR("MyCityID is nil")
	end
	
	_table.m_iDestCityId = HisCityID
	
	_table.m_ExchangeList = _Exchange
	
	_table.m_iState = TradingLogic:ContractState("UNDEFINED")
	
	_table.m_CreationDate = _EndDate
	_table.m_EndDate = _EndDate
		
	table.insert( MapSaveMgr.ContractsTable, _table) 
	
	MapSaveMgr:SerializeSaveNameTable()
	MapSaveMgr:ResolveContracts()
end

MapSaveMgr.OmnicorpTokenCurrentImpacts = {}

function MapSaveMgr:GetNbContracts()

	local Nb = 0
	for k,_table in ipairs (MapSaveMgr.ContractsTable) do 
	
		if (_table.m_iSourceCityId == MapSaveMgr:getCurrentCityId()) then 
			Nb = Nb +1 
		end
	end
	
	return Nb 

end

function MapSaveMgr:ResolveOmniContractsForCurrentCity()

	MapSaveMgr.OmnicorpTokenCurrentImpacts ={}

	for tokenID = 1,TradingLogic.MaxSoloTokens do 
		local key = TradingLogic:GetTokenName(tokenID) 
		MapSaveMgr.OmnicorpTokenCurrentImpacts[key] =  {}
		MapSaveMgr.OmnicorpTokenCurrentImpacts[key].id = tokenID
		MapSaveMgr.OmnicorpTokenCurrentImpacts[key].production = CitySaveCalculations:getNumberOfTokens(key)
		MapSaveMgr.OmnicorpTokenCurrentImpacts[key].imported =  0
		MapSaveMgr.OmnicorpTokenCurrentImpacts[key].exported =  0
	end
		
		

	for k,_table in ipairs (MapSaveMgr.ContractsTable) do 
	
		if (_table.m_iSourceCityId == MapSaveMgr:getCurrentCityId()) then 
		
			local nowDate = DateUtilities:GetNowDate() 
			
			--ShowTableElementInNotepad(firstDateTab,"firstDateTab")
			
			local contractDate = DateUtilities:ReadDateFromGameString(_table.m_EndDate) 
			
			--ShowTableElementInNotepad(contractDate,"contractDate")
		
			if (DateUtilities:IsFirstBeforeSecond(contractDate, nowDate)) then 
				LOG_ERROR("Current contract is out of date, removing") 
				local Tab = {}
				Tab.contract = {}
				Tab.now = {}
				
				for k,v in pairs (contractDate) do 
					Tab.contract[k] = v
				end
				
				for k,v in pairs (nowDate) do 
					Tab.now[k] = v
				end
				
				--ShowTableElementInNotepad(Tab, "Tab")
				
				MapSaveMgr.ContractsTable[k] = nil
				
			else			
				for tokenID, summary in pairs(_table.m_ExchangeList) do 
					
					summary = tonumber(summary)
					
					local key = TradingLogic:GetTokenName(tokenID) 
					
					LOG_ERROR(" for "..key.." ( tokenID = "..(tokenID or "nil")..") impact = "..summary) 
					
					if (key ~= "Pb") then 
						
						MapSaveMgr.OmnicorpTokenCurrentImpacts[key] = MapSaveMgr.OmnicorpTokenCurrentImpacts[tokenID] or {}
						MapSaveMgr.OmnicorpTokenCurrentImpacts[key].production = CitySaveCalculations:getNumberOfTokens(key)
						
						if (summary < 0) then 
							MapSaveMgr.OmnicorpTokenCurrentImpacts[key].imported =  -1*summary
							MapSaveMgr.OmnicorpTokenCurrentImpacts[key].exported =  0
						else	
							MapSaveMgr.OmnicorpTokenCurrentImpacts[key].imported =  0
							MapSaveMgr.OmnicorpTokenCurrentImpacts[key].exported =  summary
						end	
					end	
				end
			end	
		end
	end
	
	TradingLogic:PushTokenStatusToCurrentCity(MapSaveMgr.OmnicorpTokenCurrentImpacts) 

end

function MapSaveMgr:ResolveContracts()	-- now the fun starts

	-- set all the contract states to undefined and all the import and export to 0
	if (true) then 
		MapSaveMgr:ResolveOmniContractsForCurrentCity()
		return 
	end
	
	for _CityID,_CityTable in pairs (MapSaveMgr.SaveNameTable) do 

		for _tokenID, _TokenTable in pairs (MapSaveMgr.SaveNameTable[_CityID].Tokens) do 
			MapSaveMgr.SaveNameTable[_CityID].Tokens[_tokenID].m_iContractsIn = 0
			MapSaveMgr.SaveNameTable[_CityID].Tokens[_tokenID].m_iContractsOut = 0
		end
	end	
	
	for k,v in pairs (MapSaveMgr.ContractsTable) do 
		MapSaveMgr.ContractsTable[k].m_iState = TradingLogic:ContractState("UNDEFINED")
	end
	
	local _newContractFound = true
	
	while (_newContractFound) do 
	
		_newContractFound = false
	
		for k,v in ipairs (MapSaveMgr.ContractsTable) do 
		
			if (v.m_iState == TradingLogic:ContractState("UNDEFINED")) then 
			
				local _contractPossible = true 

				-- check that the contract is possible 	
				for _id, _table in pairs (v.m_ExchangeList) do 
				
					local tokID = _table.m_iTokenId 
					local Amount = _table.m_iAmount 
					local Provider = _table.m_iSourceCityId 
					
					if (MapSaveMgr:GetAvailableTokens(Provider, tokID) < Amount) then 
						_contractPossible = false
					end	
					
				end
				
				-- if so, apply it 
				if (_contractPossible) then 
					
					LOG_ERROR("Contract is possible") 
					
					for _id, _table in pairs (v.m_ExchangeList) do 
					
						local tokID = _table.m_iTokenId 
						
						local Amount = _table.m_iAmount 
						local Exporter = _table.m_iSourceCityId 
						local Importer = _table.m_iDestCityId 
						
						if (Exporter == nil) then 
							LOG_ERROR("Exporter is nill")
						end
						
						if (Importer == nil) then 
							LOG_ERROR("Importer is nill")
						end
						
						if (MapSaveMgr.SaveNameTable[Importer] == nil) then 
							LOG_ERROR("MapSaveMgr.SaveNameTable["..Importer.."].Tokens is nill")
						end
						
						
						MapSaveMgr.SaveNameTable[Importer].Tokens[tokID].m_iContractsIn = (MapSaveMgr.SaveNameTable[Importer].Tokens[tokID].m_iContractsIn or 0) + Amount 
						MapSaveMgr.SaveNameTable[Exporter].Tokens[tokID].m_iContractsOut = (MapSaveMgr.SaveNameTable[Exporter].Tokens[tokID].m_iContractsOut or 0) + Amount
		
					end
					
					MapSaveMgr.ContractsTable[k].m_iState = TradingLogic:ContractState("ACTIVE")
					LOG_ERROR("Setting contract "..k.." is now valid ("..TradingLogic:ContractState("ACTIVE")..") insead of undef ("..TradingLogic:ContractState("UNDEFINED")..")")
					_newContractFound = true 
				end	
			
			end
		end
	end
	
	for k,v in pairs (MapSaveMgr.ContractsTable) do 
		if (v.m_iState == TradingLogic:ContractState("UNDEFINED")) then 
			LOG_ERROR("Contract "..k.." is now Alerted")
			MapSaveMgr.ContractsTable[k].m_iState = TradingLogic:ContractState("ALERTED")
		else
			LOG_ERROR("Contract "..k.." is now Active ("..MapSaveMgr.ContractsTable[k].m_iState..")")
		end
	end
	
	MapSaveMgr:SerializeSaveNameTable()

end

function MapSaveMgr:GetAvailableTokens(_cityID, _tokenNB)

	if (MapSaveMgr.SaveNameTable[_cityID] == nil) then
		LOG_ERROR("No available tokens for ".._cityID.." because no entry in SaveNameTable") 
		return 0
	end	
    
	if (MapSaveMgr.SaveNameTable[_cityID].Tokens[_tokenNB] == nil) then
		LOG_ERROR("No available tokens for ".._cityID.." on token ".._tokenNB.." because that entry is nil")
		return 0
	end	
	
	local prod =   MapSaveMgr.SaveNameTable[_cityID].Tokens[_tokenNB].m_iProduction
	local import = MapSaveMgr.SaveNameTable[_cityID].Tokens[_tokenNB].m_iContractsIn or 0
	local export = MapSaveMgr.SaveNameTable[_cityID].Tokens[_tokenNB].m_iContractsOut or 0
	
	local Available = prod + import - export

	return (Available)
end


function MapSaveMgr:TokenSearch(_tokentable, _city, _player)

	local resultTable = {}
	
	for k,v in pairs(MapSaveMgr.SaveNameTable) do 
	
		local _cityfits = true
		
		for k2,v2 in pairs(_tokentable) do 
			if (MapSaveMgr:GetAvailableTokens(k, k2) < v2) then 
					_cityfits = false
				end
			end
		
		if (_cityfits == true) then 
			LOG_ERROR("We found a fit, in "..k)
			resultTable[k] = {}
			resultTable[k].CityID = k
			resultTable[k].CityName = v.CityName
			resultTable[k].PlayerName = "Solo"
			--resultTable[k].Tokens = {}
			for k2,v2 in pairs (v.Tokens) do
				resultTable[k][TradingLogic:GetTokenName(k2)] = MapSaveMgr:GetAvailableTokens(k, k2)
			end
		end
			
	end
	
	return resultTable

end


function MapSaveMgr:getCurrentCityId()
	return MapSaveMgr:getFileName(MapSaveMgr.CurrentRegion,MapSaveMgr.CurrentMap)
end


function MapSaveMgr:getCurrentCityName()

	if (TutorialStatesMgr.TutorialActive) then
		return TutorialStatesMgr.TutorialChapter 
	end

	local fn =  MapSaveMgr:getFileName(MapSaveMgr.CurrentRegion,MapSaveMgr.CurrentMap)
	return (MapSaveMgr.SaveNameTable[fn].CityName)
end

function MapSaveMgr:getFileName(Region,Map)
	local FileName ="SoloSaveRegion"..tostring(Region).."Map"..tostring(Map)..".sol"
	return (FileName)
end

function MapSaveMgr:getCityName(_Id)

	if (TutorialStatesMgr.TutorialActive) then
		return TutorialStatesMgr.TutorialChapter 
	end
	
	if (MapSaveMgr.SaveNameTable[_Id] ~= nil) then 
		return (MapSaveMgr.SaveNameTable[_Id].CityName)
	else
		return "Unknown"
	end
end	

function MapSaveMgr:getAvailable(_tokenID)

	TradingHouse:OfflineUpdate()

	local fn = TradingLogic:GetCurrentCityId()

	if (MapSaveMgr.SaveNameTable[fn] == nil) then 
		MapSaveMgr:getCurrentCityTokens()
		LOG_ERROR("No available tokens - MapSaveMgr.SaveNameTable is nil in MapSaveMgr:getAvailable") 
		return 0
	end
	
	local key = TradingLogic:GetTokenName(_tokenID)
	
	if (TradingLogic.CityTokens[fn][key] == nil) then 
		LOG_ERROR("No available tokens - TradingLogic.CityTokens[fn][key] is nil for this city / token pair") 
		return 0
	end
	
	return (TradingLogic.CityTokens[fn][key].available or 0)

end

function MapSaveMgr:getCurrentCityTokens()

	
	MapSaveMgr:ResolveContracts()
	InterfaceUtilities:LOG_CUSTOM1(" MapSaveMgr:getCurrentCityTokens() called") 
	
	local fn 
	
	if (TutorialStatesMgr.TutorialActive) then 
		MapSaveMgr.CurrentRegion = 0
		MapSaveMgr.CurrentMap = 0
	
		fn = "SoloSaveRegion0Map0.sol"
	else	
		fn = TradingLogic:GetCurrentCityId()
	end
	
	local _table = {}
	
	if (MapSaveMgr.SaveNameTable[fn] == nil) and (TutorialStatesMgr.TutorialActive == false)  then 
	
		LOG_ERROR("No effect - MapSaveMgr.SaveNameTable in MapSaveMgr:getCurrentCityTokens") 
		return _table
	else
		_table.PlayerName = "solo"
		if (TutorialStatesMgr.TutorialActive == false) then 
			_table.CityName = MapSaveMgr.SaveNameTable[fn].CityName
		else 
			_table.CityName = TutorialStatesMgr.TutorialChapter or "Tutorial"
		end	
		_table.CityID = fn 
		
		TradingLogic.CityTokens = TradingLogic.CityTokens or {}
		TradingLogic.CityTokens[fn] = TradingLogic.CityTokens[fn] or {}
		
		for k = 1,TradingLogic.MaxSoloTokens do 
			local key = TradingLogic:GetTokenName(k)
			
			local prod = CitySaveCalculations:getNumberOfTokens(key)
			
			local import = MapSaveMgr:CalculateOfflineTradeImpact(k) --MapSaveMgr.OmnicorpTokenCurrentImpacts[key].imported or 0
			local export = 0 --MapSaveMgr.OmnicorpTokenCurrentImpacts[key].exported or 0
			local project = TradingLogic:GetAllocatedInBpExceptThisBP(-1, key)
			
			InterfaceUtilities:LOG_CUSTOM1(" For token "..key.." prod = "..prod.." and trade balance = "..import) 
			
			--local import, export = MapSaveMgr:GetTokensTrade(fn, k)
			
			_table[key] = (prod or 0)+(import or 0) - (export or 0)  - (project or 0)
			
			TradingLogic.CityTokens[fn][key] = {}
			TradingLogic.CityTokens[fn][key].id = k
			TradingLogic.CityTokens[fn][key].production	= prod or 0
			TradingLogic.CityTokens[fn][key].imported	= import or 0
			TradingLogic.CityTokens[fn][key].exported	= export or 0
			TradingLogic.CityTokens[fn][key].committedToOffer	 = 0
			TradingLogic.CityTokens[fn][key].ToCity	 = 0
			TradingLogic.CityTokens[fn][key].available     		= prod + import - export - project
            TradingLogic.CityTokens[fn][key].assignedCity	 	= 0
            TradingLogic.CityTokens[fn][key].assignedProject 	= project
			TradingLogic.CityTokens[fn][key].currentwooffer = prod + import - export - project
			TradingLogic.CityTokens[fn][key].current = prod + import - export - project
			TradingLogic.CityTokens[fn][key].transportusage = math.abs(import) + math.abs(export)
			
			
			
		end
		
		
		return _table
	end	
end

function MapSaveMgr:GetTokensTrade(fn, tokenID) 
end


function MapSaveMgr:getCityTokens(fn)

	return MapSaveMgr:getCurrentCityTokens()
	--[[

	local _table = {}
	
	if (MapSaveMgr.SaveNameTable[fn] == nil) then 
		
		return _table
	end
	_table[fn] = {}
	_table[fn].Tokens = {}
	
	local _tempTable = {}
	
	for idx = 1, TradingLogic.MaxSoloTokens do
        _table[fn].Tokens[idx] = {}
        _table[fn].Tokens[idx].m_iTokenId       = idx
        _table[fn].Tokens[idx].m_iProduction    = MapSaveMgr.SaveNameTable[fn].Tokens[idx].m_iProduction
        _table[fn].Tokens[idx].m_iContractsIn	 = MapSaveMgr.SaveNameTable[fn].Tokens[idx].m_iContractsIn
        _table[fn].Tokens[idx].m_iContractsOut	 = MapSaveMgr.SaveNameTable[fn].Tokens[idx].m_iContractsOut
        _table[fn].Tokens[idx].m_iOffersOut	 = 0
        _table[fn].Tokens[idx].m_iToCity		 = 0
    end
	
	return _table]]
end


function MapSaveMgr:getCityOffers(fn)

	local _table = {}
	
	if (MapSaveMgr.SaveNameTable[fn] == nil) then 
		
		return _table
	end
	
	_table[fn] = {}

	-- offers are always accepted in solo mode 
	return _table

end



function MapSaveMgr:getTokenSummaryText(cityID)

	local Return = ""
	
	local aSourceCityInfos = MapSaveMgr.SaveNameTable[cityID]
	
	if (aSourceCityInfos ~= nil) and (aSourceCityInfos.Tokens ~= nil) then 
	
		for	k,v in ipairs (aSourceCityInfos.Tokens) do 
		
			
		end
	
		
	
	
	end
	
	return Return
		
end

MapSaveMgr.ContractList = MapSaveMgr.ContractList or {}

function MapSaveMgr:TestCalculateOfflineTradeImpact()

	for i = 1,15 do 
	
		local TName = (TradingLogic:GetTokenName(i) or "unknown")
		local Impact = tostring(MapSaveMgr:CalculateOfflineTradeImpact(i))
		
		InterfaceUtilities:LOG_CUSTOM1("For token "..TName.." the impact of trade is "..Impact)
	
	end
end


function MapSaveMgr:CancelContract(ContractID)


	InterfaceUtilities:LOG_CUSTOM1("Recieved order to cancel "..ContractID)
	
	--_OmniContract.TokenID..";".._OmniContract.Amount..";".._OmniContract.State ..";".._OmniContract.Cash
	
	local Tab = InterfaceUtilities:StringSplit(ContractID, ";")
	
	local tokenID = tonumber(Tab[1] or 0)
	local Amount = tonumber(Tab[2] or 0)
	local State = Tab[3] or 0
	local Cash = tonumber(Tab[4] or 0)
	local IsSale = (Tab[5] == "true")
	
	local fn = TradingLogic:GetCurrentCityId()
	
	if (MapSaveMgr.ContractList[fn] == nil) then 
		InterfaceUtilities:LOG_CUSTOM1("contract list is empty for city "..fn)
		return
	end	
	
	local TokenName = (TradingLogic:GetTokenName(tokenID) or "unknown")
	
	if (MapSaveMgr.ContractList[fn][TokenName] == nil) then 
		InterfaceUtilities:LOG_CUSTOM1("No contracts with "..TokenName)
		return
	end	
	
	for _index, _ContractTable in pairs (MapSaveMgr.ContractList[fn][TokenName]) do 
	
		if (_ContractTable.IsSell == IsSale) 
				and (_ContractTable.Amount == Amount)
				and (_ContractTable.Cash == Cash) then 
			
			InterfaceUtilities:LOG_CUSTOM1("contract found, removing")
			table.remove(MapSaveMgr.ContractList[fn][TokenName], _index)
			
			return 
		end
			
	end
	
	InterfaceUtilities:LOG_CUSTOM1("no contract found")
	

end

function MapSaveMgr:CalculateOfflineTradeImpact(tokenID)

	
	local Sum = 0

	local fn = TradingLogic:GetCurrentCityId()
	
	if (MapSaveMgr.ContractList[fn] == nil) then 
		InterfaceUtilities:LOG_CUSTOM1("contract list is empty for city "..fn)
		return 0
	end	
	
	if (tokenID == 1) then 
		for k, _TokenTable in pairs (MapSaveMgr.ContractList[fn]) do 
			for _index, _ContractTable in pairs (_TokenTable ) do 
				if (_ContractTable.IsSell) then 
					Sum = Sum - math.abs(_ContractTable.Cash)
				else
					Sum = Sum + math.abs(_ContractTable.Cash)
				end
			end
		end
		
		return Sum
	end
	
	local tName = (TradingLogic:GetTokenName(tokenID) or "unknown")
	
	if (MapSaveMgr.ContractList[fn][tName] == nil) then 
		return 0
	end	
	
	for _index, _ContractTable in pairs (MapSaveMgr.ContractList[fn][tName]) do 
	
		if (_ContractTable.IsSell) then 
			Sum = Sum + math.abs(_ContractTable.Amount)
		else
			Sum = Sum - math.abs(_ContractTable.Amount)
		end
			
	end
	
	return Sum

end




function MapSaveMgr:getTransportUsage(fn)

	fn = fn or TradingLogic:GetCurrentCityId()
	
	if (MapSaveMgr.SaveNameTable[fn] == nil) then 
		LOG_ERROR("no save found for "..fn) 
		return 0, 0
	end
	
	
	local SumPassenger = 0
	local SumFreight = 0
	
	if (MapSaveMgr.ContractList[fn] == nil) then 
		LOG_ERROR("no contracts found for "..fn) 
		return 0, 0
	else
		for key,_TokenTable in pairs (MapSaveMgr.ContractList[fn]) do 
		
			if (CitySaveCalculations.TransportType[key] == 2) then -- passenger
				for _index, _ContractTable in pairs (_TokenTable) do 
					SumPassenger = SumPassenger + math.abs(_ContractTable.Amount)
				end	
			elseif (CitySaveCalculations.TransportType[key] == 1) then -- freight
				for _index, _ContractTable in pairs (_TokenTable) do 
					SumFreight = SumFreight + math.abs(_ContractTable.Amount)
				end	
			
			end
			
		end
	end	

	return 	SumPassenger, SumFreight

end

function MapSaveMgr:getNewCityContracts(fn)

	TradingHouse:ClearContracts()
	TradingHouse:DoAS("ClearGenContracts")

	
	fn = fn or TradingLogic:GetCurrentCityId()
	
	if (MapSaveMgr.SaveNameTable[fn] == nil) then 
		LOG_ERROR("no save found for "..fn) 
		return
	end
	
	if (MapSaveMgr.ContractList[fn] == nil) then 
		LOG_ERROR("no contracts found for "..fn) 
		return
	else
		for k,_TokenTable in pairs (MapSaveMgr.ContractList[fn]) do 
			for _index, _ContractTable in pairs (_TokenTable) do 
				local GenFormatContract = TradingHouse:ConvertOmniContractToGeneralFormat(_ContractTable)
				TradingHouse:AddGenContract(GenFormatContract)
			end	
		end
	end		
	
	TradingHouse:PushContractsToInterface()

end
	


function MapSaveMgr:getCityContracts(fn)

	do 
		MapSaveMgr:getNewCityContracts(fn)
		return 
	end

	local _table = {}
	
	if (MapSaveMgr.SaveNameTable[fn] == nil) then 
		LOG_ERROR("no save found for "..fn) 
		return _table
	end

	_table[fn] = {}
	
	for k,v in pairs (MapSaveMgr.ContractsTable) do 
	
		if (v.m_iDestCityId == fn) or (v.m_iSourceCityId==fn) then 
			local iContractId = k
            _table[fn][iContractId] = {}
            _table[fn][iContractId].m_iId           = k
            _table[fn][iContractId].m_iSourceCityId = v.m_iSourceCityId
            _table[fn][iContractId].m_iDestCityId   = v.m_iDestCityId
            _table[fn][iContractId].m_iState        = v.m_iState
            _table[fn][iContractId].m_CreationDate  = v.m_CreationDate
            _table[fn][iContractId].m_EndDate       = v.m_EndDate
            _table[fn][iContractId].m_iOfferId      = v.m_iOfferId

            _table[fn][iContractId].m_ExchangeList = InterfaceUtilities:DeepCopyTable(v.m_ExchangeList) 
		end
	
	end

	-- offers are always accepted in solo mode 
	return _table
end

function  MapSaveMgr:InitSlots()

end

function MapSaveMgr_OnIconRollOver (_IconId)


end

function MapSaveMgr:RollOverMap(_IconId) 
end

FileSystem:DoFile("Data/Design/Script/interface/MapSaveMgr.master")
