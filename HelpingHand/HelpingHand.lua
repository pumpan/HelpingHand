local version = "1.0"
HelpingHand_SavedVariables = HelpingHand_SavedVariables or {}
HelpingHand_SavedVariables.Settings = HelpingHand_SavedVariables.Settings or
    { AVEnabled = 0, WBEnabled = 0, WBWhereEnabled = 0, BGTimerEnabled = 0, AVBossesEnabled = 0, AutoFixGroupsEnabled = 0 }


local function SetupTooltip(checkBox, text)
  checkBox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(checkBox, "ANCHOR_RIGHT")
    GameTooltip:SetText(text, 1, 1, 1)
    GameTooltip:Show()
  end)

  checkBox:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
  end)
end

-- Create the main frame
local mainFrame = CreateFrame("Frame", "MainFrame", UIParent)
mainFrame:SetWidth(250)
mainFrame:SetHeight(150) 
mainFrame:SetPoint("CENTER", UIParent, "CENTER")
mainFrame:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
mainFrame:SetBackdropColor(0, 0, 0, 1)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:SetScript("OnMouseDown", function()
  if arg1 == "LeftButton" and not this.isMoving then
    this:StartMoving();
    this.isMoving = true;
  end
end)
mainFrame:SetScript("OnMouseUp", function()
  if arg1 == "LeftButton" and this.isMoving then
    this:StopMovingOrSizing();
    this.isMoving = false;
  end
end)
mainFrame:Hide()

-- Add header background texture
mainFrame.header = mainFrame:CreateTexture(nil, 'ARTWORK')
mainFrame.header:SetWidth(250)
mainFrame.header:SetHeight(64)
mainFrame.header:SetPoint('TOP', mainFrame, 0, 18)
mainFrame.header:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Header")
mainFrame.header:SetVertexColor(.2, .2, .2)

-- Add header text
mainFrame.headerText = mainFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
mainFrame.headerText:SetPoint('TOP', mainFrame.header, 0, -14)
mainFrame.headerText:SetText('HelpingHand Settings')

-- Close Button
local closeButton = CreateFrame("Button", "CloseButton", mainFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -2, -2)
closeButton:SetScript("OnClick", function()
  mainFrame:Hide()
  ToggleAllFramesClose()
end)

-- Save Button
local saveButton = CreateFrame("Button", "SaveButton", mainFrame, "UIPanelButtonTemplate")
saveButton:SetWidth(100)
saveButton:SetHeight(25)
saveButton:SetPoint("BOTTOM", mainFrame, "BOTTOM", 0, 10)
saveButton:SetText("Save")
saveButton:SetScript("OnClick", function()
  ShowConfirmationFrame("SaveSettings")




  -- Apply the features based on the current settings
  if HelpingHand_Settings.AVEnabled == 1 then
    EnableAlteracValleyFeatures(true) -- Enable Alterac Valley features
  else
    EnableAlteracValleyFeatures(false) -- Disable Alterac Valley features
    DEFAULT_CHAT_FRAME:AddMessage("AlteracValley|cFFFF0000 disabled.")
  end
  if HelpingHand_Settings.WBEnabled == 1 then
    EnableWorldBossesFeatures(true) -- Enable World Bosses features
  else
    EnableWorldBossesFeatures(false) -- Disable World Bosses features
    DEFAULT_CHAT_FRAME:AddMessage("Worldboss|cFFFF0000 disabled.")
  end
  if HelpingHand_Settings.WBEnabled == 1 then
    EnableWorldBossesWhereFeatures(true) -- Enable World Bosses features
  else
    EnableWorldBossesWhereFeatures(false) -- Disable World Bosses features
    DEFAULT_CHAT_FRAME:AddMessage("Where Reply|cFFFF0000 disabled.")
  end
  if HelpingHand_Settings.BGTimerEnabled == 1 then
    EnableBGTimerFeatures(true) -- Enable BG Timer feature
  else
    EnableBGTimerFeatures(false) -- Disable BG Timer feature
    DEFAULT_CHAT_FRAME:AddMessage("BG Timer|cFFFF0000 disabled.")
  end
  if HelpingHand_Settings.AVBossesEnabled == 1 then
    EnableAVBossesFeatures(true) -- Enable AV Bosses feature
  else
    EnableAVBossesFeatures(false) -- Disable AV Bosses feature
    DEFAULT_CHAT_FRAME:AddMessage("AV Bosses|cFFFF0000 disabled.")
  end
  if HelpingHand_Settings.AutoFixGroupsEnabled == 1 then
    EnableAutoFixGroupsFeatures(true) -- Enable AutoFixGroupsFeatures
  else
    EnableAutoFixGroupsFeatures(false) -- Disable AutoFixGroupsFeatures
    DEFAULT_CHAT_FRAME:AddMessage("Autofix Groups|cFFFF0000 disabled.")
  end
  ToggleAllFramesClose()
  mainFrame:Hide();
  DEFAULT_CHAT_FRAME:AddMessage("Settings applied.")
end)

