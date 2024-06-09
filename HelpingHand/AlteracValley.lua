local hasshown = false
local bgWSG = false
local bgAB = false
local bgAV = false
local bgRESET = false
--local SidePatterns = {
--    "the (.*) will destroy it!",
--    "the (.*) will capture it!",
--    "by the (.*)!",
--    "was taken by the (.*)!"
--}

--local side = nil
local battlegroundMessages = {
    AV = {
        "The battle for Alterac Valley has begun!",
        "%f[%a]Stonhearth Bunker[%A]",
        "%f[%a]Captain Galvangar[%A]",
        "%f[%a]Vanndar[%A]",
        "%f[%a]Dun Baldar North Bunker[%A]",
        "Stormpike Aid Station",
        "Dun Baldar South Bunker",
        "Stormpike Graveyard",
        "Icewing Bunker",
        "Stonehearth Graveyard",
        "Stonehearth Bunker",
        "Snowfall Graveyard",
        "Iceblood Tower",
        "Iceblood Graveyard",
        "Tower Point",
        "Frostwolf Graveyard",
        "West Frostwolf Tower",
        "East Frostwolf Tower",
        "Frostwolf Relief Hut",
        "ya try again without",
        "Your kind has no place in Alterac Valley", -- galvangar
        "I'll never fall for that, fool! if you want a battle,", -- galvangar
        "Stormpike filth!" -- vandar
    },
    WSG = {
        "Let the battle for Warsong Gulch begin!",
        "The flags are now placed at their bases.",
        "%f[%a]Flag%f[%A]"
    },
    AB = {
        "The Battle for Arathi Basin has begun!",
        "%f[%a]stables%f[%A]",
        "%f[%a]farm%f[%A]",
        "lumber mill",
        "blacksmith",
        "mine"

    }
}

function get_player_faction()
    englishFaction, localizedFaction = UnitFactionGroup("player");
    return englishFaction;
end

function EnableAlteracValleyFeatures(enable)
    DEFAULT_CHAT_FRAME:AddMessage("av features")
end

function EnableBGTimerFrameFeatures(enable)
    if enable then
        BGTimerFrame = 1
    else
        BGTimerFrame = 0
    end
end


function IsInBattleground()
    local inInstance, instanceType = IsInInstance()
    if inInstance and instanceType == "pvp" then
        return true
    else
        return false
    end
end

