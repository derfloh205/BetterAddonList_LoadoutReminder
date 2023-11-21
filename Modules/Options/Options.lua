_, BALLoadoutReminder = ...

BALLoadoutReminder.OPTIONS = {}
function BALLoadoutReminder.OPTIONS:Init()
    BALLoadoutReminder.OPTIONS.optionsPanel = CreateFrame("Frame", "LoadoutReminderOptionsPanel")

	BALLoadoutReminder.OPTIONS.optionsPanel:HookScript("OnShow", function(self)
		end)
        BALLoadoutReminder.OPTIONS.optionsPanel.name = "LoadoutReminder"
	local title = BALLoadoutReminder.OPTIONS.optionsPanel:CreateFontString('optionsTitle', 'OVERLAY', 'GameFontNormal')
    title:SetPoint("TOP", 0, 0)
	title:SetText("Addon Loadout Reminder Options")

    local tabContentX=500
    local tabContentY=500

    ---@type GGUI.Tab
    local generalTab = BALLoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="General", parent=BALLoadoutReminder.OPTIONS.optionsPanel, anchorParent=BALLoadoutReminder.OPTIONS.optionsPanel, adjustWidth=true,
            anchorA="TOPLEFT", anchorB="TOPLEFT", offsetX=20,offsetY=-20
        },
        canBeEnabled=true,
        parent=BALLoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=BALLoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })
    ---@type GGUI.Tab
    local raidBossesTab = BALLoadoutReminder.GGUI.Tab({
        buttonOptions=
        {
            label="Raid Bosses", parent=BALLoadoutReminder.OPTIONS.optionsPanel, anchorParent=generalTab.button.frame, adjustWidth=true,
            anchorA="LEFT", anchorB="RIGHT", offsetX=10,
        },
        canBeEnabled=true,
        parent=BALLoadoutReminder.OPTIONS.optionsPanel,
        anchorParent=BALLoadoutReminder.OPTIONS.optionsPanel,
        anchorA="CENTER", anchorB="CENTER", offsetX=0,offsetY=0,
        sizeX=tabContentX, sizeY=tabContentY,
    })

    local setList = BALLoadoutReminder.MAIN:GetAddonSets()
    print("BALLoadoutReminder Options Init setlist")
    --print(unpack(setList))
    -- convert to data
    local dropdownData = {}
    table.foreach(setList, function(setName, _)
        table.insert(dropdownData, {
            label=setName,
            value=setName,
        })
    end)

    local function dropdownClickCallback(setID, setName)
        local reminderFrame = BALLoadoutReminder.GGUI:GetFrame(BALLoadoutReminder.CONST.FRAMES.REMINDER_FRAME)
        print("clicked dropdown: " .. setID .. ": " .. setName)
        BALLoadoutReminderDB[setID] = setName
        -- a new set was chosen for a new environment
        -- check if it is not already loaded anyway, then close frame if open
        if not BALLoadoutReminder.MAIN:IsSetLoaded(setName) then
            BALLoadoutReminder.MAIN:CheckAndShow()
        else
            reminderFrame:Hide()
        end
    end

    ---@type GGUI.Dropdown
    generalTab.content.dungeonDropdown=BALLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-20,label="Dungeon",
        initialData=dropdownData, initialValue=BALLoadoutReminderDB.DUNGEON, initialLabel=BALLoadoutReminderDB.DUNGEON,
        clickCallback=function (self, label, _)
            dropdownClickCallback("DUNGEON", label)
        end,
    })
    generalTab.content.raidDropdown=BALLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=220,offsetY=-20,label="Raid",
        initialData=dropdownData, initialValue=BALLoadoutReminderDB.RAID, initialLabel=BALLoadoutReminderDB.RAID,
        clickCallback=function (self, label, _)
            dropdownClickCallback("RAID", label)
        end,
    })
    generalTab.content.arenaDropdown=BALLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-60,label="Arena",
        initialData=dropdownData, initialValue=BALLoadoutReminderDB.ARENA, initialLabel=BALLoadoutReminderDB.ARENA,
        clickCallback=function (self, label, _)
            dropdownClickCallback("ARENA", label)
        end,
    })
    generalTab.content.battlegroundsDropdown=BALLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=220,offsetY=-60,label="Battlegrounds",
        initialData=dropdownData, initialValue=BALLoadoutReminderDB.BG, initialLabel=BALLoadoutReminderDB.BG,
        clickCallback=function (self, label, _)
            dropdownClickCallback("BG", label)
        end,
    })
    generalTab.content.openWorldDropdown=BALLoadoutReminder.GGUI.Dropdown({
        parent=generalTab.content, anchorParent=generalTab.content,
        anchorA="TOPLEFT",anchorB="TOPLEFT", offsetX=20,offsetY=-100,label="Open World",
        initialData=dropdownData, initialValue=BALLoadoutReminderDB.OPENWORLD, initialLabel=BALLoadoutReminderDB.OPENWORLD,
        clickCallback=function (self, label, _)
            dropdownClickCallback("OPENWORLD", label)
        end,
    })

    BALLoadoutReminder.GGUI.TabSystem({generalTab, raidBossesTab})

	InterfaceOptions_AddCategory(self.optionsPanel)
end