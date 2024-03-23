local modEnabled = false
local hasAskedEnable = false
local saidno = false
local WbWhereEnabled = false
local lastMessageTime = 0 -- For cooldown mechanism
local messageCooldown = 10 -- 10 seconds cooldown
WorldBosses = {}
WorldBosses2 = {
  name = "WorldBosses",
  bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTime or 0,
  bestTimeEverShow = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow or { minutes = 0, seconds = 0 },



}

WorldBosses.EmerissCombatStartTime = nil
WorldBosses.LordKazzakDeathTime = nil
WorldBosses.HealthNotified = {
    ["Emeriss"] = { ["80"] = false, ["55"] = false, ["30"] = false },
    ["Ysondre"] = { ["75"] = false, ["50"] = false, ["25"] = false },
    ["Lethon"] = { ["75"] = false, ["50"] = false, ["25"] = false },
    -- Add other bosses here if needed
}
local WorldbossHealthFrame = CreateFrame("Frame", nil, UIParent)
function EnableWorldBossesWhereFeatures(enable)
    WbWhereEnabled = enable
end
-- Function to encapsulate World Bosses features
function EnableWorldBossesFeatures(enable)
    if enable then

        -- Create the main frame for the addon
        local frame = CreateFrame("Frame")
        frame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILE_DEATH")
        frame:RegisterEvent("PLAYER_TARGET_CHANGED")
        frame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
        frame:RegisterEvent("CHAT_MSG_RAID")
        frame:RegisterEvent("CHAT_MSG_RAID_LEADER")

        -- Create the confirmation frame
        local confirmationFrame = CreateFrame("Frame", "WorldBossConfirmationFrame", UIParent)
        confirmationFrame:SetWidth(250)
        confirmationFrame:SetHeight(100)
        confirmationFrame:SetPoint("CENTER", UIParent, "CENTER")
        confirmationFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        confirmationFrame:SetBackdropColor(0, 0, 0, 1)
        confirmationFrame:SetMovable(true)
        confirmationFrame:EnableMouse(true)
        confirmationFrame:RegisterForDrag("LeftButton")
        confirmationFrame:SetScript("OnDragStart", confirmationFrame.StartMoving)
        confirmationFrame:SetScript("OnDragStop", confirmationFrame.StopMovingOrSizing)
        confirmationFrame:Hide()

        -- Create title for the confirmation frame
        local title = confirmationFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        title:SetPoint("TOPLEFT", confirmationFrame, "TOPLEFT", 10, -10)
        title:SetText("Start WorldBoss Mod?")

        -- Setup buttons
        local yesButton = CreateFrame("Button", nil, confirmationFrame, "UIPanelButtonTemplate")
        yesButton:SetPoint("BOTTOMLEFT", confirmationFrame, "BOTTOMLEFT", 10, 10)
        yesButton:SetWidth(100)
        yesButton:SetHeight(20)
        yesButton:SetText("Yes")

        local noButton = CreateFrame("Button", nil, confirmationFrame, "UIPanelButtonTemplate")
        noButton:SetPoint("BOTTOMRIGHT", confirmationFrame, "BOTTOMRIGHT", -10, 10)
        noButton:SetWidth(100)
        noButton:SetHeight(20)
        noButton:SetText("No")

        -- Function to hide the confirmation frame
        local function HideFrame()
            confirmationFrame:Hide()
        end

        -- Setup the button scripts
        yesButton:SetScript("OnClick", function()
            modEnabled = true
            HideFrame()
        end)

        noButton:SetScript("OnClick", function()
            modEnabled = false
            saidno = true
            HideFrame()
        end)

        -- Check if player is raid leader or assistant
        local function isPlayerRaidLeaderOrAssistant()
            local playerName = UnitName("player")
            for i = 1, 40 do
                local name, rank = GetRaidRosterInfo(i)
                if name == playerName then
                    if rank == 2 then
                        return true
                    elseif rank == 1 then
                        return true
                    else
                        return false
                    end
                end
            end
            return false
        end

        -- Tracking variables
        local hasTargetedEmeriss = false
        local hasTargetedYsondre = false
        local hasTargetedTaerar = false
        local hasTargetedLethon = false
        local hasTargetedAzuregos = false
        local hasTargetedLordKazzak = false
        local EmerissIsDead = false
        local YsondreIsDead = false
        local TaerarIsDead = false
        local LethonIsDead = false
        local AzuregosIsDead = false
        local hasAskedWhere = {}

        frame:SetScript("OnUpdate", function()
            if not isPlayerRaidLeaderOrAssistant() then
                return
            end

            if GameTooltip:IsVisible() then
                local isEmerissFound = false
                for i = 1, GameTooltip:NumLines() do
                    local line = getglobal("GameTooltipTextLeft" .. i)
                    if line and line:GetText() == "Emeriss" then -- add for debugging-> or line:GetText() == "Plate Ogre" 
                        isEmerissFound = true
                        if not hasAskedEnable and not modEnabled and not saidno then
                            confirmationFrame:Show()
                            hasAskedEnable = true
                        end
                        break
                    end
                end
                if not isEmerissFound then
                    hasAskedEnable = false
                end
            else
                hasAskedEnable = false
            end
        end)

        local function OnEvent()
            if not isPlayerRaidLeaderOrAssistant() then
                return
            end

      local function CheckWorldbossHealth(bossName)
        if UnitName("target") == bossName or UnitName("targettarget") == bossName then
          local health, maxHealth, healthPerc
          if UnitName("target") == bossName then
            health = UnitHealth("target")
            maxHealth = UnitHealthMax("target")
            healthPerc = (health / maxHealth) * 100
          elseif UnitName("targettarget") == bossName then
            health = UnitHealth("targettarget")
            maxHealth = UnitHealthMax("targettarget")
            healthPerc = (health / maxHealth) * 100
          end


                    -- Notifications for Emeriss sista
                    if bossName == "Emeriss" then
                        if healthPerc <= 80 and not (healthPerc <= 75) and not WorldBosses.HealthNotified[bossName]["80"] then
                            SendChatMessage("Emeriss 80% EMBRACE FOR FREEZE!", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["80"] = true
                        elseif healthPerc <= 55 and not (healthPerc <= 50) and not WorldBosses.HealthNotified[bossName]["55"] then
                            SendChatMessage("Emeriss 55% EMBRACE FOR FREEZE!", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["55"] = true
                        elseif healthPerc <= 30 and not (healthPerc <= 25) and not WorldBosses.HealthNotified[bossName]["30"] then
                            SendChatMessage("Emeriss 30% EMBRACE FOR FREEZE!", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["30"] = true
                        end
                    end

                    -- Notifications for Ysondre
                    if bossName == "Ysondre" then
                        if healthPerc <= 75 and not (healthPerc <= 70) and not WorldBosses.HealthNotified[bossName]["75"] then
                            SendChatMessage("Ysondre 75% spawned a dragon.", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["75"] = true
                        elseif healthPerc <= 50 and not (healthPerc <= 45) and not WorldBosses.HealthNotified[bossName]["50"] then
                            SendChatMessage("Ysondre 50% spawned a dragon.", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["50"] = true
                        elseif healthPerc <= 25 and not (healthPerc <= 20) and not WorldBosses.HealthNotified[bossName]["25"] then
                            SendChatMessage("Ysondre 25% spawned a dragon.", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["25"] = true
                        end
                    end

                    -- Notifications for Lethon
                    if bossName == "Lethon" then
                        if healthPerc <= 75 and not (healthPerc <= 70) and not WorldBosses.HealthNotified[bossName]["75"] then
                            SendChatMessage("Lethon 75% AOE/KILL the adds!", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["75"] = true
                        elseif healthPerc <= 50 and not (healthPerc <= 45) and not WorldBosses.HealthNotified[bossName]["50"] then
                            SendChatMessage("Lethon 50% AOE/KILL the adds!", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["50"] = true
                        elseif healthPerc <= 25 and not (healthPerc <= 20) and not WorldBosses.HealthNotified[bossName]["25"] then
                            SendChatMessage("Lethon 25% AOE/KILL the adds!", "RAID_WARNING")
                            WorldBosses.HealthNotified[bossName]["25"] = true
                        end
                    end
                end
            end

            WorldbossHealthFrame:SetScript("OnEvent", function()
                CheckWorldbossHealth("Emeriss")
                CheckWorldbossHealth("Ysondre")
                CheckWorldbossHealth("Lethon")
                -- Add other bosses here if needed
            end)

            WorldbossHealthFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
            WorldbossHealthFrame:RegisterEvent("UNIT_HEALTH")


            if event == "PLAYER_TARGET_CHANGED" and modEnabled then
                local targetName = UnitName("target")
                if targetName == "Emeriss" and not hasTargetedEmeriss then  -- add for debugging --> or targetName == "Plate Ogre" 
                    SendChatMessage("Emeriss heals at 75% 50% 25% to full hp.", "RAID_WARNING")
                    hasTargetedEmeriss = true
                elseif targetName == "Ysondre" and not hasTargetedYsondre then
                    SendChatMessage("Ysondre: Watch out for knockbacks, staying at the portal is safe for range dps",
                        "RAID_WARNING")
                    hasTargetedYsondre = true
                elseif targetName == "Taerar" and not hasTargetedTaerar then
                    SendChatMessage("Taerar has no special abilities", "RAID_WARNING")
                    hasTargetedTaerar = true
                elseif targetName == "Lethon" and not hasTargetedLethon then
                    SendChatMessage("Lethon spawns Druids at 75% 50% and 25% AOE THEM! MELEE CAN ALSO HELP!",
                        "RAID_WARNING")
                    hasTargetedLethon = true
                elseif targetName == "Azuregos" and not hasTargetedAzuregos then
                    SendChatMessage("Azuregos: 1. Stay behind boss 2. Dispell tank 3. Watch out for spell reflect! 4. Mana users get out of Blizzard (drains mana)"
                        , "RAID_WARNING")
                    hasTargetedAzuregos = true
                elseif targetName == "Lord Kazzak" and not hasTargetedLordKazzak then
                    SendChatMessage("Lord Kazzak: 1. Decurse and dispel (or WE will wipe) 2. DONT run out of mana (or you will explode in the raid)"
                        , "RAID_WARNING")
                    hasTargetedLordKazzak = true
                end
            elseif event == "CHAT_MSG_MONSTER_YELL" then
                if arg1 == "I can sense the SHADOW on your hearts. There can be no rest for the wicked!" and
                    arg2 == "Lethon" then
                    --if UnitName("target") == "Emeriss" then -- timers wont start if emeriss isnt targeted may remove this line
                        WorldBosses.EmerissCombatStartTime = GetTime()
                        print("World bosses timer started")
            if HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow then
              DEFAULT_CHAT_FRAME:AddMessage("Best time Ever: " .. string.format("%02d:%02d", HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.minutes, HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.seconds), 1.0, 1.0, 0.0)
                        end
                    --end
                end
            elseif event == "CHAT_MSG_COMBAT_HOSTILE_DEATH" and modEnabled then
                local delayTimer = 0
                local delayDuration = 2 
                if arg1 and string.find(arg1, "Emeriss dies") then -- add for debugging --> or string.find(arg1, "Plate Ogre dies")
                    WorldBosses.EmerissCombatStartTime = GetTime()
                    local message = "Port to DEW"
                    WBDelayedMessage(message, delayDuration)
                    EmerissIsDead = true
                    hasAskedWhere = {}
                elseif arg1 and string.find(arg1, "Ysondre dies") then
                    local message = "Port to ZG"
                    WBDelayedMessage(message, delayDuration)
                    YsondreIsDead = true
                    hasAskedWhere = {}
                elseif arg1 and string.find(arg1, "Taerar dies") and YsondreIsDead then
                    local message = "Use a portal to ORGRIMMAR in Hyjal or by a Mage"
                    WBDelayedMessage(message, delayDuration)
                    TaerarIsDead = true
                    hasAskedWhere = {}
                elseif arg1 and string.find(arg1, "Lethon dies") then
                    local message = "DONT PORT! We are riding to AZSHARA!"
                    WBDelayedMessage(message, delayDuration)
                    LethonIsDead = true
                    hasAskedWhere = {}
                elseif arg1 and string.find(arg1, "Azuregos dies") then
                    local message = "Port to HIGHLORD AND DOOMGUARD"
                    WBDelayedMessage(message, delayDuration)
                    AzuregosIsDead = true
                    hasAskedWhere = {}
                elseif arg1 and string.find(arg1, "Lord Kazzak dies") then -- add for debugging --> or string.find(arg1, "Red Ogre Puncher dies")
                    hasAskedWhere = {}
                    WorldBosses.LordKazzakDeathTime = GetTime()
                    if WorldBosses.EmerissCombatStartTime and WorldBosses.LordKazzakDeathTime then
                        local durationInSeconds = WorldBosses.LordKazzakDeathTime - WorldBosses.EmerissCombatStartTime
                        local durationInMinutes = math.floor(durationInSeconds / 60)
                        local seconds = durationInSeconds - durationInMinutes * 60
                        if seconds < 0 then
                          seconds = seconds * -1 
                        end

                        if HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow then
                          if WorldBosses2.bestTimeEver == 0 or durationInSeconds < WorldBosses2.bestTimeEver or durationInSeconds < WorldBosses2.bestTimeEver then
	  

                            WorldBosses2.bestTimeEver = durationInSeconds
                            WorldBosses2.bestTimeEverShow = { minutes = durationInMinutes, seconds = seconds }

                            HelpingHand_SavedVariables.Settings[WorldBosses2.name .. "bestTime"] = durationInSeconds
                            HelpingHand_SavedVariables.Settings[WorldBosses2.name .. "bestTimeShow"] = { minutes = durationInMinutes, seconds = seconds }

                            local message = "New RECORD for " .. WorldBosses2.name .. " : " .. durationInMinutes .. " minutes " .. string.format("%02d", seconds) .. " seconds"
                            WBDelayedMessage(message, delayDuration)
                          elseif durationInSeconds > WorldBosses2.bestTimeEver then
                            local message = "Not a Record Time " .. WorldBosses2.name .. ": " .. durationInMinutes .. " min " .. string.format("%02d", seconds) .. " sec. Record is: " .. WorldBosses2.bestTimeEverShow.minutes .. " min " .. string.format("%02d", WorldBosses2.bestTimeEverShow.seconds) .. " sec."

                            WBDelayedMessage(message, delayDuration)
                          end
                        end
                    else
                        UIErrorsFrame:AddMessage("No Time recorded you probably joined late", 1.0, 0.0, 0.0)

                    end
                end
		    
            elseif (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") and modEnabled and WbWhereEnabled then
                local msg, author = arg1, arg2
                local lowerMsg = string.lower(msg)
                if string.find(lowerMsg, "%f[%a]where%f[%A]") then
                    local currentTime = GetTime()
					local numRaidMembers = GetNumRaidMembers()
					local _, instanceType = IsInInstance()
					if numRaidMembers > 6 and not (instanceType == "pvp" or instanceType == "arena") then
						if currentTime >= (lastMessageTime + messageCooldown) and (not hasAskedWhere[author] or hasAskedWhere[author] == nil) then
							if not EmerissIsDead then
								SendChatMessage("Port to Mal Desolace!", "RAID")

							elseif EmerissIsDead and not YsondreIsDead then
								SendChatMessage("Use Questporter to DEW!", "RAID")
							elseif YsondreIsDead and not TaerarIsDead then
								SendChatMessage("Use Raid Teleporter to ZG and ride to DUSKWOOD!", "RAID")
							elseif TaerarIsDead and not LethonIsDead then
								SendChatMessage("Use a PORTAL to ORGRIMMAR! Hyjal>Portal to orgrimmar", "RAID")
							elseif LethonIsDead and not AzuregosIsDead then
								SendChatMessage("DONT PORT! We are riding to AZSHARA!", "RAID")
							elseif AzuregosIsDead then
								SendChatMessage("Use Questporter to HIGHLORD AND DOOMGUARD!", "RAID")
							else
								SendChatMessage("I'm here", "RAID") -- this is not realy for anything
							end
							hasAskedWhere[author] = true
							lastMessageTime = currentTime

						end
					end	
                end
            end

        end

        frame:SetScript("OnEvent", OnEvent)
        DEFAULT_CHAT_FRAME:AddMessage("Worldbosses |cff00FF00 loaded.")
    end
end
function WBDelayedMessage(message, delay)
    local delayFrame = CreateFrame("Frame")
    local delayTimer = GetTime() + delay
    delayFrame:SetScript("OnUpdate", function(self, elapsed)
        if GetTime() >= delayTimer then
           SendChatMessage(message, "RAID_WARNING")
           delayFrame:SetScript("OnUpdate", nil) 
        end
    end)
end

function ResetWorldBossesRecords()
    if HelpingHand_SavedVariables then
        HelpingHand_SavedVariables.Settings.WorldBossesbestTime = 0
        HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow = { minutes = 0, seconds = 0 }
        DEFAULT_CHAT_FRAME:AddMessage("World Bosses timers reset.")
    else
        DEFAULT_CHAT_FRAME:AddMessage("Saved variables not found or loaded.", 1.0, 0.0, 0.0)
    end
end

SLASH_WB1 = "/wb"
SlashCmdList["WB"] = function(cmd)
    if cmd == "reset" then
        -- Reset WorldBosses records
        ResetWorldBossesRecords()
    elseif cmd == "show" then
        -- Display current WorldBosses timer data
        if HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow then
            DEFAULT_CHAT_FRAME:AddMessage("Best time Ever: " .. string.format("%02d:%02d", HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.minutes, HelpingHand_SavedVariables.Settings.WorldBossesbestTimeShow.seconds), 1.0, 1.0, 0.0)
        else
            DEFAULT_CHAT_FRAME:AddMessage("WorldBosses data not available.", 1.0, 0.0, 0.0)
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid command. Usage: /wb reset to reset records, /wb show to display current records.", 1.0, 0.0, 0.0)
    end
end

