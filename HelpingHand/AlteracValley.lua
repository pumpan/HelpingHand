function EnableAlteracValleyFeatures(enable)
        DEFAULT_CHAT_FRAME:AddMessage("av features")
end
function EnableAVBossesFeatures(enable)
        if enable then
        DEFAULT_CHAT_FRAME:AddMessage("AvBosses|cff00FF00 loaded.")

        -- Boss Health Notification
        local bossHealthFrame = CreateFrame("Frame", nil, UIParent)
        local bossHealthNotified = {
            ["Vanndar Stormpike"] = {["50"] = false, ["30"] = false, ["20"] = false, ["10"] = false},
            ["Drek'Thar"] = {["50"] = false, ["30"] = false, ["20"] = false, ["10"] = false}
            --    ["Plate Ogre"] = {["50"] = false, ["30"] = false, ["20"] = false, ["10"] = false} -- Added for debugging
        }

        local function ResetNotifications(bossName)
            bossHealthNotified[bossName] = {["50"] = false, ["30"] = false, ["20"] = false, ["10"] = false}
        end

        local function CheckBossHealth(bossName)
            local health, maxHealth, healthPerc
            if UnitName("target") == bossName or UnitName("targettarget") == bossName then
                    if UnitName("target") == bossName then
                            health = UnitHealth("target")
                            maxHealth = UnitHealthMax("target")
                            healthPerc = (health / maxHealth) * 100
                    elseif UnitName("targettarget") == bossName then
                            health = UnitHealth("targettarget")
                            maxHealth = UnitHealthMax("targettarget")
                            healthPerc = (health / maxHealth) * 100
                    end

                if healthPerc == 100 then
                    ResetNotifications(bossName)
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
        end

        bossHealthFrame:SetScript("OnEvent", function()
            CheckBossHealth("Vanndar Stormpike")
            CheckBossHealth("Drek'Thar")
            --CheckBossHealth("Plate Ogre") -- Added for debugging

        end)

        bossHealthFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        bossHealthFrame:RegisterEvent("UNIT_HEALTH")
    end
