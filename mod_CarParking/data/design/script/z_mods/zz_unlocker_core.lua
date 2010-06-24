--- !! Needs "Mod Moaku True Sandbox" to work - both share the same cheat menu !! ---
function MainMenuMgr:Cheat()
	Interface:DoActionScript(MainMenuMgr:CurrentScreen(), "ClearMenuItems")
	MainMenuMgr:AddMainMenuItem("Back","MainMenuMgr:MainMenu")
	MainMenuMgr:AddMainMenuItem("MOD_MOAKU_ADDMONEY", "MainMenuMgr:AddMoney")
	MainMenuMgr:AddMainMenuItem("MOD_MOAKU_ADDMONEYBIS", "MainMenuMgr:AddMoneyBis")
	MainMenuMgr:AddMainMenuItem("MOD_MOAKU_OMNICORP_BUY", "MainMenuMgr:OmniBuy")
	MainMenuMgr:AddMainMenuItem("MOD_MOAKU_OMNICORP_SELL", "MainMenuMgr:OmniSell")
	MainMenuMgr:AddMainMenuItem("MOD_MOAKU_OMNICORP_SPECIFIC_BUY", "MainMenuMgr:SpecificOmnicorpBuy")
	MainMenuMgr:AddMainMenuItem("MOD_MOAKU_OMNICORP_SPECIFIC_SELL", "MainMenuMgr:SpecificOmnicorpSell")
	MainMenuMgr:AddMainMenuItem("MOD_VF_UNLOCK_BUILDINGS", "MainMenuMgr:UnlockBuildings") -- aggiunto muc
	MainMenuMgr:AddMainMenuItem("MOD_VF_RELOCK_BUILDINGS", "MainMenuMgr:LockBuildings") -- aggiunto muc
end

function MainMenuMgr:UnlockBuildings() -- aggiunta muc
	LOG_INFO("Unlock all buildings")
    Manager:SetValue( "splPlayerManager", "HackAllVisible",     1 )
    Manager:SetValue( "splPlayerManager", "HackAllUnlocked",    1 )
    Manager:SetValue( "splPlayerManager", "HackAllPaid",        1 )
    Manager:SetValue( "splPlayerManager", "HackAllBuyable",     1 )	
    CONSTRUCTIONMENU2:UpdateCMButtons();
    Sound2D:Play("ui_succeed")
    MainMenuMgr:MainMenu()
    --MainMenuMgr:ReRegisterInterface()
end


function MainMenuMgr:LockBuildings() -- aggiunta muc
	LOG_INFO("Lock all buildings")
    Manager:SetValue( "splPlayerManager", "HackAllVisible",     0 )
    Manager:SetValue( "splPlayerManager", "HackAllUnlocked",    0 )
    Manager:SetValue( "splPlayerManager", "HackAllPaid",        0 )
    Manager:SetValue( "splPlayerManager", "HackAllBuyable",     0 )	
    CONSTRUCTIONMENU2:UpdateCMButtons();
    Sound2D:Play("ui_failed")
    MainMenuMgr:MainMenu()
   -- MainMenuMgr:ReRegisterInterface()
end
--------------------------------------------------------------------------------------
-- MEDIEVAL PACK MENU ----------------------------------------------------------------
function CONSTRUCTIONMENU2:Init()

	InterfaceMgr:SetCurrentGfxQlty()

	PrototypeType:Init()
	AutoActions.InGameStarted = true

	CONSTRUCTIONMENU2.TownHallHere["GemCity"] = false
	CONSTRUCTIONMENU2.TownHallHere["City"] = false
	CONSTRUCTIONMENU2.TownHallHere["GemCity"] = false
	CONSTRUCTIONMENU2.TownHallHere["GemBeach"] = false
	CONSTRUCTIONMENU2.TownHallHere["GemSki"] = false

	CONSTRUCTIONMENU2.IsChatOpen = false
	CONSTRUCTIONMENU2.IsActiveHint = false

	SCALEFORMMGR:DoActionScriptWithArg("CONSTRUCTIONMENU2","SetModeSolo",""..tostring(RightsMgr:BusAllowed()==false))

	if (INGAME.VisitMode == true) then 
		SCALEFORMMGR:DoActionScript("CONSTRUCTIONMENU2","ForceVisitMode")
	end

	SCALEFORMMGR:DoActionScriptWithArg("CONSTRUCTIONMENU2","SetBuildingSet",CONSTRUCTIONMENU2.BuildingSet) 

	SCALEFORMMGR:DoActionScript("CONSTRUCTIONMENU2","Init") 
	CONSTRUCTIONMENU2:CheckAvatarBuilding()
	TradingLogic:EnterCity()

	TRADING:GetMultiProgress()
	
	DelayedTasks:Addtask("CONSTRUCTIONMENU2:DelayedAvatarMode", {}, 40)
	SCALEFORMMGR:DoActionScript("CONSTRUCTIONMENU2", "Tutorial_ResetAvailableButtons")
	RightsMgr:ULB()
	--local PlayerHasPack = CONSTRUCTIONMENU2:CheckIfPlayerHasPacks()
	--if (PlayerHasPack == false or InterfaceMgr.SoloMode == true) then
		--SCALEFORMMGR:DoActionScript("CONSTRUCTIONMENU2", "HidePackButtons")
	--end
	
	if (ProfileMgr.Options.Game.TogglePlop == false) then 
		DelayedTasks:Addtask("CONSTRUCTIONMENU2:DeActivatePlopButton", "", 7)
	else
		DelayedTasks:Addtask("CONSTRUCTIONMENU2:ActivatePlopButton", "", 7)
	end	
