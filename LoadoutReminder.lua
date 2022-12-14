-- BAL Version
-- TODO: Try to hook onto BALs update functions for the sets to recognize changes!
-- TODO: Maybe also try to do this to recognize a "manual" set change

if BetterAddonListDB == nil then
	print("Could not find BetterAddonList Addon")
	return
end

BALFrame = nil

local addon = CreateFrame("Frame", "LoadoutReminderAddon")
addon:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_LOGOUT")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")

addon.defaultDB = {
	DUNGEON = nil,
	OPENWORLD = nil,
	RAID = nil,
	BG = nil,
	ARENA = nil,
	CURRENT_SET = nil,
	ADV_MODE = false,
	BAL_LOADED_SET = nil
}

-- CASE: if player manipulates addon sets via addon list gui of BAL
BALDropdownHooked = false
BetterAddonListSetsButton:HookScript("OnClick", function(self) 
	if not BALDropdownHooked then
		DropDownList2Button4:HookScript("OnClick", function(self) 
			local setName = DropDownList2Button1NormalText:GetText()
			-- print("clicked load button, addon set: " .. setName)
			-- print("remember set because it was loaded in addon list BAL overview")
			LoadoutReminderDB['BAL_LOADED_SET'] = setName
		end)
		DropDownList2Button12:HookScript("OnClick", function(self) 
			local setName = DropDownList2Button1NormalText:GetText()
			-- print("clicked enable button, addon set: " .. setName)
			-- print("set current set because it was enabled in addon list BAL overview")
			LoadoutReminderDB['BAL_LOADED_SET'] = setName
		end)
		DropDownList2Button5:HookScript("OnClick", function(self) 
			local setName = DropDownList2Button1NormalText:GetText()
			-- print("clicked save button, addon set: " .. setName)

			_G['LibDialog-1.0_Button1']:HookScript("OnClick", function(self) 
				-- print("clicked save on set: " .. setName)
				-- well a saved set is also always the current set!
				addon:setCurrentSet(setName)
				-- if the reminder frame is currently visible, update it by calling check and Show again
				if LoadoutReminderFrame:IsVisible() then
					addon:checkAndShow()
				end
			end)
		end)
		BALDropdownHooked = true
	end
end)

-- CASE: TODO: If player manipulates addon sets via macro usage of better addon list
--

-- If I ever need this..
--function addon:findBALFrame()
	--local f = EnumerateFrames()
	
	--while f do
	--	if f['RenameSet'] and f['DeleteSet'] and f['SaveSet'] and f['DisableSet'] and f['EnableSet'] and f['LoadSet'] and f['EnableProtected'] then
	--		BALFrame = f
	--		return
	--	end
	--	f = EnumerateFrames(f)
	--end
--end

function addon:getAddonSets()
	return BetterAddonListDB.sets
end

function addon:ADDON_LOADED(addon_name)
	if addon_name ~= 'BetterAddonList_LoadoutReminder' then
		return
	end
	addon:loadDefaultDB()
	addon:initOptions()
	addon:initLoadoutReminderFrame()
end

function addon:setCurrentSet(loaded_set)
	LoadoutReminderDB["CURRENT_SET"] = loaded_set
end

function addon:isSetLoaded(setName) 
	if LoadoutReminderDB["CURRENT_SET"] == nil then
		return false
	end
	return LoadoutReminderDB["CURRENT_SET"] == setName
end

function addon:printAlreadyLoadedMessage(set)
	if set == nil then
		print("LOR: Addonset not assigned yet. Type /lor config to configure")
	else
		print("LOR: Addonset already loaded: " .. set)
	end
	
end

