-- correction made after root.patch (GlobexCo). The file used isn't an updated version, but it works correctly.

PlayerPathMgr = PlayerPathMgr  or {}

PlayerPathMgr.CurrentVideo = PlayerPathMgr.CurrentVideo or 0 

PlayerPathMgr.CurrentInfoScreen =  PlayerPathMgr.CurrentInfoScreen or ""

PlayerPathMgr.BetaOn = false

FileSystem:DoFile("data/design/script/rights/InfoScreens.data")


FileSystem:DoFile("data/design/script/rights/ExplaneList.data")

FileSystem:DoFile("data/design/script/rights/ExplaneListHide.data")



PlayerPathMgr.VideoList = {
							
							--"LogoMonteCristo",
							--"LogoCXL",
							"Intro",
							}
							
							
							
PlayerPathMgr.ShortPath = false

PlayerPathMgr.CountIsCounted = false

PlayerPathMgr.DefaultImage = "Beta"

PlayerPathMgr.Directory = "live"
--PlayerPathMgr.DataFile = PlayerPathMgr.Directory  .. "/ppath.dat"
PlayerPathMgr.DataFile = "ppath.dat"

PlayerPathMgr.Info = PlayerPathMgr.Info or {}
PlayerPathMgr.Info.Count = PlayerPathMgr.Count or 0

PlayerPathMgr.Info.GameStartCount = PlayerPathMgr.GameStartCount or 0

PlayerPathMgr.Info.PlacementCount = PlayerPathMgr.Info.PlacementCount or {}

PlayerPathMgr.Info.InGameCount = PlayerPathMgr.Info.InGameCountCount or 0
PlayerPathMgr.Info.SaveCount = PlayerPathMgr.Info.SaveCount or 0

PlayerPathMgr.Info.ScreenCount = PlayerPathMgr.Info.ScreenCount or {}

PlayerPathMgr.Info.ExplaneShownList = PlayerPathMgr.Info.ExplaneShownList or {}

PlayerPathMgr.Info.TutoDoneList = PlayerPathMgr.Info.TutoDoneList or {}

PlayerPathMgr.Info.PlayerHasAvatar = PlayerPathMgr.Info.PlayerHasAvatar or false

PlayerPathMgr.ThisSession = PlayerPathMgr.ThisSession  or {}
PlayerPathMgr.ThisSession.ScreenCount = PlayerPathMgr.ThisSession.ScreenCount or {}

PlayerPathMgr.Info = PlayerPathMgr.Info or {}

function PlayerPathMgr:ReadValidationsFile()
	if (InterfaceFileMgr:FileOrCXLExists(PlayerPathMgr.DataFile)) then 
		InterfaceFileMgr:DoFile(PlayerPathMgr.DataFile, nil, "PlayerPathMgr.Info")
	end	
end

function PlayerPathMgr:CountExplane(_Name) 
	
	PlayerPathMgr.Info.ExplaneShownList = PlayerPathMgr.Info.ExplaneShownList or {}
	
	PlayerPathMgr.Info.ExplaneShownList[_Name] = (PlayerPathMgr.Info.ExplaneShownList[_Name] or 0) + 1 
	PlayerPathMgr:SerializeDataFile()
end


function PlayerPathMgr:IncreaseGamestartCount()
	if (PlayerPathMgr.GameStartCountIsCounted == true) then 
		return 
	end	

	PlayerPathMgr.Info.GameStartCount = (PlayerPathMgr.Info.GameStartCount or 0) +1
	PlayerPathMgr:SerializeDataFile()
	PlayerPathMgr.GameStartCountIsCounted = true
end

function PlayerPathMgr:TutorialCompleted(_Name) 
	
	PlayerPathMgr.Info.TutoDoneList = PlayerPathMgr.Info.TutoDoneList or {}
	
	PlayerPathMgr.Info.TutoDoneList[_Name] = _Name
	PlayerPathMgr:SerializeDataFile()
end

function PlayerPathMgr:IsTutoDone(_Name) 
	PlayerPathMgr.Info.TutoDoneList = PlayerPathMgr.Info.TutoDoneList or {}
	return (PlayerPathMgr.Info.TutoDoneList[_Name] ~= nil) 

end