end
function EnableBGTimerFeatures(enable)
        if enable then
        DEFAULT_CHAT_FRAME:AddMessage("BG Timers|cff00FF00 loaded.")
        local battlegrounds = {
            AV = {
                name = "AV",
                bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.AVbestTime or 0,
                bestTimeEverShow = (HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.AVbestTimeShow and { minutes = HelpingHand_SavedVariables.Settings.AVbestTimeShow.minutes, seconds = HelpingHand_SavedVariables.Settings.AVbestTimeShow.seconds }) or { minutes = 0, seconds = 0 },
                bestTimeThisSession = 0,
                bestTimeThisSessionShow = { minutes = 0, seconds = 0 }
            },
            WSG = {
                name = "WSG",
                bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WSGbestTime or 0,
                bestTimeEverShow = (HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.WSGbestTimeShow and { minutes = HelpingHand_SavedVariables.Settings.WSGbestTimeShow.minutes, seconds = HelpingHand_SavedVariables.Settings.WSGbestTimeShow.seconds }) or { minutes = 0, seconds = 0 },
                bestTimeThisSession = 0,
                bestTimeThisSessionShow = { minutes = 0, seconds = 0 }
            },
            AB = {
                name = "AB",
                bestTimeEver = HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.ABbestTime or 0,
                bestTimeEverShow = (HelpingHand_SavedVariables.Settings and HelpingHand_SavedVariables.Settings.ABbestTimeShow and { minutes = HelpingHand_SavedVariables.Settings.ABbestTimeShow.minutes, seconds = HelpingHand_SavedVariables.Settings.ABbestTimeShow.seconds }) or { minutes = 0, seconds = 0 },
                bestTimeThisSession = 0,
                bestTimeThisSessionShow = { minutes = 0, seconds = 0 }
            }
        }
        if HelpingHand_SavedVariables then
            DEFAULT_CHAT_FRAME:AddMessage("Saved variables loaded successfully!")

        else
            DEFAULT_CHAT_FRAME:AddMessage("Saved variables not found or loaded.", 1.0, 0.0, 0.0)
        end

    local avTimeFrame = CreateFrame("Frame", nil, UIParent)
    local startTime, endTime
    local isInAlteracValley = false
    local battleground
    local delayTimer = 0
    local delayDuration = 2 


    avTimeFrame:SetScript("OnEvent", function()
      local _, instanceType = IsInInstance()

      if event == "CHAT_MSG_BG_SYSTEM_NEUTRAL" or event == "CHAT_MSG_TEXT_EMOTE" and arg1 then
        if string.find(arg1, "The battle for Alterac Valley has begun!") 
        or string.find(arg1, "Let the battle for Warsong Gulch begin!")
        -- or string.find(arg1, "You laugh.")  to debug
        --or string.find(arg1, "You nod.") to debug
        or string.find(arg1, "The Battle for Arathi Basin has begun!") then

          if string.find(arg1, "The battle for Alterac Valley has begun!") then -- or string.find(arg1, "You laugh.") <-- Put this in to debug
            battleground = battlegrounds.AV
          elseif string.find(arg1, "Let the battle for Warsong Gulch begin!") then --  or string.find(arg1, "You nod.") <-- Put this in to debugg
            battleground = battlegrounds.WSG
          elseif string.find(arg1, "The Battle for Arathi Basin has begun!") then
            battleground = battlegrounds.AB
          end

          if battleground then
            if battleground.bestTimeEverShow and battleground.bestTimeEverShow.minutes then
              DEFAULT_CHAT_FRAME:AddMessage("Best time " .. battleground.name .. ": " .. battleground.bestTimeEverShow.minutes .. " minutes " .. string.format("%02d", battleground.bestTimeEverShow.seconds) .. " seconds ", 1.0, 1.0, 0.0)
            end
            if battleground.bestTimeThisSessionShow and battleground.bestTimeThisSessionShow.minutes then
              DEFAULT_CHAT_FRAME:AddMessage("Best time " .. battleground.name .. " today: " .. battleground.bestTimeThisSessionShow.minutes .. " minutes " .. string.format("%02d", battleground.bestTimeThisSessionShow.seconds) .. " seconds ", 1.0, 1.0, 0.0)
            end
          end

          print("Timer started!")
          startTime = GetTime()

    elseif (string.find(string.lower(arg1), "victory") and not string.find(string.lower(arg1), "near victory")) or 
        string.find(string.lower(arg1), "defeat") or 
        -- string.find(arg1, "You wave.") or <-- to debug
        string.find(string.lower(arg1), "wins") then

          if startTime then
            endTime = GetTime()
            local durationInSeconds = endTime - startTime
            local durationInMinutes = math.floor(durationInSeconds / 60)
            local seconds = durationInSeconds - durationInMinutes * 60
            if seconds < 0 then
              seconds = seconds * -1 -- Make seconds positive
            end
            -- Handle battleground best times here


      if battleground then
        if battleground.bestTimeEver == 0 or durationInSeconds < battleground.bestTimeEver or (durationInSeconds < battleground.bestTimeEver and battleground.bestTimeThisSession == nil) then 
          battleground.bestTimeThisSession = durationInSeconds
          battleground.bestTimeThisSessionShow = { minutes = durationInMinutes, seconds = seconds }

          battleground.bestTimeEver = durationInSeconds
          battleground.bestTimeEverShow = { minutes = durationInMinutes, seconds = seconds }

          HelpingHand_SavedVariables.Settings[battleground.name .. "bestTime"] = durationInSeconds
          HelpingHand_SavedVariables.Settings[battleground.name .. "bestTimeShow"] = { minutes = durationInMinutes, seconds = seconds }

          local message = "New RECORD for " .. battleground.name .. " : " .. durationInMinutes .. " minutes " .. string.format("%02d", seconds) .. " seconds"
          DelayedMessage(message, delayDuration)

        elseif battleground.bestTimeThisSession == 0 or durationInSeconds < battleground.bestTimeThisSession then
          battleground.bestTimeThisSession = durationInSeconds
          battleground.bestTimeThisSessionShow = { minutes = durationInMinutes, seconds = seconds }

          local message = "Best time " .. battleground.name .. " this session: " .. durationInMinutes .. " minutes " .. string.format("%02d", seconds) .. " seconds"
          DelayedMessage(message, delayDuration)
        else
          local message = "Time: " .. battleground.name .. " : " .. durationInMinutes .. " minutes " .. string.format("%02d", seconds) .. " seconds"
          DelayedMessage(message, delayDuration)                       
        end
      else
        DEFAULT_CHAT_FRAME:AddMessage("You Joined late, no time recorded", 1.0, 1.0, 0.0)
      end
        end
      end
  end  
end)

