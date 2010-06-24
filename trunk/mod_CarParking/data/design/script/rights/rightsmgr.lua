
RightsMgr = RightsMgr or {}

RightsMgr.DemoLimit = 22000 

RightsMgr.Edition = RightsMgr.Edition or ""

RightsMgr.POEndDate = 0

RightsMgr.ServerSentProfileError = false

RightsMgr.ET = 
	{
	limited = "LimitedEdition",
	}
	
	



	
RightsMgr.SB = 	-- r_building_ .. etc.
	{
	london_admiralty_arch = "Distributeur_Amazon",
	london_saint_paul_cathedral = "Distributeur_Game",
	london_nelsons_column = "Distributeur_Play",
	la_royce_hall = "Distributeur_Valve",
	new_york_woolworth = "Distributeur_IGN",
	
--	new_york_40th_wall_street = "whoknows",
--	los_angeles_city_hall = "whoknows",

	sydney_saint_mary_cathedral = "sydney_saint_mary_cathedral",
	sydney_queen_victoria_building = "sydney_queen_victoria_building",
	sydney_australian_museum = "sydney_australian_museum",

	
	}
	
	
RightsMgr.Features = 
					{
					Bus = "BUS", -- BUS
					BP = "ALL", -- ALL
					TEST = "TR", -- TR
					Ski = "ALL", -- IT originale, diventa ALL personale
					Linear = "BTP", -- BTP
					PauseDisconnects = "ALL", -- ALL
					NewTaxes = "ALL", -- ALL
					Medieval = "ALL", -- SUB originale, diventa ALL con pack
					Chinatown = "ALL", -- NONE originale, diventa ALL personale
					}
					

RightsMgr.FeatureTags = 		
				{
				Bus = {
					"BusTerminus", 
					"BusHeadQuarter",
					"BusLine",
					"BusLineTuto",
					},
					
				Medieval = {
					"Medieval", 
					},	
				
				Chinatown = {
					"Chinatown", 
					},					
				
					
				}

					
Feature = Feature or {}
Feature.Bus = "Bus"
Feature.Ski = "Ski"
Feature.Linear = "Linear"
Feature.PauseDisconnects = "PauseDisconnects"
Feature.NewTaxes = "NewTaxes"




	
function RightsMgr:NoAction(_args)
end


function RightsMgr:IsMapAllowed(MapName)

	if (MapName == nil) or (MapMgr.g_FullMapList[MapName] == nil) then 
		
		return true -- false originale, diventa true con muc
	end

	local AssetName = MapMgr.g_FullMapList[MapName].AssetName or "nil"
	


	if ((MapMgr.g_FullMapList[MapName].Special == nil) or (next(MapMgr.g_FullMapList[MapName].Special) == nil)) and (AssetName == "nil") then 
		return true
	end
	
	
	if (MapMgr.g_FullMapList[MapName].Special ~= nil) then 
		for k,v in pairs (MapMgr.g_FullMapList[MapName].Special) do 
			if RightsMgr:IsVersionAllowed(v) then 
				return true
			end	
		end
	end
	
	if (AssetName ~= "nil") then 
		if (NETWORK:IsAssetUsable("r_map_"..AssetName)) then 
			return true
		else
			return true -- false in origine (personale)
		end		
	end	
	
	--temp
	local Name = "r_map_"..MapName
	-- return NETWORK:IsAssetUsable( Name)  originale
	local _flag = NETWORK:IsAssetUsable( Name) -- muc
		return true	

end

function RightsMgr:IsVersionAllowed(EditionName)

	if (EditionName == nil) then 
		return true
	end
	
	local Ed = string.lower(EditionName or "")
	
	if NETWORK:IsAssetUsable( "r_edition_"..Ed) then
		return true
	end

	--special cases
	
	if (EditionName == "demo") or (EditionName == "trial") or (EditionName == "beta") then 
		return true
	end

	if (EditionName == "standard") and RightsMgr:IsLE() then
		return true
	end	

	return false

end

function RightsMgr:StartWaitForRightsTicket()
	g_WaitingForRightTicket = true
	NETWORK:GetMyProfile()
end

function RightsMgr:IsDiscoveryVersion()
	return NETWORK:IsAssetUsable("r_edition_planet_account")
end


function RightsMgr:NextScreenOnRightsTicketArrival()

	

	if (g_WaitingForRightTicket == true) then 
	
		NETWORK:CheckGetMyProfile()
		
		
	
		if (g_RightTicketArrived == true) then 
		
			InterfaceUtilities:LOG_CUSTOM1("Rights ticket arrived, going to next screen")
		
			if (RightsMgr.POEndDate ~= 0) or (NETWORK:IsAssetUsable( "r_account_planetoffer") ==false) or (RightsMgr.ServerSentProfileError==true) then 
				DMC()
				PlayerPathMgr:NextScreen()
				g_WaitingForRightTicket = false
			end	
		end
	end	
	
	
end


function RightsMgr:IsGemAllowed(GemName)

	-- should be "ski", "beach", etc.
	
	local Name = "r_gem_"..GemName
	-- return NETWORK:IsAssetUsable( Name)
	local _flag NETWORK:IsAssetUsable( Name) -- muc
		return true