function PlayerPathMgr:GetExplaneCount(_Name) 
	PlayerPathMgr.Info.ExplaneShownList = PlayerPathMgr.Info.ExplaneShownList or {}
	return (PlayerPathMgr.Info.ExplaneShownList[_Name] or 0)
end

function PlayerPathMgr:GetScreenCount(_Name) 

	PlayerPathMgr.Info.ScreenCount = PlayerPathMgr.Info.ScreenCount or {}
	return (PlayerPathMgr.Info.ScreenCount[_Name] or 0)
end


function PlayerPathMgr:DoExplane(_Table, _id) 

	EXPLANE:DoExplaneTable(_Table, _id) 
	
end

function PlayerPathMgr:EnteringScreen(_Name) 

	if (PlayerPathMgr.Info == nil) then 
		return 
	end
	
	PlayerPathMgr.Info.ScreenCount = PlayerPathMgr.Info.ScreenCount or {}
	
	PlayerPathMgr.ThisSession.ScreenCount = PlayerPathMgr.ThisSession.ScreenCount or {}	
	
	PlayerPathMgr.Info.ScreenCount[_Name] = (PlayerPathMgr.Info.ScreenCount[_Name] or 0) +1
	PlayerPathMgr.ThisSession.ScreenCount[_Name] = (PlayerPathMgr.ThisSession.ScreenCount[_Name] or 0) +1
	
	PlayerPathMgr:SerializeDataFile()
end

function PlayerPathMgr:EnteringInfoScreen(_Name) 

	if (PlayerPathMgr.Info == nil) then 
		return 
	end
	
	PlayerPathMgr.Info.InfoScreenCount = PlayerPathMgr.Info.InfoScreenCount or {}
		
	
	PlayerPathMgr.Info.InfoScreenCount[_Name] = (PlayerPathMgr.Info.InfoScreenCount[_Name] or 0) +1
	PlayerPathMgr:SerializeDataFile()
end


function PlayerPathMgr:FirstTimeInCurrentScreen() 

	if (PlayerPathMgr.Info.ScreenCount[InterfaceMgr.CurrentScreen] == nil) then 
		InterfaceUtilities:LOG_CUSTOM1("Screen count for "..InterfaceMgr.CurrentScreen.." is nil")
		return true
	end	
	
	if (PlayerPathMgr.Info.ScreenCount[InterfaceMgr.CurrentScreen] == 0) or  (PlayerPathMgr.Info.ScreenCount[InterfaceMgr.CurrentScreen] == 1)then 
		InterfaceUtilities:LOG_CUSTOM1("Screen count for "..InterfaceMgr.CurrentScreen.." is "..PlayerPathMgr.Info.ScreenCount[InterfaceMgr.CurrentScreen].." returning true")
		return true
	end	
	InterfaceUtilities:LOG_CUSTOM1("Screen count for "..InterfaceMgr.CurrentScreen.." is "..PlayerPathMgr.Info.ScreenCount[InterfaceMgr.CurrentScreen].." returning false")
	return false

end

function PlayerPathMgr:FirstTimeInCurrentScreenThisSession() 

	if (PlayerPathMgr.ThisSession.ScreenCount[InterfaceMgr.CurrentScreen] == nil) then 
		--InterfaceUtilities:LOG_CUSTOM1("Screen count for "..InterfaceMgr.CurrentScreen.." is nil")
		return true
	end	
	
	if (PlayerPathMgr.ThisSession.ScreenCount[InterfaceMgr.CurrentScreen] == 0) or  (PlayerPathMgr.ThisSession.ScreenCount[InterfaceMgr.CurrentScreen] == 1)then 
		--InterfaceUtilities:LOG_CUSTOM1("Screen count for "..InterfaceMgr.CurrentScreen.." is "..PlayerPathMgr.ThisSession.ScreenCount[InterfaceMgr.CurrentScreen].." returning true")
		return true
	end	
	--InterfaceUtilities:LOG_CUSTOM1("Screen count for "..InterfaceMgr.CurrentScreen.." is "..PlayerPathMgr.ThisSession.ScreenCount[InterfaceMgr.CurrentScreen].." returning false")
	return false

end

