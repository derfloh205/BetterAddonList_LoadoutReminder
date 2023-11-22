_, BALLoadoutReminder = ...

BALLoadoutReminder.REMINDER_FRAME = {}

function BALLoadoutReminder.REMINDER_FRAME:UpdateLoadButtonMacro(SET_TO_LOAD)
    local reminderFrame = BALLoadoutReminder.GGUI:GetFrame(BALLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
    local macroText = "/addons load " .. SET_TO_LOAD .. "\n/reload"

    ---@type GGUI.Button
	local loadSetButton = reminderFrame.content.loadButton
	loadSetButton:SetMacroText(macroText)
	loadSetButton:SetText("Load '"..SET_TO_LOAD.."'", nil, true)
end