function SetCurrentBattleground(bgType)
    if bgType == "AV" then
        bgAV = true
        bgRESET = false
        UIErrorsFrame:AddMessage("Current battleground set to Alterac Valley", 1.0, 1.0, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("Current battleground set to Alterac Valley", 1.0, 1.0, 0.0)
    elseif bgType == "WSG" then
        bgWSG = true
        bgRESET = false
        UIErrorsFrame:AddMessage("Current battleground set to Warsong Gulch", 1.0, 1.0, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("Current battleground set to Warsong Gulch", 1.0, 1.0, 0.0)
    elseif bgType == "AB" then
        bgAB = true
        bgRESET = false
        UIErrorsFrame:AddMessage("Current battleground set to Arathi Basin", 1.0, 1.0, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("Current battleground set to Arathi Basin", 1.0, 1.0, 0.0)
    elseif bgType == "RESET" then
        bgAV = false
        bgWSG = false
        bgAB = false
--        side = nil
        bgRESET = true
        UIErrorsFrame:AddMessage("Reseting bgs", 1.0, 1.0, 0.0)
        DEFAULT_CHAT_FRAME:AddMessage("Reseting bgs", 1.0, 1.0, 0.0)
    else
        UIErrorsFrame:AddMessage("Invalid battleground type", 1.0, 0.0, 0.0)
    end
end

function EnableAVBossesFeatures(enable)
    if enable then
        --DEFAULT_CHAT_FRAME:AddMessage("AvBosses|cff00FF00 loaded.")

        -- Boss Health Notification
        local bossHealthFrame = CreateFrame("Frame", nil, UIParent)
        local bossNames = { "Vanndar Stormpike", "Drek'Thar" } -- Add more boss names as needed
        local bossHealthNotified = {}
        for _, bossName in ipairs(bossNames) do
            bossHealthNotified[bossName] = { ["50"] = false, ["30"] = false, ["20"] = false, ["10"] = false }
        end

        local function ResetNotifications(bossName)
            bossHealthNotified[bossName] = { ["50"] = false, ["30"] = false, ["20"] = false, ["10"] = false }
        end

        local function NotifyHealth(bossName, healthPerc)
            if healthPerc == 100 then
                ResetNotifications(bossName)
                --DEFAULT_CHAT_FRAME:AddMessage(bossName .. "100% health!", 1.0, 0.0, 0.0)
            elseif healthPerc <= 50 and not (healthPerc <= 45) and not bossHealthNotified[bossName]["50"] then
                DEFAULT_CHAT_FRAME:AddMessage(bossName .. " is at 50% health!", 1.0, 0.0, 0.0)
                SendChatMessage(bossName .. " is at 50% health!", "BATTLEGROUND")
                bossHealthNotified[bossName]["50"] = true
            elseif healthPerc <= 30 and not (healthPerc <= 25) and not bossHealthNotified[bossName]["30"] then
                DEFAULT_CHAT_FRAME:AddMessage(bossName .. " is at 30% health!", 1.0, 0.0, 0.0)
                SendChatMessage("" .. bossName .. " is at 30% health!", "BATTLEGROUND")
                bossHealthNotified[bossName]["30"] = true
            elseif healthPerc <= 20 and not (healthPerc <= 15) and not bossHealthNotified[bossName]["20"] then
                DEFAULT_CHAT_FRAME:AddMessage(bossName .. " is at 20% health!", 1.0, 0.0, 0.0)
                SendChatMessage(bossName .. " is at 20% health!", "BATTLEGROUND")
                bossHealthNotified[bossName]["20"] = true
            elseif healthPerc <= 10 and not (healthPerc <= 5) and not bossHealthNotified[bossName]["10"] then
                DEFAULT_CHAT_FRAME:AddMessage(bossName .. " is at 10% health!", 1.0, 0.0, 0.0)
                SendChatMessage(bossName .. " is at 10% health!", "BATTLEGROUND")
                bossHealthNotified[bossName]["10"] = true
            end
        end

        local function CheckBossHealth(bossName)
            local health, maxHealth, healthPerc

            if GetNumRaidMembers() > 0 then
                for i = 1, GetNumRaidMembers() do
                    local unit = "raid" .. i .. "target"
                    if UnitExists(unit) and UnitName(unit) == bossName then
                        health = UnitHealth(unit)
                        maxHealth = UnitHealthMax(unit)
                        healthPerc = (health / maxHealth) * 100
                        NotifyHealth(bossName, healthPerc)
                        return
                    end
                end
            elseif GetNumPartyMembers() > 0 then
                for i = 1, GetNumPartyMembers() do
                    local unit = "party" .. i .. "target"
                    if UnitExists(unit) and UnitName(unit) == bossName then
                        health = UnitHealth(unit)
                        maxHealth = UnitHealthMax(unit)
                        healthPerc = (health / maxHealth) * 100
                        NotifyHealth(bossName, healthPerc)
                        return
                    end
                end
            end
        end

        bossHealthFrame:SetScript("OnUpdate", function()
            for _, bossName in ipairs(bossNames) do
                CheckBossHealth(bossName)
            end
        end)
    end
end

function EnableBGTimerFeatures(enable)
    if enable then
        --DEFAULT_CHAT_FRAME:AddMessage("BG Timers|cff00FF00 loaded.")
        local battlegrounds = {
            AV = {
                name = "AV",
                bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.AVbestTime or
                    0,
                bestTimeEverShow = (
                    HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.AVbestTimeShow)
                    or 0,
                bestTimeThisSession = 0,
                bestTimeThisSessionShow = 0
            },
            WSG = {
                name = "WSG",
                bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WSGbestTime or
                    0,
                bestTimeEverShow = (
                    HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WSGbestTimeShow)
                    or 0,
                bestTimeThisSession = 0,
                bestTimeThisSessionShow = 0
            },
            AB = {
                name = "AB",
                bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.ABbestTime or
                    0,
                bestTimeEverShow = (
                    HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.ABbestTimeShow)
                    or 0,
                bestTimeThisSession = 0,
                bestTimeThisSessionShow = 0
            }
        }
        if HelpingHand_SavedVariables then
            DEFAULT_CHAT_FRAME:AddMessage("Saved variables loaded successfully!")

        else
            DEFAULT_CHAT_FRAME:AddMessage("Saved variables not found or loaded.", 1.0, 0.0, 0.0)
        end

        local avTimeFrame = CreateFrame("Frame", nil, UIParent)
        local isInAlteracValley = false
        local battleground
        local delayTimer = 0
        local delayDuration = 2


        avTimeFrame:SetScript("OnEvent", function()
            local _, instanceType = IsInInstance()
            durationInSeconds = GetBattlefieldInstanceRunTime() / 1000 -- Convert milliseconds to seconds

            if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" or event == "CHAT_MSG_SYSTEM" or event == "CHAT_MSG_TEXT_EMOTE" or
                event == "CHAT_MSG_BG_SYSTEM_HORDE" or event == "CHAT_MSG_BG_SYSTEM_ALLIANCE" or
                event == "CHAT_MSG_MONSTER_YELL" or event == "RAID_ROSTER_UPDATE" and arg1 then
                for bgType, messages in pairs(battlegroundMessages) do
                    for _, bgMessage in ipairs(messages) do
                        if string.find(arg1, bgMessage) then
                            if bgType == "AV" and not bgAV then
                                battleground = battlegrounds.AV
                                SetCurrentBattleground("AV")
                                ras = get_player_faction()
                                print("faction:" .. ras)
                            elseif bgType == "WSG" and not bgWSG then
                                battleground = battlegrounds.WSG
                                SetCurrentBattleground("WSG")
                            elseif bgType == "AB" and not bgAB then
                                battleground = battlegrounds.AB
                                SetCurrentBattleground("AB")
                            end
                            break -- Stop checking messages for the current battleground type if a match is found
                            --else
                            --print("" .. arg1)
                            --break
                        end
                    end
                end
                -- checks side (horde/alliance)
                --if side == nil then
                --    for _, pattern in ipairs(SidePatterns) do
                --        local _, _, capturedSide = string.find(arg1, pattern)
                --        --print("" .. arg1)
                --        if capturedSide then
                --            side = capturedSide
                --            print("Side found:" .. side)
                --            break -- If side is found in any pattern, exit the loop
                --        end
                --    end
                --end
				if ras == "Horde" and string.find(string.lower(arg1), "the stormpike aid station was taken by the horde") then
					SendChatMessage("*** GY UP! ***", "BATTLEGROUND")
				elseif ras == "Alliance" and string.find(string.lower(arg1), "the frostwolf relief hut was taken by the alliance") then
					SendChatMessage("*** GY UP! ***", "BATTLEGROUND")
				end


                if battleground and not hasshown then
                    if battleground.bestTimeEverShow then
                        DEFAULT_CHAT_FRAME:AddMessage("Best time " ..
                            battleground.name .. ": " .. SecondsToTime(durationInSeconds)
                            , 1.0, 1.0, 0.0)
                        hasshown = true
                    end
                    if battleground.bestTimeThisSessionShow then
                        DEFAULT_CHAT_FRAME:AddMessage("Best time " ..
                            battleground.name .. " today: " .. SecondsToTime(durationInSeconds), 1.0, 1.0, 0.0)
                        hasshown = true
                    end
                end

                -- av timer visual frame
                if IsInBattleground() and BGTimerFrame == 1 then
                    --UIErrorsFrame:AddMessage("bg timer frame", 1.0, 1.0, 0.0)
                    --print("Bg timer frame!")
                    if not bgDurationTimerFrame then
                        -- print("show")
                        bgDurationTimerFrame = CreateFrame("Frame", "BGDurationTimerFrame", UIParent)
                        bgDurationTimerFrame:SetPoint("TOP", 0, -50) -- Adjust position as needed
                        bgDurationTimerFrame:SetWidth(200)
                        bgDurationTimerFrame:SetHeight(25)
                        bgDurationTimerFrame:SetBackdrop({
                            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                            tile = true,
                            tileSize = 1,
                            edgeSize = 1,
                            insets = { left = 1, right = 1, top = 1, bottom = 1 }
                        })
                        bgDurationTimerFrame.text = bgDurationTimerFrame:CreateFontString(nil, "OVERLAY",
                            "GameFontNormal")
                        bgDurationTimerFrame.text:SetPoint("CENTER", 0, 0)
                        bgDurationTimerFrame:SetMovable(true)
                        bgDurationTimerFrame:EnableMouse(true)
                        bgDurationTimerFrame:RegisterForDrag("LeftButton")
                        bgDurationTimerFrame:SetScript("OnDragStart", bgDurationTimerFrame.StartMoving)
                        bgDurationTimerFrame:SetScript("OnDragStop", bgDurationTimerFrame.StopMovingOrSizing)
                        local position = HelpingHand_SavedVariables.Settings.timerFramePosition
                        if position then
                            bgDurationTimerFrame:SetPoint(position[1], UIParent, position[2], position[3],
                                position[4])
                        end
                        bgDurationTimerFrame:SetScript("OnMouseDown", function()
                            if arg1 == "LeftButton" and not this.isMoving then
                                this:StartMoving();
                                this.isMoving = true;
                            end
                        end)
                        bgDurationTimerFrame:SetScript("OnMouseUp", function()
                            if arg1 == "LeftButton" and this.isMoving then
                                this:StopMovingOrSizing();
                                this.isMoving = false;
                                SaveTimerFramePosition()
                            elseif arg1 == "RightButton" then
                                SendChatMessage("Battleground Duration: " .. SecondsToTime(durationInSeconds), "SAY")
                            end
                        end)
                    end

                    bgDurationTimerFrame:SetScript("OnUpdate", function()
                        if battleground and IsInBattleground() and not bgRESET then
                            durationInSeconds = GetBattlefieldInstanceRunTime() / 1000
                            bgDurationTimerFrame.text:SetText(battleground.name ..
                                " Duration: " .. SecondsToTime(durationInSeconds))
                        else
                            bgDurationTimerFrame.text:SetText("Duration: " .. SecondsToTime(durationInSeconds))
                        end
                    end)


                end
				if (
					string.find(string.lower(arg1), "victory") and not string.find(string.lower(arg1), "near victory") and not string.find(string.lower(arg1), "daily:")
					) or (
					string.find(string.lower(arg1), "defeat") and not string.find(string.lower(arg1), "defeated") and not string.find(string.lower(arg1), "you cannot defeat the frostwolf clan")
					) or string.find(string.lower(arg1), "wins") then
					print(arg1)

                    --print("tid" .. SecondsToTime(durationInSeconds))
                    SetCurrentBattleground("RESET")
                    -- Stop the timer when victory or defeat message is received
                    if bgDurationTimerFrame then
                        bgDurationTimerFrame.text:SetText("empty")
                        bgDurationTimerFrame:SetScript("OnUpdate", nil) -- Stop updating the timer frame
                        bgDurationTimerFrame:Hide()
                        bgDurationTimerFrame = false
                    end

                    if durationInSeconds then
                        -- print("durationinseconds")
                        if battleground then
                            --print("battleground")
                            if battleground.bestTimeEver == 0 or durationInSeconds < battleground.bestTimeEver or
                                (
                                durationInSeconds < battleground.bestTimeEver and battleground.bestTimeThisSession == nil
                                ) then
                                battleground.bestTimeThisSession = durationInSeconds
                                battleground.bestTimeThisSessionShow = durationInSeconds

                                battleground.bestTimeEver = durationInSeconds
                                battleground.bestTimeEverShow = durationInSeconds

                                HelpingHand_SavedVariables.Settings[battleground.name .. "bestTime"] = durationInSeconds
                                HelpingHand_SavedVariables.Settings[battleground.name .. "bestTimeShow"] = durationInSeconds

                                local message = "New RECORD for " ..
                                    battleground.name .. " : " .. SecondsToTime(durationInSeconds)
                                DelayedMessage(message, delayDuration)

                            elseif battleground.bestTimeThisSession == 0 or
                                durationInSeconds < battleground.bestTimeThisSession then
                                battleground.bestTimeThisSession = durationInSeconds
                                battleground.bestTimeThisSessionShow = durationInSeconds

                                local message = "Time " ..
                                    battleground.name .. ": " .. SecondsToTime(durationInSeconds)
                                DelayedMessage(message, delayDuration)
                            else
                                local message = "Time: " ..
                                    battleground.name .. " : " .. SecondsToTime(durationInSeconds)
                                DelayedMessage(message, delayDuration)
                            end
                            battleground = ""
                        else
                            UIErrorsFrame:AddMessage("You Joined late, no time recorded", 1.0, 1.0, 0.0)
                            DEFAULT_CHAT_FRAME:AddMessage("You Joined late, no time recorded", 1.0, 1.0, 0.0)
                        end
                    end
                end
            end
            if not IsInBattleground() and bgDurationTimerFrame then
                -- UIErrorsFrame:AddMessage("You left early, timer canceled", 1.0, 1.0, 0.0)
                --DEFAULT_CHAT_FRAME:AddMessage("You left early, timer canceled", 1.0, 1.0, 0.0)
                bgDurationTimerFrame.text:SetText("empty")
                bgDurationTimerFrame:SetScript("OnUpdate", nil) -- Stop updating the timer frame
                bgDurationTimerFrame:Hide()
                bgDurationTimerFrame = false
                battleground = ""
                SetCurrentBattleground("RESET")


                return -- Exit the function early if the player left the raid group
            end
        end)

        function DelayedMessage(message, delay)
            local delayFrame = CreateFrame("Frame")
            local delayTimer = GetTime() + delay
            delayFrame:SetScript("OnUpdate", function(self, elapsed)
                if GetTime() >= delayTimer then
                    UIErrorsFrame:AddMessage(message, 1.0, 1.0, 0.0)
                    SendChatMessage(message, "SAY")
                    durationInSeconds = nil
                    delayFrame:SetScript("OnUpdate", nil)
                end
            end)
        end

        function ResetBattlegroundTimers()
            if HelpingHand_SavedVariables then
                for _, battleground in pairs(battlegrounds) do
                    battleground.bestTimeThisSession = 0
                    battleground.bestTimeThisSessionShow = 0
                end
                -- Update saved variables
                HelpingHand_SavedVariables.Settings.AVbestTime = 0
                HelpingHand_SavedVariables.Settings.AVbestTimeShow = 0
                HelpingHand_SavedVariables.Settings.WSGbestTime = 0
                HelpingHand_SavedVariables.Settings.WSGbestTimeShow = 0
                HelpingHand_SavedVariables.Settings.ABbestTime = 0
                HelpingHand_SavedVariables.Settings.ABbestTimeShow = 0
                DEFAULT_CHAT_FRAME:AddMessage("Battleground timers reset.")
            else
                DEFAULT_CHAT_FRAME:AddMessage("Saved variables not found or loaded.", 1.0, 0.0, 0.0)
            end
        end

        SLASH_bt1 = "/bt"
        SlashCmdList["bt"] = function(cmd)
            if cmd == "reset" then
                ResetBattlegroundTimers()
            elseif cmd == "show" then
                if battlegrounds then
                    DEFAULT_CHAT_FRAME:AddMessage("Best time AV: " ..
                        string.format("%02d:%02d", battlegrounds.AV.bestTimeEverShow.minutes,
                            battlegrounds.AV.bestTimeEverShow.seconds), 1.0, 1.0, 0.0)
                    DEFAULT_CHAT_FRAME:AddMessage("Best time AV today: " ..
                        string.format("%02d:%02d", battlegrounds.AV.bestTimeThisSessionShow.minutes,
                            battlegrounds.AV.bestTimeThisSessionShow.seconds), 1.0, 1.0, 0.0)
                    DEFAULT_CHAT_FRAME:AddMessage("Best time WSG: " ..
                        string.format("%02d:%02d", battlegrounds.WSG.bestTimeEverShow.minutes,
                            battlegrounds.WSG.bestTimeEverShow.seconds), 1.0, 1.0, 0.0)
                    DEFAULT_CHAT_FRAME:AddMessage("Best time WSG today: " ..
                        string.format("%02d:%02d", battlegrounds.WSG.bestTimeThisSessionShow.minutes,
                            battlegrounds.WSG.bestTimeThisSessionShow.seconds), 1.0, 1.0, 0.0)
                    DEFAULT_CHAT_FRAME:AddMessage("Best time AB: " ..
                        string.format("%02d:%02d", battlegrounds.AB.bestTimeEverShow.minutes,
                            battlegrounds.AB.bestTimeEverShow.seconds), 1.0, 1.0, 0.0)
                    DEFAULT_CHAT_FRAME:AddMessage("Best time AB today: " ..
                        string.format("%02d:%02d", battlegrounds.AB.bestTimeThisSessionShow.minutes,
                            battlegrounds.AB.bestTimeThisSessionShow.seconds), 1.0, 1.0, 0.0)

                else
                    DEFAULT_CHAT_FRAME:AddMessage("Battlegrounds data not available.", 1.0, 0.0, 0.0)
                end
            else
                DEFAULT_CHAT_FRAME:AddMessage("Invalid command. Usage: /bt reset to reset records, /bt show to display current records."
                    , 1.0, 0.0, 0.0)
            end
        end

        function SaveTimerFramePosition()
            local point, _, relativePoint, xOfs, yOfs = bgDurationTimerFrame:GetPoint()
            HelpingHand_SavedVariables.Settings.timerFramePosition = { point, relativePoint, xOfs, yOfs }
        end

        avTimeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        avTimeFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
        avTimeFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
        avTimeFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
        avTimeFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
        avTimeFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL")
        avTimeFrame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
        avTimeFrame:RegisterEvent("RAID_ROSTER_UPDATE")
        avTimeFrame:RegisterEvent("CHAT_MSG_SYSTEM");
    end
end

function EnableAVWarmastersFeatures(enable)
    if enable then
        local VanndarNormal = "^Avatar fades from Vanndar Stormpike."
        local VanndarEnrage = "^Vanndar Stormpike gains Avatar."
        local Marshal = "^Marshal gains Whirlwind."
        local WarmasterStart = "^(.-) gains Whirlwind."
        local WarmasterStop = "^Whirlwind fades from (.*)"
        
        local lastWarmasterStart = {} -- Table to store the last whirlwind start time for each Warmaster
        local lastWarmasterStop = {} -- Table to store the last whirlwind stop time for each Warmaster
        local WHIRLWIND_DELAY = 5 -- Delay in seconds
        local whirlwindCount = {}
        local countdownTimers = {}
        
        local BossEventFrame = CreateFrame("Frame")
        BossEventFrame:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_OTHER")
        BossEventFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS")
        
        BossEventFrame:SetScript("OnEvent", function()
            if event == "CHAT_MSG_SPELL_AURA_GONE_OTHER" or event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS" then
                if arg1 then
                    -- Print the argument received
                    --print("Argument:" .. arg1)
        
                    if string.find(arg1, VanndarNormal) then
                        UIErrorsFrame:AddMessage("Vanndar is back to normal", 1.0, 1.0, 0.0)
        
                    elseif string.find(arg1, VanndarEnrage) then
                        UIErrorsFrame:AddMessage("Vanndar is enraged!", 1.0, 1.0, 0.0)
                    end
        
                    local _, _, warmasterNameStart = string.find(arg1, WarmasterStart)
                    if warmasterNameStart then
                        local currentTime = GetTime()
                        local lastStartTime = lastWarmasterStart[warmasterNameStart] or 0
                        local value = currentTime - lastStartTime
        
        
                        if value > WHIRLWIND_DELAY then
                            UIErrorsFrame:AddMessage(warmasterNameStart .. " starts to whirlwind!", 1.0, 1.0, 0.0)
                            --print(warmasterNameStart .. " starts to whirlwind")
                            lastWarmasterStart[warmasterNameStart] = currentTime
                            StartWhirlwindCountdown(warmasterNameStart)
                        else
                            --print("Condition to print 'starts to whirlwind' is not executed.")
                        end
                    end
        
                    local _, _, warmasterNameStop = string.find(arg1, WarmasterStop)
                    if warmasterNameStop then
                        local currentTime = GetTime()
                        lastWarmasterStop[warmasterNameStop] = currentTime
        
                        if whirlwindCount[warmasterNameStop] and whirlwindCount[warmasterNameStop] > 1 then
                            UIErrorsFrame:AddMessage("Whirlwind fades from " .. warmasterNameStop, 1.0, 1.0, 0.0)
                            --print("Whirlwind fades from " .. warmasterNameStop)
                            whirlwindCount[warmasterNameStop] = 0
                        end
                        whirlwindCount[warmasterNameStop] = (whirlwindCount[warmasterNameStop] or 0) + 1
                    end
                end
            end
        end)
        
        local activeCountdownFrames = {} -- Table to store active countdown frames
        local mainCountdownFrame = nil -- Initialize main countdown frame variable
        
        local function HideMainCountdownFrame()
            if mainCountdownFrame then
                mainCountdownFrame:Hide()
            end
        end
        
        function StartWhirlwindCountdown(warmasterName)
            local countdownDuration = 15 -- Duration of the countdown in seconds
            local startTime = GetTime()
            countdownTimers[warmasterName] = startTime + countdownDuration
            local lastPrintedSecond = countdownDuration -- Initialize to the countdown duration
        
            -- Initialize activeCountdownFrames if it's nil
            if not activeCountdownFrames then
                activeCountdownFrames = {}
            end
        
            -- Check if a frame with the same warmaster name already exists
            local frameExists = false
            for _, frame in ipairs(activeCountdownFrames) do
                if frame.warmasterName == warmasterName then
                    -- Update existing frame and return
                    frame.countdownDuration = countdownDuration
                    frame.startTime = startTime
                    frameExists = true
                    break
                end
            end
        
            if not frameExists then
                -- Create the main countdown frame or use the existing one
                if not mainCountdownFrame then
                    mainCountdownFrame = CreateFrame("Frame", "MainCountdownFrame", UIParent)
                    mainCountdownFrame:SetWidth(150) -- Adjust width to match the text
                    mainCountdownFrame:SetHeight(15)
                    mainCountdownFrame:SetPoint("CENTER", 0, 0)
        
                    -- Create gray background texture for main countdown frame
                    mainCountdownFrame.backgroundTexture = mainCountdownFrame:CreateTexture(nil, "BACKGROUND")
                    mainCountdownFrame.backgroundTexture:SetAllPoints()
                    mainCountdownFrame.backgroundTexture:SetTexture(.6, .2, .2, 1) -- Set background color (red with 50% transparency)
                    -- Create font string for displaying text
                    mainCountdownFrame.text = mainCountdownFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    mainCountdownFrame.text:SetPoint("CENTER", mainCountdownFrame, "CENTER", 0, 0) -- Position the text in the center of the frame
                    mainCountdownFrame.text:SetText("Whirlwind timer") -- Set the initial text
        
                end
                -- Make the countdown frame movable and enable mouse interaction
                mainCountdownFrame:SetMovable(true)
                mainCountdownFrame:EnableMouse(true)
                mainCountdownFrame:RegisterForDrag("LeftButton")
                mainCountdownFrame:SetScript("OnDragStart", mainCountdownFrame.StartMoving)
                mainCountdownFrame:SetScript("OnDragStop", mainCountdownFrame.StopMovingOrSizing)
                local mainCountdownFramePosition = HelpingHand_SavedVariables.Settings.mainCountdownFramePosition
                if mainCountdownFramePosition then
                    mainCountdownFrame:SetPoint(mainCountdownFramePosition[1], UIParent, mainCountdownFramePosition[2],
                        mainCountdownFramePosition[3], mainCountdownFramePosition[4])
                end
        
                mainCountdownFrame:SetScript("OnMouseDown", function()
                    if arg1 == "LeftButton" and not this.isMoving then
                        this:StartMoving();
                        this.isMoving = true;
                    end
                end)
        
                mainCountdownFrame:SetScript("OnMouseUp", function()
                    if arg1 == "LeftButton" and this.isMoving then
                        this:StopMovingOrSizing()
                        this.isMoving = false
                        SaveMainCountdownFramePosition() -- Call the save function with mainCountdownFrame
                    elseif arg1 == "RightButton" then
                        SendChatMessage("Battleground Duration: " .. SecondsToTime(durationInSeconds), "SAY")
                    end
                end)
        
                -- Create a new frame for this countdown
                local countdownFrame = CreateFrame("Frame", nil, mainCountdownFrame)
                countdownFrame:SetWidth(150) -- Adjust width to match the text
                countdownFrame:SetHeight(20)
        
                -- Determine vertical position based on the number of active countdown frames
                local frameHeight = 15 -- Adjust this if the frame height changes
                local spacing = 1 -- Adjust spacing between frames if needed
                local yOffset = -table.getn(activeCountdownFrames) * (frameHeight + spacing)
        
                countdownFrame:SetPoint("TOP", mainCountdownFrame, "BOTTOM", 0, yOffset) -- Position relative to main frame
        
                -- Store the warmaster name in the frame
                countdownFrame.warmasterName = warmasterName
        
                -- Create or update the background textures
                if not countdownFrame.backgroundTexture then
                    -- Create gray background texture
                    countdownFrame.backgroundTexture = countdownFrame:CreateTexture(nil, "BACKGROUND")
                    countdownFrame.backgroundTexture:SetTexture(.6, .2, .2, 1) -- Set background color (gray with 50% transparency)
                    countdownFrame.backgroundTexture:SetPoint("LEFT", countdownFrame, "LEFT", 0, 0)
                    countdownFrame.backgroundTexture:SetHeight(10)
                    countdownFrame.backgroundTexture:SetWidth(150) -- Set the width to match the frame width
                end
        
                if not countdownFrame.texture then
                    -- Create progress bar texture
                    countdownFrame.texture = countdownFrame:CreateTexture(nil, "BACKGROUND")
                    countdownFrame.texture:SetPoint("LEFT", countdownFrame, "LEFT", 0, 0)
                    countdownFrame.texture:SetHeight(10)
                end
                if not countdownFrame.iconTexture then
                    countdownFrame.iconTexture = countdownFrame:CreateTexture(nil, "ARTWORK")
                    countdownFrame.iconTexture:SetTexture("Interface\\Icons\\Ability_Whirlwind")
                    countdownFrame.iconTexture:SetWidth(10)
                    countdownFrame.iconTexture:SetHeight(10)
                    countdownFrame.iconTexture:SetPoint("RIGHT", countdownFrame, "LEFT", -5, 0)
                end
        
                -- Update the text
                countdownFrame.text = countdownFrame.text or
                    countdownFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                countdownFrame.text:SetPoint("CENTER", 0, 0)
        
                -- Set text color to white
                countdownFrame.text:SetTextColor(1, 1, 1) -- Set RGB values to 1, 1, 1 for white
        
                -- Define the update function
                countdownFrame:SetScript("OnUpdate", function()
                    local remainingTime = countdownTimers[warmasterName] and countdownTimers[warmasterName] - GetTime() or 0
                    local remainingSeconds = math.floor(remainingTime)
                    if remainingSeconds > 0 then
                        local progress = (countdownDuration - remainingTime) / countdownDuration
                        if remainingSeconds > 10 then
                            countdownFrame.texture:SetTexture(1, 0, 0, 0.5) -- Set red color with 50% transparency
                            countdownFrame.texture:SetWidth(150) -- Set full width when red
                            countdownFrame.text:SetText(warmasterName .. " Whirlwind!")
                            countdownFrame.iconTexture:Show()
                        else
                            countdownFrame.texture:SetTexture(0, 1, 0, 0.5) -- Set green color with 50% transparency
                            countdownFrame.texture:SetWidth(150 * progress) -- Adjust width based on progress
                            countdownFrame.text:SetText(warmasterName .. " : " .. remainingSeconds .. " s.")
                            countdownFrame:EnableMouse(true)
                            countdownFrame:SetScript("OnMouseUp", function()
                                if arg1 == "RightButton" then
                                    SendChatMessage(warmasterName .. " whirlwinds in:" .. remainingSeconds .. " seconds", "SAY")
                                end
                            end)
                            countdownFrame.iconTexture:Hide()
                        end
                        lastPrintedSecond = remainingSeconds
                    elseif remainingSeconds <= 0 then
                        countdownFrame.text:SetText(warmasterName .. " starts to whirlwind now.")
                        countdownTimers[warmasterName] = nil
                        countdownFrame:SetScript("OnUpdate", nil) -- Stop the update script
                        countdownFrame:Hide() -- Hide the frame when countdown is over
        
                        -- Remove the frame from the active frames table
                        for i, frame in ipairs(activeCountdownFrames) do
                            if frame == countdownFrame then
                                table.remove(activeCountdownFrames, i)
                                break
                            end
                        end
        
                        -- Adjust the position of remaining frames
                        for i, frame in ipairs(activeCountdownFrames) do
                            frame:SetPoint("TOP", mainCountdownFrame, "BOTTOM", 0, (i - 1) * -(frameHeight + spacing))
                        end
        
                        -- Check if there are no more active countdown frames
                        if table.getn(activeCountdownFrames) == 0 then
                            -- If no active countdown frames and hiddenTime is not set, hide the main countdown frame
                            if not mainCountdownFrame.hiddenTime then
                                HideMainCountdownFrame()
                                mainCountdownFrame.hiddenTime = GetTime() -- Update the hiddenTime
                            else
                                -- If hiddenTime is set, check if it's been 2 seconds since it was set
                                local currentTime = GetTime()
                                if currentTime - mainCountdownFrame.hiddenTime >= 2 then
                                    HideMainCountdownFrame()
                                    mainCountdownFrame.hiddenTime = nil
                                end
                            end
                        end
        
                    end
                end)
        
                -- Show the frame
                countdownFrame:Show()
                mainCountdownFrame:Show()
                -- Add the frame to the active frames table
                table.insert(activeCountdownFrames, countdownFrame)
            end
        end
        
        -- Save the position of the countdown frame
        function SaveMainCountdownFramePosition()
            local point, _, relativePoint, xOfs, yOfs = mainCountdownFrame:GetPoint()
            HelpingHand_SavedVariables.Settings.mainCountdownFramePosition = { point, relativePoint, xOfs, yOfs }
        end
    end
end    