function PlayerPathMgr:TextExplain() 

	InterfaceUtilities:LOG_CUSTOM1("Testing for explane")

	if (ExplaneList[InterfaceMgr.CurrentScreen] == nil) then 
		InterfaceUtilities:LOG_CUSTOM1("Nothing in explainList for "..InterfaceMgr.CurrentScreen)
		
		if (EXPLANE.PanelActive == false) then 
			EXPLANE:Close()
		end	
		
		
		return 
	end	
	
	for k,v in pairs (ExplaneList[InterfaceMgr.CurrentScreen]) do 
	
		local Valid = true
	
		if (v.Condition ~= nil) then  
			local f = loadstring("return "..v.Condition.."()")
			InterfaceUtilities:LOG_CUSTOM1("condition found")
			if (f~=nil) then 
				InterfaceUtilities:LOG_CUSTOM1("fonction is not nil")
				Valid = f() 
				
				if (Valid == false) then 
					InterfaceUtilities:LOG_CUSTOM1("fonction returned false")
				end	
				
				if (Valid  == nil) then 
					InterfaceUtilities:LOG_CUSTOM1("fonction returned nil")
					Valid = true
				end	
			end
		end

		if (Valid) then 
			InterfaceUtilities:LOG_CUSTOM1("Pane is valid, doing it")
			EXPLANE:DoExplaneTable(v,k) 
			PlayerPathMgr:CountExplane(k) 
			return 
		end
	end

	--if (EXPLANE.PanelActive == false) then 
	--	EXPLANE:Close()
	--end

end


function PlayerPathMgr:SerializeDataFile()
	--FileSystem:CreateDirectory(PlayerPathMgr.Directory)

	InterfaceFileMgr:SaveTableAsCXLFile(InterfaceFileMgr:LuaToXmlName(PlayerPathMgr.DataFile), "PlayerPathMgr.Info")

	--local f = InterfaceFileMgr:Open(PlayerPathMgr.DataFile)
	--FileSystem:FileWrite(f,"PlayerPathMgr.Info =")
	--InterfaceFileMgr:Serialize(PlayerPathMgr.Info, f)
	--FileSystem:FileClose(f)
end

function PlayerPathMgr:IncreaseSaveCount()
	if (PlayerPathMgr.Info.SaveCount ~= nil) then
		PlayerPathMgr.Info.SaveCount = PlayerPathMgr.Info.SaveCount +1
	else
		PlayerPathMgr.Info.SaveCount = 1
	end
	PlayerPathMgr:SerializeDataFile()
end

function PlayerPathMgr:IncreaseInGameCount()
	if (PlayerPathMgr.Info.InGameCount ~= nil) then
		PlayerPathMgr.Info.InGameCount = PlayerPathMgr.Info.InGameCount +1
	else
		PlayerPathMgr.Info.InGameCount = 1
	end
	PlayerPathMgr:SerializeDataFile()
end

function PlayerPathMgr:TrialPOAboutToExpire_Full()

	if (NETWORK:IsAssetUsable( "r_account_planetoffer") == false) then 
		LOG_INFO(" Player does not have the po")
		return false
	end
	
	if (RightsMgr:IsFullversionPOTrial() == false) then 
		LOG_INFO(" Player is not in trial po")
		return false
	end	
	
	if  (RightsMgr:PlanetOfferIsAboutToExpire()) then 
		return true
	end	
	
	return false


end


function PlayerPathMgr:IncreaseCount()

	if (PlayerPathMgr.CountIsCounted) then 
		return 
	end	

	PlayerPathMgr.Info.Count = PlayerPathMgr.Info.Count +1
	PlayerPathMgr:SerializeDataFile()
	PlayerPathMgr.CountIsCounted = true
end

function PlayerPathMgr:PlayerHasANewAvatar()
	PlayerPathMgr.Info.PlayerHasAvatar = true
	PlayerPathMgr:SerializeDataFile()
end


function PlayerPathMgr:CheckIfExplanationNeeded()
	
	
	


end