-- Alterac Valley Button
local bgButton = CreateFrame("Button", "bgButton", mainFrame, "UIPanelButtonTemplate")
bgButton:SetWidth(100)
bgButton:SetHeight(25)
bgButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 10, -30)
bgButton:SetText("Battleground")
bgButton:SetScript("OnClick", function()
  ToggleAVFrame()
end)

-- World Bosses Button
local wbButton = CreateFrame("Button", "WBButton", mainFrame, "UIPanelButtonTemplate")
wbButton:SetWidth(100)
wbButton:SetHeight(25)
wbButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -10, -30)
wbButton:SetText("World Bosses")
wbButton:SetScript("OnClick", function()
  ToggleWBFrame()
end)

-- FixGroups Button
local FixGroupsButton = CreateFrame("Button", "FixGroupsButton", mainFrame, "UIPanelButtonTemplate")
FixGroupsButton:SetWidth(100)
FixGroupsButton:SetHeight(25)
FixGroupsButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -10, -55)
FixGroupsButton:SetText("FixGroups")
FixGroupsButton.tooltipText = "Leftclick to fix groups, Rightclick for settings."
FixGroupsButton:RegisterForClicks("LeftButtonUp", "RightButtonDown")

-- Set script for OnClick event
FixGroupsButton:SetScript("OnClick", function()
  if arg1 == "LeftButton" then
    SlashCmdList["FIXGROUPS2"]("")

  elseif arg1 == "RightButton" then
    ToggleAutoFixGroupsFrame()
  end
end)
SetupTooltip(FixGroupsButton, FixGroupsButton.tooltipText)

-- AV Frame
local avFrame = CreateFrame("Frame", "AVFrame", UIParent)
avFrame:SetWidth(200)
avFrame:SetHeight(100)
avFrame:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
avFrame:SetBackdropColor(0, 0, 0, 1)
avFrame:SetPoint("LEFT", mainFrame, "RIGHT", 10, 0)
avFrame:Hide()

-- AV Bosses Checkbox
local avbossesCheckbox = CreateFrame("CheckButton", "AVBossesCheckbox", avFrame, "UICheckButtonTemplate")
avbossesCheckbox:SetPoint("TOPLEFT", 10, -10)
AVBossesCheckboxText:SetText("AV Bosses")
avbossesCheckbox.tooltipText = "Enable this option to Announce HP off Drek/Vandar."
avbossesCheckbox:SetScript("OnClick", function()
  HelpingHand_Settings.AVBossesEnabled = avbossesCheckbox:GetChecked() and 1 or 0
end)
SetupTooltip(avbossesCheckbox, avbossesCheckbox.tooltipText)

-- BG Timer Checkbox
local bgCheckbox = CreateFrame("CheckButton", "BGCheckbox", avFrame, "UICheckButtonTemplate")
bgCheckbox:SetPoint("TOPLEFT", 10, -35)
BGCheckboxText:SetText("BG Timer")
bgCheckbox.tooltipText = "Tracks Av/Ab/Wsg time from Gate opens to Game ends and announces the time."
bgCheckbox:SetScript("OnClick", function()
  HelpingHand_Settings.BGTimerEnabled = bgCheckbox:GetChecked() and 1 or 0
end)
SetupTooltip(bgCheckbox, bgCheckbox.tooltipText)


-- Bg timer button and label
local labelText = avFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
labelText:SetPoint("TOPLEFT", avFrame, "TOPLEFT", 90, -25) 

-- Function to update the text
local function UpdateLabelText()
    if battlegrounds then
        labelText:SetText(
            "Best time AV: " .. string.format("%02d:%02d", battlegrounds.AV.bestTimeEverShow.minutes, battlegrounds.AV.bestTimeEverShow.seconds) ..
            "\nBest time WSG: " .. string.format("%02d:%02d", battlegrounds.WSG.bestTimeEverShow.minutes, battlegrounds.WSG.bestTimeEverShow.seconds) ..
            "\nBest time AB: " .. string.format("%02d:%02d", battlegrounds.AB.bestTimeEverShow.minutes, battlegrounds.AB.bestTimeEverShow.seconds) 
        )
    else
        labelText:SetText("Battlegrounds data not available.")
    end