end
--------------------------------------------------------------------------------------
-- TUTORIAL MENU ---------------------------------------------------------------------
function MainMenuMgr:TutorialMainMenu(Bool)

	g_ActiveOutgameMenu = "TutorialMainMenu"
	SCALEFORMMGR:DoActionScript(MainMenuMgr:CurrentScreen(), "ClearMenuItems")
	MainMenuMgr:AddMainMenuItem("City", "MainMenuMgr:GotoCityTutorial")
	MainMenuMgr:AddMainMenuItem("Planet", "MainMenuMgr:GotoPlanetTutorial")
	MainMenuMgr:AddMainMenuItem("SkiGem", "MainMenuMgr:GotoSkiTutorial") 
	--MainMenuMgr:AddMainMenuItem("BeachGem", "TutorialStatesMgr:GemBeachTutorial")
	MainMenuMgr:AddMainMenuItem("ReturnToMainMenu", "MainMenuMgr:OutgameMainMenu")
	
end
--------------------------------------------------------------------------------------
-- MAIN MENU -------------------------------------------------------------------------
function ModeSelectMenu:PushGame()

	local Screen = "CONSTRUCTIONMENU2"

	ModeSelectMenu:Clear(Screen)

	if true then --(TutorialStatesMgr.TutorialActive == false) then 

		if (INGAME.VisitMode == false) then 

			ModeSelectMenu:PushItem(Screen, "trade", "PanelInfoCity:OnButtonPress", "ButtonTrade")	
			
			if (InterfaceMgr.SoloMode == true) then 
				ModeSelectMenu:PushItem(Screen, "Blueprint", "TradingLogic:ShowAllBluePrintsSimple", "")
			end	

			ModeSelectMenu:PushItem(Screen, "City", "ModeSelectMenu:GotoIngameMode", "City")

			-- Not working ...
			--if (InterfaceMgr.ShowGems) then

		
				--if (RightsMgr:IsGemAllowed("ski")) then 
					--ModeSelectMenu:PushItem(Screen, "GemSki", "ModeSelectMenu:GotoGameMode", "GemSki")
				--else
					--ModeSelectMenu:PushGreyedItem(Screen, "GemSki", "ModeSelectMenu:GotoGameMode", "GemSki")
				--end	
			
		--		 probably not valid
				--if (RightsMgr:IsGemAllowed("beach")) then 
					--ModeSelectMenu:PushItem(Screen, "GemBeach", "ModeSelectMenu:GotoGameMode", "GemBeach")
				--else
					--ModeSelectMenu:PushGreyedItem(Screen, "GemBeach", "ModeSelectMenu:GotoGameMode", "GemBeach")
				--end
				

			--end
		end
		
		if (INGAME.VisitMode == false) then
			if (bInAvatarMode == nil or bInAvatarMode == false) then
				--if (InterfaceMgr.SoloMode == false) then
					ModeSelectMenu:PushItem(Screen, "avatar", "VISIT:EnterAvatar", "")
				--end
			else
				ModeSelectMenu:PushItem(Screen, "City", "ModeSelectMenu:GotoIngameMode", "City")
			end
		end	

	else
		
		local Mode = "City"
		if (Screen == "PLANET") then
			Mode = "Planet"
		end
			
		ModeSelectMenu:PushItem(Screen, "trade", "PanelInfoCity:OnButtonPress", "ButtonTrade", Mode)	
		
	end

	ModeSelectMenu:PushItem(Screen, "ViewOptions", "InterfaceMgr:ToggleDayAndNightPane", "")

	if (TutorialStatesMgr.TutorialActive == false) then 
		ModeSelectMenu:PushItem(Screen, "Menu", "PanelMgr:RequestPanel", "MAINMENU|NA")
		if (InterfaceMgr.SoloMode) then 
			ModeSelectMenu:PushItem(Screen, "back", "INGAME:OnButtonPress", "ButSolo")
	    else
			ModeSelectMenu:PushItem(Screen, "Planet", "INGAME:OnButtonPress", "ButPlanet")
	    end
	end
	
	if (TutorialStatesMgr.TutorialActive) then 
		ModeSelectMenu:PushItem(Screen, "back", "TutorialStatesMgr:onClose", "")
	else
		--ModeSelectMenu:PushItem(Screen, "back", "TutorialStatesMgr:onClose", "")
		
		ModeSelectMenu:PushItem(Screen, "quit", "INGAME:OnButtonPress", "ButtonQuit")
	end
end
--------------------------------------------------------------------------------------
-- OutGame MAIN MENU -----------------------------------------------------------------
function MainMenuMgr:OutgameMainMenu()

	TutorialStatesMgr.TutorialChapter = ""
	
	g_ActiveOutgameMenu = "OutgameMainMenu"
	SCALEFORMMGR:DoActionScript(MainMenuMgr:CurrentScreen(), "ClearMenuItems")
	
	if (profile_name == "disconnected") then 
		g_InterfaceDisconnected = true
	end
		
	MainMenuMgr:AddMainMenuItem("Play", "MainMenuMgr:OutgameGotoSolo")
	MainMenuMgr:AddMainMenuItem("Tutorial", "MainMenuMgr:TutorialMainMenu")

    MainMenuMgr:AddSpace()
	MainMenuMgr:AddMainMenuItem("AvatarEditor", "MainMenuMgr:OutgameGotoAvatar")
	
	MainMenuMgr:AddSpace()	
	MainMenuMgr:AddMainMenuItem("Options", 		"InterfaceMgr:OptionsPanelToggle")
	MainMenuMgr:AddMainMenuItem("Quit", 		"NETWORK:YesQuit","")
	
end
--------------------------------------------------------------------------------------