function PlayerPathMgr:EscapePressed()

	if (InterfaceMgr.CurrentScreen == "INTROVIDEO") then 
	
		if (PlayerPathMgr.CurrentVideo == 0) then 
		
			INTROVIDEO:Play(PlayerPathMgr.VideoList[1])
			PlayerPathMgr.CurrentVideo = 1
			return true
		else
			local prevVid = PlayerPathMgr.VideoList[PlayerPathMgr.CurrentVideo]
			PlayerPathMgr.CurrentVideo = PlayerPathMgr.CurrentVideo +1
			local nextVid = PlayerPathMgr.VideoList[PlayerPathMgr.CurrentVideo]
			
			if (nextVid == nil) then 
				PlayerPathMgr.CurrentVideo = PlayerPathMgr.CurrentVideo - 1
				INTROVIDEO:Play(nil , prevVid)
				PlayerPathMgr:NextScreen()
				return true
			else	
				INTROVIDEO:Play(nextVid, prevVid)
				return true
			end	
		end		
	end	
end

function PlayerPathMgr:CitySaveDone()

	PlayerPathMgr:IncreaseSaveCount()
	
	if (PlayerPathMgr.Info.SaveCount < 2) then 
		EXPLANE:DoExplane("CitySaveDone")
	end	

end
function PlayerPathMgr:False() 
	return false
end

function PlayerPathMgr:PlacementCalled(Type)

	if (Type == nil) then 
		InterfaceUtilities:LOG_CUSTOM1("Null type called")
		InterfaceUtilities:LOG_CUSTOM1("Null type called")
		return 
	end
	
	InterfaceUtilities:LOG_CUSTOM1("Placement called with type "..Type)
	
	PlayerPathMgr.Info.PlacementCount = PlayerPathMgr.Info.PLacementCount or {}
	PlayerPathMgr.Info.PlacementCount[Type] = (PlayerPathMgr.Info.PlacementCount[Type] or 0) + 1
	
--	if (PlayerPathMgr.Info.PlacementCount[Type] == 1) then 
	ActionReactionMgr:DoEvent(Type)
	--end
	
	PlayerPathMgr:SerializeDataFile()

end

function InterfaceMgr:MainMenuScreen()
	InterfaceMgr:GotoScreen("OUTGAMEMENU")
end

function PlayerPathMgr:NextScreen()
	
	--Interface:ClosePanel(InterfaceMgr.CurrentScreen)
	
	PlayerPathMgr.Info.Count = PlayerPathMgr.Info.Count  or 0
	
	if (InterfaceMgr.CurrentScreen == "INTROVIDEO") then 
		if (PlayerPathMgr:TooLate()) then 
			PlayerPathMgr:GotoInfoScreen("BetaEnd")
			return
		end	
		InterfaceMgr:GotoScreen("LOGIN")
		return
	end
	
	if (InterfaceMgr.CurrentScreen == "INFOSCREEN") then 
		if (PlayerPathMgr:IsFirstScreen(PlayerPathMgr.CurrentInfoScreen)) then 
		
			--PlayerPathMgr.CurrentInfoScreen == "WelcomeBeta") or (PlayerPathMgr.CurrentInfoScreen == "WelcomeDemo2") then 
		
			if (PlayerPathMgr.Info.PlayerHasAvatar) or ((RightsMgr:GetPlanetMode() == false) or (profile_name == "disconnected")) then 
				TutorialStatesMgr:CityTutorial()
				return
			else	
				InterfaceMgr:GotoScreen("AVATAR")
				return
			end
		end
		

		
		
		if (PlayerPathMgr.CurrentInfoScreen == "MyWelcome") then 
		
			if ((PlayerPathMgr.Info.Count == 0) and (PlayerPathMgr:IsTutoDone("&TutorialChapter1") == false)) then 
				TutorialStatesMgr:CityTutorial()
			else
				InterfaceMgr:GotoScreen("OUTGAMEMENU")
			end			
			
			
			-- PlayerPathMgr:GotoMenu("Tutorial")
			--InterfaceMgr:GotoScreen("OUTGAMEMENU")
			return 
		end
		
		if (PlayerPathMgr.CurrentInfoScreen == "WelcomeBackBeta") then 
			InterfaceMgr:GotoScreen("OUTGAMEMENU")
			return 
		end
	end
	
	if (InterfaceMgr.CurrentScreen == "NETWORKLOGIN") or (InterfaceMgr.CurrentScreen == "LICENSE") then 
	
		if (LicencesMgr:NeedsAccepting()) then 
			InterfaceMgr:GotoScreen("LICENSE")
			LicencesMgr:SetupCurrentLicense()
			return
		end	
		
		PlayerPathMgr:IncreaseGamestartCount()
		
		local InfoScreenName = PlayerPathMgr:GetFirstScreenFromEdition()
		
		if (InfoScreenName == "Avatar") then 
			InterfaceMgr:GotoScreen("AVATAR")
			return 
		end	
		
		if (InfoScreenName == "None") then 
			PlayerPathMgr:IncreaseCount()
			InterfaceMgr:GotoScreen("OUTGAMEMENU")
			return 
		else
			PlayerPathMgr:GotoInfoScreen(InfoScreenName)
			return 
		end
		
		if (PlayerPathMgr.BetaOn) then 
			if (PlayerPathMgr.Info.Count == 0) then 
				PlayerPathMgr:GotoInfoScreen("WelcomeBeta")
				return 
			else
				if (PlayerPathMgr.Info.Count <= 3) then 
					PlayerPathMgr:GotoInfoScreen("WelcomeBackBeta")
					return 
				end
			end
		end
	end

	
	if (InterfaceMgr.CurrentScreen == "AVATARSCREEN") then 
	
	

		if (PlayerPathMgr.Info.Count == 0) then 
		
			InterfaceUtilities:LOG_CUSTOM1("Going to MyWelcome")
			
			--PlayerPathMgr.CurrentInfoScreen = "WebSite"
			PlayerPathMgr:IncreaseCount()
			PlayerPathMgr:GotoInfoScreen("MyWelcome")
			return 
		else
			InterfaceMgr:GotoScreen("OUTGAMEMENU")
		end	

	
		if (PlayerPathMgr.ShortPath) then 
			InterfaceMgr:GotoScreen("GALAXY")
			return
		else
			InterfaceMgr:GotoScreen("OUTGAMEMENU")
			return
		end		
	end
	
	
	
	if (InterfaceMgr.CurrentScreen == "INFOSCREEN") then 
		LOG_ERROR("Don't know how to deal with next screen in INFOSCREEN : "..PlayerPathMgr.CurrentInfoScreen)
		
	else
		LOG_ERROR("Don't know how to deal with next screen in "..InterfaceMgr.CurrentScreen)
	end
	
