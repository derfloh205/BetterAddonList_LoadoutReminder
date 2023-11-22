_, BALLoadoutReminder = ...
BALLoadoutReminder.REMINDER_FRAME.FRAMES = {}

function BALLoadoutReminder.REMINDER_FRAME.FRAMES:Init()
    local sizeX = 320
    local sizeY = 120
    local offsetX = -10
    local offsetY = 30

    --- @type GGUI.Frame | GGUI.Widget
    local reminderFrame = BALLoadoutReminder.GGUI.Frame({
        parent=UIParent, 
        anchorParent=UIParent,
        anchorA="CENTER",anchorB="CENTER",
        sizeX=sizeX,sizeY=sizeY,
        offsetX=offsetX,offsetY=offsetY,
        frameID=BALLoadoutReminder.CONST.FRAMES.REMINDER_FRAME, 
        title="Addon Loadout Reminder",
        collapseable=true,
        closeable=true,
        moveable=true,
        backdropOptions=BALLoadoutReminder.CONST.DEFAULT_BACKDROP_OPTIONS,
        -- onCloseCallback=,
    })

    local function createContent(frame)
        --- @type GGUI.Text
        frame.content.info = BALLoadoutReminder.GGUI.Text({
            parent=frame.content, anchorParent=frame.content, offsetX=0, offsetY=0,
            anchorA="CENTER", anchorB="CENTER",
            text="",
        })

        frame.content.loadButton = BALLoadoutReminder.GGUI.Button({
            parent=frame.content, anchorParent=frame.content, anchorA="BOTTOM", anchorB="BOTTOM",
            label="Load Set", adjustWidth=true, macro=true, offsetY=20
        })
        
        frame:Hide()
    end

    createContent(reminderFrame)
end