end


-- Create the button
local BgTimerButton = CreateFrame("Button", "BgTimerButton", avFrame, "UIPanelButtonTemplate")
BgTimerButton:SetWidth(100)
BgTimerButton:SetHeight(25)
BgTimerButton:SetPoint("TOPLEFT", avFrame, "TOPLEFT", 10, -70)
BgTimerButton:SetText("Reset Timers")
BgTimerButton.tooltipText = "RightClick to reset all battleground timers"
BgTimerButton:RegisterForClicks("LeftButtonUp", "RightButtonDown")
BgTimerButton:SetScript("OnClick", function()
  if arg1 == "LeftButton" then
    ShowConfirmationFrame("ResetTimers", "Battlegrounds")
  end
end)
SetupTooltip(BgTimerButton, BgTimerButton.tooltipText)


-- WB Frame
local wbFrame = CreateFrame("Frame", "WBFrame", UIParent)
wbFrame:SetWidth(200)
wbFrame:SetHeight(100)
wbFrame:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
wbFrame:SetBackdropColor(0, 0, 0, 1)
wbFrame:SetPoint("LEFT", mainFrame, "RIGHT", 10, 0)
wbFrame:Hide()

-- Bg timer button and label
local labelTextwb = wbFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
labelTextwb:SetPoint("TOPLEFT", wbFrame, "TOPLEFT", 95, -30)

-- Function to update the text
local function UpdateLabelTextwb()
    if WorldBosses2 then
        labelTextwb:SetText(
            "Best time WB: " .. string.format("%02d:%02d", WorldBosses2.bestTimeEverShow.minutes, WorldBosses2.bestTimeEverShow.seconds) 
        )
    else
        labelTextwb:SetText("Battlegrounds data not available.")
    end
end


-- World Bosses Checkbox
local wbCheckbox = CreateFrame("CheckButton", "WBCheckbox", wbFrame, "UICheckButtonTemplate")
wbCheckbox:SetPoint("TOPLEFT", 10, -10)
WBCheckboxText:SetText("World Bosses")
wbCheckbox.tooltipText = "Announces Boss abilities and where to go when the boss is dies."
wbCheckbox:SetScript("OnClick", function()
  HelpingHand_Settings.WBEnabled = wbCheckbox:GetChecked() and 1 or 0
end)
SetupTooltip(wbCheckbox, wbCheckbox.tooltipText)

-- World Bosses Where Reply Checkbox
local wbWhereCheckbox = CreateFrame("CheckButton", "WBWhereCheckbox", wbFrame, "UICheckButtonTemplate")
wbWhereCheckbox:SetPoint("TOPLEFT", 10, -35)
WBWhereCheckboxText:SetText("Where Reply")
wbWhereCheckbox.tooltipText = "Replies Where to go when someone writes Where in Raidchat."
wbWhereCheckbox:SetScript("OnClick", function()
  HelpingHand_Settings.WBWhereEnabled = wbWhereCheckbox:GetChecked() and 1 or 0
end)
SetupTooltip(wbWhereCheckbox, wbWhereCheckbox.tooltipText)

-- World Bosses Timer button reset/announce
local WbTimerButton = CreateFrame("Button", "WbTimerButton", wbFrame, "UIPanelButtonTemplate")
WbTimerButton:SetWidth(100)
WbTimerButton:SetHeight(25)
WbTimerButton:SetPoint("TOPLEFT", wbFrame, "TOPLEFT", 10, -65)
WbTimerButton:SetText("Reset Timer")
WbTimerButton.tooltipText = "Click to reset timer"
WbTimerButton:RegisterForClicks("LeftButtonUp", "RightButtonDown")
WbTimerButton:SetScript("OnClick", function()
  if arg1 == "LeftButton" then
    ShowConfirmationFrame("ResetTimers", "World Bosses")  
  end
end)

SetupTooltip(WbTimerButton, WbTimerButton.tooltipText)

local confirmationFrame -- Declaration moved to the global scope

--  confirmation frame
confirmationFrame = CreateFrame("Frame", "ConfirmationFrame", UIParent)
confirmationFrame:SetWidth(200)
confirmationFrame:SetHeight(100)
confirmationFrame:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
confirmationFrame:SetBackdropColor(0, 0, 0, 1)
confirmationFrame:SetPoint("CENTER", UIParent, "CENTER")
confirmationFrame:SetFrameStrata("DIALOG")
confirmationFrame:SetFrameLevel(100)
confirmationFrame:Hide()