end


function PlayerPathMgr:GotoInfoScreen(_ID)

	InterfaceMgr:GotoScreen("INFOSCREEN")
	
	
	PlayerPathMgr.CurrentInfoScreen = _ID
	
	PlayerPathMgr:EnteringInfoScreen(_ID) 
	
	
	InterfaceUtilities:LOG_CUSTOM1("Going to infoscreen ".._ID)
	
	local TextFile, Image, ActionsList
	local Ratio = 0.5
	local Color = "0x0C73BD"
	ActionsList = {}
	
	local lang = string.upper(Config:GetSettingsString("LOCALIZATION/LANGUAGE"))
	
	InterfaceUtilities:LOG_CUSTOM1("Lang = "..lang)
	
	local HasPanel = true
	
	for k,v in pairs (InfoScreensList) do 
	
		if (string.lower(v.ID) == string.lower(_ID)) then 
			TextFile = v.File
			Image = v.Image or PlayerPathMgr.DefaultImage 
			
			if (v.ImageIsLanguageDependant == true) then 
				Image = Image .."_"..lang
			end
			
			if (v.NoPanel == true) then 
				HasPanel = false
			end			
			
			Ratio = Ratio or v.ImageRatio
			Color = Color or v.Color
			for k2, v2 in ipairs (v.ActionsList or {}) do 
				table.insert(ActionsList, v2)
			end
		end
	end
	
	local Table = {}  
	
	
	local LangFile = TextFile.."_"..lang..".data"
	
	InterfaceUtilities:LOG_CUSTOM1("Loading "..LangFile)
	
	if (FileSystem:FileExist(LangFile)) then 
		InterfaceUtilities:LOG_CUSTOM1("File "..LangFile.." exists, loading ")
		FileSystem:LoadTxtFile(LangFile, Table)	
	else
		
		InterfaceUtilities:LOG_CUSTOM1("File "..LangFile.." does not exist")
		
		FileSystem:LoadTxtFile(TextFile.."_ENG.data", Table)	
	end	
	
	--FileSystem:LoadTxtFile(TextFile.."_"..lang..".data", Table)	
	
	local t = ""
	local nb = 0
	
	
	
	for k2,v2 in pairs (Table) do
		t = t..v2
		nb = nb+1
	end

	InterfaceUtilities:LOG_CUSTOM1("In infoscreen ".._ID.." text length = "..nb)
	
	if (HasPanel == false) then 
		INFOSCREEN:HidePanel()
		INFOSCREEN:SetTitle("")
		SCALEFORMMGR:DoActionScriptWithArg("INFOSCREEN", "CenterImage")
	else
		INFOSCREEN:SetTitle("&".._ID)
	end	
	
	for k,v in pairs (ActionsList) do 
		local BtnName = v.Button or "Continue"
		local Action = v.Action or "PlayerPathMgr:NextScreen"
		local Param = v.Param or "",
		INFOSCREEN:AddButton(BtnName, Action, Param)
	end
	
	
	INFOSCREEN:SetImageRatio(Ratio)
	INFOSCREEN:SetColor(Color)
	INFOSCREEN:SetText(t)
	INFOSCREEN:LoadImg(Image)

	
	
	
	INFOSCREEN:UpdateStretch()


