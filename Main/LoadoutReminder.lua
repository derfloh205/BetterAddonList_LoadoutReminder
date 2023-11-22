BALLoadoutReminderAddonName, BALLoadoutReminder = ...

BALLoadoutReminder.MAIN = CreateFrame("Frame", "BALLoadoutReminderAddon")
BALLoadoutReminder.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
BALLoadoutReminder.MAIN:RegisterEvent("ADDON_LOADED")
BALLoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGIN")
BALLoadoutReminder.MAIN:RegisterEvent("PLAYER_LOGOUT")
BALLoadoutReminder.MAIN:RegisterEvent("PLAYER_ENTERING_WORLD")

BALLoadoutReminder.MAIN.FRAMES = {}

BALLoadoutReminderGGUIConfig = BALLoadoutReminderGGUIConfig or {}

BALLoadoutReminderDB = BALLoadoutReminderDB or {
	DUNGEON = nil,
	OPENWORLD = nil,
	RAID = nil,
	BG = nil,
	ARENA = nil,
	CURRENT_SET = nil,
}


function BALLoadoutReminder.MAIN:ADDON_LOADED(addon_name)
	if addon_name ~= BALLoadoutReminderAddonName then
		return
	end
	if BetterAddonListDB == nil then
		return
	end
	--BALLoadoutReminder.GGUI:SetConfigSavedVariable("BALLoadoutReminderGGUIConfig")

	BALLoadoutReminder.OPTIONS:Init()
	BALLoadoutReminder.REMINDER_FRAME.FRAMES:Init()	
	-- show on start -> debug

	BALLoadoutReminder.MAIN:InitBALHook()

	-- restore frame position
	local reminderFrame = BALLoadoutReminder.GGUI:GetFrame(BALLoadoutReminder.MAIN.FRAMES, BALLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	reminderFrame:RestoreSavedConfig(UIParent)
end

BALDropdownHooked = false
function BALLoadoutReminder.MAIN:InitBALHook()
	-- CASE: if player manipulates addon sets via addon list gui of BAL
	local reminderFrame = BALLoadoutReminder.GGUI:GetFrame(BALLoadoutReminder.MAIN.FRAMES, BALLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	BetterAddonListSetsButton:HookScript("OnClick", function() 
		if not BALDropdownHooked then
			DropDownList2Button4:HookScript("OnClick", function() 
				local setName = DropDownList2Button1NormalText:GetText()
				BALLoadoutReminderDB['BAL_LOADED_SET'] = setName
			end)
			DropDownList2Button12:HookScript("OnClick", function() 
				local setName = DropDownList2Button1NormalText:GetText()
				BALLoadoutReminderDB['BAL_LOADED_SET'] = setName
			end)
			DropDownList2Button5:HookScript("OnClick", function() 
				local setName = DropDownList2Button1NormalText:GetText()

				_G['LibDialog-1.0_Button1']:HookScript("OnClick", function() 
					-- well a saved set is also always the current set!
					BALLoadoutReminder.MAIN:SetCurrentSet(setName)
					-- if the reminder frame is currently visible, update it by calling check and Show again
					if reminderFrame:IsVisible() then
						BALLoadoutReminder.MAIN:CheckAndShow()
					end
				end)
			end)
			BALDropdownHooked = true
		end
	end)
end


function BALLoadoutReminder.MAIN:GetAddonSets()
	return BetterAddonListDB.sets
end

function BALLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(set)
	local reminderFrame = BALLoadoutReminder.GGUI:GetFrame(BALLoadoutReminder.MAIN.FRAMES, BALLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
	-- hide frame if its visible
	reminderFrame:Hide()
end

function BALLoadoutReminder.MAIN:CheckAndShow()
	local inInstance, instanceType = IsInInstance()

	local reminderFrame = BALLoadoutReminder.GGUI:GetFrame(BALLoadoutReminder.MAIN.FRAMES, BALLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)

	local DUNGEON_SET = BALLoadoutReminderDB["DUNGEON"]
	local RAID_SET = BALLoadoutReminderDB["RAID"]
	local BG_SET = BALLoadoutReminderDB["BG"]
	local ARENA_SET = BALLoadoutReminderDB["ARENA"]
	local OPENWORLD_SET = BALLoadoutReminderDB["OPENWORLD"]
	local SET_TO_LOAD = nil
	local CURRENT_SET = BALLoadoutReminder.MAIN:GetCurrentSet()

	-- check if player went into a dungeon
	if inInstance and instanceType == 'party' then
		if instanceType == 'party' then
			if DUNGEON_SET == CURRENT_SET or DUNGEON_SET == nil then
				BALLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(DUNGEON_SET)
				return
			end
			SET_TO_LOAD = DUNGEON_SET
		elseif instanceType == 'raid' then
			if RAID_SET == CURRENT_SET or RAID_SET == nil then
				BALLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(RAID_SET)
				return
			end
			SET_TO_LOAD = RAID_SET
		elseif instanceType == 'pvp' then
			if BG_SET == CURRENT_SET or BG_SET == nil then
				BALLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(BG_SET)
				return
			end
			SET_TO_LOAD = BG_SET
		elseif instanceType == 'arena' then
			if ARENA_SET == CURRENT_SET or ARENA_SET == nil then
				BALLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(ARENA_SET)
				return
			end
			SET_TO_LOAD = ARENA_SET
		end
	elseif not inInstance then
		if OPENWORLD_SET == CURRENT_SET or OPENWORLD_SET == nil then
			BALLoadoutReminder.MAIN:PrintAlreadyLoadedMessage(OPENWORLD_SET)
			return
		end
		SET_TO_LOAD = OPENWORLD_SET
	end

	

	if CURRENT_SET ~= nil then
		reminderFrame.content.info:SetText("Current Addon Set: \"" .. CURRENT_SET .. "\"")
	else
		reminderFrame.content.info:SetText("Current Addon Set not recognized")
	end

	BALLoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(SET_TO_LOAD)

	reminderFrame:Show()
end

--- find out what set is currently activated by iterating the addonlist
function BALLoadoutReminder.MAIN:GetCurrentSet()
	local numAddons = C_AddOns.GetNumAddOns()
	local character = UnitName("player")
	local enabledAddons = {}

	for addonIndex=1, numAddons do
		local enabledState = C_AddOns.GetAddOnEnableState(addonIndex, character)
		if enabledState > 0 then
			local addonName = C_AddOns.GetAddOnInfo(addonIndex)
			-- skip for BAL cause it does not include itself in the set lists
			if addonName ~= 'BetterAddonList' then
				-- as map for instant check 
				enabledAddons[addonName] = true
			end
		end
	end 
	-- to be able to early return
	local function matchesCurrentSet(addonList)
		for _, addonName in pairs(addonList) do
			--print("- addon: " .. addonName)
			if enabledAddons[addonName] == nil then
				-- cannot be this set
				return false
			end
		end
		return true
	end

	-- check against list of addon sets of BAL
	-- early return when matching set is found
	for set, addons in pairs(BetterAddonListDB.sets) do
		if matchesCurrentSet(addons) then
			return set
		end
	end
end


function BALLoadoutReminder.MAIN:PLAYER_ENTERING_WORLD(isLogIn, isReload)
	
	-- -- if player just logged in, dont suggest addon set loading
	-- if isLogIn then
	-- 	-- purge it on login if player changed set and logged out (for whatever reason)
	-- 	BALLoadoutReminderDB['BAL_LOADED_SET'] = nil
	-- 	return
	-- elseif isReload then
	-- 	-- check if player changed set via BAL gui
	-- 	if BALLoadoutReminderDB['BAL_LOADED_SET'] ~= nil then
	-- 		-- print("Set was changed with bal to: " .. LoadoutReminderDB['BAL_LOADED_SET'])
	-- 		BALLoadoutReminder.MAIN:SetCurrentSet(BALLoadoutReminderDB['BAL_LOADED_SET'])
	-- 		BALLoadoutReminderDB['BAL_LOADED_SET'] = nil
	-- 	end
	-- else
	-- 	-- just purge it because BAL does it too
	-- 	BALLoadoutReminderDB['BAL_LOADED_SET'] = nil
	-- end

	BALLoadoutReminder.MAIN:CheckAndShow()
end

function BALLoadoutReminder.MAIN:LoadDefaultDB() 
	BALLoadoutReminderDB = BALLoadoutReminderDB or CopyTable(self.DefaultDB)
end

function BALLoadoutReminder.MAIN:PLAYER_LOGIN()
	SLASH_ADDONLOADOUTREMINDER1 = "/loadoutreminder"
	SLASH_ADDONLOADOUTREMINDER2 = "/lor"
	SlashCmdList["ADDONLOADOUTREMINDER"] = function(input)

		input = SecureCmdOptionParse(input)
		if not input then return end

		local command, rest = input:match("^(%S*)%s*(.-)$")
		command = command and command:lower()
		rest = (rest and rest ~= "") and rest:trim() or nil

		if command == "config" then
			InterfaceOptionsFrame_OpenToCategory(BALLoadoutReminder.OPTIONS.optionsPanel)
		end

		if command == "check" then 
			BALLoadoutReminder.MAIN:CheckAndShow()
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