end

function RightsMgr:IsMonteCristo()
	-- return NETWORK:IsAssetUsable("r_montecristo_int_employee")
	local _flag NETWORK:IsAssetUsable("r_montecristo_int_employee") -- personale
		return true
end

function RightsMgr:IsLocalTest()

	if (NETWORK:IsAssetUsable("r_montecristo_int_employee")) then 
		local Configuration = Main:GetConfiguration()
		return (Configuration == "PROFILE")
	else
		return false
	end	
end


function RightsMgr:IsCommunityManager()
	-- return NETWORK:IsAssetUsable("r_montecristo_int_community")
	local _flag NETWORK:IsAssetUsable("r_montecristo_int_community") -- personale
		return true
end

function RightsMgr:NbSlotsAllowed()
	--temp
	return 55
end

function RightsMgr:IsNewSlotAllowed()

	return true

end

function RightsMgr:StoreRemainingTime(_Time)

	InterfaceUtilities:LOG_CUSTOM1("Setting end date to "..tostring(_Time))
	
	RightsMgr.POEndDate = _Time 
	
	--temp = os.date("*t", RightsMgr.POEndDate) or {}
	
	RightsMgr.ServerSentProfileError = false

end


function RightsMgr:ProfileError()
	RightsMgr.ServerSentProfileError = true
end

function RightsMgr:PlanetModeAllowed()

		do return false end
	--temp
	return NETWORK:IsAssetUsable( "r_account_planetoffer")
end

function RightsMgr:GetPlanetMode()
	do return false end
	return NETWORK:IsAssetUsable( "r_account_planetoffer")

end

function RightsMgr:GetSlots()
end


function RightsMgr:InitRights()

	ChatMgr.CMMode =  RightsMgr:IsCommunityManager()
	
	
	
	if (RightsMgr:IsDemo()) then 
	
		InterfaceUtilities:LOG_CUSTOM1("We are in the demo")
	
		MapMgr:SetEdition("DEMO") 

		if (RightsMgr:PlanetModeAllowed()== false) then 
			InterfaceUtilities:LOG_CUSTOM1("No planet rights")
			PlayerPathMgr:GotoInfoScreen("DemoEnd")
			return 
		else
			InterfaceUtilities:LOG_CUSTOM1("We have planet rights")
		end

	else
		InterfaceUtilities:LOG_CUSTOM1("We are not in the demo")
	end
	
end

function RightsMgr:PlanetVisitAllowed()
	--temp
		do return false end
	
	return true
end

function RightsMgr:PlanetOfferIsAboutToExpire()
	do return false end
	
	if (RightsMgr.ServerSentProfileError==true) then 
		return false
	end

	if (NETWORK:IsAssetUsable( "r_account_planetoffer") == false) then 
		--LOG_INFO(" Player does not have the po")
		return false
	end

	local TimeLeft = RightsMgr.POEndDate - os.time()
	
	if (TimeLeft < 86400) then -- 24 hours 
		LOG_INFO(" time left is "..tostring(TimeLeft))
		return true
	end	

	return false
end

function RightsMgr:PopLimitAllowed()
	--temp
	return 1000000000
end

function RightsMgr:BuildingAllowed()
	--temp
	return 1000000000
end


function RightsMgr:IsDemo()
	do return false end
	
	local _flag = (NETWORK:IsAssetUsable("r_edition_demo") and 
				 (NETWORK:IsAssetUsable( "r_edition_standard") == false) and 
				 (NETWORK:IsAssetUsable( "r_edition_limited")==false) and 
				 (NETWORK:IsAssetUsable( "r_edition_beta")==false))
				 
	return _flag
	
end

function RightsMgr:IsTrialVersion()
	do return false end
	return (NETWORK:IsAssetUsable( "r_edition_trial") == true)
	
	
end


function RightsMgr:IsBTPPlayer()
	do return false end
	return NETWORK:IsAssetUsable("r_bonus_btp")
end 

function RightsMgr:IsInBTP()
	do return false end
	if (RightsMgr:IsBTPPlayer() == false) then 
		return false
	end
	
	return (GALAXY:GetCurrentAccess() == "BTP")

end


function RightsMgr:IsFullversionPOTrial()
	do return false end
	
	return NETWORK:IsAssetUsable( "r_account_trialpo") 

end

function RightsMgr:BusAllowed()
	
	--return ((RightsMgr:IsPayingSubscriber() or NETWORK:IsAssetUsable( "r_bonus_bus")) or ((TutorialStatesMgr.TutorialActive == true) and (TutorialStatesMgr.TutorialChapter == "&TutorialChapter9")))
	return true 
	
end



function RightsMgr:SoloModeAllowed()

--[[
if (RightsMgr:IsFullVersion()) then
		return true
	end	
	
	return false
]]

	return NETWORK:IsAssetUsable( "r_type_can_play_solo")

	
end