end

function PlayerPathMgr:GotoMenu(_param)
	
	InterfaceMgr:GotoScreen("OUTGAMEMENU")
	g_TutorialGoesToPlay = true
	MainMenuMgr:GotoCityTutorial()
	--g_TutorialGoesToPlay = false
end

BStartDate =
	{
	year = 2009,
	month = 6,
	day = 9,
	}
	
BEndDate =
	{
	year = 2009,
	month = 7,
	day = 31,
	}

	
function PlayerPathMgr:TooLate()

	--[[
	local Date = DateUtilities:GetNowDate() 

	ShowTableElementInLog(Date, "Date")
	
	if (Date.year ~= BEndDate.year) then
		--LOG_ERROR("wrong year - nok")
		return true
	end
	
	if (Date.month < BStartDate.month) then 
		--LOG_ERROR("Before start month - nok")
		return true
	end
	
	if (Date.month > BEndDate.month) then 
		--LOG_ERROR("after end - nok")
		return true
	end
	
	if (Date.month < BEndDate.month) then 
		--LOG_ERROR("before end month - ok")
		return false
	end
	
	if ((Date.month == BEndDate.month) and (Date.day <= BEndDate.day)) then 
		--LOG_ERROR("end month ok, end day ok ")
		return false
	end
	
	--LOG_ERROR("no date ?")
	
	return true
	]]
	
	return false

end

function PlayerPathMgr:PrevScreen()
	
	--Interface:ClosePanel(InterfaceMgr.CurrentScreen)
	
	if (InterfaceMgr.CurrentScreen == "AVATAR") then 
		if (PlayerPathMgr.ShortPath) then 
			InterfaceMgr:GotoScreen("LOGIN")
			return
		end	
	end
	
	if ((InterfaceMgr.CurrentScreen == "NETWORKLOGIN") or (InterfaceMgr.CurrentScreen == "LICENSE")) then 
	
		if (PlayerPathMgr:TooLate()) then 
			PlayerPathMgr:GotoInfoScreen("BetaEnd")
			return
		end	
	
		CursorMgr:SetCursorType(Cursor.Basic) 
	
		if (LicencesMgr:NeedsAccepting()) then 
			InterfaceMgr:GotoScreen("LICENSE")
			LicencesMgr:SetupCurrentLicense()
			return
		end	
	
		if (PlayerPathMgr.ShortPath) then 
			InterfaceMgr:GotoScreen("AVATAR")
			return
		else
			InterfaceMgr:GotoScreen("OUTGAMEMENU")
			return
		end		
	end
	
	LOG_ERROR("Don't know how to deal with next screen in "..InterfaceMgr.CurrentScreen)
	
	
	
end

function PlayerPathMgr:ReallyQuit()
	NETWORK:Disconnect()
	Main:RequestExitApp(0) -- ok to quit
end