function addon:checkAndShow()
	inInstance, instanceType = IsInInstance()

	local DUNGEON_SET = LoadoutReminderDB["DUNGEON"]
	local RAID_SET = LoadoutReminderDB["RAID"]
	local BG_SET = LoadoutReminderDB["BG"]
	local ARENA_SET = LoadoutReminderDB["ARENA"]
	local OPENWORLD_SET = LoadoutReminderDB["OPENWORLD"]
	local SET_TO_LOAD = nil
	-- check if player went into a dungeon
	if inInstance and instanceType == 'party' then
		if instanceType == 'party' then
			if addon:isSetLoaded(DUNGEON_SET) or DUNGEON_SET == nil then
				addon:printAlreadyLoadedMessage(DUNGEON_SET)
				return
			end
			SET_TO_LOAD = DUNGEON_SET
		elseif instanceType == 'raid' then
			if addon:isSetLoaded(RAID_SET) or RAID_SET == nil then
				addon:printAlreadyLoadedMessage(RAID_SET)
				return
			end
			SET_TO_LOAD = RAID_SET
		elseif instanceType == 'pvp' then
			if addon:isSetLoaded(BG_SET) or BG_SET == nil then
				addon:printAlreadyLoadedMessage(BG_SET)
				return
			end
			SET_TO_LOAD = BG_SET
		elseif instanceType == 'arena' then
			if addon:isSetLoaded(ARENA_SET) or ARENA_SET == nil then
				addon:printAlreadyLoadedMessage(ARENA_SET)
				return
			end
			SET_TO_LOAD = ARENA_SET
		end
	elseif not inInstance then
		if addon:isSetLoaded(OPENWORLD_SET) or OPENWORLD_SET == nil then
			addon:printAlreadyLoadedMessage(OPENWORLD_SET)
			return
		end
		SET_TO_LOAD = OPENWORLD_SET
	end

	local CURRENT_SET = LoadoutReminderDB["CURRENT_SET"]

	if CURRENT_SET ~= nil then
		LoadoutReminderFrame.ContentFrame.text:SetText("Current Addon Set: \"" .. CURRENT_SET .. "\"")
	else
		LoadoutReminderFrame.ContentFrame.text:SetText("")
	end

	

	local macroTextLoad = "/addons load " .. SET_TO_LOAD .. "\n/script LoadoutReminderAddon:setCurrentSet('"..SET_TO_LOAD.."')\n/reload"
	LoadSetButton:SetAttribute("macrotext", macroTextLoad)
	LoadSetButton:SetText("Load '"..SET_TO_LOAD.."'")

	if LoadoutReminderDB['ADV_MODE'] then

		LoadoutReminderFrame:SetSize(300, 170)
		LoadSetButton:SetPoint("CENTER",LoadoutReminderFrame, "CENTER", 0, 5)

		local macroTextEnable = "/addons enable " .. SET_TO_LOAD .. "\n/script LoadoutReminderAddon:setCurrentSet('"..SET_TO_LOAD.."')\n/reload"
		EnableSetButton:SetAttribute("macrotext", macroText)
		EnableSetButton:SetText("Enable '"..SET_TO_LOAD.."'")
		EnableSetButton:Show()

		if CURRENT_SET ~= nil then
			local macroTextDisable = "/addons disable " .. CURRENT_SET .. "\n/script LoadoutReminderAddon:setCurrentSet('"..SET_TO_LOAD.."')\n/reload"
			DisableSetButton:SetAttribute("macrotext", macroText)
			DisableSetButton:SetText("Disable '"..CURRENT_SET.."'")
			DisableSetButton:Show()
		else
			DisableSetButton:SetAttribute("macrotext", "")
			DisableSetButton:SetText("Disable current Set")
			DisableSetButton:Show()
		end
		
		DisableSetButton:SetEnabled(CURRENT_SET ~= nil)
	else
		EnableSetButton:Hide()
		DisableSetButton:Hide()
		LoadoutReminderFrame:SetSize(300, 100)

		LoadSetButton:SetPoint("CENTER",LoadoutReminderFrame, "CENTER", 0, -20)
	end 

	LoadoutReminderFrame:Show()
end


function addon:PLAYER_ENTERING_WORLD(isLogIn, isReload)
	-- if player just logged in, dont suggest addon set loading
	if isLogIn then
		-- purge it on login if player changed set and logged out (for whatever reason)
		LoadoutReminderDB['BAL_LOADED_SET'] = nil
		return
	elseif isReload then
		-- check if player changed set via BAL gui
		if LoadoutReminderDB['BAL_LOADED_SET'] ~= nil then
			-- print("Set was changed with bal to: " .. LoadoutReminderDB['BAL_LOADED_SET'])
			addon:setCurrentSet(LoadoutReminderDB['BAL_LOADED_SET'])
			LoadoutReminderDB['BAL_LOADED_SET'] = nil
		end
	else
		-- just purge it because BAL does it too
		LoadoutReminderDB['BAL_LOADED_SET'] = nil
	end

	self:checkAndShow()