function DelayedMessage(message, delay)
    local delayFrame = CreateFrame("Frame")
    local delayTimer = GetTime() + delay
    delayFrame:SetScript("OnUpdate", function(self, elapsed)
        if GetTime() >= delayTimer then
            UIErrorsFrame:AddMessage(message, 1.0, 1.0, 0.0)
            SendChatMessage(message, "SAY")
      startTime = nil 
           delayFrame:SetScript("OnUpdate", nil) 
        end
    end)
end

function ResetBattlegroundTimers()
    if HelpingHand_SavedVariables then
        for _, battleground in pairs(battlegrounds) do
            battleground.bestTimeThisSession = 0
            battleground.bestTimeThisSessionShow = { minutes = 0, seconds = 0 }
        end
        -- Update saved variables
        HelpingHand_SavedVariables.Settings.AVbestTime = 0
        HelpingHand_SavedVariables.Settings.AVbestTimeShow = { minutes = 0, seconds = 0 }
        HelpingHand_SavedVariables.Settings.WSGbestTime = 0
        HelpingHand_SavedVariables.Settings.WSGbestTimeShow = { minutes = 0, seconds = 0 }
        HelpingHand_SavedVariables.Settings.ABbestTime = 0
        HelpingHand_SavedVariables.Settings.ABbestTimeShow = { minutes = 0, seconds = 0 }
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
            DEFAULT_CHAT_FRAME:AddMessage("Best time AV: " .. string.format("%02d:%02d", battlegrounds.AV.bestTimeEverShow.minutes, battlegrounds.AV.bestTimeEverShow.seconds), 1.0, 1.0, 0.0)
            DEFAULT_CHAT_FRAME:AddMessage("Best time AV today: " .. string.format("%02d:%02d", battlegrounds.AV.bestTimeThisSessionShow.minutes, battlegrounds.AV.bestTimeThisSessionShow.seconds), 1.0, 1.0, 0.0)
            DEFAULT_CHAT_FRAME:AddMessage("Best time WSG: " .. string.format("%02d:%02d", battlegrounds.WSG.bestTimeEverShow.minutes, battlegrounds.WSG.bestTimeEverShow.seconds), 1.0, 1.0, 0.0)
            DEFAULT_CHAT_FRAME:AddMessage("Best time WSG today: " .. string.format("%02d:%02d", battlegrounds.WSG.bestTimeThisSessionShow.minutes, battlegrounds.WSG.bestTimeThisSessionShow.seconds), 1.0, 1.0, 0.0)
            DEFAULT_CHAT_FRAME:AddMessage("Best time AB: " .. string.format("%02d:%02d", battlegrounds.AB.bestTimeEverShow.minutes, battlegrounds.AB.bestTimeEverShow.seconds), 1.0, 1.0, 0.0)
            DEFAULT_CHAT_FRAME:AddMessage("Best time AB today: " .. string.format("%02d:%02d", battlegrounds.AB.bestTimeThisSessionShow.minutes, battlegrounds.AB.bestTimeThisSessionShow.seconds), 1.0, 1.0, 0.0)
        else
            DEFAULT_CHAT_FRAME:AddMessage("Battlegrounds data not available.", 1.0, 0.0, 0.0)
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid command. Usage: /bt reset to reset records, /bt show to display current records.", 1.0, 0.0, 0.0)
    end
end




        avTimeFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        avTimeFrame:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
        avTimeFrame:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
    end	
end