-- Add confirmation text
local confirmationText = confirmationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
confirmationText:SetPoint("TOP", confirmationFrame, "TOP", 0, -20)


local yesButton = CreateFrame("Button", "YesButton", confirmationFrame, "UIPanelButtonTemplate")
yesButton:SetWidth(80)
yesButton:SetHeight(25)
yesButton:SetPoint("BOTTOMRIGHT", confirmationFrame, "BOTTOM", -10, 10)
yesButton:SetText("Yes")


local noButton = CreateFrame("Button", "NoButton", confirmationFrame, "UIPanelButtonTemplate")
noButton:SetWidth(80)
noButton:SetHeight(25)

noButton:SetPoint("BOTTOMLEFT", confirmationFrame, "BOTTOM", 10, 10)
noButton:SetText("No")


function ShowConfirmationFrame(actionType, actionName)
  confirmationFrame:Show()
  if actionType == "ResetTimers" then
    confirmationText:SetText("Are you sure you want to reset \nthe timers for " .. actionName .. "?\nThis will also ReloadUI.")
    confirmationFrame.timerType = actionName  -- Store the action name as the timerType
  elseif actionType == "SaveSettings" then
    confirmationText:SetText("Are you sure you want to \nsave settings and reload UI?")
  end
  confirmationFrame.actionType = actionType  -- Store the action type in the frame for later use
end



yesButton:SetScript("OnClick", function()
  if confirmationFrame.actionType == "SaveSettings" then
    HelpingHand_SaveSettings()
    confirmationFrame:Hide()
    ReloadUI()
  elseif confirmationFrame.actionType == "ResetTimers" then
    if confirmationFrame.timerType == "Battlegrounds" then
      ResetBattlegroundTimers()
    elseif confirmationFrame.timerType == "World Bosses" then
      ResetWorldBossesRecords()
    end
    confirmationFrame:Hide()
    ReloadUI()  
  end
end)



noButton:SetScript("OnClick", function()
  confirmationFrame:Hide()
end)


-- AutoFixGroups frame
local AutoFixGroupsFrame = CreateFrame("Frame", "AutoFixGroupsFrame", UIParent)
AutoFixGroupsFrame:SetWidth(200)
AutoFixGroupsFrame:SetHeight(100)
AutoFixGroupsFrame:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
AutoFixGroupsFrame:SetBackdropColor(0, 0, 0, 1)
AutoFixGroupsFrame:SetPoint("LEFT", mainFrame, "RIGHT", 10, 0)
AutoFixGroupsFrame:Hide()

-- AutoFixGroups Checkbox
local AutoFixGroupsCheckbox = CreateFrame("CheckButton", "AutoFixGroupsCheckbox", AutoFixGroupsFrame,
  "UICheckButtonTemplate")
AutoFixGroupsCheckbox:SetPoint("TOPLEFT", 10, -10)
AutoFixGroupsCheckboxText:SetText("Auto fix")
AutoFixGroupsCheckbox.tooltipText = "Automaticaly fixes the group on group change."
AutoFixGroupsCheckbox:SetScript("OnClick", function()
  HelpingHand_Settings.AutoFixGroupsEnabled = AutoFixGroupsCheckbox:GetChecked() and 1 or 0
end)
SetupTooltip(AutoFixGroupsCheckbox, AutoFixGroupsCheckbox.tooltipText)

function ToggleAVFrame()
  if avFrame:IsShown() then
    avFrame:Hide()
  else
    avFrame:Show()
    wbFrame:Hide()
  AutoFixGroupsFrame:Hide()
  end
end

function ToggleWBFrame()
  if wbFrame:IsShown() then
    wbFrame:Hide()
  else
    wbFrame:Show()
    avFrame:Hide()
  AutoFixGroupsFrame:Hide()
  end
end

function ToggleAutoFixGroupsFrame()
  if AutoFixGroupsFrame:IsShown() then
    AutoFixGroupsFrame:Hide()
  else
    AutoFixGroupsFrame:Show()
    avFrame:Hide()
  wbFrame:Hide()
  end
end

function ToggleAllFramesClose()
  if avFrame:IsShown() then
    avFrame:Hide()
  elseif wbFrame:IsShown() then
    wbFrame:Hide()
  elseif AutoFixGroupsFrame:IsShown() then
    AutoFixGroupsFrame:Hide()	
  end
end