end

function addon:loadDefaultDB() 
	LoadoutReminderDB = LoadoutReminderDB or CopyTable(self.defaultDB)
end

function addon:PLAYER_LOGIN()
	SLASH_LOADOUTREMINDER1 = "/loadoutreminder"
	SLASH_LOADOUTREMINDER1 = "/lor"
	SlashCmdList["LOADOUTREMINDER"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "config" then
			InterfaceOptionsFrame_OpenToCategory(addon.optionsPanel)
		end

		if command == "check" then 
			self:checkAndShow()
		end

		if command == "" then
			print("BetterAddonList LoadoutReminder Help")
			print("/lor or /loadoutreminder can be used for following commands")
			print("/lor -> show help text")
			print("/lor config -> show options panel")
			print("/lor check -> if configured check current player situation")
		end
	end
end


function addon:initLoadoutReminderFrame()

	LoadoutReminderFrame.title = LoadoutReminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LoadoutReminderFrame.title:SetPoint("CENTER", LoadoutReminderFrameTitleBG, "CENTER", 5, 0)
	LoadoutReminderFrame.title:SetText("Loadout Reminder")

  
	LoadoutReminderFrame.ContentFrame = CreateFrame("Frame", nil, LoadoutReminderFrame)
	LoadoutReminderFrame.ContentFrame:SetSize(300, 150)
	LoadoutReminderFrame.ContentFrame:SetPoint("TOPLEFT", LoadoutReminderFrameDialogBG, "TOPLEFT", -3, 4)

	LoadoutReminderFrame.ContentFrame.text = LoadoutReminderFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	LoadoutReminderFrame.ContentFrame.text:SetPoint("TOP", LoadoutReminderFrameDialogBG, "TOP", 5, -15)

	makeFrameMoveable()

	local bLoad = CreateFrame("Button", "LoadSetButton", LoadoutReminderFrame, "SecureActionButtonTemplate,UIPanelButtonTemplate")
	bLoad:RegisterForClicks("AnyUp", "AnyDown")
	bLoad:SetSize(200 ,30)
	bLoad:SetPoint("CENTER",LoadoutReminderFrame, "CENTER", 0, 5)	
	bLoad:SetAttribute("type1", "macro")
	bLoad:SetAttribute("macrotext", "")
	bLoad:SetText("Load Addonset")

	local bEnable = CreateFrame("Button", "EnableSetButton", LoadoutReminderFrame, "SecureActionButtonTemplate,UIPanelButtonTemplate")
	bEnable:RegisterForClicks("AnyUp", "AnyDown")
	bEnable:SetSize(200 ,30)
	bEnable:SetPoint("CENTER",LoadoutReminderFrame, "CENTER", 0, -25)
	bEnable:SetAttribute("type1", "macro")
	bEnable:SetAttribute("macrotext", "")
	bEnable:SetText("Enable Addonset")

	local bDisable = CreateFrame("Button", "DisableSetButton", LoadoutReminderFrame, "SecureActionButtonTemplate,UIPanelButtonTemplate")
	bDisable:RegisterForClicks("AnyUp", "AnyDown")
	bDisable:SetSize(200 ,30)
	bDisable:SetPoint("CENTER",LoadoutReminderFrame, "CENTER", 0, -55)
	bDisable:SetAttribute("type1", "macro")
	bDisable:SetAttribute("macrotext", "")
	bDisable:SetText("Disable Addonset")
end

function addon:updateOptionDropdowns()
	UIDropDownMenu_Initialize(DropdownDUNGEON, initializeDropdownValues) 
	UIDropDownMenu_Initialize(DropdownRAID, initializeDropdownValues) 
	UIDropDownMenu_Initialize(DropdownARENA, initializeDropdownValues) 
	UIDropDownMenu_Initialize(DropdownBG, initializeDropdownValues) 
	UIDropDownMenu_Initialize(DropdownOPENWORLD, initializeDropdownValues) 
end

function addon:initOptions()
	self.optionsPanel = CreateFrame("Frame")
	self.optionsPanel:HookScript("OnShow", function(self)
		addon:updateOptionDropdowns()
end)
	self.optionsPanel.name = "BetterAddonList_LoadoutReminder"
	local title = self.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("BetterAddonList_LoadoutReminder")

	self:initDropdownMenu("DUNGEON", "Dungeon", -115, -50)
	self:initDropdownMenu("RAID", "Raid", 115, -50)

	self:initDropdownMenu("ARENA", "Arena", -115, -100)
	self:initDropdownMenu("BG", "Battlegrounds", 115, -100)

	self:initDropdownMenu("OPENWORLD", "Open World", -115, -150)

	local checkButton = CreateFrame("CheckButton", nil, self.optionsPanel, "InterfaceOptionsCheckButtonTemplate")
	checkButton:SetPoint("TOP", self.optionsPanel, 20, -150)
	checkButton.Text:SetText("Advanced Mode (Enabling/Disabling Addonsets)")
	-- there already is an existing OnClick script that plays a sound, hook it
	checkButton:HookScript("OnClick", function(_, btn, down)
		local checked = checkButton:GetChecked()
		LoadoutReminderDB['ADV_MODE'] = checked
		if LoadoutReminderFrame:IsVisible() then
			addon:checkAndShow()
		end
	end)
	if LoadoutReminderDB['ADV_MODE'] == nil then
		LoadoutReminderDB['ADV_MODE'] = false
	end
	checkButton:SetChecked(LoadoutReminderDB['ADV_MODE']) -- set the initial checked state

	InterfaceOptions_AddCategory(self.optionsPanel)
end

function addon:initializeDropdownValues(dropDown, linkedSetID)
	local setList = addon:getAddonSets()

	UIDropDownMenu_Initialize(dropDown, function(self) 
		-- loop through possible sets and put them as option
		for k, v in pairs(setList) do
			setName = k -- in BAL K is needed
			local info = UIDropDownMenu_CreateInfo()
			info.func = function(self, arg1, arg2, checked) 
				--print("clicked: " .. linkedSetID .. " -> " .. tostring(arg1))
				LoadoutReminderDB[linkedSetID] = arg1
				UIDropDownMenu_SetText(dropDown, arg1)
				-- a new set was chosen for a new environment
				-- check if it is not already loaded anyway, then close frame if open
				if not addon:isSetLoaded(arg1) then
					addon:checkAndShow()
				else
					LoadoutReminderFrame:Hide()
				end
			end

			info.text = setName
			info.arg1 = info.text
			UIDropDownMenu_AddButton(info)
		end
	end)
end

function addon:initDropdownMenu(linkedSetID, label, offsetX, offsetY)
	local dropDown = CreateFrame("Frame", "Dropdown" .. linkedSetID, self.optionsPanel, "UIDropDownMenuTemplate")
	dropDown:SetPoint("TOP", self.optionsPanel, offsetX, offsetY)
	UIDropDownMenu_SetWidth(dropDown, 200) -- Use in place of dropDown:SetWidth
	-- Bind an initializer function to the dropdown; see previous sections for initializer function examples.
	if LoadoutReminderDB[linkedSetID] ~= nil then
		UIDropDownMenu_SetText(dropDown, LoadoutReminderDB[linkedSetID])
	else
		UIDropDownMenu_SetText(dropDown, "Choose an addon set")
	end
	
	addon:initializeDropdownValues(dropDown, linkedSetID)

	local dd_title = dropDown:CreateFontString('dd_title', 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOP", 0, 10)
	dd_title:SetText(label)
end

function makeFrameMoveable()
	LoadoutReminderFrame:SetMovable(true)
	LoadoutReminderFrame:SetScript("OnMouseDown", function(self, button)
		self:StartMoving()
		end)
	LoadoutReminderFrame:SetScript("OnMouseUp", function(self, button)
		self:StopMovingOrSizing()
		end)
end