function PlayerPathMgr:TryQuit()

	
	PlayerPathMgr.Info.InfoScreenCount = PlayerPathMgr.Info.InfoScreenCount or {}
	
	--if ((PlayerPathMgr.Info.InfoScreenCount["Goodbye"] == nil) or (PlayerPathMgr.Info.InfoScreenCount["Goodbye"] == 0)) then   
	
		--if ((PlayerPathMgr.Info.SaveCount or 0) >=0) then 
			--PlayerPathMgr:GotoInfoScreen("Goodbye")
			--return
		--end	
		
	--end
	
	PlayerPathMgr:ReallyQuit()
	
	
end


FirstScreens = 
	{
	"FullVersionWelcome1",
	"FullVersionWelcome2",
	"WelcomeDemo1",
	"WelcomeDemo2",
	"WelcomeBeta",
	"WelcomeBackBeta",
	"TrialWelcome1",
	"TrialWelcome2",
	}

function PlayerPathMgr:IsFirstScreen(_Name)

	for k,v in pairs (FirstScreens) do 
		if (v == _Name) then 
			return true
		end
	end
	
	return false

end

function PlayerPathMgr:SecondPath_Full()

	if (RightsMgr:IsFullVersion() == false) then 
		return false
	end
	
	if (RightsMgr:GetPlanetMode() == false) then 
		return false
	end

	return PlayerPathMgr:PathNb(2)

end

function PlayerPathMgr:SecondPath_Trial()

	if (RightsMgr:IsTrialVersion() == false) then 
		return false
	end
	
	if (RightsMgr:GetPlanetMode() == false) then 
		return false
	end

	return PlayerPathMgr:PathNb(2)

end

function PlayerPathMgr:SecondPath()

return PlayerPathMgr:PathNb(2)
	
end

function PlayerPathMgr:ThirdPath()
	return PlayerPathMgr:PathNb(3)
	

end


function PlayerPathMgr:FourthPath_Full()

	if (RightsMgr:IsFullVersion() == false) then 
		return false
	end
	
	if (RightsMgr:GetPlanetMode() == false) then 
		return false
	end

	return PlayerPathMgr:PathNb(4)

end



function PlayerPathMgr:FourthPath_Trial()

	if (RightsMgr:IsTrialVersion() == false) then 
		return false
	end
	
	if (RightsMgr:GetPlanetMode() == false) then 
		return false
	end

	return PlayerPathMgr:PathNb(4)

end


function PlayerPathMgr:FifthPath()

	return PlayerPathMgr:PathNb(5)

end

function PlayerPathMgr:PathNb(_Nb)

	if (_Nb == nil) then 
		return false
	end	

	local Count = PlayerPathMgr.Info.GameStartCount or 0
	
	return ((Count ==_Nb) and (PlayerPathMgr:FirstTimeInCurrentScreenThisSession()))

end


function PlayerPathMgr:ShowEndOfPOTrial() 

	if (RightsMgr:IsFullVersion()) and (RightsMgr:GetPlanetMode() == false) then

		if (PlayerPathMgr:GetExplaneCount("EndFullTrial1") < 2) then 
			return true
		end
	end	
	
	return false
 	

end

function PlayerPathMgr:GetFirstScreenFromEdition()

	if (RightsMgr:IsTrialVersion() or RightsMgr:IsDiscoveryVersion()) and (RightsMgr:GetPlanetMode() == false) then  	
		return "TrialEnd"
	end
				
	
	local Count = PlayerPathMgr.Info.GameStartCount or 0
	
	
	InterfaceUtilities:LOG_CUSTOM1(" Getting first screen")
	
	if (RightsMgr:IsTrialVersion() or RightsMgr:IsDiscoveryVersion()) then 
	
		InterfaceUtilities:LOG_CUSTOM1("Trial version")
	
		if (Count < 2) then 
			return "TrialWelcome1"
		end

		--if (Count < 4) then 
		--	return "TrialWelcome2"
		--end
			
		
	end

	if (RightsMgr:IsFullVersion()) then
		
		InterfaceUtilities:LOG_CUSTOM1("Full version")
		
		if (Count < 2) and (RightsMgr:IsFullversionPOTrial()) then 
			return "FullVersionWelcome1"
		end
		
		if (PlayerPathMgr.Info.PlayerHasAvatar) then 
			LOG_INFO("Player has an avatar or does not have the planet mode") 
			return "None"
		else	
			InterfaceUtilities:LOG_CUSTOM1("Full version - Going to avatar") 
			return "Avatar"
		end		
		

		--if (Count < 4) then 
		--	return "FullVersionWelcome2"
		--end
			


	end	

	if (RightsMgr:IsDemo()) then
		if (Count < 2) then 
			return "WelcomeDemo1"
		end
		
		--if (Count < 4) then 
		--	return "WelcomeDemo2"
		--end
		
	end	
	
	--if (RightsMgr:PlanetOfferIsAboutToExpire()) then 
	--	return "POExpiresSoon"
	--end
	
	return "None"