function HelpingHand_OnLoad()
  this:RegisterEvent("PLAYER_LOGIN");
  this:RegisterEvent("PLAYER_LOGOUT");
  this:RegisterEvent("ADDON_LOADED");
  DEFAULT_CHAT_FRAME:AddMessage("HelpingHand |cff00FF00 loaded.")
end

function HelpingHand_OnEvent()
  if event == "ADDON_LOADED" then
    HelpingHand_LoadSettings()
  elseif event == "PLAYER_LOGOUT" then
    HelpingHand_SaveSettings()
  end
end

local settingsLoaded = false

function HelpingHand_LoadSettings()
  if settingsLoaded then return end
  settingsLoaded = true
  -- Load settings and update checkboxes
  HelpingHand_Settings = HelpingHand_SavedVariables.Settings or
      { AVEnabled = 0, WBEnabled = 0, WBWhereEnabled = 0, BGTimerEnabled = 0, AVBossesEnabled = 0 }
  --avCheckbox:SetChecked(HelpingHand_Settings.AVEnabled == 1)
  wbCheckbox:SetChecked(HelpingHand_Settings.WBEnabled == 1)
  wbWhereCheckbox:SetChecked(HelpingHand_Settings.WBWhereEnabled == 1)
  bgCheckbox:SetChecked(HelpingHand_Settings.BGTimerEnabled == 1)
  avbossesCheckbox:SetChecked(HelpingHand_Settings.AVBossesEnabled == 1)
  AutoFixGroupsCheckbox:SetChecked(HelpingHand_Settings.AutoFixGroupsEnabled == 1)
  if HelpingHand_Settings.AVEnabled == 1 then
    EnableAlteracValleyFeatures(true)
  end
  if HelpingHand_Settings.WBEnabled == 1 then
    EnableWorldBossesFeatures(true)
  end
  if HelpingHand_Settings.WBWhereEnabled == 1 then
    EnableWorldBossesWhereFeatures(true)
  end
  if HelpingHand_Settings.BGTimerEnabled == 1 then
    EnableBGTimerFeatures(true)
  end
  if HelpingHand_Settings.AVBossesEnabled == 1 then
    EnableAVBossesFeatures(true)
  end
  if HelpingHand_Settings.AutoFixGroupsEnabled == 1 then
    EnableAutoFixGroupsFeatures(true)
  end


  battlegrounds = {
    AV = {
        name = "AV",
        bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.AVbestTime or 0,
        bestTimeEverShow = (HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.AVbestTimeShow and { minutes = HelpingHand_SavedVariables.Settings.AVbestTimeShow.minutes, seconds = HelpingHand_SavedVariables.Settings.AVbestTimeShow.seconds }) or { minutes = 0, seconds = 0 },

    },
    WSG = {
        name = "WSG",
        bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WSGbestTime or 0,
        bestTimeEverShow = (HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WSGbestTimeShow and { minutes = HelpingHand_SavedVariables.Settings.WSGbestTimeShow.minutes, seconds = HelpingHand_SavedVariables.Settings.WSGbestTimeShow.seconds }) or { minutes = 0, seconds = 0 },

    },
    AB = {
        name = "AB",
        bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.ABbestTime or 0,
        bestTimeEverShow = (HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.ABbestTimeShow and { minutes = HelpingHand_SavedVariables.Settings.ABbestTimeShow.minutes, seconds = HelpingHand_SavedVariables.Settings.ABbestTimeShow.seconds }) or { minutes = 0, seconds = 0 },

    }
  }
  WorldBosses2 = {
    name = "WorldBosses",
    bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTime or 0,
    bestTimeEverShow = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow or { minutes = 0, seconds = 0 },
    }  
  UpdateLabelText()
  UpdateLabelTextwb()
end


function HelpingHand_SaveSettings()
  HelpingHand_SavedVariables.Settings = HelpingHand_Settings
  DEFAULT_CHAT_FRAME:AddMessage("Settings saved.")
end

-- Assign the event handler function to mainFrame
mainFrame:SetScript("OnEvent", HelpingHand_OnEvent);
mainFrame:RegisterEvent("ADDON_LOADED");
mainFrame:RegisterEvent("PLAYER_LOGIN");
mainFrame:RegisterEvent("PLAYER_LOGOUT");

-- Slash Command to Open the Frame
SLASH_HELPINGHAND1 = "/hhand";
SlashCmdList["HELPINGHAND"] = function()
  mainFrame:Show(); 
end

mainFrame:Hide();

function DisableWorldBossesFeatures()
  DEFAULT_CHAT_FRAME:AddMessage("Worldboss|cFFFF0000 disabled.")
  return
end


