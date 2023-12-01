BALLoadoutReminderAddonName, BALLoadoutReminder = ...

BALLoadoutReminder.MAIN = CreateFrame("Frame")
BALLoadoutReminder.MAIN:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
BALLoadoutReminder.MAIN:RegisterEvent("ADDON_LOADED")

BALLoadoutReminderGGUIConfig = nil

BALLoadoutReminderDB = nil

local DEFAULT_BACKDROP_OPTIONS = {
    bgFile = "Interface\\CharacterFrame\\UI-Party-Background",
    borderOptions = {
        edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
        edgeSize = 16,
        insets = { left = 8, right = 6, top = 8, bottom = 8 },
    }
}

function BALLoadoutReminder.MAIN:ADDON_LOADED(addon_name)
	if addon_name ~= BALLoadoutReminderAddonName then
		return
	end

	-- show info
	---@type GGUI.Frame
	local frame = BALLoadoutReminder.GGUI.Frame({title=addon_name, 130 ,sizeX=500, sizeY=130, offsetY=130, closeable=true, backdropOptions=DEFAULT_BACKDROP_OPTIONS})
	local LR = BALLoadoutReminder.GUTIL:ColorizeText("LoadoutReminder", BALLoadoutReminder.GUTIL.COLORS.LEGENDARY)
	local BLR = BALLoadoutReminder.GUTIL:ColorizeText(addon_name, BALLoadoutReminder.GUTIL.COLORS.BRIGHT_BLUE)

	frame.content.info = BALLoadoutReminder.GGUI.Text({parent=frame.content, anchorParent=frame.content, 
		text=BLR.." was merged into a new addon called\n" .. LR ..
		"\nwith support for talent sets, addons, equip sets and specializations!\nYou can safely delete " .. BLR .. "\nand download " .. LR
    })
end