end

function PlayerPathMgr:GotoMainMenu()
	InterfaceMgr:GotoScreen("OUTGAMEMENU")
	TutorialStatesMgr.TutorialMenuActive = false
	MainMenuMgr:MainMenu(true)
end


function PlayerPathMgr:GotoGalaxy()
	InterfaceMgr:GotoScreen("GALAXY")
end

function PlayerPathMgr:TutorialMainMenu()
	InterfaceMgr:GotoScreen("OUTGAMEMENU")
	TutorialStatesMgr.TutorialMenuActive = false
	MainMenuMgr:MainMenu(true)
end	


function PlayerPathMgr:PlanetTutorials()
	InterfaceMgr:GotoScreen("OUTGAMEMENU")
	TutorialStatesMgr.TutorialMenuActive = false
	MainMenuMgr:GotoPlanetTutorial()
end	

function PlayerPathMgr:ManageTutorialEnd(_CurrentChapter)

	Interface:SetElemValue("INGAME", "_root.DayAndNight.Container.quitButton", "_visible", 1)
	Interface:SetElemValue("INGAME", "_root.DayAndNight.Container.quitButton", "hitTestDisable", 0)

	if (PlayerPathMgr:GetScreenCount("OUTGAMEMENU") < 1) then 

		if (_CurrentChapter == "&TutorialChapter1") then 
			if (PlayerPathMgr:IsTutoDone("&TutorialChapter2") == false) then 
			
				Interface:SetElemValue("INGAME", "_root.DayAndNight", "_visible", 0)
				Interface:SetElemValue("INGAME", "_root.DayAndNight", "hitTestDisable", 1)
				
				TutorialStatesMgr:StartCity()
				DelayedTasks:Addtask("PlayerPathMgr:TextExplain", {}, 10)
				return 
			end
		end
		
		if (_CurrentChapter == "&TutorialChapter2") then 
			if (PlayerPathMgr:IsTutoDone("&TutorialChapter3") == false) then 
				
				Interface:SetElemValue("INGAME", "_root.DayAndNight", "_visible", 0)
				Interface:SetElemValue("INGAME", "_root.DayAndNight", "hitTestDisable", 1)
				
				TutorialStatesMgr:Interface()
				DelayedTasks:Addtask("PlayerPathMgr:TextExplain", {}, 10)
				return 
			end
		end
		
		
		if (_CurrentChapter == "&TutorialChapter3") then 
			PlayerPathMgr:GotoInfoScreen("TUTORIALCHAPTER3")
			return 
		end
		
	end
	
	
	MainMenuMgr:TutorialMainMenu(true)
	
	TutorialStatesMgr:onClose()
	TutorialStatesMgr.TutorialMenuActive = true

end

function PlayerPathMgr:OpenUpgradeURL()
	MainMenuMgr:OpenURL("http://www.citiesxl.com/upgrade")
end


function PlayerPathMgr:FirstTutorialMenu()



end

function PlayerPathMgr:FirstTutorial()

	if (TutorialStatesMgr.TutorialActive == false) then 
		return false
	end

	if (TutorialStatesMgr.TutorialChapter == "&TutorialChapter1") then 
		if (PlayerPathMgr:IsTutoDone("&TutorialChapter1") == false) then 
			return true
		end	
	end

	return false
	

end


function PlayerPathMgr:SecondTutorial()

	if (TutorialStatesMgr.TutorialActive == false) then 
		return false
	end

	if (TutorialStatesMgr.TutorialChapter == "&TutorialChapter2") then 
		if (PlayerPathMgr:IsTutoDone("&TutorialChapter2") == false) then 
			return true
		end	
	end

	return false
	

end


--FileSystem:DoFile("Data/Design/Script/Rights/PlayerPathMgr.demo")