function RightsMgr:IsPayingSubscriber()

	--if (RightsMgr:IsFullVersion() == false) and (RightsMgr:IsDiscoveryVersion()==false) then 
	--	return false
	--end	
	
	if (InterfaceMgr.SoloMode == true) then 
		return true -- false originale, true con muc
	end	
	
	local _flag2 = RightsMgr:GetPlanetMode() 
	
	if (_flag2 == false) then 
		return true -- false originale, true con muc
	end	
	
	local _flag = NETWORK:IsAssetUsable( "r_account_trialpo") 
	
	if (_flag == true) then 
		return true -- false originale, true con muc
	end	
	
	return true
	
end



function RightsMgr:IsFullVersion()

	local _flag = ((NETWORK:IsAssetUsable( "r_edition_standard") == true) or
				 (NETWORK:IsAssetUsable( "r_edition_limited")==true))
				 
	return _flag
	
end

function RightsMgr:IsLE()
	
	--return NETWORK:IsAssetUsable( "r_edition_limited")
	-- !!May be used for cracking purposes -> ask! (GlobexCo)
	
	return true
end


function RightsMgr:Demo()

	
end

function RightsMgr:TU(_tag, _flag)

	--_flag = true 

	if (_flag) then 
		PlayerManager:AddLevelConditionTag(_tag) 
		
	else
		PlayerManager:RemoveConditionTag(_tag) 
	end	

end

--function RightsMgr:ULB()
	
	--for k,v in pairs (RightsMgr.ET) do 
		--RightsMgr:TU(v,NETWORK:IsAssetUsable("r_edition_"..k))
	--end
	
	--for k,v in pairs (RightsMgr.SB) do 
		
		--RightsMgr:TU(v,NETWORK:IsAssetUsable("r_building_"..k))
		
	--end
	
--end

function RightsMgr:ULB() -- muc
	local _flag = false;
	for k,v in pairs (RightsMgr.ET) do
			_flag = NETWORK:IsAssetUsable("r_edition_"..k)
		RightsMgr:TU(v,true)
	end
	
	for k,v in pairs (RightsMgr.SB) do
			_flag = NETWORK:IsAssetUsable("r_building_"..k)
		RightsMgr:TU(v,true)
	end
end

function RightsMgr:Allowed(NAME)

	if (RightsMgr.Features[NAME] == nil) then 
		return true -- false originale, true personale
	end

	local rType = RightsMgr.Functions[RightsMgr.Features[NAME]]
	
	if (type(rType) == "string") then 
		return NETWORK:IsAssetUsable(rType)
	end	
	
	
	if (rType == nil) then 
		LOG_ERROR_BUILD("Function returned nill for feature "..tostring(NAME))
		return false
	else
	
		local Flag = rType()
		
		if (Flag == nil) then 
			LOG_ERROR_BUILD("No function")
		end
	
		return (rType() or false) 
	end	

end


function RightsMgr:IsInterfaceTeam()
	return (InterfaceTeamAreTheBest or false)
end

function RightsMgr:OnEnterGalaxy() 
	if (RightsMgr:Allowed(Feature.NewTaxes)) then 
		NewIngame:GotoNewTaxes()
	else	
		NewIngame:GotoOldTaxes()
	end
	
	RightsMgr:setRightsTags() 
	
end

function RightsMgr:OnEnterTutorial() 
	if (RightsMgr:Allowed(Feature.NewTaxes)) then 
		NewIngame:GotoNewTaxes()
	else	
		NewIngame:GotoOldTaxes()
	end
	
	RightsMgr:setRightsTags() 
	
end

function RightsMgr:OnEnterSolo() 

	if (RightsMgr:Allowed(Feature.NewTaxes)) then 
		NewIngame:GotoNewTaxes()
	else	
 NewIngame:GotoOldTaxes()
end
	
	RightsMgr:setRightsTags() 
end


function RightsMgr:setRightsTags() 

	TagManager:clearAllForbidden()

	for feature, TagList in pairs(RightsMgr.FeatureTags) do 
		if (RightsMgr:Allowed(feature)==false) then 
			
			for index,_tag in pairs (TagList) do
				TagManager:addForbidden(_tag)
			end
		end
end

end

function RightsMgr:OnEnterPlanet() 

	if (RightsMgr:Allowed(Feature.NewTaxes)) then 
		NewIngame:GotoNewTaxes()
	else	
		NewIngame:GotoOldTaxes()
	end
	
	RightsMgr:setRightsTags() 
	
	
end



function RightsMgr:IsTrue() 
	return true
end	

function RightsMgr:IsFalse() 
	return false
end	


RightsMgr.Functions = 					
	{
	MC = RightsMgr.IsMonteCristo,
	MC00 = RightsMgr.IsLocalTest,
	BTP = RightsMgr.IsInBTP,
	BTPA = RightsMgr.IsBTPPlayer,
	SUB = RightsMgr.IsPayingSubscriber,
	TR = RightsMgr.IsTrue,
	ALL = RightsMgr.IsTrue,
	NONE = RightsMgr.IsFalse, 
	MOD = RightsMgr.IsModMode,
	IT = RightsMgr.IsInterfaceTeam,
	BUS = RightsMgr.BusAllowed,
	}




